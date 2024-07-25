module gamma (
    input wire clk,
    input wire rst_n,
    input wire [15:0] data_in,
    input wire clken,

    output wire [15:0] data_out,
    output wire out_en
);

wire [5:0] r_data_in;
wire [5:0] g_data_in;
wire [5:0] b_data_in;
wire [5:0] r_data_out;
wire [5:0] g_data_out;
wire [5:0] b_data_out;
reg         rOut_en;

assign r_data_in = {data_in[15:11], 1'b0};
assign g_data_in = data_in[10:5];
assign b_data_in = {data_in[4:0], 1'b0};

gamma_rom u_red_gamma_rom(
    .clk    (clk),
    .addr   (r_data_in),
    .out    (r_data_out)
);

gamma_rom u_green_gamma_rom(
    .clk    (clk),
    .addr   (g_data_in),
    .out    (g_data_out)
);

gamma_rom u_blue_gamma_rom(
    .clk    (clk),
    .addr   (b_data_in),
    .out    (b_data_out)
);

always @(posedge clk or negedge rst_n) begin
if(!rst_n)
rOut_en <= 1'b0;
else 
rOut_en <= clken;
end

assign data_out = {r_data_out[5:1], g_data_out, b_data_out[5:1]};
//assign data_out = {g_data_out[2:0],b_data_out[5:1],r_data_out[5:1],g_data_out[5:3] };

assign out_en = rOut_en;

endmodule