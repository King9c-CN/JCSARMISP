module AHBISPSYS (
  input wire HCLK,
  input wire HRESETn,
  input wire [31:0] HADDR,
  input wire [31:0] HWDATA,
  input wire HREADY,
  input wire HWRITE,
  input wire [1:0] HTRANS,
  input wire HSEL,
  input wire [2:0] HSIZE,
 
  
  output wire [31:0] HRDATA,
  output wire HREADYOUT,
// AHB-Lite inout port
  
  input wire ISPCLK,
  input wire [15:0] data_in,
  input wire fifo_empty,

  
  output wire [15:0] rgb_data_out,
  output wire        DoutEn,
  output wire [15:0] frames_cnt
);

//reg define
//AHB signal reg
reg [31:0] rHADDR;
reg [1:0]  rHTRANS;
reg [2:0]  rHSIZE;
reg        rHSEL;
reg        rHWRITE;

//MODULE param_set reg
reg [31:0] rParamRDATA;
reg [3:0]  rParamSel;



//wire define
//MODULE param_set wire
wire [31:0] wParamRDATA;
wire [7:0]  wRedGain;
wire [7:0]  wGreGain;
wire [7:0]  wBluGain;
wire [11:0] wHActive;
wire [11:0] wVActive;
wire [3:0]  wBayerStart;
wire [2:0]  wIspMode;
wire [2:0]  wGammaCoe;
wire [3:0]  wParamSel;
wire [3:0]  wParamSel_in;

//main block
always @(posedge HCLK or negedge HRESETn) begin
  if (!HRESETn) begin
    rHADDR <= 32'h0;
    rHTRANS <= 2'b00;
    rHSIZE <= 2'b00;
    rHWRITE <= 1'b0;
    rHSEL <= 1'b0;
  end
  else if(HREADY) begin
    rHADDR <= HADDR;
    rHTRANS <= HTRANS;
    rHWRITE <= HWRITE;
    rHSIZE <= HSIZE;
    rHSEL <= HSEL;
  end
end

assign wParamSel_in = rParamSel;
assign wParamSel = (~rHSEL)? 4'b0000 : 
                   (rHADDR[11:0] == 12'h0)? 4'b0001 :
                   (rHADDR[11:0] == 12'h4)? 4'b0011 :
                   (rHADDR[11:0] == 12'h8)? 4'b0111 :
                   (rHADDR[11:0] == 12'hC)? 4'b1111 : 4'b0000;
assign HREADYOUT = 1'b1;

always @(posedge HCLK or negedge HRESETn) begin
  if(!HRESETn) begin
    rParamRDATA <= 32'h0;
    rParamSel <= 4'h0;
  end
  else if(rHWRITE & rHTRANS[1] & rHSEL & wParamSel[0]) begin
    rParamRDATA <= HWDATA;
    rParamSel <= wParamSel;
  end
  else begin
    rParamRDATA <= 32'h0;
    rParamSel <=  4'h0;
  end
end

param_set u_param_set(
    .HCLK       ( HCLK       ),
    .param_sel  ( wParamSel_in  ),
    .rd_data    ( rParamRDATA    ),
    .HRESETn    ( HRESETn    ),
    .redGain    ( wRedGain    ),
    .greGain    ( wGreGain    ),
    .bluGain    ( wBluGain    ),
    .hActive    ( wHActive    ),
    .vActive    ( wVActive    ),
    .bayerStart ( wBayerStart ),
    .isp_mode   ( wIspMode   ),
    .gamma_coe  ( wGammaCoe  )
);

ISP_pipeline u_ISP_pipeline(
    .isp_data_in ( data_in ),
    .h_active_in ( wHActive ),
    .v_active_in ( wVActive ),
    .bayerStart  ( wBayerStart  ),
    .isp_clk     ( ISPCLK     ),
    .data_en     ( ~fifo_empty     ),
    .rst_n       ( HRESETn       ),
    .mode_sel    ( wIspMode    ),
    .gamma_coe   ( wGammaCoe   ),
    .r_gain      ( wRedGain      ),
    .g_gain      ( wGreGain      ),
    .b_gain      ( wBluGain      ),
    .rgb_out     ( rgb_data_out     ),
    .ips_out_en  ( DoutEn  ),
    .frames_cnt  ( frames_cnt  )
);


    
endmodule