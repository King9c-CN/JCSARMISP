module makstb ();
    
reg clk;
reg rst_n;
reg dataEn;
wire [15:0] Dout1;
wire [15:0] Dout2;
wire [15:0] Dout3;

conv_mask6 u_conv_mask6(
    .clk                    ( clk                    ),
    .rst_n                  ( rst_n                  ),
    .dataEn                 ( dataEn                 ),
    .pix_6_weight0          ( 16'hFFF0         ),
    .pix_2_weight0          ( 16'hFFF0          ),
    .pix_2_weight1          ( 16'hFFF0          ),
    .pix_2_weight2          ( 16'hFFF0          ),
    .pix_2_weight3          ( 16'hFFF0          ),
    .pix_1_and_half_weight0 ( 16'h0 ),
    .pix_1_and_half_weight1 ( 16'h0 ),
    .pix_1_and_half_weight2 ( 16'h0 ),
    .pix_1_and_half_weight3 ( 16'h0 ),
    .Dout                   ( Dout1                   )
);

conv_mask5 u_conv_mask5(
    .isp_clk          ( clk          ),
    .rst_n            ( rst_n            ),
    .dataEn           ( dataEn           ),
    .pix_5_weight0    ( 16'hFFF0    ),
    .pix_4_weight0    ( 16'hFFF0    ),
    .pix_4_weight1    ( 16'hFFF0     ),
    .pix_1_weight0    ( 16'h0   ),
    .pix_1_weight1    ( 16'h0    ),
    .pix_1_weight2    ( 16'h0   ),
    .pix_1_weight3    ( 16'h0   ),
    .pix_1_weight4    ( 16'h0    ),
    .pix_1_weight5    ( 16'h0    ),
    .pix_half_weight0 ( 16'hFFF0  ),
    .pix_half_weight1 ( 16'hFFF0  ),
    .Dout             ( Dout2             )
);

conv_mask4 u_conv_mask4(
    .isp_clk       ( clk       ),
    .rst_n         ( rst_n         ),
    .pix_4_weight  ( 16'hFFF0 ),
    .pix_2_weight1 ( 16'hFFF0 ),
    .pix_2_weight2 ( 16'hFFF0 ),
    .pix_2_weight3 ( 16'hFFF0 ),
    .pix_2_weight4 ( 16'hFFF0 ),
    .pix_1_weight1 ( 16'h0 ),
    .pix_1_weight2 ( 16'h0),
    .pix_1_weight3 ( 16'h0 ),
    .pix_1_weight4 ( 16'h0 ),
    .dataEn        ( dataEn        ),
    .Dout          ( Dout3        )
);

initial begin
    clk = 'b0;
    forever begin
        #5
        clk = ~clk;
    end
end

initial begin
    rst_n = 'b1;
    #20
    rst_n = 'b0;
    #20 
    rst_n = 'b1;
    dataEn = 'b1;
end
endmodule