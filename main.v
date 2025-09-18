module tiny_cpu (
  //Inputs 
  input CLK,
  // outputs
  output wire led_red  , // Red
  output wire led_blue , // Blue
  output wire led_green  // Green
);
  
  /* Counter Register for slowing clock*/
  reg  [20:0] frequency_counter_i;


  // CPU  General Purpose register
  reg [31:0] R [0:15]; 
  //Program Counter 
  reg [3:0] PC; 
  //ROM Memory 16 registers whose size is 8 bits
  reg [31:0] ROM [0:15];

  /* Wires to access registers */
  reg [31:0] IR; 

  wire [6:0] opcode = IR[6:0];
  wire [4:0] rd     = IR[11:7]; 
  wire [3:0] funct3 = IR[14:12];
  wire [4:0] rs1    = IR[19:15]; 
  wire [4:0] rs2    = IR[24:20];
  wire [6:0] funct7 = IR[31:25];

  wire signed [31:0] imm_i = {{20{IR[31]}}, IR[31:20]};

  /*hold computation for LED*/
  reg [4:0] last_written_reg; 


  /*Run the FPGA oscillator*/
  always @(posedge CLK) begin
    frequency_counter_i <= frequency_counter_i + 1'b1;
  end

  wire slow_clk = frequency_counter_i[19];

  /*
   *  These are placeholder instructions before we have to deal with
   *  a compiler. 
  *  The lower 4 bits now become the register to use
   */
  initial begin
	  ROM[0] = 32'h00500093;  // ADDI x1, x0, 5 
	  ROM[1] = 32'h00300113; // ADD1 x1, x2, 3 
	  ROM[2] = 32'h002081B3; // ADD x3, x1, 2
	  ROM[3] = 32'h0071F213; // ANDI x4, x3,7
 	  ROM[4] = 32'h0011E293; // ORI  x5, x3, 1
	  ROM[5] = 32'h00000000;  //NOPS
	  ROM[6] = 32'h00000000;  
	  ROM[7] = 32'h00000000;  
	  ROM[8] = 32'h00000000;  
	  ROM[9] = 32'h00000000;
	  ROM[10] = 32'h00000000; 
	  ROM[11] = 32'h00000000;
 	  ROM[12] = 32'h00000000;  
	  ROM[13] = 32'h00000000;  
	  ROM[14] = 32'h00000000;  
	  ROM[15] = 32'h00000000;
  end
  
  /* Actually run ourt CPU */
  always @(posedge slow_clk) begin
	  IR <= ROM[PC]; 

	  case(opcode)
		  //RTYPE
		  7'b0110011: begin
			  case(funct3)
				  3'b000: begin 
				  if(funct7 == 7'b0100000) R[rd] <= R[rs1] - R[rs2]; // SUB
				  else 			   R[rd] <= R[rs1] + R[rs2]; // ADD
			  end
		  	  3'b111: R[rd] <= R[rs1] & R[rs2]; //AND 
			  3'b110: R[rd] <= R[rs1] | R[rs2]; //OR
			  3'b100: R[rd] <= R[rs1] ^ R[rs2]; //XOR
			  default: ;
		  endcase
		  last_written_reg <= rd;
	  end
	  	7'b0010011: begin
		case (funct3)
			3'b000: R[rd] <= R[rs1] + imm_i; //ADDI
			3'b111: R[rd] <= R[rs1] & imm_i; //ANDI
			3'b110: R[rd] <= R[rs1] | imm_i; //ORI
			default: ;
		endcase
		last_written_reg <= rd; 
		end 
		default: ;
	endcase 
	PC <= PC + 1;
	/* R0 is always a 0*/
	R[0] <= 32'b0; 
  end

  assign led_blue = 	R[last_written_reg][2]; 
  assign led_green =	R[last_written_reg][1]; 
  assign led_red = 	R[last_written_reg][0];

endmodule
