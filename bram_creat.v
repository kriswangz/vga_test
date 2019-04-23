/*
		description:	
					creat bram.
		notes:
					read operation : data will be added into data output port after raddr. 
	
		author:		Chris Wang

*/

module bram_creat(
	rclk,
	raddr,
	dout,
	wclk,
	we,
	waddr,
	din
	);
	parameter 	addr_width = 8 ;
	parameter	data_width = 12 ;

	input	rclk ;	//read clock
	input	wclk ;	//write clock
	input	we ;	// write enable, active High!!
	input	[addr_width - 1 : 0 ]	raddr ;
	input	[addr_width - 1 : 0 ]	waddr ;
	input	[data_width - 1 : 0 ]	din ;
	output	[data_width - 1 : 0 ]	dout ;

	reg 	[data_width - 1 : 0 ] 	mem [ (1 << addr_width)-1 : 0 ] /* synthesis syn_ramstyle = *block_ram**/;
	reg		[addr_width - 1 : 0 ]	ra ;
	/*attention please. read data should be 1 clock later after write (#1 means 1 clock delay)*/
	always @ (posedge rclk)		ra <=	#1 raddr ;
	assign dout = mem[ ra ] ;

	/*write operation*/
	always @ (posedge wclk) begin
		if(we == 1)
			mem[waddr] <= #1 din ;
	end

	// data can be initialed , they are from file "init_mem", put into mem,
	// file should be the same folder with this file.
	initial $readmemh ("init_mem",mem) ;
endmodule
