module conv_mask5 (
    input clk,
    input rst_n,
    input clken,
    input [7:0] pix_5_weight0,
    input [7:0] pix_4_weight0,
    input [7:0] pix_4_weight1,
    input [7:0] pix_1_weight0,
    input [7:0] pix_1_weight1,
    input [7:0] pix_1_weight2,
    input [7:0] pix_1_weight3,
    input [7:0] pix_1_weight4,
    input [7:0] pix_1_weight5,
    input [7:0] pix_half_weight0,
    input [7:0] pix_half_weight1,

    output wire [7:0] out,
    output wire out_en
);

reg [11:0] process1_value [4:0];
reg [11:0] process2_value [1:0];
reg [11:0] result_value;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        process1_value[0] <= 12'd0;
        process1_value[1] <= 12'd0;
        process1_value[2] <= 12'd0;
        process1_value[3] <= 12'd0;
        process1_value[4] <= 12'd0;
    end
    else begin
        process1_value[0] <= {pix_5_weight0, 2'b00} + pix_5_weight0;
        process1_value[1] <= {(pix_4_weight0 + pix_4_weight1), 2'b00} ;
        process1_value[2] <= pix_1_weight0 + pix_1_weight1 + pix_1_weight2;
        process1_value[3] <= pix_1_weight3 + pix_1_weight4 + pix_1_weight5;
        process1_value[4] <= (pix_half_weight0 + pix_half_weight1) >> 1;
    end
end
    
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        process2_value[0] <= 12'd0;
        process2_value[1] <= 12'd0;
    end
    else begin
        process2_value[0] <= process1_value[0] + process1_value[1] + process1_value[4];
        process2_value[1] <= process1_value[2] + process1_value[3];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result_value <= 12'd0;
    end
        else if (process2_value[0] < process2_value[1]) begin
        result_value <= 12'd0;
    end
    else begin
        result_value <= process2_value[0] - process2_value[1];
    end
end

/*reg [2:0] shift_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_reg <= 3'b0;
    end
    else begin
        shift_reg <= {shift_reg[1:0], clken};
    end
end
    
assign out_en = shift_reg[2];*/
assign out =result_value[11]? 8'hFF : result_value[10:3];
endmodule