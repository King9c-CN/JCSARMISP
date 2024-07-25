module conv_mask4 (
    input wire clk,
    input wire rst_n,
    input wire [7:0] pix_4_weight,
    input wire [7:0] pix_2_weight1,
    input wire [7:0] pix_2_weight2,
    input wire [7:0] pix_2_weight3,
    input wire [7:0] pix_2_weight4,
    input wire [7:0] pix_1_weight1,
    input wire [7:0] pix_1_weight2,
    input wire [7:0] pix_1_weight3,
    input wire [7:0] pix_1_weight4,
    input wire clken,

    output wire [7:0] out,
    output wire out_en
);

reg [11:0] process1_value_0;
reg [11:0] process1_value_1;
reg [11:0] process1_value_2; 
reg [11:0] process1_value_3;
reg [11:0] process1_value_4;  //process value in pipeline1

reg [11:0] process2_value_0; //process value in pipeline2
reg [11:0] process2_value_1;
reg [11:0] process2_value_2;

reg [11:0] result_value;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        process1_value_0 <= 12'd0;
        process1_value_1 <= 12'd0;
        process1_value_2 <= 12'd0;
        process1_value_3 <= 12'd0;
        process1_value_4 <= 12'd0;
    end
    else begin
        process1_value_0 <= {pix_4_weight, 2'b00};
        process1_value_1 <= {pix_2_weight1, 1'b0} + {pix_2_weight2, 1'b0};
        process1_value_2 <= {pix_2_weight3, 1'b0} + {pix_2_weight4, 1'b0};
        process1_value_3 <= pix_1_weight1 + pix_1_weight2;
        process1_value_4 <= pix_1_weight3 + pix_1_weight4;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        process2_value_0 <= 12'd0;
        process2_value_1 <= 12'd0;
        process2_value_2 <= 12'd0;
    end
    else begin
        process2_value_0 <= process1_value_0 + process1_value_1 + process1_value_2;
        process2_value_1 <= process1_value_3 + process1_value_4;
        process2_value_2 <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result_value <= 12'd0;
    end
    else if (process2_value_0 < process2_value_1) begin
       result_value <= 12'd0;
   end
    else begin
        result_value <= process2_value_2 + process2_value_0 - process2_value_1;
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