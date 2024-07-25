module demosaic (
    input wire clk,
    input wire rst_n,
    input wire [3:0] bayer_state, // 4'b0001: Gb   4'b0010: B    4'b0100: R    4'b1000:Gr
    input wire [7:0] matrix_p13,
    input wire [7:0] matrix_p22,
    input wire [7:0] matrix_p23,
    input wire [7:0] matrix_p24,
    input wire [7:0] matrix_p31,
    input wire [7:0] matrix_p32,
    input wire [7:0] matrix_p33,
    input wire [7:0] matrix_p34,
    input wire [7:0] matrix_p35,
    input wire [7:0] matrix_p42,
    input wire [7:0] matrix_p43,
    input wire [7:0] matrix_p44,
    input wire [7:0] matrix_p53,

    input wire clken,

    output wire [7:0] red_data,
    output wire [7:0] green_data,
    output wire [7:0] blue_data,
    output wire [15:0] rgb_data,
    output wire data_en
);

wire [7:0] red_vec;
wire [7:0] green_vec;
wire [7:0] blue_vec;

wire mask5_sel;
wire red_sel;
wire Gb_sel;
wire conv4_data_en;
wire [7:0] conv4_data_out;
wire [1:0] conv5_data_en;
wire [7:0] conv5_data0;
wire [7:0] conv5_data1;
wire conv6_data_en;
wire [7:0] conv6_data;

assign mask5_sel = ~(bayer_state[0] | bayer_state[3]);
assign Gb_sel = mask5_sel & bayer_state[0];
assign red_sel = (~mask5_sel) & bayer_state[1];

conv_mask4 u_conv_mask4(
    .clk    (clk),
    .rst_n  (rst_n),
    .clken  (clken & ~mask5_sel),

    .pix_4_weight   (matrix_p33),
    .pix_2_weight1  (matrix_p32),
    .pix_2_weight2  (matrix_p34),
    .pix_2_weight3  (matrix_p23),
    .pix_2_weight4  (matrix_p43),
    .pix_1_weight1  (matrix_p13),
    .pix_1_weight2  (matrix_p31),
    .pix_1_weight3  (matrix_p35),
    .pix_1_weight4  (matrix_p53),

    .out    (conv4_data_out),
    .out_en (conv4_data_en)
);

conv_mask5 u1_conv_mask5(
    .clk    (clk),
    .rst_n  (rst_n),
    .clken  (clken & mask5_sel),

    .pix_5_weight0  (matrix_p33),
    .pix_4_weight0  (matrix_p32),
    .pix_4_weight1  (matrix_p34),
    .pix_1_weight0  (matrix_p31),
    .pix_1_weight1  (matrix_p35),
    .pix_1_weight2  (matrix_p22),
    .pix_1_weight3  (matrix_p24),
    .pix_1_weight4  (matrix_p42),
    .pix_1_weight5  (matrix_p44),
    .pix_half_weight0   (matrix_p13),
    .pix_half_weight1   (matrix_p53),

    .out    (conv5_data0),
    .out_en (conv5_data_en[0])
);

conv_mask5 u2_conv_mask5(
    .clk    (clk),
    .rst_n  (rst_n),
    .clken  (clken & mask5_sel),

    .pix_5_weight0  (matrix_p33),
    .pix_4_weight0  (matrix_p43),
    .pix_4_weight1  (matrix_p23),
    .pix_1_weight0  (matrix_p13),
    .pix_1_weight1  (matrix_p53),
    .pix_1_weight2  (matrix_p22),
    .pix_1_weight3  (matrix_p24),
    .pix_1_weight4  (matrix_p42),
    .pix_1_weight5  (matrix_p44),
    .pix_half_weight0   (matrix_p31),
    .pix_half_weight1   (matrix_p35),

    .out    (conv5_data1),
    .out_en (conv5_data_en[1])
);

conv_mask6 u_conv_mask6(
    .clk    (clk),
    .rst_n  (rst_n),
    .clken  (clken & ~mask5_sel),

    .pix_6_weight0  (matrix_p33),
    .pix_2_weight0  (matrix_p22),
    .pix_2_weight1  (matrix_p24),
    .pix_2_weight2  (matrix_p42),
    .pix_2_weight3  (matrix_p44),
    .pix_1_and_half_weight0 (matrix_p13),
    .pix_1_and_half_weight1 (matrix_p31),
    .pix_1_and_half_weight2 (matrix_p35),
    .pix_1_and_half_weight3 (matrix_p53),

    .out    (conv6_data),
    .out_en (conv6_data_en)
);

reg [23:0] shift_reg_data;
wire [7:0] delay_data;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        shift_reg_data <= 24'h0;
    end
    else begin
        shift_reg_data <= {shift_reg_data[15:8], shift_reg_data[7:0], matrix_p33}; 
    end
end
assign delay_data = shift_reg_data[23:16];


reg [11:0] shift_reg_state;
wire [3:0] delay_state;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_reg_state <= 12'h0;
    end
    else begin
        shift_reg_state <= {shift_reg_state[7:4], shift_reg_state[3:0], bayer_state};
    end
end
assign delay_state = shift_reg_state[11:8];

assign red_vec = delay_state[2]? delay_data : delay_state[1]? conv6_data : delay_state[0]? conv5_data1 : conv5_data0;
assign blue_vec = delay_state[1]? delay_data : delay_state[2]? conv6_data : delay_state[0]? conv5_data0 : conv5_data1;
assign green_vec = delay_state[0]? delay_data : delay_state[3]? delay_data : conv4_data_out;

assign rgb_data = {red_vec[7:3], green_vec[7:2], blue_vec[7:3]};
assign red_data = red_vec;
assign green_data = green_vec;
assign blue_data = blue_vec;
//assign data_en = conv4_data_en | conv5_data_en[0] | conv5_data_en[1] | conv6_data_en;

reg [2:0] shift_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_reg <= 3'b0;
    end
    else begin
        shift_reg <= {shift_reg[1:0], clken};
    end
end

assign data_en = shift_reg[2];


endmodule