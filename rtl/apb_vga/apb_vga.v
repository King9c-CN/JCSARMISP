module APB_VGA_CONTROL(
  input  wire        PCLK,     // Clock
  input  wire        PCLKG,     // Clock
  input  wire        PRESETn,  // Reset

  input  wire        PSEL,     // Device select
  input  wire [11:2] PADDR,    // Address
  input  wire        PENABLE,  // Transfer control
  input  wire        PWRITE,   // Write control
  input  wire [31:0] PWDATA,   // Write data

  input  wire [3:0]  ECOREVNUM,// Engineering-change-order revision bits

  output wire [31:0] PRDATA,   // Read data
  output wire        PREADY,   // Device ready
  output wire        PSLVERR,  // Device error response
 
  output reg      vga_en 
);

assign PREADY = 1'b1;
assign PRDATA = 1'b0;

wire write_en;
assign write_en = PSEL & PWRITE;

reg addr_reg;
always@(posedge PCLK or negedge PRESETn) begin
  if(~PRESETn) addr_reg <= 1'b0;
  else if(write_en) addr_reg <= PADDR[2];//0 
end

reg wr_en_reg;
always@(posedge PCLK or negedge PRESETn) begin
  if(~PRESETn) wr_en_reg <= 1'b0;
  else if(write_en) wr_en_reg <= 1'b1;
  else wr_en_reg <= 1'b0;
end

always@(posedge PCLK) begin
    if(~PRESETn) begin
        vga_en <= 1'd0;
    end else if(wr_en_reg && PREADY && write_en) begin
        if(~addr_reg)
            vga_en <= PWDATA[0];
    end
end



endmodule


