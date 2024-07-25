module colorCorrection (
    input wire [7:0]    redGain,
    input wire [7:0]    bluGain,
    input wire [7:0]    greGain,
    input wire          clk,
    input wire          rst_n,
    input wire [15:0]   Din,
    input wire          dataEn,

    output wire [15:0]  Dout,
    output wire         outEn
);

//reg define
reg [27:0] step0_value0;
reg [27:0] step0_value1;
reg [27:0] step0_value2;
reg [27:0] step0_value3;
reg [27:0] step1_value0;
reg [27:0] step1_value1;
reg [27:0] step2_value0;
reg [3:0]  step0_bayerSt;
reg [3:0]  step1_bayerSt;
reg [3:0]  step2_bayerSt;

//wire define
wire [31:0] expandData;
wire [27:0] redGainData[7:0];
wire [27:0] greGainData[7:0];
wire [27:0] bluGainData[7:0];
wire [27:0] input_value0;
wire [27:0] input_value1;
wire [27:0] input_value2;
wire [27:0] input_value3;
wire [27:0] input_value4;
wire [27:0] input_value5;
wire [27:0] input_value6;
wire [27:0] input_value7;
wire [11:0] postGainData;
wire [3:0]  bayerId;


assign expandData = {{8{1'b0}},Din[15:4],{8{1'b0}},Din[3:0]};

assign redGainData[7] = redGain[7]? expandData[31:4] : 28'h0;         
assign redGainData[6] = redGain[6]? {{1{1'b0}},expandData[31:5]} : 28'h0;
assign redGainData[5] = redGain[5]? {{2{1'b0}},expandData[31:6]} : 28'h0;
assign redGainData[4] = redGain[4]? {{3{1'b0}},expandData[31:7]} : 28'h0;
assign redGainData[3] = redGain[3]? {{4{1'b0}},expandData[31:8]} : 28'h0;
assign redGainData[2] = redGain[2]? {{5{1'b0}},expandData[31:9]} : 28'h0;
assign redGainData[1] = redGain[1]? {{6{1'b0}},expandData[31:10]} : 28'h0;
assign redGainData[0] = redGain[0]? {{15{1'b0}},Din[15:4],{1{1'b0}}} : 28'h0;

assign greGainData[7] = greGain[7]? expandData[31:4] : 28'h0;         
assign greGainData[6] = greGain[6]? {{1{1'b0}},expandData[31:5]} : 28'h0;
assign greGainData[5] = greGain[5]? {{2{1'b0}},expandData[31:6]} : 28'h0;
assign greGainData[4] = greGain[4]? {{3{1'b0}},expandData[31:7]} : 28'h0;
assign greGainData[3] = greGain[3]? {{4{1'b0}},expandData[31:8]} : 28'h0;
assign greGainData[2] = greGain[2]? {{5{1'b0}},expandData[31:9]} : 28'h0;
assign greGainData[1] = greGain[1]? {{6{1'b0}},expandData[31:10]} : 28'h0;
assign greGainData[0] = greGain[0]? {{15{1'b0}},Din[15:4],{1{1'b0}}} : 28'h0;

assign bluGainData[7] = bluGain[7]? expandData[31:4] : 28'h0;         
assign bluGainData[6] = bluGain[6]? {{1{1'b0}},expandData[31:5]} : 28'h0;
assign bluGainData[5] = bluGain[5]? {{2{1'b0}},expandData[31:6]} : 28'h0;
assign bluGainData[4] = bluGain[4]? {{3{1'b0}},expandData[31:7]} : 28'h0;
assign bluGainData[3] = bluGain[3]? {{4{1'b0}},expandData[31:8]} : 28'h0;
assign bluGainData[2] = bluGain[2]? {{5{1'b0}},expandData[31:9]} : 28'h0;
assign bluGainData[1] = bluGain[1]? {{6{1'b0}},expandData[31:10]} : 28'h0;
assign bluGainData[0] = bluGain[0]? {{15{1'b0}},Din[15:4],{1{1'b0}}} : 28'h0;

assign input_value7 = expandData[1]? bluGainData[7] : 
                      expandData[2]? redGainData[7] : greGainData[7];
assign input_value6 = expandData[1]? bluGainData[6] : 
                      expandData[2]? redGainData[6] : greGainData[6];
assign input_value5 = expandData[1]? bluGainData[5] : 
                      expandData[2]? redGainData[5] : greGainData[5]; 
assign input_value4 = expandData[1]? bluGainData[4] : 
                      expandData[2]? redGainData[4] : greGainData[4];                                           
assign input_value3 = expandData[1]? bluGainData[3] : 
                      expandData[2]? redGainData[3] : greGainData[3];
assign input_value2 = expandData[1]? bluGainData[2] : 
                      expandData[2]? redGainData[2] : greGainData[2];
assign input_value1 = expandData[1]? bluGainData[1] : 
                      expandData[2]? redGainData[1] : greGainData[1];
assign input_value0 = expandData[1]? bluGainData[0] : 
                      expandData[2]? redGainData[0] : greGainData[0];


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        step0_value0 <= 28'h0;
        step0_value1 <= 28'h0;
        step0_value2 <= 28'h0;
        step0_value3 <= 28'h0;
        step0_bayerSt <= 4'h0;
    end
    else if(dataEn) begin
        step0_value0 <= input_value0 + input_value1;
        step0_value1 <= input_value2 + input_value3;
        step0_value2 <= input_value4 + input_value5;
        step0_value3 <= input_value6 + input_value7;
        step0_bayerSt <= expandData[3:0];
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        step1_value0 <= 28'h0;
        step1_value1 <= 28'h0;
        step1_bayerSt <= 4'h0;
    end
    else begin
        step1_value0 <= step0_value0 + step0_value1;
        step1_value1 <= step0_value2 + step0_value3;
        step1_bayerSt <= step0_bayerSt;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        step2_value0 <= 28'h0;
        step2_bayerSt <= 4'h0;
    end
    else begin
        step2_value0 <= step1_value0 + step1_value1;
        step2_bayerSt <= step1_bayerSt;
    end
end

reg [2:0] shift_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_reg <= 3'b0;
    end
    else begin
        shift_reg <= {shift_reg[1:0], dataEn};
    end
end

assign outEn = shift_reg[2];

assign postGainData = step2_value0[20]? 12'hFFF : step2_value0[19:8];
assign bayerId = step2_bayerSt;

assign Dout = {postGainData, bayerId};

endmodule