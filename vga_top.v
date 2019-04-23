`timescale 1ns / 1ps
/*
		description:	
					the top module of vga function.
		notes:
				includes:
					---vga_dparam	: 	used for generating vga data.
					---vga_ctrl		:	used for generating vga sync signal.
	
		author:		Chris Wang

*/

module vga_top(
		input	clk ,
		input	rst ,       //active  high
		input	feed_addr ,
		input	feed_data ,
		input	[11 : 0]	din ,
		output	[3 : 0]		R ,
		output	[3 : 0]		G ,
		output	[3 : 0]		B ,
		output				h_synch ,
		output				v_synch	
		//output              led
    ) ;
    wire    pixel_clk ;
    clk_wiz_0  clk_wiz_0_inst(
	  // Clock out ports
	  .clk_out1	(	pixel_clk	) ,
	 // Clock in ports
	  .clk_in1	(	clk 		)
	 ) ;

	vga_out(
	.pixel_clk  (	pixel_clk	) ,
	.rst 		(	rst			) ,
	.feed_addr  (	1'b0		) ,	//active high
	.feed_data	(	1'b0		) , //active high
	.din		(	12'b0		) ,
	.R(R) ,
	.G(G) ,
	.B(B) ,
	.h_synch	(	h_synch		) ,
	.v_synch	(	v_synch		) ,
	.line_cnt() ,
	.pixel_cnt()
	) ;
	assign led = 1 ;
endmodule
