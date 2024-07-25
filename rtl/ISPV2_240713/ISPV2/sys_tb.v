module sys_tb;
integer i = 0;
integer j;
integer min = 12'h0FF;
integer max = 12'hFFF;

reg HCLK;
reg HRESETn;
reg [31:0] HADDR;
reg [31:0] HWDATA;
reg HREADY;
reg HWRITE;
reg [1:0] HTRANS;
reg HSEL;
reg [2:0] HSIZE;
reg ISPCLK;
reg [12:0] raw_data;
reg data_en;


wire HREADYOUT;
wire [15:0] data_in;
wire [15:0] rgb_data_out;
wire DoutEn;
wire [31:0] HRDATA;

assign data_in = {raw_data,{4{1'b0}}};

initial begin
    HCLK = 1'b1;
    forever#5
    HCLK = ~HCLK;
end

initial begin
    HRESETn = 1'b1;
    HADDR = 'h0;
    HWDATA = 'h0;
    HREADY = 'h0;
    HWRITE = 'h0;
    HTRANS = 'h0;
    HSEL = 'h0;
    #50
    HRESETn = 1'b0;
    #10
    HRESETn = 1'b1;
    #10
    HREADY = 1'b1;
    HSEL = 1'b1;
    HTRANS = 2'b10;
    HSIZE = 2'b01;
    HWRITE = 1'b1;
    #10
    HWDATA = 32'h0000_0004;
    HSEL = 1'b0;
    #20
    HADDR = 'h4;
    HREADY = 1'b1;
    HSEL = 1'b1;
    HTRANS = 2'b10;
    HSIZE = 2'b01;
    HWRITE = 1'b1;
    #10
    HWDATA = 32'h10015010;
    HSEL = 1'b0;
    #20
    HREADY = 1'b1;
    HSEL = 1'b1;
    HTRANS = 2'b10;
    HSIZE = 2'b01;
    HWRITE = 1'b1;
    HADDR = 32'h8;
    #10
    HWDATA = 32'h8899AA00;
    HSEL = 1'b0;
    #20
    HADDR = 32'hC;
    HREADY = 1'b1;
    HSEL = 1'b1;
    HTRANS = 2'b10;
    HSIZE = 2'b01;
    HWRITE = 1'b1;
    #10
    HWDATA = 32'h0000_0002;
    HSEL = 1'b0;
end

initial begin
    data_en = 'b0;
    raw_data = 'h0;
    #100
    while(i<200) begin
    #20
    j=0;
    data_en = 'b1;
    raw_data = min+{$random}%(max-min+1);
    while(j<20) begin
    #10    
    raw_data = min+{$random}%(max-min+1);
    j = j+1;
    end
    #10
    data_en = 'b0;
    i = i+1;
    end
end

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
    .HRDATA       ( HRDATA       ),
    .HREADYOUT    ( HREADYOUT    ),
    .ISPCLK       ( HCLK       ),
    .data_in      ( data_in      ),
    .fifo_empty   ( ~data_en   ),
    .rgb_data_out ( rgb_data_out ),
    .DoutEn       ( DoutEn       ),
    .frames_cnt   (    )
);


endmodule