

module slidingWindow_5X5(
    input wire [7:0] din,
    input wire [10:0] h_active_in,
    input wire [10:0] v_active_in,
    input wire clk,
    input wire rst_n,
    input wire clken,
    input wire [3:0] bayer_state_start,

    output reg [7:0] dout_11,
    output reg [7:0] dout_12,
    output reg [7:0] dout_13,
    output reg [7:0] dout_14,
    output reg [7:0] dout_15,
    output reg [7:0] dout_21,
    output reg [7:0] dout_22,
    output reg [7:0] dout_23,
    output reg [7:0] dout_24, 
    output reg [7:0] dout_25, 
    output reg [7:0] dout_31, 
    output reg [7:0] dout_32, 
    output reg [7:0] dout_33, 
    output reg [7:0] dout_34,
    output reg [7:0] dout_35,
    output reg [7:0] dout_41, 
    output reg [7:0] dout_42, 
    output reg [7:0] dout_43, 
    output reg [7:0] dout_44, 
    output reg [7:0] dout_45, 
    output reg [7:0] dout_51, 
    output reg [7:0] dout_52, 
    output reg [7:0] dout_53, 
    output reg [7:0] dout_54, 
    output reg [7:0] dout_55, 
    output wire [3:0] bayer_state_out,
    output reg out_en_1,
    output wire isp_int,
    output wire end_flag
);

reg [10:0] h_cnt;
reg [10:0] v_cnt;
reg [3:0] bayer_state;
reg [3:0] bayer_state_next;
reg bayer_state_erro_int;
wire h_flag;
wire v_falg;


wire [7:0] fifo_1_in;
wire       fifo_1_wr_en;
wire       fifo_1_rd_en;
wire [7:0] fifo_1_out;

wire [7:0] fifo_2_in;
wire       fifo_2_wr_en;
wire       fifo_2_rd_en;
wire [7:0] fifo_2_out;

wire [7:0] fifo_3_in;
wire       fifo_3_wr_en;
wire       fifo_3_rd_en;
wire [7:0] fifo_3_out;

wire [7:0] fifo_4_in;
wire       fifo_4_wr_en;
wire       fifo_4_rd_en;
wire [7:0] fifo_4_out;




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

assign h_flag = h_cnt==h_active_in-1'b1;
assign v_falg = v_cnt==v_active_in-1'b1;
assign end_flag = h_flag & v_falg;

assign fifo_1_in = din;
assign fifo_1_wr_en = (v_cnt < v_active_in -1  )? clken : 1'b0;
assign fifo_1_rd_en = (v_cnt > 0)? clken : 1'b0;

assign fifo_2_in = fifo_1_out;
assign fifo_2_wr_en = fifo_1_rd_en && (v_cnt < v_active_in -1  );
assign fifo_2_rd_en = (v_cnt > 1)? clken : 1'b0;

assign fifo_3_in = fifo_2_out;
assign fifo_3_wr_en = fifo_2_rd_en && (v_cnt < v_active_in -1  );
assign fifo_3_rd_en = (v_cnt > 2)? clken : 1'b0;

assign fifo_4_in = fifo_3_out;
assign fifo_4_wr_en = fifo_3_rd_en && (v_cnt < v_active_in -1  );
assign fifo_4_rd_en = (v_cnt > 3)? clken : 1'b0;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        bayer_state <= 4'b0000;
    end
    else if (h_cnt == 11'd0 && v_cnt == 11'd0) begin
        bayer_state <= bayer_state_start;
    end
    else if(clken) begin
        bayer_state <= bayer_state_next;
    end
end

always @* begin
    bayer_state_next = bayer_state;
    bayer_state_erro_int = 1'b0;
    case ({bayer_state,h_flag})
        5'b00010: bayer_state_next = 4'b0010;
        5'b00100: bayer_state_next = 4'b0001;
        5'b00011: bayer_state_next = bayer_state_start << 2;
        5'b00101: bayer_state_next = bayer_state_start << 2;
        5'b01000: bayer_state_next = 4'b1000;
        5'b10000: bayer_state_next = 4'b0100;
        5'b01001: bayer_state_next = bayer_state_start;
        5'b10001: bayer_state_next = bayer_state_start;
        default: bayer_state_erro_int = 1'b1; 
    endcase
