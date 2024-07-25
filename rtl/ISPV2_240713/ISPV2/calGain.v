module calGain (
    input wire [15:0]   Din,
    input wire          clk,
    input wire          rst_n,
    input wire          data_en,
    input wire          end_flag,  

    output wire [7:0]   rGain,
    output wire [7:0]   gGain,
    output wire [7:0]   bGain           
);

reg [63:0]  rSum;
reg [63:0]  gSum;
reg [63:0]  bSum;      
reg         frameEnd;

wire [63:0] kSumWt;
wire [63:0] rSumWt;
wire [63:0] gSumWt;
wire [63:0] bSumWt;

wire [15:0] redIn;
wire [15:0] greIn;
wire [15:0] bluIn;
wire [15:0] rawIn;

assign redIn = Din[2]? {Din[15:4], 4'h0} : 16'h0;
assign greIn = (Din[3]|Din[0])? {Din[15:4], 4'h0} : 16'h0;
assign bluIn = Din[1]? {Din[15:4], 4'h0} : 16'h0;
assign rawIn = {Din[15:4], 4'h0};

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rSum <= 'h0;
        gSum <= 'h0;
        bSum <= 'h0;
        frameEnd <= 'b0;
    end
    else if(data_en) begin
        if(~frameEnd) begin
        rSum <= rSum + redIn;
        gSum <= gSum + greIn;
        bSum <= bSum + bluIn;
        frameEnd <= end_flag;
        end
    end
end

assign rSumWt = 


endmodule