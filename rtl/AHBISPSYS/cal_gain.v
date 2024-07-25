module cal_gain (
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
    input   wire            sel,
    input   wire            direct,

    output  wire    [7:0]   r_gain_out,
    output  wire    [7:0]   g_gain_out,
    output  wire    [7:0]   b_gain_out,
    output  wire            out_en
);

reg [7:0]   rRedGain[1:0];
reg [7:0]   rGreenGain[1:0];
reg [7:0]   rBlueGain[1:0];
wire [7:0]  wRedGain;
wire [7:0]  wGreenGain;
wire [7:0]  wBlueGain;
reg [10:0]  h_cnt;
reg rDirect;
//reg [10:0] dH_cnt;
reg [10:0]  v_cnt;
//reg [10:0] dV_cnt;
reg [3:0]   bayer_state;
reg [3:0]   bayer_state_next;
reg     rOut_en[1:0];
wire    wOut_en;
wire    h_flag;
wire    v_falg;
wire    end_flag;

assign h_flag = h_cnt==h_active_in-1'b1;
assign v_falg = v_cnt==v_active_in-1'b1;
assign end_flag = h_flag&v_falg;

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
        5'b00010: bayer_state_next = 5'b0010;
        5'b00100: bayer_state_next = 5'b0001;
        5'b00011: bayer_state_next = bayer_state_start << 2;
        5'b00101: bayer_state_next = bayer_state_start << 2;
        5'b01000: bayer_state_next = 5'b1000;
        5'b10000: bayer_state_next = 5'b0100;
        5'b01001: bayer_state_next = bayer_state_start;
        5'b10001: bayer_state_next = bayer_state_start;
        default:  bayer_state_next = 5'b0010;
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
        rRedGain[0] <= 8'b1000_0000;
        rGreenGain[0] <= 8'b1000_0000;
        rBlueGain[0] <= 8'b1000_0000;
    end
    else begin
        if (rDirect) begin
            rRedGain[0] <= r_gain_in;
            rBlueGain[0] <= b_gain_in;
            rGreenGain[0] <= g_gain_in;
        end
        else begin
            rRedGain[0] <= 8'b1000_0000;
            rGreenGain[0] <= 8'b1000_0000;
            rBlueGain[0] <= 8'b1000_0000;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rDirect <= 1'b0;
        rOut_en[0] <= 1'b0;
    end
    else begin
        if(sel) begin
            rOut_en[0] <= rDirect;
            rDirect <= direct;
        end
        else begin
            rOut_en[0] <= rDirect;
            rDirect <= rDirect; 
        end
    end
end

wire calculate_en;
wire calculate_rd;

assign calculate_en = ~rDirect & clken;
assign calculate_rd = ~rDirect & wOut_en;

calculator u_calculator(
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .clken       ( calculate_en ),
    .din         ( din         ),
    .bayer_state ( bayer_state ),
    .end_flag    ( end_flag    ),
    .r_gain_cal  ( wRedGain  ),
    .g_gain_cal  ( wGreenGain  ),
    .b_gain_cal  ( wBlueGain  ),
    .gain_ready  ( wOut_en  )
);


always @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
    rOut_en[1] <= 1'b0;
    rRedGain[1] <= 8'b1000_0000;
    rGreenGain[1] <= 8'b1000_0000;
    rBlueGain[1] <= 8'b1000_0000;
   end
   else if (calculate_rd) begin
    rRedGain[1] <= wRedGain;
    rGreenGain[1] <= wGreenGain;
    rBlueGain[1] <= wBlueGain;
    rOut_en[1] <= 1'b1;
   end
end


assign r_gain_out = (~rDirect)? rRedGain[1] : rRedGain[0];
assign g_gain_out = (~rDirect)? rGreenGain[1] : rGreenGain[0];
assign b_gain_out = (~rDirect)? rBlueGain[1] : rBlueGain[0];

assign out_en = rOut_en[0] | rOut_en[1];




endmodule