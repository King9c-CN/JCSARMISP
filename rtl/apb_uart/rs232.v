module rs232(
input wire clk , //系统时钟50MHz
input wire rstn , //全局复位
input wire rx , //串口接收数据

output wire tx, //串口发送数据

output wire [7:0] po_data,
output wire po_flag,

input wire [7:0] pi_data,
input wire pi_flag,

output wire tx_busy
);
////
 //\* Parameter and Internal Signal \//
 ////
 
 //parameter define
 parameter UART_BPS = 16'd9600; //比特率
 parameter CLK_FREQ = 26'd24_000_000; //时钟频率

 //wire define




 ////
 //\* Instantiation \//
 ////

 //------------------------uart_rx_inst------------------------
 uart_rx 
 #(
     .UART_BPS(UART_BPS),
     .CLK_FREQ(CLK_FREQ)
 )
 uart_rx_inst
 (
 .sys_clk (clk), //input sys_clk
 .sys_rst_n (rstn ), //input sys_rst_n
 .rx (rx ), //input rx

 .po_data (po_data ), //output [7:0] po_data
 .po_flag (po_flag ) //output po_flag
 );

 //------------------------uart_tx_inst------------------------
 uart_tx 
  #(
     .UART_BPS(UART_BPS),
     .CLK_FREQ(CLK_FREQ)
 )
 uart_tx_inst (
 .sys_clk (clk ), //input sys_clk
 .sys_rst_n (rstn ), //input sys_rst_n
 .pi_data (pi_data ), //input [7:0] pi_data
 .pi_flag (pi_flag ), //input pi_flag

 .tx (tx ), //output tx
 
 .work_en (tx_busy)
 );

 endmodule
