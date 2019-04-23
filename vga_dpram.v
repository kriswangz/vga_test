/*
		description:	
					creat combination of bram.
		notes:		7020 clg484 do not have so that large brams, so we should 
		            combine 2 brams (256K + 64K brams) into a suitable bram.
	
		author:		Chris Wang

*/
module vga_dparm(
	input 	wclk ,
	input	[11:0]	din ,
	input	[31:0]	waddr ,
	input	wr ,	//active high
	input 	rclk ,
	input	[31:0] 	raddr ,
	output	[11:0]	dout
	);

	wire 	[11:0]	dout_256k ;
	wire 	[11:0]	dout_64k ;
	
	reg		addr18;
	always @ (posedge rclk)		addr18  <=	raddr[18];
	assign dout = ( addr18	== 0 )	?	dout_256k : dout_64k; 

	bram_creat_256k	#(
			.addr_width(18) ,
			.data_width(12)
		)	ram_256k_12(
			.rclk	(	rclk	) ,
			.raddr	(	raddr[17:0]		) ,
			.dout   (	dout    ) ,
			.wclk	(	wclk	) ,
			.we 	(	wr & ~ waddr[18]	) ,	//(wr=1, waddr[18]=0) == (we=1)
			.waddr	(	waddr[17:0]		),
			.din 	(	din 	)
		);

	bram_creat_64k	#(
			.addr_width(16) ,
			.data_width(12)
		)	ram_64k_12(
			.rclk	(	rclk	) ,
			.raddr	(	raddr[15:0]		) ,
			.dout   (	dout    ) ,
			.wclk	(	wclk	) ,
			.we 	(	wr &  waddr[18]	) ,
			.waddr	(	waddr[15:0]		),
			.din 	(	din 	)
		);
endmodule

/*
		description:	
					creat bram.
		notes:
					read operation : data will be added into data output port after raddr. 
	
		author:		Chris Wang

*/

module bram_creat_256k(
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

	reg 	[data_width - 1 : 0 ] 	mem [ (1 << addr_width)-1 : 0 ]	/*  synthesis syn_ramstyle = "block_ram" */; 

	reg		[addr_width - 1 : 0 ]	ra ;
	/*attention please. read data should be 1 clock later after write (#1 means 1 clock delay)*/
	always @ (posedge rclk)		ra <=	#1 raddr ; // like latch in bram
	assign dout = mem[ ra ] ;

	/*write operation*/
	always @ (posedge wclk) begin
		if(we == 1)
			mem[waddr] <= #1 din ;
	end

	// data can be initialed , they are from file "xxxxx", put into mem,
	// file should be the same folder with this file.
	//initial $readmemh ("bmp_256k",mem) ;
endmodule

module bram_creat_64k(
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

	reg 	[data_width - 1 : 0 ] 	mem [ (1 << addr_width)-1 : 0 ] /* synthesis syn_ramstyle = "block_ram"*/;
	reg		[addr_width - 1 : 0 ]	ra ;
	/*attention please. read data should be 1 clock later after write (#1 means 1 clock delay)*/
	always @ (posedge rclk)		ra <=	#1 raddr ;
	assign dout = mem[ ra ] ;

	/*write operation*/
	always @ (posedge wclk) begin
		if(we == 1)
			mem[waddr] <= #1 din ;
	end

	// data can be initialed , they are from file "xxxxxx", put into mem,
	// file should be the same folder with this file.
	//initial $readmemh ("bmp_64k",mem) ;
endmodule