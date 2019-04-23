/*
		description:	
					used for vga sync signal ctrl.
					1024*768 @ 60Hz
	
		author:		Chris Wang

*/
	`define		vga_640_480
	//`define vga_1024_768
	//`define		vga_1368_768
/****************************************************/	
	 `ifdef   	vga_640_480
	//define the characters of 640*480	@	60Hz with 65MHz pxiel clock
	//actually we need : 1344*806	@	60Hz
	`define H_ACTIVE 640
	`define H_FRONT_PROCH 16
	`define H_SYNCH 96
	`define H_BACK_PROCH 48
	`define H_TOTAL (`H_SYNCH + `H_BACK_PROCH + `H_ACTIVE + `H_FRONT_PROCH)

	`define V_ACTIVE 480
	`define V_FRONT_PROCH 11
	`define V_SYNCH 5
	`define V_BACK_PROCH 31
	`define V_TOTAL (`V_SYNCH + `V_BACK_PROCH + `V_ACTIVE + `V_FRONT_PROCH)
	  `endif

	  `ifdef   vga_1024_768
	//define the characters of 1024*768	@	60Hz with 65MHz pxiel clock
	//actually we need : 1344*806	@	60Hz
	`define H_ACTIVE 1024
	`define H_FRONT_PROCH 24
	`define H_SYNCH 136
	`define H_BACK_PROCH 160
	`define H_TOTAL (`H_SYNCH + `H_BACK_PROCH + `H_ACTIVE + `H_FRONT_PROCH)

	`define V_ACTIVE 768
	`define V_FRONT_PROCH 3
	`define V_SYNCH 6
	`define V_BACK_PROCH 29
	`define V_TOTAL (`V_SYNCH + `V_BACK_PROCH + `V_ACTIVE + `V_FRONT_PROCH)
	  `endif

	  `ifdef   vga_1368_768
	//define the characters of 1368*768	@	60Hz with 65MHz pxiel clock
	//actually we need : 1344*806	@	60Hz
	`define H_ACTIVE 1368
	`define H_FRONT_PROCH 72
	`define H_SYNCH 144
	`define H_BACK_PROCH 216
	`define H_TOTAL (`H_SYNCH + `H_BACK_PROCH + `H_ACTIVE + `H_FRONT_PROCH)

	`define V_ACTIVE 768
	`define V_FRONT_PROCH 1
	`define V_SYNCH 3
	`define V_BACK_PROCH 23
	`define V_TOTAL (`V_SYNCH + `V_BACK_PROCH + `V_ACTIVE + `V_FRONT_PROCH)
	  `endif
/****************************************************/	
module vga_ctrl(
	input pixel_clk ,
	input rst ,
	output reg h_synch, v_synch ,
	output reg dp_en ,
	output reg [9:0] line_cnt ,
	output reg [10:0] pixel_cnt
	);

/*
	notes: use 2 counters, one of them is used for  recording the H clocks,
			the other is used for recording the number of H.	 
*/
always @(posedge pixel_clk or posedge rst) begin
	if (rst) begin
		// reset
		pixel_cnt	<=	0 ;
	end
	else if (pixel_cnt	==	(`H_TOTAL - 1)) begin
		pixel_cnt	<=  0 ;
	end
	else 	pixel_cnt <= pixel_cnt + 1 ;
end

always @(posedge pixel_clk or posedge rst) begin
	if (rst) begin
		// reset
		line_cnt	<=	0 ;
	end
	else if (pixel_cnt	==	(`H_TOTAL-1)) begin
		if( line_cnt	==	(`V_TOTAL-1))
			line_cnt 	<= 0 ;
		else line_cnt	<=  line_cnt + 1 ;
	end
end
//	high_level synthesis, >= or <= is not advised typically 
always @(posedge pixel_clk or posedge rst) begin
	if (rst) begin
		// reset
		dp_en <= 0 ; 
	end
	else if (pixel_cnt <= (`H_ACTIVE-1)	
			&
			(line_cnt <= (`V_ACTIVE - 1))	) begin
			dp_en <= 1 ;
	end
	else 	dp_en <= 0 ; 
end
//generate h_synch
always @(posedge pixel_clk or posedge rst) begin
	if (rst) begin
		// reset
		h_synch <= 1 ;
	end
	else if (pixel_cnt	==	(`H_ACTIVE + `H_FRONT_PROCH -1)) begin
		h_synch <= 0 ;
	end
		else if (pixel_cnt	==	(`H_ACTIVE + `H_FRONT_PROCH +`H_SYNCH-1)) begin
		h_synch <= 1 ;
	end
end
//generate v_synch
always @(posedge pixel_clk or posedge rst) begin
	if (rst) begin
		// reset
		v_synch <= 1 ;
	end
	else if (pixel_cnt	==	(`H_TOTAL -1)) begin
		 if (line_cnt	==	(`V_ACTIVE + `V_FRONT_PROCH-1)) begin
			v_synch <= 0 ;
		end
		 else if (line_cnt	==	(`V_ACTIVE + `V_FRONT_PROCH +`V_SYNCH-1)) begin
			v_synch <= 1 ;
		end
	end
end

endmodule
