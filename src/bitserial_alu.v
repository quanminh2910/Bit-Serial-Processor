// ===========================================================
// bitserial_alu.v : Bit-serial RV32I ALU
// ===========================================================
module bitserial_alu(
    input  wire        clk,
    input  wire        rstn,
    input  wire        start,
    input  wire [3:0]  op,
    input  wire [31:0] a,
    input  wire [31:0] b,
    output reg  [31:0] result,
    output reg         done
);
  // op encodings
  localparam OP_ADD = 4'd0,
             OP_SUB = 4'd1,
             OP_AND = 4'd2,
             OP_OR  = 4'd3,
             OP_XOR = 4'd4,
             OP_SLL = 4'd5,
             OP_SRL = 4'd6,
             OP_SRA = 4'd7;

  reg [5:0] bitcnt;
  reg running;
  reg [31:0] A, B, RES;
  reg carry;
  reg [4:0] shamt;
  reg [3:0] op_reg;

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      running <= 0; done <= 0; bitcnt <= 0;
      result <= 0; RES <= 0; A <= 0; B <= 0;
      carry <= 0; shamt <= 0; op_reg <= 4'hf;
    end else begin
      if (!running) begin
        done <= 0;
        if (start) begin
          running <= 1;
          op_reg  <= op;
          A <= a;
          B <= b;
          RES <= 0;
          carry <= (op==OP_SUB);
          shamt <= b[4:0];
          bitcnt <= 0;
        end
      end else begin
        // core bit-serial operation
        case (op_reg)
          OP_ADD, OP_SUB, OP_AND, OP_OR, OP_XOR: begin
            if (bitcnt < 32) begin
              wire abit = A[0];
              wire bbit = (op_reg==OP_SUB) ? ~B[0] : B[0];
              reg outb;
              case (op_reg)
                OP_ADD, OP_SUB: begin
                  outb  = abit ^ bbit ^ carry;
                  carry = (abit & bbit) | (abit & carry) | (bbit & carry);
                end
                OP_AND: outb = abit & bbit;
                OP_OR : outb = abit | bbit;
                OP_XOR: outb = abit ^ bbit;
                default: outb = 0;
              endcase
              RES[bitcnt] <= outb;
              A <= A >> 1;  B <= B >> 1;
              bitcnt <= bitcnt + 1;
            end else begin
              result <= RES;
              running <= 0; done <= 1;
            end
          end
          OP_SLL: begin
            if (bitcnt < shamt) begin
              A <= (A << 1); bitcnt <= bitcnt + 1;
            end else begin result <= A; running <= 0; done <= 1; end
          end
          OP_SRL: begin
            if (bitcnt < shamt) begin
              A <= (A >> 1); bitcnt <= bitcnt + 1;
            end else begin result <= A; running <= 0; done <= 1; end
          end
          OP_SRA: begin
            if (bitcnt < shamt) begin
              A <= {A[31], A[31:1]}; bitcnt <= bitcnt + 1;
            end else begin result <= A; running <= 0; done <= 1; end
          end
          default: begin result <= 0; running <= 0; done <= 1; end
        endcase
      end
    end
  end
endmodule
