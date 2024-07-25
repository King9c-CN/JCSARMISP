module APB_SDCARD_CONTROL(
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
 
  output reg  [7:0]  sdcard_rd_en,
  output reg  [31:0] sdcard_rd_addr, 
  output reg         sdcard_rd_reset 
);

assign PREADY = 1'b1;
assign PRDATA = 1'b0;

wire write_en;
assign write_en = PSEL & PWRITE;

reg [1:0]addr_reg;
always@(posedge PCLK or negedge PRESETn) begin
  if(~PRESETn) addr_reg <= 2'b00;
  else if(write_en) addr_reg <= PADDR[3:2];//0 EN 1 ADDR
end

reg wr_en_reg;
always@(posedge PCLK or negedge PRESETn) begin
  if(~PRESETn) wr_en_reg <= 1'b0;
  else if(write_en) wr_en_reg <= 1'b1;
  else wr_en_reg <= 1'b0;
end

always@(posedge PCLK) begin
    if(~PRESETn) begin
        sdcard_rd_en   <= 8'd0;
        sdcard_rd_addr <= 32'd0;
    end else if(wr_en_reg && PREADY && write_en) begin
        if (addr_reg==2'b0)
            sdcard_rd_en <= PWDATA[7:0];
        else if(addr_reg==2'b01)    
            sdcard_rd_addr <= PWDATA;
    end 
end

always@(posedge PCLK) begin
    if(~PRESETn) begin
        sdcard_rd_reset<=1'b0;
    end  else if(wr_en_reg && PREADY ) begin
        if (addr_reg==2'b10)
           sdcard_rd_reset<=PWDATA[0];        
    end
end

endmodule


