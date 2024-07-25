module calFrames (
    input wire [15:0]   framesCnt,
    input wire          ispclk,
    input wire          rst_n,

    output reg [6:0]    seg0,
    output reg [6:0]    seg1,
    output reg [6:0]    seg2,
    output reg [6:0]    seg3,
    output reg          dp
);
    reg [31:0] timer;
    reg [7:0]  frameNow;
    reg [7:0]  frameVar;

    always @(posedge ispclk or negedge rst_n) begin
        if(!rst_n)
        timer <= 'h0;
        else if (framesCnt > 0) begin
            if(timer == (32'd192000000-1'b1))
            timer <= 'h0;
            else
            timer <= timer + 1'b1;
        end
        else
        timer <= 'h0;
    end

    always @(posedge ispclk or negedge rst_n) begin
        if(!rst_n)begin
            frameNow <= 'h0;
            frameVar <= 'h0;
        end
        else if(timer == 1'b1) begin
            frameNow <= framesCnt;
            frameVar <= framesCnt - frameNow;
        end
    end

    always@* begin
        if(frameVar >= 8'd20)
        seg0 = 7'b1001111;
        else
        seg0 = 7'b0000001;
    end

    always @* begin
        case (frameVar)
            8'd29: seg1 = 7'b1001100;
            8'd28: seg1 = 7'b1001100;
            8'd27: seg1 = 7'b0000110;
            8'd26: seg1 = 7'b0000110;
            8'd25: seg1 = 7'b0010010;
            8'd24: seg1 = 7'b0010010;
            8'd23: seg1 = 7'b1001111;
            8'd22: seg1 = 7'b1001111;
            8'd21: seg1 = 7'b0000001;
            8'd20: seg1 = 7'b0000001;
            8'd19: seg1 = 7'b0000100;
            8'd18: seg1 = 7'b0000100;
            8'd17: seg1 = 7'b0000000;
            8'd16: seg1 = 7'b0000000;
            8'd15: seg1 = 7'b0001111;
            8'd14: seg1 = 7'b0001111;
            8'd13: seg1 = 7'b0100000;
            8'd12: seg1 = 7'b0100000;
            8'd11: seg1 = 7'b0100100;
            8'd10: seg1 = 7'b0100100;  
            default: seg1 = 7'd0;
        endcase
    end

    always @* begin
        
        if(frameVar[0] == 1'b1)
        seg2 = 7'b0100100;
        else
        seg2 = 7'b0000001;
    end


endmodule