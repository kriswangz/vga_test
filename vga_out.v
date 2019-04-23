/*
		File name:	vga_out.v
		description:	
					the top module of vga function.
		notes:
				includes:
					---vga_dparam	: 	used for generating vga data.
					---vga_ctrl		:	used for generating vga sync signal.

				it can only provide the 12bits RGB signal, each color has 4bits sides.
				R,G,B,h_synch and v_synch is the real-port(output) signal. line_cnt and 
				pixel_cnt is the virtual signal in FPGA, it can provide sync sigal for 
				other modules  to change the color data.
					Like this: assign R = (line_cnt == xxxx)	? 	4'd7 : 0 ;
				Also, it can be used for saving data into brams.
	
		author:		Chris Wang

*/

module vga_out (
	input	pixel_clk ,
	input	rst ,
	input	feed_addr ,		//for continuous writing address, active high
	input	feed_data ,		//active high
	input	[11 : 0]	din ,
	output	[3 : 0]		R ,
	output	[3 : 0]		G ,
	output	[3 : 0]		B ,
	output				h_synch ,
	output				v_synch	,
	output	[9 : 0] 	line_cnt ,
	output	[10 : 0]	pixel_cnt
	) ;

// AXI4 databus cannot provide enough address for this module (64K typical),
// so we need use a "DMA" operation : use 2 registers to +1 by itself.
	reg 	[11 : 0]	buffer_addr ;	
	always @(posedge pixel_clk or posedge rst) begin
		if (rst) begin
			// reset
			buffer_addr		<=		0 ;
		end
		else if (feed_addr	==	1) begin
			buffer_addr 	<=		din ;
		end
		else if (feed_data	==	1)begin
			buffer_addr		<=		buffer_addr	+ 1 ;
		end
	end

	reg	[31:0]	pixel_addr;
always @ (*)
	`ifdef   	vga_640_480
		pixel_addr	<=	line_cnt*640 + pixel_cnt ;
	`endif
	`ifdef   	vga_1024_768
		pixel_addr	<=	line_cnt*1024 + pixel_cnt ;
	`endif
	`ifdef   	vga_1368_768
		pixel_addr	<=	line_cnt*1368 + pixel_cnt ;
	`endif

	wire 	[11:0]		buffer_out ;
	 vga_dparm vga_dparm_inst(
	 	.wclk	(	pixel_clk	) ,
		.din 	(	din			) ,
		.waddr 	(	buffer_addr	) ,
		.wr     (	1'b0		) ,	//active high
	 	.rclk 	(	pixel_clk	) ,
		.raddr  (	pixel_addr[18:0]	) ,
		.dout	(	buffer_out			)
	);

	 wire 	dp_en ;
	 vga_ctrl vga_ctrl_inst(
	 	.pixel_clk	(	pixel_clk	) ,
	 	.rst 		( 	rst 		) ,
	 	.h_synch	(	h_synch		) , 
	 	.v_synch	(	v_synch		) ,
	 	.dp_en		(	dp_en		) ,
	 	.line_cnt	(	line_cnt	) , 
	 	.pixel_cnt	(	pixel_cnt	)
	);	 

	 assign R = (dp_en == 1)	?	buffer_out[11:8] :  0 ;
	 assign G = (dp_en == 1)	?	buffer_out[7:4]  :  0 ;
	 assign B = (dp_en == 1)	?	buffer_out[3:0]  :  0 ;
endmodule 
