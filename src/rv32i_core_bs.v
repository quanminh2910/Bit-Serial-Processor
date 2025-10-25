// ===========================================================
// rv32i_core_bs.v : Minimal single-issue RV32I core
// ===========================================================
module rv32i_core_bs(
  input  wire        clk,
  input  wire        rstn,
  // memory interfaces
  output wire [31:0] imem_addr,
  input  wire [31:0] imem_instr,
  output reg  [31:0] dmem_addr,
  output reg  [31:0] dmem_wdata,
  output reg  [3:0]  dmem_we,
  input  wire [31:0] dmem_rdata,
  // debug
  output wire [31:0] leds
);
  reg [31:0] pc;
  assign imem_addr = pc;
  assign leds = pc;

  // decode fields
  wire [6:0] opcode = imem_instr[6:0];
  wire [2:0] funct3 = imem_instr[14:12];
  wire [6:0] funct7 = imem_instr[31:25];
  wire [4:0] rd  = imem_instr[11:7];
  wire [4:0] rs1 = imem_instr[19:15];
  wire [4:0] rs2 = imem_instr[24:20];

  // immediates
  wire [31:0] imm_i = {{20{imem_instr[31]}}, imem_instr[31:20]};
  wire [31:0] imm_s = {{20{imem_instr[31]}}, imem_instr[31:25], imem_instr[11:7]};
  wire [31:0] imm_b = {{19{imem_instr[31]}}, imem_instr[31], imem_instr[7],
                       imem_instr[30:25], imem_instr[11:8], 1'b0};
  wire [31:0] imm_u = {imem_instr[31:12], 12'b0};
  wire [31:0] imm_j = {{11{imem_instr[31]}}, imem_instr[31], imem_instr[19:12],
                       imem_instr[20], imem_instr[30:21], 1'b0};

  // register file
  wire [31:0] rs1d, rs2d;
  reg  [4:0]  wb_rd;   reg wb_we;
  reg  [31:0] wb_wd;
  regfile32x32 RF(.clk(clk),.rstn(rstn),
                  .rs1(rs1),.rs2(rs2),.rd(wb_rd),
                  .wd(wb_wd),.we(wb_we),
                  .rd1(rs1d),.rd2(rs2d));

  // ALU
  reg alu_start; reg [3:0] alu_op; reg [31:0] alu_a, alu_b;
  wire [31:0] alu_res; wire alu_done;
  bitserial_alu ALU(.clk(clk),.rstn(rstn),
                    .start(alu_start),.op(alu_op),
                    .a(alu_a),.b(alu_b),
                    .result(alu_res),.done(alu_done));

  // FSM
  localparam S_FETCH=0,S_DECODE=1,S_EXEC=2,S_MEM=3,S_WB=4;
  reg [2:0] state;

  always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
      state<=S_FETCH; pc<=0; alu_start<=0; wb_we<=0; dmem_we<=0;
    end else begin
      case(state)
        S_FETCH: state<=S_DECODE;

        S_DECODE: begin
          alu_start<=0; wb_we<=0; dmem_we<=0;
          case(opcode)
            7'b0110011: begin // R-type
              alu_a<=rs1d; alu_b<=rs2d;
              case(funct3)
                3'b000: alu_op<=(funct7[5]?1:0);
                3'b111: alu_op<=2;
                3'b110: alu_op<=3;
                3'b100: alu_op<=4;
                default: alu_op<=15;
              endcase
              alu_start<=1; state<=S_EXEC;
            end
            7'b0010011: begin // ADDI
              alu_a<=rs1d; alu_b<=imm_i; alu_op<=0;
              alu_start<=1; state<=S_EXEC;
            end
            7'b0000011: begin // LW
              alu_a<=rs1d; alu_b<=imm_i; alu_op<=0;
              alu_start<=1; state<=S_EXEC;
            end
            7'b0100011: begin // SW
              alu_a<=rs1d; alu_b<=imm_s; alu_op<=0;
              alu_start<=1; state<=S_EXEC;
            end
            7'b1100011: begin // BEQ
              alu_a<=rs1d; alu_b<=rs2d; alu_op<=1;
              alu_start<=1; state<=S_EXEC;
            end
            7'b1101111: begin // JAL
              wb_we<=1; wb_rd<=rd; wb_wd<=pc+4;
              pc<=pc+imm_j; state<=S_WB;
            end
            default: begin pc<=pc+4; state<=S_FETCH; end
          endcase
        end

        S_EXEC: begin
          alu_start<=0;
          if(alu_done) begin
            case(opcode)
              7'b0110011,7'b0010011: begin
                wb_we<=1; wb_rd<=rd; wb_wd<=alu_res; state<=S_WB;
              end
              7'b0000011: begin
                dmem_addr<=alu_res; dmem_we<=0; state<=S_MEM;
              end
              7'b0100011: begin
                dmem_addr<=alu_res; dmem_wdata<=rs2d;
                dmem_we<=4'b1111; state<=S_MEM;
              end
              7'b1100011: begin
                pc <= (alu_res==0)? pc+imm_b : pc+4;
                state<=S_FETCH;
              end
              default: begin pc<=pc+4; state<=S_FETCH; end
            endcase
          end
        end

        S_MEM: begin
          if(dmem_we!=0) begin dmem_we<=0; pc<=pc+4; state<=S_FETCH; end
          else begin wb_we<=1; wb_rd<=rd; wb_wd<=dmem_rdata; state<=S_WB; end
        end

        S_WB: begin wb_we<=0; pc<=pc+4; state<=S_FETCH; end
      endcase
    end
  end
endmodule
