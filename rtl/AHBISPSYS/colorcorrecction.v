module CC (
    input   wire            clk,
    input   wire            rst_n,
    input   wire            clken,
    input   wire    [7:0]   din,
    input   wire    [3:0]   bayer_state_start,
    input   wire    [10:0]  h_active_in,
    input   wire    [10:0]  v_active_in,
    input   wire    [7:0]   r_gain_in,
    input   wire    [7:0]   g_gain_in,
    input   wire    [7:0]   b_gain_in,

    output  wire    [7:0]   dout,
    output  wire            out_en
);

reg [10:0] h_cnt;
//reg [10:0] dH_cnt;
reg [10:0] v_cnt;
//reg [10:0] dV_cnt;
reg [3:0] bayer_state;
reg [3:0] bayer_state_next;
wire [7:0] r_gain_7;
wire [7:0] r_gain_6;
wire [7:0] r_gain_5;
wire [7:0] r_gain_4;
wire [7:0] r_gain_3;
wire [7:0] r_gain_2;
wire [7:0] r_gain_1;
wire [7:0] r_gain_0;
wire [7:0] g_gain_7;
wire [7:0] g_gain_6;
wire [7:0] g_gain_5;
wire [7:0] g_gain_4;
wire [7:0] g_gain_3;
wire [7:0] g_gain_2;
wire [7:0] g_gain_1;
wire [7:0] g_gain_0;
wire [7:0] b_gain_7;
wire [7:0] b_gain_6;
wire [7:0] b_gain_5;
wire [7:0] b_gain_4;
wire [7:0] b_gain_3;
wire [7:0] b_gain_2;
wire [7:0] b_gain_1;
wire [7:0] b_gain_0;
wire [7:0] step0_value7;
wire [7:0] step0_value0;
wire [7:0] step0_value6;
wire [7:0] step0_value5;
wire [7:0] step0_value4;
wire [7:0] step0_value3;
wire [7:0] step0_value2;
wire [7:0] step0_value1;
reg [8:0] step1_value [3:0];
reg [8:0] step2_value [1:0];
reg [8:0] result_value;
wire h_flag;
wire v_falg;

