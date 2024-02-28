module en_ahb 
(
    input logic CLK, nRST, update_dr, ahb_select, ack, lsb_en,
    output logic ahb_enable
);
  logic enable_latch;

  always_ff @( posedge CLK, negedge nRST) //jtag clk
  begin : ff
    if(!nRST)
    begin
      ahb_enable <= 0;
    end
    else
    begin
      ahb_enable <= enable_latch;
    end
  end

  always_comb 
  begin : logi
    enable_latch = ahb_enable;
    if((update_dr && ahb_select) && lsb_en)
    begin
      enable_latch = 1;
    end
    if(ack)
    begin
      enable_latch = 0;
    end
  end
    
endmodule