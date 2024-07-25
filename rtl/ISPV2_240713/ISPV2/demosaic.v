module demosaic (
    input wire          isp_clk,
    input wire          rst_n,
    input wire [15:0]   Din,
    input wire          dataEn,
    input wire [11:0]   h_active,
    input wire [11:0]   v_active,

    output wire [11:0]  redVec,
    output wire [11:0]  greVec,
    output wire [11:0]  bluVec,
    output wire         doutEn,
    output wire         frame_done

);

wire [15:0] slideWindowOut11;
wire [15:0] slideWindowOut12;
wire [15:0] slideWindowOut13;
wire [15:0] slideWindowOut14;
wire [15:0] slideWindowOut15;

wire [15:0] slideWindowOut21;
wire [15:0] slideWindowOut22;
wire [15:0] slideWindowOut23;
wire [15:0] slideWindowOut24;
wire [15:0] slideWindowOut25;

wire [15:0] slideWindowOut31;
wire [15:0] slideWindowOut32;
wire [15:0] slideWindowOut33;
wire [15:0] slideWindowOut34;
wire [15:0] slideWindowOut35;

wire [15:0] slideWindowOut41;
wire [15:0] slideWindowOut42;
wire [15:0] slideWindowOut43;
wire [15:0] slideWindowOut44;
wire [15:0] slideWindowOut45;

wire [15:0] slideWindowOut51;
wire [15:0] slideWindowOut52;
wire [15:0] slideWindowOut53;
wire [15:0] slideWindowOut54;
wire [15:0] slideWindowOut55;

wire [3:0]  centerPixBayer;
wire        byStIsR;
wire        byStIsGr;
wire        byStIsGb;
wire        byStIsB; 

wire        swOutEn;

wire [15:0] convMask4_out;
wire [15:0] convMask5_out0;
wire [15:0] convMask5_out1;
wire [15:0] convMask6_out;
wire [15:0] conv1x1_out;


slideWindow u_slideWindow(
    .isp_clk  ( isp_clk             ),
    .rst_n    ( rst_n               ),
    .dataIn   ( Din                 ),
    .dataEn   ( dataEn              ),
    .h_active ( h_active            ),
    .v_active ( v_active            ),
    .Dout11   ( slideWindowOut11    ),
    .Dout12   ( slideWindowOut12    ),
    .Dout13   ( slideWindowOut13    ),
    .Dout14   ( slideWindowOut14    ),
    .Dout15   ( slideWindowOut15    ),
    .Dout21   ( slideWindowOut21    ),
    .Dout22   ( slideWindowOut22    ),
    .Dout23   ( slideWindowOut23    ),
    .Dout24   ( slideWindowOut24    ),
    .Dout25   ( slideWindowOut25    ),
    .Dout31   ( slideWindowOut31    ),
    .Dout32   ( slideWindowOut32    ),
    .Dout33   ( slideWindowOut33    ),
    .Dout34   ( slideWindowOut34    ),
    .Dout35   ( slideWindowOut35    ),
    .Dout41   ( slideWindowOut41    ),
    .Dout42   ( slideWindowOut42    ),
    .Dout43   ( slideWindowOut43    ),
    .Dout44   ( slideWindowOut44    ),
    .Dout45   ( slideWindowOut45    ),
    .Dout51   ( slideWindowOut51    ),
    .Dout52   ( slideWindowOut52    ),
    .Dout53   ( slideWindowOut53    ),
    .Dout54   ( slideWindowOut54    ),
    .Dout55   ( slideWindowOut55    ),
    .outEn    ( swOutEn             ),
    .endFlag  ( frame_done          )
);

assign centerPixBayer = slideWindowOut33[3:0];
assign byStIsGb = centerPixBayer[0];
assign byStIsB = centerPixBayer[1];
assign byStIsR = centerPixBayer[2];
assign byStIsGr = centerPixBayer[3];