assign r_gain_7 = r_gain_in[7]? din : 8'h00;
assign r_gain_6 = r_gain_in[6]? {1'b0, din[7:1]} : 8'h00;
assign r_gain_5 = r_gain_in[5]? {2'b00, din[7:2]} : 8'h00;
assign r_gain_4 = r_gain_in[4]? {3'b000, din[7:3]} : 8'h00;
assign r_gain_3 = r_gain_in[3]? {4'b0000, din[7:4]} : 8'h00;
assign r_gain_2 = r_gain_in[2]? {5'b00000, din[7:5]} : 8'h00;
assign r_gain_1 = r_gain_in[1]? {6'b000000, din[7:6]} : 8'h00;
assign r_gain_0 = r_gain_in[0]? {7'b0000000, din[7]} : 8'h00;
assign g_gain_7 = g_gain_in[7]? din : 8'h00;
assign g_gain_6 = g_gain_in[6]? {1'b0, din[7:1]} : 8'h00;
assign g_gain_5 = g_gain_in[5]? {2'b00, din[7:2]} : 8'h00;
assign g_gain_4 = g_gain_in[4]? {3'b000, din[7:3]} : 8'h00;
assign g_gain_3 = g_gain_in[3]? {4'b0000, din[7:4]} : 8'h00;
assign g_gain_2 = g_gain_in[2]? {5'b00000, din[7:5]} : 8'h00;
assign g_gain_1 = g_gain_in[1]? {6'b000000, din[7:6]} : 8'h00;
assign g_gain_0 = g_gain_in[0]? {7'b0000000, din[7]} : 8'h00;
assign b_gain_7 = b_gain_in[7]? din : 8'h00;
assign b_gain_6 = b_gain_in[6]? {1'b0, din[7:1]} : 8'h00;
assign b_gain_5 = b_gain_in[5]? {2'b00, din[7:2]} : 8'h00;
assign b_gain_4 = b_gain_in[4]? {3'b000, din[7:3]} : 8'h00;
assign b_gain_3 = b_gain_in[3]? {4'b0000, din[7:4]} : 8'h00;
assign b_gain_2 = b_gain_in[2]? {5'b00000, din[7:5]} : 8'h00;
assign b_gain_1 = b_gain_in[1]? {6'b000000, din[7:6]} : 8'h00;
assign b_gain_0 = b_gain_in[0]? {7'b0000000, din[7]} : 8'h00;
assign step0_value7 = bayer_state[1]? b_gain_7 : bayer_state[2]? r_gain_7 : g_gain_7;
assign step0_value6 = bayer_state[1]? b_gain_6 : bayer_state[2]? r_gain_6 : g_gain_6;
assign step0_value5 = bayer_state[1]? b_gain_5 : bayer_state[2]? r_gain_5 : g_gain_5;
assign step0_value4 = bayer_state[1]? b_gain_4 : bayer_state[2]? r_gain_4 : g_gain_4;
assign step0_value3 = bayer_state[1]? b_gain_3 : bayer_state[2]? r_gain_3 : g_gain_3;
assign step0_value2 = bayer_state[1]? b_gain_2 : bayer_state[2]? r_gain_2 : g_gain_2;
assign step0_value1 = bayer_state[1]? b_gain_1 : bayer_state[2]? r_gain_1 : g_gain_1;
assign step0_value0 = bayer_state[1]? b_gain_0 : bayer_state[2]? r_gain_0 : g_gain_0;
assign h_flag = h_cnt==h_active_in-1'b1;
assign v_falg = v_cnt==v_active_in-1'b1;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        bayer_state <= 4'b0000;
    end
        else if(clken)begin  
        bayer_state <= bayer_state_next;
        end
        
    else if (h_cnt == 11'd0 && v_cnt == 11'd0) begin
        bayer_state <= bayer_state_start;
        end

    end

always @* begin
    bayer_state_next = bayer_state;
    case ({bayer_state,h_flag})
        5'b00010: bayer_state_next = 4'b0010;
        5'b00100: bayer_state_next = 4'b0001;
        5'b00011: bayer_state_next = bayer_state_start << 2;
        5'b00101: bayer_state_next = bayer_state_start << 2;
        5'b01000: bayer_state_next = 4'b1000;
        5'b10000: bayer_state_next = 4'b0100;
        5'b01001: bayer_state_next = bayer_state_start;
        5'b10001: bayer_state_next = bayer_state_start;
        default:  bayer_state_next = 4'b0001;
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        h_cnt <= 11'd0;
    end
    else if(clken) begin
        if(h_cnt == h_active_in - 1'b1)
            h_cnt <= 11'd0;
        else
            h_cnt <= h_cnt + 1'b1;
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        v_cnt <= 11'd0;
    end
    else if(clken) begin
    if(h_cnt == h_active_in - 1'b1)begin
        if(v_cnt == v_active_in - 1'b1)
            v_cnt <= 11'd0;
        else
            v_cnt <= v_cnt + 1'b1;
    end
    end    
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        step1_value[0] <= 9'h0;
        step1_value[1] <= 9'h0;
        step1_value[2] <= 9'h0;
        step1_value[3] <= 9'h0;
    end
    else begin
        step1_value[0] <= step0_value0 + step0_value1;
        step1_value[1] <= step0_value2 + step0_value3;
        step1_value[2] <= step0_value4 + step0_value5;
        step1_value[3] <= step0_value6 + step0_value7;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        step2_value[0] <= 9'h0;
        step2_value[1] <= 9'h0;
    end
    else begin
        step2_value[0] <= step1_value[0] + step1_value[1];
        step2_value[1] <= step1_value[2] + step1_value[3];
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    result_value <= 9'h0;
    else
    result_value <= step2_value[0] + step2_value[1];
end

reg [2:0] shift_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_reg <= 3'b0;
    end
    else begin
        shift_reg <= {shift_reg[1:0], clken};
    end
end

assign out_en = shift_reg[2];
assign dout = result_value[8]? 8'hFF : result_value[7:0];

endmodule