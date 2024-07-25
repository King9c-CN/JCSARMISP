
module CortexM0_SoC (
        input  wire  clk,
        input  wire  RSTn,
        inout  wire  SWDIO,  
        
input  wire  SWCLK,


//SD卡
input wire sddat0 , //主输入从输出信号
output wire sdclk  , //SD卡时钟信号
inout wire sdcmd , //片选信号
input wire sddat1 , //主输出从输入信号
input wire sddat2 , //主输出从输入信号
input wire sddat3 , //主输出从输入信号

//VGA
output wire vga_hs , //输出行同步信号
output wire vga_vs , //输出场同步信号
output wire [7:0] rgb_r, //输出像素信息
output wire [7:0] rgb_g,
output wire [7:0] rgb_b,
output wire clk_148m_vga,

//LED
output [3:0] LED,
input wire [3:0]col,

//UART
input wire RX,
output wire TX
);
 
////
//\* Parameter and Internal Signal \//
////
//parameter define
parameter H_VALID = 24'd1920 ; //行有效数据
parameter V_VALID = 24'd1080 ; //列有效数据

wire sdram_clk ;//SDRAM 芯片时钟
 wire sdram_cke ;//SDRAM 时钟有效
 wire sdram_cs_n ;//SDRAM 片选
 wire sdram_cas_n ; //SDRAM 行有效
 wire sdram_ras_n ; //SDRAM 列有效
 wire sdram_we_n ; //SDRAM 写有效
 wire [1:0] sdram_ba ; //SDRAM Bank地址
 wire [10:0] sdram_addr ; //SDRAM 行/列地址
 wire [1:0] sdram_dqm ; //SDRAM 数据掩码
 wire [31:0] sdram_dq; //SDRAM 数据
 
//wire define
wire rst_n ; //复位信号
wire clk_150m ; //生成25MHz时钟
wire clk_120m ; //生成25MHz时钟
wire locked ; //时钟锁定信号

wire sdcard_rd_en ; //开始写SD卡数据信号
wire [31:0] sdcard_rd_addr ; //读数据扇区地址
wire sd_rd_busy ; //读忙信号
wire sd_rd_data_en ; //数据读取有效使能信号
wire [15:0] sd_rd_data ;//读数据
wire sd_init_end ; //SD卡初始化完成信号

wire wr_en ; //sdram_ctrl模块写使能
wire [15:0] wr_data ; //sdram_ctrl模块写数据
wire rd_en ; //sdram_ctrl模块读使能
wire [15:0] rd_data ; //sdram_ctrl模块读数据
wire sdram_init_end ; //SDRAM初始化完成

////
//\* Main Code \//
////
//rdt_n:复位信号,系统复位与时钟锁定取与
assign rst_n = RSTn && locked;


//PLL
clk_gen clk_gen_inst (
.refclk (clk ),
.reset (~RSTn ),
.clk1_out (clk_150m ),
.clk3_out (clk_148m_vga),
.clk4_out (clk_120m),
.extlock (locked )
);


//------------------------------------------------------------------------------
// DEBUG IOBUF 
//------------------------------------------------------------------------------

wire SWDO;
wire SWDOEN;
wire SWDI;
 
assign SWDI = SWDIO;
assign SWDIO = (SWDOEN) ?  SWDO : 1'bz;

//------------------------------------------------------------------------------
// Interrupt
//------------------------------------------------------------------------------

assign row = 4'b1110;
wire [3:0] key_interrupt;
wire uart_interrupt; //synthesis keep
Keyboard kb(
    .HCLK(clk),
    .HRESETn(RSTn),
    .col(col),
    .key_interrupt(key_interrupt)
    );

