// dmem_bram.v
module dmem_bram(
  input  wire        clk,
  input  wire [31:0] addr,
  input  wire [31:0] wdata,
  input  wire [3:0]  we,
  output reg  [31:0] rdata
);
  reg [7:0] mem [0:4095];
  integer i;
  initial for(i=0;i<4096;i=i+1) mem[i]=8'h00;
  always @(posedge clk) begin
    if (|we) begin
      if (we[0]) mem[addr]   <= wdata[7:0];
      if (we[1]) mem[addr+1] <= wdata[15:8];
      if (we[2]) mem[addr+2] <= wdata[23:16];
      if (we[3]) mem[addr+3] <= wdata[31:24];
    end
    rdata <= {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]};
  end
endmodule