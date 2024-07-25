module gamma (
    input wire [11:0] r_data,
    input wire [11:0] g_data,
    input wire [11:0] b_data,
    input wire        clk,
    input wire        rst_n,
    input wire [2:0] gamma_coe, // 001: 1.4 gamma || 010: 1.6 gamma || 100:1.8 gamma || 000: no gamma 
    input wire        dataEn,

    output wire [7:0] r_out,
    output wire [7:0] g_out,
    output wire [7:0] b_out,
    output wire       outEn 
);
reg         rDataEn;
reg [7:0]   rRedIn;
reg [7:0]   rGreIn;
reg [7:0]   rBluIn;

wire [7:0]  red_in;
wire [7:0]  gre_in;
wire [7:0]  blu_in;

wire [7:0]  red_00_out;
wire [7:0]  red_14_out;
wire [7:0]  red_16_out;
wire [7:0]  red_18_out;

wire [7:0]  gre_00_out;
wire [7:0]  gre_14_out;
wire [7:0]  gre_16_out;
wire [7:0]  gre_18_out;

wire [7:0]  blu_00_out;
wire [7:0]  blu_14_out;
wire [7:0]  blu_16_out;
wire [7:0]  blu_18_out;

assign red_in = (r_data[3:0]>9)? r_data[11:4]+1'b1 : r_data[11:4];
assign gre_in = (g_data[3:0]>9)? g_data[11:4]+1'b1 : g_data[11:4];
assign blu_in = (b_data[3:0]>9)? b_data[11:4]+1'b1 : b_data[11:4];

assign red_00_out = rRedIn;
assign gre_00_out = rGreIn;
assign blu_00_out = rBluIn;

rom_14gamma u_red_rom14gamma(
    .clk        (clk),
    .addr       (red_in),
    .data       (red_14_out)
);

rom_14gamma u_gre_rom14gamma(
    .clk        (clk),
    .addr       (gre_in),
    .data       (gre_14_out)
);

rom_14gamma u_blu_rom14gamma(
    .clk        (clk),
    .addr       (blu_in),
    .data       (blu_14_out)
); 

rom_16gamma u_red_rom16gamma(
    .clk        (clk),
    .addr       (red_in),
    .data       (red_16_out)
);

rom_16gamma u_gre_rom16gamma(
    .clk        (clk),
    .addr       (gre_in),
    .data       (gre_16_out)
);

rom_16gamma u_blu_rom16gamma(
    .clk        (clk),
    .addr       (blu_in),
    .data       (blu_16_out)
); 

rom_18gamma u_red_rom18gamma(
    .clk        (clk),
    .addr       (red_in),
    .data       (red_18_out)
);

rom_18gamma u_gre_rom18gamma(
    .clk        (clk),
    .addr       (gre_in),
    .data       (gre_18_out)
);

rom_18gamma u_blu_rom18gamma(
    .clk        (clk),
    .addr       (blu_in),
    .data       (blu_18_out)
); 

always @(posedge clk) begin
    rDataEn <= dataEn;
    rRedIn <= r_data[11:4];
    rGreIn <= g_data[11:4];
    rBluIn <= b_data[11:4];
end

assign r_out = gamma_coe[0]? red_14_out : 
               gamma_coe[1]? red_16_out :
               gamma_coe[2]? red_18_out : red_00_out;

assign g_out = gamma_coe[0]? gre_14_out : 
               gamma_coe[1]? gre_16_out :
               gamma_coe[2]? gre_18_out : gre_00_out;

assign b_out = gamma_coe[0]? blu_14_out : 
               gamma_coe[1]? blu_16_out :
               gamma_coe[2]? blu_18_out : blu_00_out;

assign outEn = rDataEn;               
endmodule