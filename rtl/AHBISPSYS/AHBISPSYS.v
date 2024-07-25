module AHBISP (
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

  input wire [7:0] data_in,
  input wire fifo_empty,

  output wire fifo_rd,
  output wire [31:0] fb_addr_out,
  output wire [15:0] rgb_data_out,
  output wire fb_sel,
  output wire dout_en,
  output wire isp_int
// ISP interact port with fb
);
  reg [31:0]rHWDATA;
  reg rHSEL;
  reg rHSEL1;

  reg [31:0] rHADDR1;
  reg [31:0] rHADDR2;
  reg [1:0] rHTRANS;
  reg rHWRITE;
  reg [2:0] rHSIZE;
  reg rFIFO_rd;
  reg [15:0] sw_state;
  reg [15:0] sw_state_next;

  reg [3:0]  bayer_state_start;
  reg [11:0] r_h_active0;
  reg [11:0] r_v_active0;
  reg [11:0] r_h_active1;
  reg [11:0] r_v_active1;
  reg [11:0] r_h_active2;
  reg [11:0] r_v_active2;
  reg        rCalculatePoll;
  wire [3:0] wBayer_state_start;
  wire [2:0] r_fb_sel;
  wire [11:0] h_active;
  wire [11:0] v_active;
  wire bypas_mod;
  wire bypas_clken;
  wire isp_clken;
  wire end_flag_isp;
  wire end_flag_bypass;
  wire end_flag;
  wire [7:0] array_pix11;
  wire [7:0] array_pix12;
  wire [7:0] array_pix13;
  wire [7:0] array_pix14;
  wire [7:0] array_pix15;
  wire [7:0] array_pix21;
  wire [7:0] array_pix22;
  wire [7:0] array_pix23;
  wire [7:0] array_pix24;
  wire [7:0] array_pix25;
  wire [7:0] array_pix31;
  wire [7:0] array_pix32;
  wire [7:0] array_pix33;
  wire [7:0] array_pix34;
  wire [7:0] array_pix35;
  wire [7:0] array_pix41;
  wire [7:0] array_pix42;
  wire [7:0] array_pix43;
  wire [7:0] array_pix44;
  wire [7:0] array_pix45;
  wire [7:0] array_pix51;
  wire [7:0] array_pix52;
  wire [7:0] array_pix53;
  wire [7:0] array_pix54;
  wire [7:0] array_pix55;
  wire sw_out_en;
  wire [3:0] sw_bayer_state;
  wire [15:0] rgb_data_dm;
  wire [15:0] rgb_data_isp;
  wire [15:0] rgb_data_bypas;
  wire dm_out_en;
  wire bp_out_en;
  wire gamma_out_en;
  wire [31:0] bp_addr_out;

  wire [7:0]cc_dout;
  wire cc_out_en;

  wire calclken;
  wire gain_config;//synthesis keep
  reg  [7:0] rDirect_red_gain;  //synthesis keep
  reg  [7:0] rDirect_gre_gain;//synthesis keep
  reg  [7:0] rDirect_blu_gain;//synthesis keep
  reg config_poll;
  wire [7:0] wDirect_red_gain;
  wire [7:0] wDirect_gre_gain;
  wire [7:0] wDirect_blu_gain;
  wire wConfig_poll;

  wire [7:0] redGainISP;//synthesis keep
  wire [7:0] greGainISP;//synthesis keep
  wire [7:0] bluGainISP;//synthesis keep
  wire  gainReady;

  assign wDirect_red_gain = rDirect_red_gain;
  assign wDirect_gre_gain = rDirect_gre_gain;
  assign wDirect_blu_gain = rDirect_blu_gain;
  assign wConfig_poll = config_poll;
  
  

  always @(posedge HCLK or negedge HRESETn)
  begin
	 if(!HRESETn)
	 begin
		rHSEL	<= 1'b0;
        rHSEL1	<= 1'b0;

		rHADDR1	<= 32'h0;
		rHADDR2 <= 32'h0;
		rHTRANS	<= 2'b00;
		rHWRITE	<= 1'b0;
		rHSIZE	<= 3'b000;
        rHWDATA <= 32'b0;
	 end
    else if(HREADY && HSEL)
    begin
        rHSEL1	<= HSEL;
        rHSEL	<= HSEL;

		rHTRANS	<= HTRANS;
		rHWRITE	<= HWRITE;
		rHSIZE	<= HSIZE;
       // rHWDATA <= HWDATA;
       if ((HADDR[11:0] == 12'hC) | (HADDR[11:0] == 12'h14)) begin
           rHADDR1 <= HADDR;
       end
       else begin
           rHADDR1 <= HADDR;
           rHADDR2 <= HADDR;
       end
    end
    else if(rHSEL1)   begin rHWDATA <= HWDATA; rHSEL1<=1'b0; end

  end

  
  assign r_fb_sel = (rHADDR2[11:0] == 12'h0)? 3'b001 : 
                    (rHADDR2[11:0] == 12'h4)? 3'b010 : 
                    (rHADDR2[11:0] == 12'h8)? 3'b011 : 
                    (rHADDR2[11:0] == 12'h14)?3'b100 : 3'b000;
  assign gain_config = (rHADDR2[11:0] == 12'h18)? 1'b1 : 1'b0;
  assign bypas_mod = r_fb_sel[0] & r_fb_sel[1];
  assign h_active = r_fb_sel[0]? r_h_active0 :
                    r_fb_sel[1]? r_h_active1 : 
                    r_fb_sel[2]? r_h_active2 : 12'h0;
  assign v_active = r_fb_sel[0]? r_v_active0 :
                    r_fb_sel[1]? r_v_active1 :
                    r_fb_sel[2]? r_v_active2 : 12'h0;
  
  always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        r_h_active0 <= 12'h10;
        r_h_active1 <= 12'h10;
        r_v_active0 <= 12'h10;
        r_v_active1 <= 12'h10;
        rFIFO_rd <= 1'b0;
    end
    else if(r_fb_sel[0] && rHWRITE && rHTRANS[1] && rHSEL) begin
        bayer_state_start <= rHWDATA[31:28];
        r_h_active0 <= rHWDATA[11:0];
        r_v_active0 <= rHWDATA[23:12];
        rFIFO_rd <= 1'b1;
    end
    else if (r_fb_sel[1] && rHWRITE && rHTRANS[1] && rHSEL) begin
        bayer_state_start <= rHWDATA[31:28];
        r_h_active1 <= rHWDATA[11:0];
        r_v_active1 <= rHWDATA[23:12];
        rFIFO_rd <= 1'b1;
    end
    else if (r_fb_sel[2] && rHWRITE && rHTRANS[1] && rHSEL) begin
      bayer_state_start <= rHWDATA[31:28];
      r_h_active2 <= rHWDATA[12:1];
      r_v_active2 <= rHWDATA[24:13];
      rCalculatePoll <= rHWDATA[0];
    end
    else if (gain_config && rHWRITE && rHTRANS[1] && rHSEL) begin
      rDirect_red_gain <= rHWDATA[31:24];
      rDirect_gre_gain <= rHWDATA[23:16];
      rDirect_blu_gain <= rHWDATA[15:8];
      config_poll <= rHWDATA[0];
    end
    else if (end_flag)
    rFIFO_rd <= 1'b0;
  end

  always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn) begin
        sw_state <= 16'h1D1E;
    end
    else begin
        sw_state <= sw_state_next;
    end
  end

  always @* begin
    sw_state_next = sw_state;
    case (sw_state_next)
        16'h1D1E: sw_state_next = isp_clken? 16'h9C9C : 
                                  bypas_mod? 16'hB485 : 16'h1D1E; 
        16'hB485: sw_state_next = isp_clken? 16'h9C9C :
                                  end_flag?  16'hD02E : 16'hB485;
        16'h9C9C: sw_state_next = end_flag?  16'hD02E : 
                                  bypas_mod? 16'hB485 : 16'h9C9C;
        16'hD02E: sw_state_next = isp_clken? 16'h9C9C : 
                                  bypas_mod? 16'hB485 : 16'hD02E;
        default: sw_state_next = 16'h1D1E;
    endcase
  end

  assign HRDATA = (rHADDR1[7:0]==8'h0)? {bayer_state_start, 4'b0000, r_h_active0, r_v_active0} : 
                  (rHADDR1[7:0]==8'h4)? {bayer_state_start, 4'b0000, r_h_active1, r_v_active1} :
                  (rHADDR1[7:0]==8'h8)? {bayer_state_start, 4'b0000, r_h_active0, r_v_active0} : 
                  (rHADDR1[7:0]==8'hC)? {16'h0000, sw_state} :
                  (rHADDR1[7:0]==8'h10)? rHWDATA : 
                  (rHADDR1[7:0]==8'h14)? {redGainISP, greGainISP, bluGainISP, 7'd0, gainReady} : rHWDATA;

  assign HREADYOUT = (rHADDR1[7:0]>8'h8)? (sw_state[15] | r_fb_sel[2] | gainReady) : (r_fb_sel[0] | r_fb_sel[1] );



  assign fifo_rd = rFIFO_rd;
  assign isp_clken = fifo_rd & (~fifo_empty) & (~bypas_mod);
  assign bypas_clken = fifo_rd & (~fifo_empty) & bypas_mod;
  assign calclken = (~fifo_empty) & r_fb_sel[2];
  assign wBayer_state_start = bayer_state_start;
  assign end_flag = (end_flag_isp&(r_fb_sel[0]^r_fb_sel[1])) | (end_flag_bypass&bypas_mod);

  bypass u_bypass (
    .clk                (HCLK),
    .rst_n              (HRESETn),
    .din                (data_in),
    .h_active_in        (h_active),
    .v_active_in        (v_active),
    .clken              (bypas_clken),
    .dout               (rgb_data_bypas),
    .bayer_state_start  (wBayer_state_start),
    .end_flag           (end_flag_bypass),
    .dout_en            (bp_out_en),
    .addr_out           (bp_addr_out)
  );

cal_gain u_cal_gain(
    .clk               ( HCLK               ),
    .rst_n             ( HRESETn             ),
    .clken             ( calclken             ),
    .din               ( data_in               ),
    .bayer_state_start ( wBayer_state_start ),
    .h_active_in       ( h_active       ),
    .v_active_in       ( v_active       ),
    .r_gain_in         ( wDirect_red_gain         ),
    .g_gain_in         ( wDirect_gre_gain         ),
    .b_gain_in         ( wDirect_blu_gain         ),
    .sel               ( wConfig_poll               ),
    .direct            ( wConfig_poll/*gain_config */           ),
    .r_gain_out        ( redGainISP        ),
    .g_gain_out        ( greGainISP        ),
    .b_gain_out        ( bluGainISP        ),
    .out_en            ( gainReady            )
);


CC u_CC(
    .clk                 (HCLK),
    .rst_n       	     (HRESETn),
    .din				 (data_in),
    .h_active_in         (h_active),
    .v_active_in		 (v_active),
    .clken				 (isp_clken),
    .bayer_state_start	 (wBayer_state_start),
    .r_gain_in		     (redGainISP),
    .g_gain_in			 (greGainISP),
    .b_gain_in			 (bluGainISP),
    .dout				 (cc_dout),
    .out_en				 (cc_out_en)
);

  slidingWindow_5X5 u_5X5Window (
    .clk            (HCLK),
    .rst_n          (HRESETn),
    .din            (cc_dout),
    .h_active_in    (h_active),
    .v_active_in    (v_active),
    .clken          (cc_out_en),
    .bayer_state_start (wBayer_state_start),

    .dout_11        (array_pix11),
    .dout_12        (array_pix12),
    .dout_13        (array_pix13),
    .dout_14        (array_pix14),
    .dout_15        (array_pix15),
    .dout_21        (array_pix21),
    .dout_22        (array_pix22),
    .dout_23        (array_pix23),
    .dout_24        (array_pix24),
    .dout_25        (array_pix25),
    .dout_31        (array_pix31),
    .dout_32        (array_pix32),
    .dout_33        (array_pix33),        
    .dout_34        (array_pix34),
    .dout_35        (array_pix35),
    .dout_41        (array_pix41),
    .dout_42        (array_pix42),
    .dout_43        (array_pix43),
    .dout_44        (array_pix44),
    .dout_45        (array_pix45),
    .dout_51        (array_pix51),
    .dout_52        (array_pix52),
    .dout_53        (array_pix53),
    .dout_54        (array_pix54),
    .dout_55        (array_pix55),
    .out_en_1         (sw_out_en),
    .bayer_state_out (sw_bayer_state),
    .isp_int        (isp_int),
    .end_flag       (end_flag_isp)
  );

  demosaic u_demosaic (
    .clk            (HCLK),
    .rst_n          (HRESETn),
    .bayer_state    (sw_bayer_state),
    .matrix_p13     (array_pix13),
    .matrix_p22     (array_pix22),
    .matrix_p23     (array_pix23),
    .matrix_p24     (array_pix24),
    .matrix_p31     (array_pix31),
    .matrix_p32     (array_pix32),
    .matrix_p33     (array_pix33),
    .matrix_p34     (array_pix34),
    .matrix_p35     (array_pix35),
    .matrix_p42     (array_pix42),
    .matrix_p43     (array_pix43),
    .matrix_p44     (array_pix44),
    .matrix_p53     (array_pix53),
    .clken          (sw_out_en),

    .red_data       (),
    .green_data     (),
    .blue_data      (),
    .rgb_data       (rgb_data_dm),
    .data_en         (dm_out_en)
  );

  gamma u_gamma (
    .clk            (HCLK),
    .rst_n          (HRESETn),
    .data_in        (rgb_data_dm),
    .clken          (dm_out_en),

    .data_out       (rgb_data_isp),
    .out_en         (gamma_out_en)
  );

  reg [32:0] addr_cnt;
  always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)
        addr_cnt <= 32'h0;
    else if (dout_en) begin
        if (sw_state == 16'h9C9C) begin
            addr_cnt <= addr_cnt + 1'b1;
        end
        else
            addr_cnt <= 32'h0;
    end
  end

  assign fb_addr_out = gamma_out_en? addr_cnt : bp_out_en? bp_addr_out : 16'h0;
  assign fb_sel = r_fb_sel[0];
 assign dout_en = gamma_out_en | bp_out_en;
 assign rgb_data_out = gamma_out_en? rgb_data_isp : bp_out_en? rgb_data_bypas : 16'h0;
  
 //assign dout_en = dm_out_en | bp_out_en;
 //assign rgb_data_out = dm_out_en? rgb_data_dm : bp_out_en? rgb_data_bypas : 16'h0;



  












endmodule