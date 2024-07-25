module conv_mask5 (
    input wire          isp_clk,
    input wire          rst_n,
    input wire          dataEn,
    input wire [15:0]   pix_5_weight0,
    input wire [15:0]   pix_4_weight0,
    input wire [15:0]   pix_4_weight1,
    input wire [15:0]   pix_1_weight0,
    input wire [15:0]   pix_1_weight1,
    input wire [15:0]   pix_1_weight2,
    input wire [15:0]   pix_1_weight3,
    input wire [15:0]   pix_1_weight4,
    input wire [15:0]   pix_1_weight5,
    input wire [15:0]   pix_half_weight0,
    input wire [15:0]   pix_half_weight1,

    output wire [15:0]  Dout
);
wire [11:0] wDoutData;

reg [15:0] process1_value [4:0];
reg [15:0] process2_value [1:0];
reg [15:0] result_value;
reg [3:0]   rBySt[2:0];

always @(posedge isp_clk or negedge rst_n) begin
    if (!rst_n) begin
        process1_value[0] <= 'd0;
        process1_value[1] <= 'd0;
        process1_value[2] <= 'd0;
        process1_value[3] <= 'd0;
        process1_value[4] <= 'd0;
        rBySt[0] <= 4'b0000;
    end
    else begin
        process1_value[0] <= {{2{1'b0}}, pix_5_weight0[15:4], {2{1'b0}}} + {{4{1'b0}}, pix_5_weight0[15:4]};
        process1_value[1] <= {{2{1'b0}}, pix_4_weight0[15:4], {2{1'b0}}} + {{2{1'b0}}, pix_4_weight1[15:4], {2{1'b0}}};
        process1_value[2] <= {{4{1'b0}}, pix_1_weight0[15:4]} + {{4{1'b0}}, pix_1_weight1[15:4]} + {{4{1'b0}}, pix_1_weight2[15:4]};
        process1_value[3] <= {{4{1'b0}}, pix_1_weight3[15:4]} + {{4{1'b0}}, pix_1_weight4[15:4]} + {{4{1'b0}}, pix_1_weight5[15:4]};
        process1_value[4] <= {{5{1'b0}}, pix_half_weight0[15:5]} + {{5{1'b0}}, pix_half_weight1[15:5]};
        rBySt[0] <= pix_5_weight0[3:0];
    end
end
    
always @(posedge isp_clk or negedge rst_n) begin
    if (!rst_n) begin
        process2_value[0] <= 'd0;
        process2_value[1] <= 'd0;
        rBySt[1] <= 'h0;
    end
    else begin
        process2_value[0] <= process1_value[0] + process1_value[1] + process1_value[4];
        process2_value[1] <= process1_value[2] + process1_value[3];
        rBySt[1] <= rBySt[0];
    end
end

always @(posedge isp_clk or negedge rst_n) begin
    if (!rst_n) begin
        result_value <= 'd0;
        rBySt[2] <= 'h0;
    end
        else if (process2_value[0] < process2_value[1]) begin
        result_value <= 'd0;
        rBySt[2] <= rBySt[1];
    end
    else begin
        result_value <= process2_value[0] - process2_value[1];
        rBySt[2] <= rBySt[1];
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

assign wDoutData = result_value[15]? 'hFFF : result_value[14:3];
assign Dout ={wDoutData, rBySt[2]};
endmodule