conv_mask4 u_conv_mask4(
    .isp_clk       ( isp_clk                            ),
    .rst_n         ( rst_n                              ),
    .pix_4_weight  ( slideWindowOut33                   ),
    .pix_2_weight1 ( slideWindowOut32                   ),
    .pix_2_weight2 ( slideWindowOut34                   ),
    .pix_2_weight3 ( slideWindowOut23                   ),
    .pix_2_weight4 ( slideWindowOut43                   ),
    .pix_1_weight1 ( slideWindowOut13                   ),
    .pix_1_weight2 ( slideWindowOut31                   ),
    .pix_1_weight3 ( slideWindowOut35                   ),
    .pix_1_weight4 ( slideWindowOut53                   ),
    .dataEn        ( swOutEn&(byStIsB|byStIsR)          ),
    .Dout          ( convMask4_out                      )
);

conv_mask5 u0_conv_mask5(
    .isp_clk          ( isp_clk                     ),
    .rst_n            ( rst_n                       ),
    .dataEn           ( swOutEn&(byStIsGb|byStIsGr) ),
    .pix_5_weight0    ( slideWindowOut33            ),
    .pix_4_weight0    ( slideWindowOut32            ),
    .pix_4_weight1    ( slideWindowOut34            ),
    .pix_1_weight0    ( slideWindowOut31            ),
    .pix_1_weight1    ( slideWindowOut35            ),
    .pix_1_weight2    ( slideWindowOut22            ),
    .pix_1_weight3    ( slideWindowOut24            ),
    .pix_1_weight4    ( slideWindowOut42            ),
    .pix_1_weight5    ( slideWindowOut44            ),
    .pix_half_weight0 ( slideWindowOut31            ),
    .pix_half_weight1 ( slideWindowOut35            ),
    .Dout             ( convMask5_out0              )
);

conv_mask5 u1_conv_mask5(
    .isp_clk          ( isp_clk                     ),
    .rst_n            ( rst_n                       ),
    .dataEn           ( swOutEn&(byStIsGb|byStIsGr) ),
    .pix_5_weight0    ( slideWindowOut33            ),
    .pix_4_weight0    ( slideWindowOut43            ),
    .pix_4_weight1    ( slideWindowOut23            ),
    .pix_1_weight0    ( slideWindowOut13            ),
    .pix_1_weight1    ( slideWindowOut53            ),
    .pix_1_weight2    ( slideWindowOut22            ),
    .pix_1_weight3    ( slideWindowOut24            ),
    .pix_1_weight4    ( slideWindowOut42            ),
    .pix_1_weight5    ( slideWindowOut44            ),
    .pix_half_weight0 ( slideWindowOut31            ),
    .pix_half_weight1 ( slideWindowOut35            ),
    .Dout             ( convMask5_out1              )
);

conv_mask6 u_conv_mask6(
    .clk                    ( isp_clk                   ),
    .rst_n                  ( rst_n                     ),
    .dataEn                 ( swOutEn&(byStIsB|byStIsR) ),
    .pix_6_weight0          ( slideWindowOut33          ),
    .pix_2_weight0          ( slideWindowOut22          ),
    .pix_2_weight1          ( slideWindowOut24          ),
    .pix_2_weight2          ( slideWindowOut42          ),
    .pix_2_weight3          ( slideWindowOut44          ),
    .pix_1_and_half_weight0 ( slideWindowOut13          ),
    .pix_1_and_half_weight1 ( slideWindowOut31          ),
    .pix_1_and_half_weight2 ( slideWindowOut35          ),
    .pix_1_and_half_weight3 ( slideWindowOut53          ),
    .Dout                   ( convMask6_out             )
);

conv1x1 u_conv1x1(
    .Din    ( slideWindowOut33              ),
    .clk    ( isp_clk                       ),
    .rst_n  ( rst_n                         ),
    .dataEn ( swOutEn                        ),
    .Dout   ( conv1x1_out                   ),
    .DoutEn ( doutEn                        )
);

assign redVec = conv1x1_out[2]? conv1x1_out[15:4] : conv1x1_out[1]? convMask6_out[15:4] : conv1x1_out[0]? convMask5_out1[15:4] : convMask5_out0[15:4];
assign bluVec = conv1x1_out[1]? conv1x1_out[15:4] : conv1x1_out[2]? convMask6_out[15:4] : conv1x1_out[0]? convMask5_out0[15:4] : convMask5_out1[15:4];
assign greVec = conv1x1_out[0]? conv1x1_out[15:4] : conv1x1_out[3]? conv1x1_out[15:4] : convMask4_out[15:4];

endmodule