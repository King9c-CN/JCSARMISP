module slideWindow(
    input wire          isp_clk,
    input wire          rst_n,
    input wire [15:0]   dataIn,
    input wire          dataEn,
    input wire [11:0]   h_active,
    input wire [11:0]   v_active,

    output reg [15:0]   Dout11,
    output reg [15:0]   Dout12,
    output reg [15:0]   Dout13,
    output reg [15:0]   Dout14,
    output reg [15:0]   Dout15,
    output reg [15:0]   Dout21,
    output reg [15:0]   Dout22,
    output reg [15:0]   Dout23,
    output reg [15:0]   Dout24,
    output reg [15:0]   Dout25,
    output reg [15:0]   Dout31,
    output reg [15:0]   Dout32,
    output reg [15:0]   Dout33,
    output reg [15:0]   Dout34,
    output reg [15:0]   Dout35,
    output reg [15:0]   Dout41,
    output reg [15:0]   Dout42,
    output reg [15:0]   Dout43,
    output reg [15:0]   Dout44,
    output reg [15:0]   Dout45,
    output reg [15:0]   Dout51,
    output reg [15:0]   Dout52,
    output reg [15:0]   Dout53,
    output reg [15:0]   Dout54,
    output reg [15:0]   Dout55,

    output wire         outEn,
    output wire         endFlag
);


reg [11:0] hCnt;
reg [11:0] vCnt;

reg rOutEn;

wire        h_flag;
wire        v_flag;
wire        vInit;
wire [15:0] fifo_1_in;
wire       fifo_1_wr_en;
wire       fifo_1_rd_en;
wire [15:0] fifo_1_out;

wire [15:0] fifo_2_in;
wire       fifo_2_wr_en;
wire       fifo_2_rd_en;
wire [15:0] fifo_2_out;

wire [15:0] fifo_3_in;
wire       fifo_3_wr_en;
wire       fifo_3_rd_en;
wire [15:0] fifo_3_out;

wire [15:0] fifo_4_in;
wire       fifo_4_wr_en;
wire       fifo_4_rd_en;
wire [15:0] fifo_4_out;