wire [31:0] IRQ;//synthesis keep
/*Connect the IRQ with keyboard*/
assign IRQ = {27'b0,uart_interrupt,key_interrupt};
/***************************/


wire RXEV;
assign RXEV = 1'b0;

//------------------------------------------------------------------------------
// AHB
//------------------------------------------------------------------------------

wire [31:0] HADDR;  
wire [ 2:0] HBURST;
wire        HMASTLOCK;
wire [ 3:0] HPROT;
wire [ 2:0] HSIZE;
wire [ 1:0] HTRANS;
wire [31:0] HWDATA; 
wire        HWRITE;
wire [31:0] HRDATA;
wire        HRESP;
wire        HMASTER;
wire        HREADY;

//------------------------------------------------------------------------------
// RESET AND DEBUG
//------------------------------------------------------------------------------

wire SYSRESETREQ;
reg cpuresetn;

always @(posedge clk or negedge RSTn)begin
        if (~RSTn) cpuresetn <= 1'b0;
        else if (SYSRESETREQ) cpuresetn <= 1'b0;
        else cpuresetn <= 1'b1;
end

wire CDBGPWRUPREQ;
reg CDBGPWRUPACK;

always @(posedge clk or negedge RSTn)begin
        if (~RSTn) CDBGPWRUPACK <= 1'b0;
        else CDBGPWRUPACK <= CDBGPWRUPREQ;
end


//------------------------------------------------------------------------------
// Instantiate Cortex-M0 processor logic level
//------------------------------------------------------------------------------

cortexm0ds_logic u_logic (

        // System inputs
        .FCLK           (clk),           //FREE running clock 
        .SCLK           (clk),           //system clock
        .HCLK           (clk),           //AHB clock
        .DCLK           (clk),           //Debug clock
        .PORESETn       (RSTn),          //Power on reset
        .HRESETn        (cpuresetn),     //AHB and System reset
        .DBGRESETn      (RSTn),          //Debug Reset
        .RSTBYPASS      (1'b0),          //Reset bypass
        .SE             (1'b0),          // dummy scan enable port for synthesis

        // Power management inputs
        .SLEEPHOLDREQn  (1'b1),          // Sleep extension request from PMU
        .WICENREQ       (1'b0),          // WIC enable request from PMU
        .CDBGPWRUPACK   (CDBGPWRUPACK),  // Debug Power Up ACK from PMU

        // Power management outputs
        .CDBGPWRUPREQ   (CDBGPWRUPREQ),
        .SYSRESETREQ    (SYSRESETREQ),

        // System bus
        .HADDR          (HADDR[31:0]),
        .HTRANS         (HTRANS[1:0]),
        .HSIZE          (HSIZE[2:0]),
        .HBURST         (HBURST[2:0]),
        .HPROT          (HPROT[3:0]),
        .HMASTER        (HMASTER),
        .HMASTLOCK      (HMASTLOCK),
        .HWRITE         (HWRITE),
        .HWDATA         (HWDATA[31:0]),
        .HRDATA         (HRDATA[31:0]),
        .HREADY         (HREADY),
        .HRESP          (HRESP),

        // Interrupts
        .IRQ            (IRQ),          //Interrupt
        .NMI            (1'b0),         //Watch dog interrupt
        .IRQLATENCY     (8'h0),
        .ECOREVNUM      (28'h0),

        // Systick
        .STCLKEN        (1'b0),
        .STCALIB        (26'h0),

        // Debug - JTAG or Serial wire
        // Inputs
        .nTRST          (1'b1),
        .SWDITMS        (SWDI),
        .SWCLKTCK       (SWCLK),
        .TDI            (1'b0),
        // Outputs
        .SWDO           (SWDO),
        .SWDOEN         (SWDOEN),

        .DBGRESTART     (1'b0),

        // Event communication
        .RXEV           (RXEV),         // Generate event when a DMA operation completed.
        .EDBGRQ         (1'b0)          // multi-core synchronous halt request
);

//------------------------------------------------------------------------------
// AHBlite Interconncet
//------------------------------------------------------------------------------

wire            HSEL_P0;
wire    [31:0]  HADDR_P0;
wire    [2:0]   HBURST_P0;
wire            HMASTLOCK_P0;
wire    [3:0]   HPROT_P0;
wire    [2:0]   HSIZE_P0;
wire    [1:0]   HTRANS_P0;
wire    [31:0]  HWDATA_P0;
wire            HWRITE_P0;
wire            HREADY_P0;
wire            HREADYOUT_P0;
wire    [31:0]  HRDATA_P0;
wire            HRESP_P0;

wire            HSEL_P1;
wire    [31:0]  HADDR_P1;
wire    [2:0]   HBURST_P1;
wire            HMASTLOCK_P1;
wire    [3:0]   HPROT_P1;
wire    [2:0]   HSIZE_P1;
wire    [1:0]   HTRANS_P1;
wire    [31:0]  HWDATA_P1;
wire            HWRITE_P1;
wire            HREADY_P1;
wire            HREADYOUT_P1;
wire    [31:0]  HRDATA_P1;
wire            HRESP_P1;

wire            HSEL_P2;
wire    [31:0]  HADDR_P2;
wire    [2:0]   HBURST_P2;
wire            HMASTLOCK_P2;
wire    [3:0]   HPROT_P2;
wire    [2:0]   HSIZE_P2;
wire    [1:0]   HTRANS_P2;
wire    [31:0]  HWDATA_P2;
wire            HWRITE_P2;
wire            HREADY_P2;
wire            HREADYOUT_P2;
wire    [31:0]  HRDATA_P2;
wire            HRESP_P2;

wire            HSEL_P3;
wire    [31:0]  HADDR_P3;
wire    [2:0]   HBURST_P3;
wire            HMASTLOCK_P3;
wire    [3:0]   HPROT_P3;
wire    [2:0]   HSIZE_P3;
wire    [1:0]   HTRANS_P3;
wire    [31:0]  HWDATA_P3;
wire            HWRITE_P3;
wire            HREADY_P3;
wire            HREADYOUT_P3;
wire    [31:0]  HRDATA_P3;
wire            HRESP_P3;

AHBlite_Interconnect Interconncet(
        .HCLK           (clk),
        .HRESETn        (cpuresetn),

        // CORE SIDE
        .HADDR          (HADDR),
        .HTRANS         (HTRANS),
        .HSIZE          (HSIZE),
        .HBURST         (HBURST),
        .HPROT          (HPROT),
        .HMASTLOCK      (HMASTLOCK),
        .HWRITE         (HWRITE),
        .HWDATA         (HWDATA),
        .HRDATA         (HRDATA),
        .HREADY         (HREADY),
        .HRESP          (HRESP),

        // P0
        .HSEL_P0        (HSEL_P0),
        .HADDR_P0       (HADDR_P0),
        .HBURST_P0      (HBURST_P0),
        .HMASTLOCK_P0   (HMASTLOCK_P0),
        .HPROT_P0       (HPROT_P0),
        .HSIZE_P0       (HSIZE_P0),
        .HTRANS_P0      (HTRANS_P0),
        .HWDATA_P0      (HWDATA_P0),
        .HWRITE_P0      (HWRITE_P0),
        .HREADY_P0      (HREADY_P0),
        .HREADYOUT_P0   (HREADYOUT_P0),
        .HRDATA_P0      (HRDATA_P0),
        .HRESP_P0       (HRESP_P0),

        // P1
        .HSEL_P1        (HSEL_P1),
        .HADDR_P1       (HADDR_P1),
        .HBURST_P1      (HBURST_P1),
        .HMASTLOCK_P1   (HMASTLOCK_P1),
        .HPROT_P1       (HPROT_P1),
        .HSIZE_P1       (HSIZE_P1),
        .HTRANS_P1      (HTRANS_P1),
        .HWDATA_P1      (HWDATA_P1),
        .HWRITE_P1      (HWRITE_P1),
        .HREADY_P1      (HREADY_P1),
        .HREADYOUT_P1   (HREADYOUT_P1),
        .HRDATA_P1      (HRDATA_P1),
        .HRESP_P1       (HRESP_P1),

        // P2
        .HSEL_P2        (HSEL_P2),
        .HADDR_P2       (HADDR_P2),
        .HBURST_P2      (HBURST_P2),
        .HMASTLOCK_P2   (HMASTLOCK_P2),
        .HPROT_P2       (HPROT_P2),
        .HSIZE_P2       (HSIZE_P2),
        .HTRANS_P2      (HTRANS_P2),
        .HWDATA_P2      (HWDATA_P2),
        .HWRITE_P2      (HWRITE_P2),
        .HREADY_P2      (HREADY_P2),
        .HREADYOUT_P2   (HREADYOUT_P2),
        .HRDATA_P2      (HRDATA_P2),
        .HRESP_P2       (HRESP_P2),

        // P3
        .HSEL_P3        (HSEL_P3),
        .HADDR_P3       (HADDR_P3),
        .HBURST_P3      (HBURST_P3),
        .HMASTLOCK_P3   (HMASTLOCK_P3),
        .HPROT_P3       (HPROT_P3),
        .HSIZE_P3       (HSIZE_P3),
        .HTRANS_P3      (HTRANS_P3),
        .HWDATA_P3      (HWDATA_P3),
        .HWRITE_P3      (HWRITE_P3),
        .HREADY_P3      (HREADY_P3),
        .HREADYOUT_P3   (HREADYOUT_P3),
        .HRDATA_P3      (HRDATA_P3),
        .HRESP_P3       (HRESP_P3)
);

//------------------------------------------------------------------------------
// AHB RAMCODE
//------------------------------------------------------------------------------

wire [31:0] RAMCODE_RDATA,RAMCODE_WDATA;
wire [13:0] RAMCODE_WADDR;
wire [13:0] RAMCODE_RADDR;
wire [3:0]  RAMCODE_WRITE;

AHBlite_Block_RAM RAMCODE_Interface(
        /* Connect to Interconnect Port 0 */
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .HSEL           (HSEL_P0),
        .HADDR          (HADDR_P0),
        .HPROT          (HPROT_P0),
        .HSIZE          (HSIZE_P0),
        .HTRANS         (HTRANS_P0),
        .HWDATA         (HWDATA_P0),
        .HWRITE         (HWRITE_P0),
        .HRDATA         (HRDATA_P0),
        .HREADY         (HREADY_P0),
        .HREADYOUT      (HREADYOUT_P0),
        .HRESP          (HRESP_P0),
        .BRAM_WRADDR    (RAMCODE_WADDR),
        .BRAM_RDADDR    (RAMCODE_RADDR),
        .BRAM_RDATA     (RAMCODE_RDATA),
        .BRAM_WDATA     (RAMCODE_WDATA),
        .BRAM_WRITE     (RAMCODE_WRITE)
        /**********************************/
);

//------------------------------------------------------------------------------
// AHB RAMDATA
//------------------------------------------------------------------------------

wire [31:0] RAMDATA_RDATA;
wire [31:0] RAMDATA_WDATA;
wire [13:0] RAMDATA_WADDR;
wire [13:0] RAMDATA_RADDR;
wire [3:0]  RAMDATA_WRITE;

AHBlite_Block_RAM RAMDATA_Interface(
        /* Connect to Interconnect Port 1 */
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .HSEL           (HSEL_P1),
        .HADDR          (HADDR_P1),
        .HPROT          (HPROT_P1),
        .HSIZE          (HSIZE_P1),
        .HTRANS         (HTRANS_P1),
        .HWDATA         (HWDATA_P1),
        .HWRITE         (HWRITE_P1),
        .HRDATA         (HRDATA_P1),
        .HREADY         (HREADY_P1),
        .HREADYOUT      (HREADYOUT_P1),
        .HRESP          (HRESP_P1),
        .BRAM_WRADDR    (RAMDATA_WADDR),
        .BRAM_RDADDR    (RAMDATA_RADDR),
        .BRAM_WDATA     (RAMDATA_WDATA),
        .BRAM_RDATA     (RAMDATA_RDATA),
        .BRAM_WRITE     (RAMDATA_WRITE)
        /**********************************/
);


//------------------------------------------------------------------------------
// AHB ISP
//------------------------------------------------------------------------------
wire [15:0] isp_out_data;
wire  isp_out_en;

wire isp_fifo_rd;
wire [15:0] isp_din;

    wire  sdcard_rd_reset;

AHBISP ISP(

	.HCLK(clk),
	.HRESETn(RSTn && ~sdcard_rd_reset),
	.HADDR(HADDR_P2),
	.HWDATA(HWDATA_P2),
	.HREADY(HREADY_P2),
	.HWRITE(HWRITE_P2),
	.HTRANS(HTRANS_P2),
	.HSEL(HSEL_P2),
	.HSIZE(HSIZE_P2),
  
.HRDATA(HRDATA_P2),
.HREADYOUT(HREADYOUT_P2),

// AHB-Lite inout port  

    .data_in(isp_din[15:8]),
    .fifo_empty(~isp_fifo_rd ),

    .fifo_rd(),
    .fb_addr_out( ),
    .rgb_data_out(isp_out_data ),
    .fb_sel(),
    .dout_en(isp_out_en ),
    .isp_int()
// ISP interact port with fb
);

wire [9:0] fifo_num;

sd2isp_fifo fifo(
//sd接口
	.clkw (clk_150m ), 		//写时钟
	.we (sd_rd_data_en ), 	//写请求
	.di (sd_rd_data),	    //写数据
//isp接口
	.clkr (clk ), 			//读时钟
	.re (isp_fifo_rd ),	    //读请求
	.dout (isp_din ),       //读数据

	.rdusedw (fifo_num ),   //FIFO中的数据量
	.wrusedw ( ),
	.rst (~RSTn || sdcard_rd_reset)            //清零信号
);
assign isp_fifo_rd=(fifo_num>512) ? 1 : 0;     


//------------------------------------------------------------------------------
// AHB2APB BRIDGE
//------------------------------------------------------------------------------

    //APB Port
    wire[15:0]          PADDR;   
    wire                PENABLE;
    wire                PWRITE; //synthesis keep
    wire[31:0]          PWDATA; //synthesis keep
    wire                PSEL;   

    wire[31:0]          PRDATA;//synthesis keep
    wire                PREADY;
    wire                PSLVERR;

    cmsdk_ahb_to_apb #(
        .ADDRWIDTH(16),
        .REGISTER_RDATA(0),
        .REGISTER_WDATA(0)
    ) ahb_to_apb(
        //General Signals
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .PCLKEN         (1'b1),

        //AHB Port
        .HSEL           (HSEL_P3),
        .HADDR          (HADDR_P3[15:0]),
        .HTRANS         (HTRANS_P3),
        .HSIZE          (HSIZE_P3),
        .HPROT          (HPROT_P3),
        .HWRITE         (HWRITE_P3),
        .HREADY         (HREADY_P3),
        .HWDATA         (HWDATA_P3),
        
        .HREADYOUT      (HREADYOUT_P3),
        .HRDATA         (HRDATA_P3),
        .HRESP          (HRESP_P3),

        //APB Port
        .PADDR          (PADDR),
        .PENABLE        (PENABLE),
        .PWRITE         (PWRITE),
        .PSTRB          (),
        .PPROT          (),
        .PWDATA         (PWDATA),
        .PSEL           (PSEL),

        .APBACTIVE      (),
        
        .PRDATA         (PRDATA),
        .PREADY         (PREADY),
        .PSLVERR        (PSLVERR)
    );

    //VGA port
    wire       VGA_PSEL; 

    //SD Port
    wire       SDCARD_PSEL;

    //SDRAM Port
    wire       GPIO_PSEL;

    //UART Port
    wire       UART_PSEL;//synthesis keep
    
wire PREADY0;
wire PREADY1;
wire PREADY2;
wire PREADY3_UART;//synthesis keep

wire [31:0] PRDATA3_UART;
   cmsdk_apb_slave_mux #(
        .PORT0_ENABLE (1),
        .PORT1_ENABLE (1),
        .PORT2_ENABLE (1),
        .PORT3_ENABLE (1),
        .PORT4_ENABLE (0),
        .PORT5_ENABLE (0),
        .PORT6_ENABLE (0),
        .PORT7_ENABLE (0),
        .PORT8_ENABLE (0),
        .PORT9_ENABLE (0),
        .PORT10_ENABLE(0),
        .PORT11_ENABLE(0),
        .PORT12_ENABLE(0),
        .PORT13_ENABLE(0),
        .PORT14_ENABLE(0),
        .PORT15_ENABLE(0)
    )
    cmsdk_apb_slave_mux(
        .DECODE4BIT     (PADDR[15:12]),
        .PSEL           (PSEL),

        .PSEL0          (VGA_PSEL),
        .PREADY0        (1'b1),
        .PRDATA0        (32'b0),
        .PSLVERR0       (1'b0),

        .PSEL1          (SDCARD_PSEL),
        .PREADY1        (1'b1),
        .PRDATA1        (32'b0),
        .PSLVERR1       (1'b0),

        .PSEL2          (GPIO_PSEL),
        .PREADY2        (1'b1),
        .PRDATA2        (32'b0),
        .PSLVERR2       (1'b0),

        .PSEL3          (UART_PSEL),
        .PREADY3        (PREADY3_UART),
        .PRDATA3        (PRDATA3_UART),
        .PSLVERR3       (1'b0),

        .PSEL4          (),
        .PREADY4        (1'b0),
        .PRDATA4        (32'b0),
        .PSLVERR4       (1'b0),

        .PSEL5          (),
        .PREADY5        (1'b0),
        .PRDATA5        (32'b0),
        .PSLVERR5       (1'b0),

        .PSEL6          (),
        .PREADY6        (1'b0),
        .PRDATA6        (32'b0),
        .PSLVERR6       (1'b0),

        .PSEL7          (),
        .PREADY7        (1'b0),
        .PRDATA7        (32'b0),
        .PSLVERR7       (1'b0),

        .PSEL8          (),
        .PREADY8        (1'b0),
        .PRDATA8        (32'b0),
        .PSLVERR8       (1'b0),

        .PSEL9          (),
        .PREADY9        (1'b0),
        .PRDATA9        (32'b0),
        .PSLVERR9       (1'b0),

        .PSEL10         (),
        .PREADY10       (1'b0),
        .PRDATA10       (32'b0),
        .PSLVERR10      (1'b0),

        .PSEL11         (),
        .PREADY11       (1'b0),
        .PRDATA11       (32'b0),
        .PSLVERR11      (1'b0),

        .PSEL12         (),
        .PREADY12       (1'b0),
        .PRDATA12       (32'b0),
        .PSLVERR12      (1'b0),

        .PSEL13         (),
        .PREADY13       (1'b0),
        .PRDATA13       (32'b0),
        .PSLVERR13      (1'b0),

        .PSEL14         (),
        .PREADY14       (1'b0),
        .PRDATA14       (32'b0),
        .PSLVERR14      (1'b0),

        .PSEL15         (),
        .PREADY15       (1'b0),
        .PRDATA15       (32'b0),
        .PSLVERR15      (1'b0),

        .PREADY         (PREADY),
        .PRDATA         (PRDATA),
        .PSLVERR        (PSLVERR)
    );

//------------------------------------------------------------------------------
// RAM
//------------------------------------------------------------------------------

Block_RAM RAM_CODE(
        .clka           (clk),
        .addra          (RAMCODE_WADDR),
        .addrb          (RAMCODE_RADDR),
        .dina           (RAMCODE_WDATA),
        .doutb          (RAMCODE_RDATA),
        .wea            (RAMCODE_WRITE)
);

Block_RAM RAM_DATA(
        .clka           (clk),
        .addra          (RAMDATA_WADDR),
        .addrb          (RAMDATA_RADDR),
        .dina           (RAMDATA_WDATA),
        .doutb          (RAMDATA_RDATA),
        .wea            (RAMDATA_WRITE)
);


//------------------------------------------------------------------------------
// APB SLAVE
//------------------------------------------------------------------------------
wire vga_en; 
	//VGA
APB_VGA_CONTROL U_APB_VGA_CONTROL(
    .PCLK                               (clk),
    .PCLKG                              (clk),
    .PRESETn                            (cpuresetn),
    .PSEL                               (VGA_PSEL),
    .PADDR                              (PADDR[11:2]),
    .PENABLE                            (PENABLE), 
    .PWRITE                             (PWRITE),
    .PWDATA                             (PWDATA),
    .ECOREVNUM                          (),
    .PREADY      		     		    (),
    .PRDATA                             (),
    .PSLVERR       						(),
 
    .vga_en                             (vga_en)
);

      
		//------------- vga_ctrl_inst -------------
vga_ctrl vga_ctrl_inst
(
	.vga_clk 			(clk_148m_vga ), 		//输入工作时钟,频率148.5MHz 输出vga时钟
	.sys_rst_n 			(RSTn && vga_en  ), 	//输入复位信号,低电平有效
	.pix_data 			(rd_data ), 			//待显示数据输入
	.pix_data_req 		(rd_en ),			    //数据请求信号

	.hsync 				(vga_hs ), 				//输出行同步信号
	.vsync 				(vga_vs ), 				//输出场同步信号
	.rgb_r 				(rgb_r ), 				//输出像素点色彩信息,16bit
	.rgb_g 				(rgb_g ), 				//输出像素点色彩信息,16bit
	.rgb_b 				(rgb_b ) 				//输出像素点色彩信息,16bit
);
	
	//SD_CARD
APB_SDCARD_CONTROL U_APB_SDCARD_CONTROL(
    .PCLK                               (clk),
    .PCLKG                              (clk),
    .PRESETn                            (cpuresetn),
    .PSEL                               (SDCARD_PSEL),
    .PADDR                              (PADDR[11:2]),
    .PENABLE                            (PENABLE), 
    .PWRITE                             (PWRITE),
    .PWDATA                             (PWDATA),
    .ECOREVNUM                          (),
    .PREADY      		     	        (),
    .PRDATA                             (),
    .PSLVERR       			            (),
 
    .sdcard_rd_en                       (sdcard_rd_en),
    .sdcard_rd_addr                     (sdcard_rd_addr),
    .sdcard_rd_reset                    (sdcard_rd_reset)
);
    
      
sd_reader#(
    .CLK_DIV(0)
    )sd_reader
(
	.clk (clk_150m ),   //输入工作时钟,频率150MHz
	.rstn (rst_n && ~sdcard_rd_reset),     //输入复位信号,低电平有效

	.sdclk (sdclk ),    //SD卡时钟信号 40Mhz
	.sdcmd (sdcmd ),    //片选信号
	.sddat0 (sddat0 ),  
	.sddat1 (sddat1 ),  
	.sddat2 (sddat2 ),  
	.sddat3 (sddat3 ),  
   
	.rstart     (sdcard_rd_en ),                 //数据读使能信号
	.rsector    (sdcard_rd_addr ), 				 //读数据扇区地址
	.rbusy      (sd_rd_busy ), 			     	 //读操作忙信号
	.rd_data_en (sd_rd_data_en ), 				 //读数据标志信号
	.rd_data    (sd_rd_data )				     //读数据
);

	//GPIO       
APB_GPIO U_APB_GPIO(
    .PCLK                               (clk),
    .PCLKG                              (clk),
    .PRESETn                            (cpuresetn),
    .PSEL                               (GPIO_PSEL),
    .PADDR                              (PADDR[11:2]),
    .PENABLE                            (PENABLE), 
    .PWRITE                             (PWRITE),
    .PWDATA                             (PWDATA),
    .ECOREVNUM                          (),
    .PREADY      		     		    (),
    .PRDATA                             (),
    .PSLVERR       						(),
    .LED 								(LED)
);


	// UART
wire tx_busy;  //synthesis keep
wire [7:0] UART_RX_data;//synthesis keep
wire [7:0] UART_TX_data;//synthesis keep
wire tx_en;//synthesis keep
 
APB_UART U_APB_UART(
        .PCLK           				(clk),
        .PRESETn       				    (cpuresetn),
        .PSEL           				(UART_PSEL),
        .PADDR          				(PADDR[11:2]),
        .PWDATA         				(PWDATA),
        .PWRITE         				(PWRITE),
        .ECOREVNUM                      (),
        .PREADY      		     		(PREADY3_UART),
        .PRDATA                         (PRDATA3_UART),
        .PSLVERR       				    (),
       
        .UART_RX        				(UART_RX_data),    //INPUT
        .state          				(tx_busy),         //INPUT
        .tx_en          				(tx_en),           //OUTPUT
        .UART_TX        				(UART_TX_data)     //OUTPUT
);

rs232 u_rs232(
    	.clk							(clk),
        .rstn							(cpuresetn),
        .rx								(RX),
        .tx								(TX),
        .po_data						(UART_RX_data),
        .po_flag 						(uart_interrupt),
        .pi_data						(UART_TX_data),
        .pi_flag						(tx_en),
        .tx_busy						(tx_busy)
);

//------------------------------------------------------------------------------
// SDRAM FIFO
//------------------------------------------------------------------------------
//------------- sdram_top_inst -------------

reg [31:0] isp_rd_data_reg;
reg  isp_rd_data_en_reg;
reg cnt_isp;
always @(posedge clk or negedge rst_n)
begin
if(!rst_n) begin cnt_isp<=0; isp_rd_data_reg<=0;end
else if(isp_out_en ) begin 
        if(cnt_isp) begin
          isp_rd_data_reg <= {isp_out_data,isp_rd_data_reg[31:16]}; 
          cnt_isp<=0; isp_rd_data_en_reg<=1; end 
        else begin 
          isp_rd_data_reg <= {isp_out_data,isp_rd_data_reg[31:16]}; 
          cnt_isp<=1; isp_rd_data_en_reg<=0;end 
end
else isp_rd_data_en_reg<=0;          

end




sdram_top sdram_top_inst
(
.sys_clk (clk_120m ), 						//sdram 控制器参考时钟
.clk_out (clk_120m ), 						//用于输出的相位偏移时钟
.sys_rst_n (rst_n ), 						//系统复位
//用户写端口
.wr_fifo_wr_clk (clk ), 					//写端口FIFO: 写时钟
.wr_fifo_wr_req ( isp_rd_data_en_reg),				//写端口FIFO: 写使能
.wr_fifo_wr_data (isp_rd_data_reg  ), 			//写端口FIFO: 写数据
.sdram_wr_b_addr (21'd0 ), 					//写SDRAM的起始地址
.sdram_wr_e_addr (H_VALID*V_VALID/2), 		//写SDRAM的结束地址
.wr_burst_len (9'd256 ), 					//写SDRAM时的数据突发长度
.wr_rst (~rst_n || sdcard_rd_reset ), 							//写端口复位: 复位写地址,清空写FIFO
//用户读端口
.rd_fifo_rd_clk (clk_148m_vga ), 			//读端口FIFO: 读时钟
.rd_fifo_rd_req (rd_en ),			     	//读端口FIFO: 读使能
.rd_fifo_rd_data (rd_data ),     			//读端口FIFO: 读数据
.sdram_rd_b_addr (21'd0 ), 					//读SDRAM的起始地址
.sdram_rd_e_addr (H_VALID*V_VALID/2), 		//读SDRAM的结束地址
.rd_burst_len (9'd256 ), 					//从SDRAM中读数据时的突发长度
.rd_fifo_num ( ), 							//读fifo中的数据量
.rd_rst (~rst_n  ), 							//读端口复位: 复位读地址,清空读FIFO
//用户控制端口
.read_valid (1'b1 ), 						//SDRAM 读使能
//.pingpang_en (1'b0 ), 					//SDRAM 乒乓操作使能
.init_end (sdram_init_end ), 				//SDRAM 初始化完成标志
//SDRAM 芯片接口
.sdram_clk (sdram_clk ), 					//SDRAM 芯片时钟
.sdram_cke (sdram_cke ), 					//SDRAM 时钟有效
.sdram_cs_n (sdram_cs_n ), 					//SDRAM 片选
.sdram_ras_n (sdram_ras_n ), 				//SDRAM 行有效
.sdram_cas_n (sdram_cas_n ), 				//SDRAM 列有效
.sdram_we_n (sdram_we_n ), 					//SDRAM 写有效
.sdram_ba (sdram_ba ), 						//SDRAM Bank地址
.sdram_addr (sdram_addr ), 					//SDRAM 行/列地址
.sdram_dq (sdram_dq ), 						//SDRAM 数据
.sdram_dqm (sdram_dqm ) 					//SDRAM 数据掩码
);

SDRAM U_sdram 
(
    .clk(sdram_clk),
    .ras_n(sdram_ras_n),
    .cas_n(sdram_cas_n),
    .we_n(sdram_we_n),
    .addr(sdram_addr),
    .ba(sdram_ba),
    .dq(sdram_dq),
    .cs_n(sdram_cs_n),
    .dm0( 0),
    .dm1(0),
    .dm2(0),
    .dm3(0),
    .cke(sdram_cke)
);
endmodule
