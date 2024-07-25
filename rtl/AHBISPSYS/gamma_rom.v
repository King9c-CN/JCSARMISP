module gamma_rom (
    input wire [5:0] addr,
    input wire clk,
    output reg [5:0] out
);

reg [5:0] reg_addr;

always@(posedge clk) begin
    reg_addr <= addr;
end

always@* 
case (reg_addr)
    6'd0: out = 6'd0;
    6'd1: out = 6'd3;
    6'd2: out = 6'd5;
    6'd3: out = 6'd7;
    6'd4: out = 6'd9; 
    6'd5: out = 6'd10; 
    6'd6: out = 6'd12; 
    6'd7: out = 6'd13; 
    6'd8: out = 6'd14; 
    6'd9: out = 6'd16; 
    6'd10: out = 6'd17; 
    6'd11: out = 6'd18; 
    6'd12: out = 6'd19; 
    6'd13: out = 6'd20; 
    6'd14: out = 6'd22; 
    6'd15: out = 6'd23; 
    6'd16: out = 6'd24; 
    6'd17: out = 6'd25; 
    6'd18: out = 6'd26;
    6'd19: out = 6'd27;
    6'd20: out = 6'd28;
    6'd21: out = 6'd29;
    6'd22: out = 6'd30;
    6'd23: out = 6'd31;
    6'd24: out = 6'd32;
    6'd25: out = 6'd33;
    6'd26: out = 6'd34;
    6'd27: out = 6'd35;
    6'd28: out = 6'd35;
    6'd29: out = 6'd36;
    6'd30: out = 6'd37;
    6'd31: out = 6'd38;
    6'd32: out = 6'd39;
    6'd33: out = 6'd40;
    6'd34: out = 6'd41;
    6'd35: out = 6'd42;
    6'd36: out = 6'd42;
    6'd37: out = 6'd43;
    6'd38: out = 6'd44;
    6'd39: out = 6'd45;
    6'd40: out = 6'd46;
    6'd41: out = 6'd47;
    6'd42: out = 6'd47;
    6'd43: out = 6'd48;
    6'd44: out = 6'd49;
    6'd45: out = 6'd50;
    6'd46: out = 6'd51;
    6'd47: out = 6'd51;
    6'd48: out = 6'd52;
    6'd49: out = 6'd53;
    6'd50: out = 6'd54;
    6'd51: out = 6'd54;
    6'd52: out = 6'd55;
    6'd53: out = 6'd56;
    6'd54: out = 6'd57;
    6'd55: out = 6'd57;
    6'd56: out = 6'd58;
    6'd57: out = 6'd59;
    6'd58: out = 6'd60;
    6'd59: out = 6'd60;
    6'd60: out = 6'd61;
    6'd61: out = 6'd62;
    6'd62: out = 6'd63;
    6'd63: out = 6'd63;                                              
endcase
    
endmodule