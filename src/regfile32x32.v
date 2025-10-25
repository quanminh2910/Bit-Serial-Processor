// ===========================================================
// regfile32x32.v : 32×32 register file
// ===========================================================
module regfile32x32(
  input  wire        clk,
  input  wire        rstn,
  input  wire [4:0]  rs1, rs2, rd,
  input  wire [31:0] wd,
  input  wire        we,
  output wire [31:0] rd1, rd2
);
  reg [31:0] regs [0:31];
  integer i;
  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      for (i=0;i<32;i=i+1) regs[i] <= 0;
    else if (we && rd!=0)
      regs[rd] <= wd;
  end
  assign rd1 = (rs1==0)?0:regs[rs1];
  assign rd2 = (rs2==0)?0:regs[rs2];
endmodule
