module ISP_pipeline (
    input wire    [15:0] isp_data_in,
    input wire    [11:0] h_active_in,
    input wire    [11:0] v_active_in,
    input wire    [3:0]  bayerStart,
    input wire           isp_clk,
    input wire           data_en,
    input wire           rst_n,
    input wire    [2:0]  mode_sel,
    input wire    [2:0]  gamma_coe,
    input wire    [7:0]  r_gain,
    input wire    [7:0]  g_gain,
    input wire    [7:0]  b_gain,

    output wire   [15:0]  rgb_out,
    output wire           ips_out_en,
    output wire   [15:0]  frames_cnt
);

reg [15:0]  rdData;
reg [15:0]  ccDin;
reg [3:0]   bayer_st;
reg [3:0]   bayer_st_nxt;
reg [11:0]  h_cnt;
reg [11:0]  v_cnt;
reg [15:0]  rFramesCnt;
reg         rDataEn;
reg         rInDataEn;

wire wInDataEn_isp;
wire wInDataEn_raw;
wire wInDataEn_grey;
wire process_mode_sel;
wire bayer_raw_sel;
wire bayer_grey_sel;
wire h_flag;
wire v_falg;
wire wCcDataEn;
wire [15:0] wRdData;
wire [15:0] wPostCcData;
wire [3:0]  wBayerSt;

//CC define
wire [11:0] r_channel_data;
wire [11:0] g_channel_data;
wire [11:0] b_channel_data;
wire        wDmscEn;
wire        frame_done;

//gamma define
wire [7:0]  r_out;
wire [7:0]  g_out;
wire [7:0]  b_out;
wire        process_out_en;
wire        direct_out_en;
wire        grey_out_en;
wire [15:0] process_rgb;
wire [15:0] direct_rgb;
wire [15:0] grey_rgb;

assign wRdData = rdData;
assign h_flag = h_cnt==h_active_in-1'b1;
assign v_flag = v_cnt==v_active_in-1'b1;
assign end_flag = h_flag & v_flag & data_en;
assign process_mode_sel = mode_sel[2];
assign bayer_raw_sel = mode_sel[1];
assign bayer_grey_sel = mode_sel[0];
assign wInDataEn_isp = rInDataEn & process_mode_sel;
assign wInDataEn_raw = rInDataEn & bayer_raw_sel;
assign wInDataEn_grey = rInDataEn & bayer_grey_sel;
assign wBayerSt = bayer_st;

always@(posedge isp_clk or negedge rst_n) begin
    if(!rst_n) begin
        h_cnt <= 'h0;
    end
    else if(rDataEn) begin
        if(h_cnt == h_active_in - 1'b1)
            h_cnt <= 'd0;
        else
            h_cnt <= h_cnt + 1'b1;
    end
end

always @(posedge isp_clk or negedge rst_n) begin
    if(!rst_n)begin
        v_cnt <= 'h0;
    end
    else if(data_en) begin
    if(h_cnt == h_active_in - 1'b1)begin
        if(v_cnt == v_active_in - 1'b1)
            v_cnt <= 'd0;
        else
            v_cnt <= v_cnt + 1'b1;
    end
    end    
end

always @(posedge isp_clk or negedge rst_n) begin
    if(!rst_n) begin
        bayer_st <= bayerStart;
    end
    else if(rDataEn)
            bayer_st <= bayer_st_nxt; 
end

always @* begin
    bayer_st_nxt = bayer_st;
    case ({bayer_st, h_flag})
        5'b00010: bayer_st_nxt = 4'b0010;
        5'b00100: bayer_st_nxt = 4'b0001;
        //5'b00011: bayer_st_nxt = bayerStart << 2;
        5'b00101: bayer_st_nxt = bayerStart << 2;
        5'b01000: bayer_st_nxt = 4'b1000;
        5'b10000: bayer_st_nxt = 4'b0100;
        //5'b01001: bayer_st_nxt = bayerStart;
        5'b10001: bayer_st_nxt = bayerStart;
        default: bayer_st_nxt = bayerStart;
    endcase
end
    
always @(posedge isp_clk) begin
    rDataEn <= data_en;
    rInDataEn <= rDataEn;
end

always @(posedge isp_clk or negedge rst_n) begin
    if(!rst_n)

    rdData <= 16'h0;
    else if(data_en) begin
    rdData <= {isp_data_in[15:4],4'b0000};
    end
    else
    rdData <= 'h0;
end

always @(posedge isp_clk or negedge rst_n) begin
    if(!rst_n)
    ccDin <= 'h0;
    else if(rDataEn) begin
        ccDin <= {rdData[15:4], bayer_st};
    end
    else
    ccDin <= 'h0;
end

colorCorrection u_colorCorrection(
    .redGain ( r_gain         ),
    .bluGain ( b_gain         ),
    .greGain ( g_gain         ),
    .clk     ( isp_clk        ),
    .rst_n   ( rst_n          ),
    .Din     ( ccDin        ),
    .dataEn  ( wInDataEn_isp  ),
    .Dout    ( wPostCcData    ),
    .outEn   ( wCcDataEn      )
);

demosaic u_demosaic(
    .isp_clk    ( isp_clk            ),
    .rst_n      ( rst_n              ),
    .Din        ( wPostCcData        ),
    .dataEn     ( wCcDataEn          ),
    .h_active   ( h_active_in        ),
    .v_active   ( v_active_in        ),
    .redVec     ( r_channel_data     ),
    .greVec     ( g_channel_data     ),
    .bluVec     ( b_channel_data     ),
    .doutEn     ( wDmscEn            ),
    .frame_done ( frame_done         )
);

gamma u_gamma(
    .r_data    ( r_channel_data     ),
    .g_data    ( g_channel_data     ),
    .b_data    ( b_channel_data     ),
    .clk       ( isp_clk            ),
    .rst_n     ( rst_n              ),
    .gamma_coe ( gamma_coe          ),
    .dataEn    ( wDmscEn            ),
    .r_out     ( r_out              ),
    .g_out     ( g_out              ),
    .b_out     ( b_out              ),
    .outEn     ( process_out_en     )
);

bypass u_bypass(
    .Din    ( ccDin             ),
    .clk    ( isp_clk           ),
    .rst_n  ( rst_n             ),
    .dataEn ( wInDataEn_raw     ),
    .Dout   ( direct_rgb        ),
    .outEn  ( direct_out_en     )
);

grey u_grey(
    .Din    ( ccDin             ),
    .clk    ( isp_clk           ),
    .rst_n  ( rst_n             ),
    .dataEn ( wInDataEn_grey    ),
    .Dout   ( grey_rgb          ),
    .outEn  ( grey_out_en       )
);

assign process_rgb = {r_out[7:3], g_out[7:2], b_out[7:3]};
assign rgb_out = mode_sel[2]? process_rgb : 
                 mode_sel[1]? direct_rgb :
                 mode_sel[0]? grey_rgb : 'h0;

assign ips_out_en = mode_sel[2]? process_out_en : 
                    mode_sel[1]? direct_out_en : 
                    mode_sel[0]? grey_out_en : 'b0;


always @(posedge isp_clk or negedge rst_n) begin
    if(!rst_n)
    rFramesCnt <= 'h0;
    else if(end_flag)
    rFramesCnt <= rFramesCnt + 1'b1;
end

assign frames_cnt = rFramesCnt;

endmodule