always@(posedge isp_clk or negedge rst_n) begin
    if(!rst_n) begin
        hCnt <= 12'h0;
    end
    else if(dataEn) begin
        if(hCnt == h_active - 1'b1)
            hCnt <= 'h0;
        else
            hCnt <= hCnt + 1'b1;
    end
end

always @(posedge isp_clk or negedge rst_n) begin
    if(!rst_n)begin
        vCnt <= 12'h0;
    end
    else if(dataEn) begin
    if(hCnt == h_active - 1'b1)begin
        if(vCnt == v_active - 1'b1)
            vCnt <= 12'd0;
        else
            vCnt <= vCnt + 1'b1;
    end
    end    
end

assign vInit = (vCnt == 12'hFFF);
assign fifo_1_in = dataIn;
assign fifo_1_wr_en = ((vCnt < v_active -1) | vInit)? dataEn : 1'b0;
assign fifo_1_rd_en = ((vCnt > 0)&(~vInit))? dataEn : 1'b0;

assign fifo_2_in = fifo_1_out;
assign fifo_2_wr_en = fifo_1_rd_en && ((vCnt < v_active -1)|vInit);
assign fifo_2_rd_en = ((vCnt > 1)&(~vInit))? dataEn : 1'b0;

assign fifo_3_in = fifo_2_out;
assign fifo_3_wr_en = fifo_2_rd_en && ((vCnt < v_active -1)|vInit);
assign fifo_3_rd_en = ((vCnt > 2)&(~vInit))? dataEn : 1'b0;

assign fifo_4_in = fifo_3_out;
assign fifo_4_wr_en = fifo_3_rd_en && ((vCnt < v_active -1)|vInit);
assign fifo_4_rd_en = ((vCnt > 3)&(~vInit))? dataEn : 1'b0;

assign h_flag = hCnt==h_active - 1'b1;
assign v_flag = vCnt==v_active - 1'b1;
assign endFlag = h_flag & v_flag & dataEn;

fifo_buf u_fifo_1(
    .clk (isp_clk ), //写时�????
	.we (fifo_1_wr_en ), //写请�????
	.di (fifo_1_in), //写数�????
//isp接口
	.re (fifo_1_rd_en ), //读请�????
	.dout (fifo_1_out ), //读数�????

	.rdusedw ( ), //FIFO中的数据�????
	.wrusedw ( ),
	.rst (~rst_n) //清零信号
);

fifo_buf u_fifo_2(
    .clk (isp_clk ), //写时�????
	.we (fifo_2_wr_en ), //写请�????
	.di (fifo_2_in), //写数�????
//isp接口
	.re (fifo_2_rd_en ), //读请�????
	.dout (fifo_2_out ), //读数�????

	.rdusedw ( ), //FIFO中的数据�????
	.wrusedw ( ),
	.rst (~rst_n) //清零信号

);


fifo_buf u_fifo_3(
    .clk (isp_clk ), //写时�????
	.we (fifo_3_wr_en ), //写请�????
	.di (fifo_3_in), //写数�????
//isp接口
	.re (fifo_3_rd_en ), //读请�????
	.dout (fifo_3_out ), //读数�????

	.rdusedw ( ), //FIFO中的数据�????
	.wrusedw ( ),
	.rst (~rst_n) //清零信号
);


fifo_buf u_fifo_4(
    .clk (isp_clk ), //写时�????
	.we (fifo_4_wr_en ), //写请�????
	.di (fifo_4_in), //写数�????
//isp接口
	.re (fifo_4_rd_en ), //读请�????
	.dout (fifo_4_out ), //读数�????

	.rdusedw ( ), //FIFO中的数据�????
	.wrusedw ( ),
	.rst (~rst_n) //清零信号
);

always @(posedge isp_clk or negedge rst_n) begin
    if(!rst_n) begin
        Dout11 <= 16'd0;
        Dout12 <= 16'd0;
        Dout13 <= 16'd0;
        Dout14 <= 16'd0;
        Dout15 <= 16'd0;

        Dout21 <= 16'd0;
        Dout22 <= 16'd0;
        Dout23 <= 16'd0;
        Dout24 <= 16'd0;
        Dout25 <= 16'd0;

        Dout31 <= 16'd0;
        Dout32 <= 16'd0;
        Dout33 <= 16'd0;
        Dout34 <= 16'd0;
        Dout35 <= 16'd0;

        Dout41 <= 16'd0;
        Dout42 <= 16'd0;
        Dout43 <= 16'd0;
        Dout44 <= 16'd0;
        Dout45 <= 16'd0;

        Dout51 <= 16'd0;
        Dout52 <= 16'd0;
        Dout53 <= 16'd0;
        Dout54 <= 16'd0;
        Dout55 <= 16'd0;
    end
    else if(dataEn) begin
        Dout11 <= Dout12;
        Dout12 <= Dout13;
        Dout13 <= Dout14;
        Dout14 <= Dout15;
        Dout15 <= fifo_4_out;

        Dout21 <= Dout22;
        Dout22 <= Dout23;
        Dout23 <= Dout24;
        Dout24 <= Dout25;
        Dout25 <= fifo_3_out;

        Dout31 <= Dout32;
        Dout32 <= Dout33;
        Dout33 <= Dout34;
        Dout34 <= Dout35;
        Dout35 <= fifo_2_out;

        Dout41 <= Dout42;
        Dout42 <= Dout43;
        Dout43 <= Dout44;
        Dout44 <= Dout45;
        Dout45 <= fifo_1_out;

        Dout51 <= Dout52;
        Dout52 <= Dout53;
        Dout53 <= Dout54;
        Dout54 <= Dout55;
        Dout55 <= dataIn;
    end    
end

always @(posedge isp_clk) begin
    rOutEn <= (vCnt>3 && hCnt >3 && dataEn); 
    //rOutEn <= (vCnt>5 &&vCnt<1086 && hCnt>9 &&hCnt<1930 && dataEn);
end

assign outEn = rOutEn;


endmodule