// ===========================================================
// top_arty_z7.v : top wrapper for Arty Z7-20
// ===========================================================
module top_arty_z7(
  input  wire clk_125mhz,
  input  wire rstn_btn,
  output wire [7:0] led
);
  wire [31:0] iaddr,instr,daddr,wd,rd,leds32;
  wire [3:0] we;

  rv32i_core_bs core(
    .clk(clk_125mhz), .rstn(rstn_btn),
    .imem_addr(iaddr), .imem_instr(instr),
    .dmem_addr(daddr), .dmem_wdata(wd), .dmem_we(we),
    .dmem_rdata(rd), .leds(leds32)
  );

  imem_bram IMEM(.clk(clk_125mhz),.addr(iaddr),.instr(instr));
  dmem_bram DMEM(.clk(clk_125mhz),.addr(daddr),.wdata(wd),.we(we),.rdata(rd));

  assign led = leds32[7:0];
endmodule
