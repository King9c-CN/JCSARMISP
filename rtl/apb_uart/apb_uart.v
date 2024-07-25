module APB_UART(
	input  wire        PCLK,     // Clock
    input  wire        PRESETn,  // Reset

    input  wire        PSEL,     // Device select
    input  wire [11:2] PADDR,    // Address
    input  wire        PENABLE,  // Transfer control
    input  wire        PWRITE,   // Write control
    input  wire [31:0] PWDATA,   // Write data

    input  wire [3:0]  ECOREVNUM,// Engineering-change-order revision bits

    output reg [31:0]  PRDATA,   // Read data
    output wire        PREADY,   // Device ready
    output wire        PSLVERR,  // Device error response
    
    input  wire [7:0]  UART_RX,
    input  wire        state,
    output wire        tx_en,
    output wire [7:0]  UART_TX
);
reg PREADY_reg = 1'b0;

wire read_en;
assign read_en=PSEL&(~PWRITE);

wire write_en;
assign write_en=PSEL&(PWRITE);

reg [3:0] addr_reg;
always@(posedge PCLK or negedge PRESETn) begin
  if(~PRESETn) addr_reg <= 4'h0;
  else if(read_en || write_en) addr_reg <= PADDR[5:2];
end

reg rd_en_reg;
always@(posedge PCLK or negedge PRESETn) begin
  if(~PRESETn) rd_en_reg <= 1'b0;
  else if(read_en) rd_en_reg <= 1'b1;
  else rd_en_reg <= 1'b0;
end

reg wr_en_reg;
always@(posedge PCLK or negedge PRESETn) begin
  if(~PRESETn) wr_en_reg <= 1'b0;
  else if(write_en)  wr_en_reg <= 1'b1; 
  else  wr_en_reg <= 1'b0;
end

always@(*) begin
  if(rd_en_reg) begin
    if(addr_reg == 4'h0) begin PRDATA <= {24'b0,UART_RX}; PREADY_reg <= 1'b1; end
    else if(addr_reg == 4'h1) begin PRDATA <= {31'b0,state}; PREADY_reg <= 1'b1; end
    else PRDATA <= 32'b0;
  end else
    PRDATA <= 32'b0;
end

assign tx_en = wr_en_reg ? 1'b1 : 1'b0;
assign UART_TX = wr_en_reg ? PWDATA[7:0] : 8'b0;

assign PREADY = read_en ? PREADY_reg : 1'b1;
endmodule


