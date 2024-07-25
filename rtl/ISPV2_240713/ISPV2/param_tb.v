module tb;

reg HCLK;
reg HRESETn;
reg [31:0] HADDR;
reg [31:0] HWDATA;
reg HREADY;
reg [1:0] HTRANS;
reg HSEL;
reg [2:0] HSIZE;
reg HWRITE;

AHBISPSYS u_AHBISPSYS(
    .HCLK         ( HCLK         ),
    .HRESETn      ( HRESETn      ),
    .HADDR        ( HADDR        ),
    .HWDATA       ( HWDATA       ),
    .HREADY       ( HREADY       ),
    .HWRITE       ( HWRITE       ),
    .HTRANS       ( HTRANS       ),
    .HSEL         ( HSEL         ),
    .HSIZE        ( HSIZE        ),
    .HRDATA       (        ),
    .HREADYOUT    (     ),
    .ISPCLK       (        ),
    .data_in      (       ),
    .fifo_empty   (    ),
    .rgb_data_out (  ),
    .frames_cnt   (    )
);

initial begin
    HCLK = 'b0;
    forever #5
    HCLK = ~HCLK;
end

initial begin
  HRESETn = 'b1;
  HADDR = 32'h0;
  HWDATA = 32'h0;
  HREADY = 'b0;
  HWRITE = 'b0;
  HTRANS = 2'b00;
  HSEL = 'b0;
  HSIZE = 'b000;
  #40
  HRESETn = 'b0;
  #10
  HRESETn = 'b1;
  #100
  HSEL = 'b1;
  HTRANS = 'b10;
  HREADY = 'b1;
  HWRITE = 'b1;
  #10
  HWDATA = 32'h1;
  #10
  HADDR = 32'h4;
  #10
  HWDATA = 32'h23498701;
  #10
  HADDR = 32'h8;
  #10
  HWDATA = 32'hAB9C8F00;
end

endmodule