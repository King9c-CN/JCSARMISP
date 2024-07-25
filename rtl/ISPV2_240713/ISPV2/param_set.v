module param_set (
    input wire HCLK,
    input wire [3:0] param_sel,     //4'b0001: set isp process mode 
                                    //4'b0011: set isp resolvation
                                    //4'b0111: set AWB coe
                                    //4'b1111: set gamma coe
    input wire [31:0] rd_data,
    input wire HRESETn,

    //channel coe out
    output wire [7:0] redGain,
    output wire [7:0] greGain,
    output wire [7:0] bluGain,
    
    //resolvation set
    output wire [11:0] hActive,
    output wire [11:0] vActive,
    output wire [3:0]  bayerStart,

    //isp mode
    output wire [2:0] isp_mode,

    //gamma 
    output wire [2:0] gamma_coe
);

reg [7:0] rRedGain;
reg [7:0] rGreGain;
reg [7:0] rBluGain;

reg [11:0] rH_active;
reg [11:0] rV_active;
reg [3:0]  rBayerStart;

reg [2:0] rISP_mode;
reg [2:0] rGammaCoe;

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        rRedGain <= 8'h8;
        rGreGain <= 8'h8;
        rBluGain <= 8'h8;
        rH_active <= 12'd1088;
        rV_active <= 12'd1936;
        rISP_mode <= 3'b0;
        rGammaCoe <= 3'b001;
    end
    else if(param_sel == 4'b0001) begin
        rISP_mode <= rd_data[2:0];
    end
    else if(param_sel == 4'b0011) begin
        rH_active <= rd_data[11:0];
        rV_active <= rd_data[23:12];
        rBayerStart <= rd_data[31:28];
    end 
    else if(param_sel == 4'b0111) begin
        rRedGain <= rd_data[31:24];
        rGreGain <= rd_data[23:16];
        rBluGain <= rd_data[15:8];
    end
    else if(param_sel == 4'b1111) begin
        rGammaCoe <= rd_data[2:0];
    end
end

//color correction coe
assign redGain = rRedGain;
assign greGain = rGreGain;
assign bluGain = rBluGain;

//vedio format
assign hActive = rH_active;
assign vActive = rV_active;
assign bayerStart = rBayerStart;

//isp mode
assign isp_mode = rISP_mode;

//gamma coe
assign gamma_coe = rGammaCoe;


    
endmodule