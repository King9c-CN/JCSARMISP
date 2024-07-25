module cc_tb;
integer j;
integer i = 0;
integer min = 12'h100;
integer max = 12'hFFF;

reg [11:0] raw_data;
reg [11:0] h_active;
reg [11:0] v_active;
reg [3:0]  bayerStart;
reg        isp_clk;
reg        data_en;
reg        rst_n;
reg        mode_sel;
reg [7:0]  r_gain;
reg [7:0]  g_gain;
reg [7:0]  b_gain;

wire [15:0] isp_data_in;
wire [11:0] h_active_in;
wire [11:0] v_active_in;
reg rData_en;

always@(posedge isp_clk) begin
rData_en <= data_en;
end

assign isp_data_in = {raw_data,{4{1'b0}}};
assign h_active_in = h_active;
assign v_active_in = v_active;

ISP_pipeline u_ISP_pipeline(
    .isp_data_in ( isp_data_in ),
    .h_active_in ( h_active_in ),
    .v_active_in ( v_active_in ),
    .bayerStart  ( bayerStart  ),
    .isp_clk     ( isp_clk     ),
    .data_en     ( data_en     ),
    .rst_n       ( rst_n       ),
    .mode_sel    ( 3'b100    ),
    .r_gain      ( r_gain      ),
    .g_gain      ( g_gain      ),
    .b_gain      ( b_gain      ),
    .rgb_out     (      ),
    .frames_cnt  (   ),
    .gamma_coe   (3'b001)
);

initial begin
    isp_clk = 'b1;
    h_active = 'h10;
    v_active = 'h20;
    bayerStart = 'b0001;
    r_gain = 'hE0;
    g_gain = 'h60;
    b_gain = 'h89;
    forever #5
    isp_clk = ~isp_clk;
end

initial begin
    rst_n = 'b1;
    #20
    rst_n = 'b0;
    #10
    rst_n = 'b1;
end

initial begin
    data_en = 'b0;
    raw_data = 'h0;
    #100
    while(i<200) begin
    #20
    j=0;
    data_en = 'b1;
    raw_data = min+{$random}%(max-min+1);
    while(j<20) begin
    #10    
    raw_data = min+{$random}%(max-min+1);
    j = j+1;
    end
    #10
    data_en = 'b0;
    i = i+1;
    end
end



endmodule