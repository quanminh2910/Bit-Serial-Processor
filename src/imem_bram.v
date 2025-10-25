// imem_bram.v
module imem_bram(
  input  wire        clk,
  input  wire [31:0] addr,
  output reg  [31:0] instr
);
  reg [31:0] mem [0:1023];
  initial $readmemh("firmware.mem", mem);
  always @(posedge clk) instr <= mem[addr[11:2]];
endmodule