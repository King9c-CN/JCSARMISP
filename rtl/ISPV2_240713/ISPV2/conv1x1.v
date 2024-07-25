module conv1x1 (
    input wire [15:0]   Din,
    input wire          clk,
    input wire          rst_n,
    input wire          dataEn,

    output wire [15:0]  Dout,
    output wire         DoutEn
);

reg [15:0]  process1_value;
reg [15:0]  process2_value;
reg [15:0]  result_value;


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        process1_value <= 'h0;
    end
    else begin
        process1_value <= Din;
    end
end
    
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      process2_value <= 'h0;
    end
    else begin
      process2_value <= process1_value;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      result_value <= 'h0;
    end
    else begin
      result_value <= process2_value;
    end
end

reg [2:0] shift_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_reg <= 3'b0;
    end
    else begin
        shift_reg <= {shift_reg[1:0], dataEn};
    end
end

assign DoutEn = shift_reg[2];
assign Dout = result_value;

endmodule