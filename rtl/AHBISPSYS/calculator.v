module calculator (
    input   wire            clk,
    input   wire            rst_n,
    input   wire            clken,
    input   wire    [7:0]   din,
    input   wire    [3:0]   bayer_state,
    input   wire            end_flag,

    output  wire    [7:0]   r_gain_cal,
    output  wire    [7:0]   g_gain_cal,
    output  wire    [7:0]   b_gain_cal,
    output  wire            gain_ready
);

reg [31:0]  r_sum;
reg [31:0]  g_sum;
reg [31:0]  b_sum;
reg [31:0]  k_sum;
reg         complete;

wire [7:0]  rRawdata;
wire [7:0]  bRawdata;
wire [7:0]  gRawdata;
wire [2:0]  channel_ready;
wire [31:0] wRedSum;
wire [31:0] wGreSum;
wire [31:0] wBluSum;
wire wComplete;

assign wComplete = complete;
assign wRedSum = r_sum;
assign wGreSum = g_sum;
assign wBluSum = b_sum;

assign rRawdata = bayer_state[2]? din : 8'b0000_0000;
assign gRawdata = bayer_state[0]? din : 
                  bayer_state[3]? din : 8'b0000_0000;
assign bRawdata = bayer_state[1]? din : 8'b0000_0000;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
    complete <= 1'b0;
    else begin
        if(end_flag)
        complete <= 1'b1;
        else if(gain_ready)
        complete <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r_sum <= 32'h0;
        g_sum <= 32'h0;
        b_sum <= 32'h0;
        k_sum <= 32'h0;
    end
    else begin
        if (clken&(~complete)) begin
            r_sum <= r_sum + {rRawdata,2'b00};
            g_sum <= g_sum + {gRawdata,1'b0};
            b_sum <= b_sum + {bRawdata,2'b00};
            k_sum <= k_sum + din;
        end
    end
end

successive u_r_successive(
   .channel_sum    (wRedSum),
   .k_sum          (k_sum) ,
    .clk           (clk),
    .rst_n         (rst_n),
    .en_flag       (wComplete),

    .gain           (r_gain_cal),
    .gain_ready     (channel_ready[0])    
);

successive u_g_successive(
   .channel_sum    (wGreSum),
   .k_sum          (k_sum) ,
    .clk           (clk),
    .rst_n         (rst_n),
    .en_flag       (wComplete),

    .gain           (g_gain_cal),
    .gain_ready     (channel_ready[1])    
);

successive u_b_successive(
   .channel_sum    (wBluSum),
   .k_sum          (k_sum) ,
    .clk           (clk),
    .rst_n         (rst_n),
    .en_flag       (wComplete),

    .gain           (b_gain_cal),
    .gain_ready     (channel_ready[2])    
);

assign gain_ready = channel_ready[0]&channel_ready[1]&channel_ready[2];

endmodule