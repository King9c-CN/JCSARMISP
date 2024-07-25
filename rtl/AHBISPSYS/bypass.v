module bypass (
    input   wire            clk,
    inout   wire            rst_n,
    input   wire    [7:0]   din,
    input   wire            clken,
    input   wire    [11:0]  h_active_in,
    input   wire    [11:0]  v_active_in,
    input   wire    [3:0]   bayer_state_start,
    

    output  wire    [31:0]  addr_out,
    output  wire    [15:0]  dout,
    output  wire            end_flag,
    output  wire            dout_en
);
    reg [31:0]  addr_cnt;
    reg [7:0]   data;
    reg         rDout_en;
    reg [11:0]  h_cnt;
    reg [11:0]  v_cnt;
    wire        h_flag;
    wire        v_falg;
    reg [3:0]   bayer_state;
    reg [3:0]   bayer_state_next;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        bayer_state <= 4'b0000;
    end
    else if (h_cnt == 11'd0 && v_cnt == 11'd0) begin
        bayer_state <= bayer_state_start;
    end
    else if(clken) begin
        bayer_state <= bayer_state_next;
    end
end


always @* begin
    bayer_state_next = bayer_state;
    case ({bayer_state,h_flag})
        5'b00010: bayer_state_next = 4'b0010;
        5'b00100: bayer_state_next = 4'b0001;
        5'b00011: bayer_state_next = bayer_state_start << 2;
        5'b00101: bayer_state_next = bayer_state_start << 2;
        5'b01000: bayer_state_next = 4'b1000;
        5'b10000: bayer_state_next = 4'b0100;
        5'b01001: bayer_state_next = bayer_state_start;
        5'b10001: bayer_state_next = bayer_state_start;
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        h_cnt <= 11'd0;
    end
    else if(clken) begin
        if(h_cnt == h_active_in - 1'b1)
            h_cnt <= 11'd0;
        else
            h_cnt <= h_cnt + 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        v_cnt <= 11'd0;
    end
    else if(clken) begin
    if(h_cnt == h_active_in - 1'b1)begin
        if(v_cnt == v_active_in - 1'b1)
            v_cnt <= 11'd0;
        else
            v_cnt <= v_cnt + 1'b1;
    end
    end    
end

always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            addr_cnt <= 32'h0;
            rDout_en <= 1'b0;
            data <= 8'h0;
        end
        else if (clken == 1'b1 && v_cnt>3 &&v_cnt<1084 && h_cnt>7 &&h_cnt<1928) begin
            addr_cnt <= addr_cnt + 1'b1;
            data <= din;
            rDout_en <= 1'b1;
        end
        else
            rDout_en <= 1'b0;
    end

    assign addr_out = addr_cnt;
    assign dout = bayer_state[1]? {11'd0, data[7:3]} : 
                  bayer_state[2]? {data[7:3], 11'd0} : {5'd0, data[7:2], 5'd0}; //BayerGBRG2RGB565
    assign dout_en = rDout_en;
    assign h_flag = h_cnt==h_active_in-1'b1;
    assign v_falg = v_cnt==v_active_in-1'b1;
    assign end_flag = h_flag & v_falg;

endmodule