end

assign bayer_state_out = bayer_state;
assign isp_int = bayer_state_erro_int;

fifo_buf u_fifo_1(
    .clk (clk ), //写时钟
	.we (fifo_1_wr_en ), //写请求
	.di (fifo_1_in), //写数据
//isp接口
	.re (fifo_1_rd_en ), //读请求
	.dout (fifo_1_out ), //读数据

	.rdusedw ( ), //FIFO中的数据量
	.wrusedw ( ),
	.rst (~rst_n) //清零信号
);

fifo_buf u_fifo_2(
    .clk (clk ), //写时钟
	.we (fifo_2_wr_en ), //写请求
	.di (fifo_2_in), //写数据
//isp接口
	.re (fifo_2_rd_en ), //读请求
	.dout (fifo_2_out ), //读数据

	.rdusedw ( ), //FIFO中的数据量
	.wrusedw ( ),
	.rst (~rst_n) //清零信号

);


fifo_buf u_fifo_3(
    .clk (clk ), //写时钟
	.we (fifo_3_wr_en ), //写请求
	.di (fifo_3_in), //写数据
//isp接口
	.re (fifo_3_rd_en ), //读请求
	.dout (fifo_3_out ), //读数据

	.rdusedw ( ), //FIFO中的数据量
	.wrusedw ( ),
	.rst (~rst_n) //清零信号
);


fifo_buf u_fifo_4(
    .clk (clk ), //写时钟
	.we (fifo_4_wr_en ), //写请求
	.di (fifo_4_in), //写数据
//isp接口
	.re (fifo_4_rd_en ), //读请求
	.dout (fifo_4_out ), //读数据

	.rdusedw ( ), //FIFO中的数据量
	.wrusedw ( ),
	.rst (~rst_n) //清零信号
);



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dout_11 <= 8'd0;
        dout_12 <= 8'd0;
        dout_13 <= 8'd0;
        dout_14 <= 8'd0;
        dout_15 <= 8'd0;

        dout_21 <= 8'd0;
        dout_22 <= 8'd0;
        dout_23 <= 8'd0;
        dout_24 <= 8'd0;
        dout_25 <= 8'd0;

        dout_31 <= 8'd0;
        dout_32 <= 8'd0;
        dout_33 <= 8'd0;
        dout_34 <= 8'd0;
        dout_35 <= 8'd0;

        dout_41 <= 8'd0;
        dout_42 <= 8'd0;
        dout_43 <= 8'd0;
        dout_44 <= 8'd0;
        dout_45 <= 8'd0;

        dout_51 <= 8'd0;
        dout_52 <= 8'd0;
        dout_53 <= 8'd0;
        dout_54 <= 8'd0;
        dout_55 <= 8'd0;
    end
    else if(clken) begin
        dout_11 <= dout_12;
        dout_12 <= dout_13;
        dout_13 <= dout_14;
        dout_14 <= dout_15;
        dout_15 <= fifo_4_out;

        dout_21 <= dout_22;
        dout_22 <= dout_23;
        dout_23 <= dout_24;
        dout_24 <= dout_25;
        dout_25 <= fifo_3_out;

        dout_31 <= dout_32;
        dout_32 <= dout_33;
        dout_33 <= dout_34;
        dout_34 <= dout_35;
        dout_35 <= fifo_2_out;

        dout_41 <= dout_42;
        dout_42 <= dout_43;
        dout_43 <= dout_44;
        dout_44 <= dout_45;
        dout_45 <= fifo_1_out;

        dout_51 <= dout_52;
        dout_52 <= dout_53;
        dout_53 <= dout_54;
        dout_54 <= dout_55;
        dout_55 <= din;
        
            end    
end

wire out_en;

assign out_en = (v_cnt>5 &&v_cnt<1086 && h_cnt>9 &&h_cnt<1930)? clken:1'b0;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) out_en_1<= 1'b0;
    else out_en_1 <= out_en;
end
endmodule

