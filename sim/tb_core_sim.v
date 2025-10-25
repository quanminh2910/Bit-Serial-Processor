`timescale 1ns/1ps
module tb;
  reg clk=0, rstn=0;
  always #5 clk = ~clk; // 100 MHz
  initial begin #50; rstn=1; #5000; $finish; end

  rv32i_core_bs core(.clk(clk),.rstn(rstn),
      .imem_addr(),.imem_instr(),
      .dmem_addr(),.dmem_wdata(),.dmem_we(),.dmem_rdata(32'b0),
      .leds());
endmodule
