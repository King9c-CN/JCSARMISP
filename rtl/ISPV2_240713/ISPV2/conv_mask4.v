module conv_mask4 (
    input wire          isp_clk,
    input wire          rst_n,
    input wire [15:0]   pix_4_weight,
    input wire [15:0]   pix_2_weight1,
    input wire [15:0]   pix_2_weight2,
    input wire [15:0]   pix_2_weight3,
    input wire [15:0]   pix_2_weight4,
    input wire [15:0]   pix_1_weight1,
    input wire [15:0]   pix_1_weight2,
    input wire [15:0]   pix_1_weight3,
    input wire [15:0]   pix_1_weight4,
    input wire          dataEn,

    output wire [15:0]  Dout

);
wire [11:0] wDoutData;

reg [15:0]  process1_value_0;
reg [15:0]  process1_value_1;
reg [15:0]  process1_value_2; 
reg [15:0]  process1_value_3;
reg [15:0]  process1_value_4;  //process value in pipeline1
 

reg [15:0]  process2_value_0; //process value in pipeline2
reg [15:0]  process2_value_1;
reg [15:0]  process2_value_2;

reg [15:0]  result_value;
reg [3:0]   rBySt[2:0];


always @(posedge isp_clk or negedge rst_n) begin
    if (!rst_n) begin
        process1_value_0 <= 'd0;
        process1_value_1 <= 'd0;
        process1_value_2 <= 'd0;
        process1_value_3 <= 'd0;
        process1_value_4 <= 'd0;
        rBySt[0] <= 4'b0000;
    end
    else begin
        process1_value_0 <= {{2{1'b0}}, pix_4_weight[15:4], {2{1'b0}}};
        process1_value_1 <= {{3{1'b0}}, pix_2_weight1[15:4], {1{1'b0}}} + {{3{1'b0}}, pix_2_weight2[15:4], {1{1'b0}}};
        process1_value_2 <= {{3{1'b0}}, pix_2_weight3[15:4], {1{1'b0}}} + {{3{1'b0}}, pix_2_weight4[15:4], {1{1'b0}}};
        process1_value_3 <= {{4{1'b0}}, pix_1_weight1[15:4]} + {{4{1'b0}}, pix_1_weight2[15:4]};
        process1_value_4 <= {{4{1'b0}}, pix_1_weight3[15:4]} + {{4{1'b0}}, pix_1_weight4[15:4]};
        rBySt[0] <= pix_4_weight[3:0];
    end
end

always @(posedge isp_clk or negedge rst_n) begin
    if (!rst_n) begin
        process2_value_0 <= 'd0;
        process2_value_1 <= 'd0;
        process2_value_2 <= 'd0;
        rBySt[1] <= 'h0;
    end
    else begin
        process2_value_0 <= process1_value_0 + process1_value_1 + process1_value_2;
        process2_value_1 <= process1_value_3 + process1_value_4;
        process2_value_2 <= 0;
        rBySt[1] <= rBySt[0];
    end
end

always @(posedge isp_clk or negedge rst_n) begin
    if (!rst_n) begin
        result_value <= 'd0;
        rBySt[2] <= 'h0;
    end
    else if (process2_value_0 < process2_value_1) begin
       result_value <= 'd0;
       rBySt[2] <= rBySt[1];
   end
    else begin
        result_value <= process2_value_2 + process2_value_0 - process2_value_1;
        rBySt[2] <= rBySt[1];
    end
end
assign wDoutData = result_value[15]? 'hFFF : result_value[14:3];
assign Dout ={wDoutData, rBySt[2]};
endmodule