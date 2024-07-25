module conv_mask6 (
    input clk,
    input rst_n,
    input clken,
    input [7:0] pix_6_weight0,
    input [7:0] pix_2_weight0,
    input [7:0] pix_2_weight1,
    input [7:0] pix_2_weight2,
    input [7:0] pix_2_weight3,
    input [7:0] pix_1_and_half_weight0,
    input [7:0] pix_1_and_half_weight1,
    input [7:0] pix_1_and_half_weight2,
    input [7:0] pix_1_and_half_weight3,

    output wire [7:0] out,
    output wire         out_en
);

reg [11:0] process1_value [4:0];
reg [11:0] process2_value [1:0];
reg [11:0] result_value;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        process1_value[0] <= 12'd0;
        process1_value[1] <= 12'd0;
        process1_value[2] <= 12'd0;
        process1_value[3] <= 12'd0;
        process1_value[4] <= 12'd0;
    end
    else begin
        process1_value[0] <= {pix_6_weight0,2'b00} + {pix_6_weight0,1'b0};
        process1_value[1] <= {(pix_2_weight0 + pix_2_weight1), 1'b0};
        process1_value[2] <= {(pix_2_weight2 + pix_2_weight3), 1'b0};
        process1_value[3] <= {(pix_1_and_half_weight0 + pix_1_and_half_weight1),1'b0} + (pix_1_and_half_weight0 + pix_1_and_half_weight1);
        process1_value[4] <= {(pix_1_and_half_weight2 + pix_1_and_half_weight3), 1'b0} + (pix_1_and_half_weight2 + pix_1_and_half_weight3);
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        process2_value[0] <= 12'd0;
        process2_value[1] <= 12'd0;
    end
    else begin
        process2_value[0] <= process1_value[0] + process1_value[1] + process1_value[2];
        process2_value[1] <= (process1_value[3] + process1_value[4]) >> 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
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