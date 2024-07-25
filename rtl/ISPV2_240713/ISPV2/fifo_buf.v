module fifo_buf #(parameter DWIDTH=16, AWIDTH=12)
(
  input wire clk,
  input wire rst,
  input wire re,
  input wire we,
  input wire [DWIDTH-1:0] di,
  
  output wire rdusedw,
  output wire wrusedw,
  output wire [DWIDTH-1:0] dout
);

//Internal Signal declarations

  reg [DWIDTH-1:0] array_reg [2**AWIDTH-1:0];
  reg [AWIDTH-1:0] w_ptr_reg;
  reg [AWIDTH-1:0] w_ptr_next;
  reg [AWIDTH-1:0] w_ptr_succ;
  reg [AWIDTH-1:0] r_ptr_reg;
  reg [AWIDTH-1:0] r_ptr_next;
  reg [AWIDTH-1:0] r_ptr_succ;
  
  reg full_reg;
  reg empty_reg;
  reg full_next;
  
  
  
  
  
  reg empty_next;
  
  wire w_en;
  

  always @ (posedge clk)
    if(w_en)
    begin
      array_reg[w_ptr_reg] <= di;
    end

  assign dout = array_reg[r_ptr_reg];   

  assign w_en = we & ~full_reg;           

//State Machine
  always @ (posedge clk, negedge rst)
  begin
    if(rst)
      begin
        w_ptr_reg <= 0;
        r_ptr_reg <= 0;
        full_reg <= 1'b0;
        empty_reg <= 1'b1;
      end
    else
      begin
        w_ptr_reg <= w_ptr_next;
        r_ptr_reg <= r_ptr_next;
        full_reg <= full_next;
        empty_reg <= empty_next;
      end
  end


//Next State Logic
  always @*
  begin
    w_ptr_succ = w_ptr_reg + 1;
    r_ptr_succ = r_ptr_reg + 1;
    
    w_ptr_next = w_ptr_reg;
    r_ptr_next = r_ptr_reg;
    full_next = full_reg;
    empty_next = empty_reg;
    
    case({w_en,re})
      //2'b00: nop
      2'b01:
        if(~empty_reg)
          begin
            r_ptr_next = r_ptr_succ;
            full_next = 1'b0;
            if (r_ptr_succ == w_ptr_reg)
              empty_next = 1'b1;
          end
      2'b10:
        if(~full_reg)
          begin
            w_ptr_next = w_ptr_succ;
            empty_next = 1'b0;
            if (w_ptr_succ == r_ptr_reg)
              full_next = 1'b1;
          end
      2'b11:
        begin
          w_ptr_next = w_ptr_succ;
          r_ptr_next = r_ptr_succ;
        end
    endcase
  end

//Set wrusedw and rdusedw

  assign wrusedw = full_reg;
  assign rdusedw = empty_reg;
  
endmodule