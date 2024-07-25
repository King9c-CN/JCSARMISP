module successive (
    input wire [63:0]   channel_sum,
    input wire [63:0]   k_sum,
    input wire          clk,
    input wire          rst_n,
    input wire          en_flag,

    output wire [7:0]   gain,
    output wire         gain_ready
);

reg [7:0]   rGain;
reg [63:0]  rChannelSum;
reg [63:0]  rK_Sum;
reg [7:0]   state;
reg [7:0]   state_next;
reg         rGainReady;

wire k_gt_sum[7:0];
wire [31:0] div_cSum [6:0];

assign k_gt_sum[7]=(rK_Sum>rChannelSum)? 1'b1 : 1'b0;
assign k_gt_sum[6]=(rK_Sum>div_cSum[6])? 1'b1 : 1'b0;
assign k_gt_sum[5]=(rK_Sum>div_cSum[5])? 1'b1 : 1'b0;
assign k_gt_sum[4]=(rK_Sum>div_cSum[4])? 1'b1 : 1'b0;
assign k_gt_sum[3]=(rK_Sum>div_cSum[3])? 1'b1 : 1'b0;
assign k_gt_sum[2]=(rK_Sum>div_cSum[2])? 1'b1 : 1'b0;
assign k_gt_sum[1]=(rK_Sum>div_cSum[1])? 1'b1 : 1'b0;
assign k_gt_sum[0]=(rK_Sum>div_cSum[0])? 1'b1 : 1'b0;

assign div_cSum[6] = {1'b0,rChannelSum[31:1]};
assign div_cSum[5] = {2'b00,rChannelSum[31:2]};
assign div_cSum[4] = {3'b000,rChannelSum[31:3]};
assign div_cSum[3] = {4'b0000,rChannelSum[31:4]};
assign div_cSum[2] = {5'b00000,rChannelSum[31:5]};
assign div_cSum[1] = {6'b000000,rChannelSum[31:6]};
assign div_cSum[0] = {7'b000_0000,rChannelSum[31:7]};


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= 8'b1000_0001;
    end
    else if (en_flag) begin
        state <= state_next;
    end
end

always @(*) begin
    case (state)
        8'b1000_0001:state_next=8'b1000_0000;
        8'b1000_0000:state_next=8'b0100_0000;
        8'b0100_0000:state_next=8'b0010_0000;
        8'b0010_0000:state_next=8'b0001_0000;
        8'b0001_0000:state_next=8'b0000_1000;
        8'b0000_1000:state_next=8'b0000_0100;
        8'b0000_0100:state_next=8'b0000_0010;
        8'b0000_0010:state_next=8'b0000_0001;
        8'b0000_0001:state_next=8'b0000_0000;
        8'b0000_0000:state_next=8'b0000_0000; 
        default: state_next=8'b0000_0000;
    endcase    
end

always @(posedge clk) begin
    if(state == 8'b1000_0001) begin
        rGain <= 8'b0000_0000;
        rK_Sum <= k_sum;
        rChannelSum <= channel_sum;
        rGainReady <= 1'b0;
    end
    else if(state == 8'b1000_0000) begin
        if (k_gt_sum[7]) begin
            rK_Sum <= rK_Sum-rChannelSum;
            rGain <= 8'b1000_0000;
            rGainReady <= 1'b0;
        end
    end
    else if(state == 8'b0100_0000) begin
        if (k_gt_sum[6]) begin
            rK_Sum <= rK_Sum-div_cSum[6];
            rGain <= {rGain[7],7'b100_0000};
            rGainReady <= 1'b0;
        end
    end
    else if(state == 8'b0010_0000) begin
        if (k_gt_sum[5]) begin
            rK_Sum <= rK_Sum-div_cSum[5];
            rGain <= {rGain[7:6],6'b10_0000};
            rGainReady <= 1'b0;
        end
    end
    else if(state == 8'b0001_0000) begin
        if (k_gt_sum[4]) begin
            rK_Sum <= rK_Sum-div_cSum[4];
            rGain <= {rGain[7:5],5'b1_0000};
            rGainReady <= 1'b0;
        end
    end
    else if(state == 8'b0000_1000) begin
        if (k_gt_sum[3]) begin
            rK_Sum <= rK_Sum-div_cSum[3];
            rGain <= {rGain[7:4],4'b1000};
            rGainReady <= 1'b0;
        end
    end
    else if(state == 8'b0000_0100) begin
        if (k_gt_sum[2]) begin
            rK_Sum <= rK_Sum-div_cSum[2];
            rGain <= {rGain[7:3],3'b100};
            rGainReady <= 1'b0;
        end
    end
    else if(state == 8'b0000_0010) begin
        if (k_gt_sum[1]) begin
            rK_Sum <= rK_Sum-div_cSum[1];
            rGain <= {rGain[7:2],2'b10};
            rGainReady <= 1'b0;
        end
    end
    else if(state == 8'b0000_0001) begin
        if (k_gt_sum[0]) begin
            rK_Sum <= rK_Sum-div_cSum[0];
            rGain <= {rGain[7:1],1'b1};
            rGainReady <= 1'b0;
        end
    end
    else if (state == 8'b0000_0000) begin
        rGainReady <= 1'b1;
    end
    else begin
    rGain <= 8'b1000_0000;
    rGainReady <= 1'b0;
    end
end

assign gain = rGain;
assign gain_ready = rGainReady;

endmodule