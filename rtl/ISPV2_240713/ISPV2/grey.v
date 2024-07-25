module grey (
    input wire [15:0]   Din,
    input wire          clk,
    input wire          rst_n,
    input wire          dataEn,

    output wire [15:0]  Dout,
    output wire         outEn
);

    reg [15:0] data_buf;
    reg        rDataEn;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        data_buf <= 'h0;
        else
        data_buf <= Din;
    end

    always @(posedge clk) begin
        rDataEn <= dataEn;
    end

    assign outEn = rDataEn;
    assign Dout = (~outEn)? 'h0 : {data_buf[15:11], data_buf[15:10], data_buf[15:11]};


endmodule