module tiny_cpu (
  // outputs
  output wire led_red  , // Red
  output wire led_blue , // Blue
  output wire led_green  // Green
);
  
  /*Clock Output, Counter Register and clock setup*/
  wire        int_osc            ;
  reg  [27:0] frequency_counter_i;

  /* verilator lint_off PINMISSING */
  SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
  /* verilator lint_on PINMISSING */

  // CPU  General Purpose register
  reg [31:0] R [0:15]; 
  //Program Counter 
  reg [3:0] PC; 
  //ROM Memory 16 registers whose size is 8 bits
  reg [7:0] ROM [0:15];

  /*Run the FPGA oscillator*/
  always @(posedge int_osc) begin
    frequency_counter_i <= frequency_counter_i + 1'b1;
  end

  /*Divide the the oscillator output by 2^25*/

  wire slow_clk = frequency_counter_i[24];

  /*
   *  These are placeholder instructions before we have to deal with
   *  a compiler. 
  *  The lower 4 bits now become the register to use
   */
  initial begin
	  ROM[0] = 8'b0001_0000; // go to next instruction
	  ROM[1] = 8'b0010_0000; // Output result of computation
	  ROM[2] = 8'b0001_0001; 
	  ROM[3] = 8'b0010_0001;
 	  ROM[4] = 8'b0001_0010;  
	  ROM[5] = 8'b0010_0010;  
	  ROM[6] = 8'b0001_0011;  
	  ROM[7] = 8'b0010_0011;  
	  ROM[8] = 8'b0001_0100;  
	  ROM[9] = 8'b0010_0100;
	  ROM[10] = 8'b0001_0101; 
	  ROM[11] = 8'b0010_0101;
 	  ROM[12] = 8'b0001_0110;  
	  ROM[13] = 8'b0010_0110;  
	  ROM[14] = 8'b0001_0111;  
	  ROM[15] = 8'b0010_0111;  
  end
  
  /*
   *  The instructions upper 4 bits are the opcode 
   *  0001 INC , 0010  ADD, 0011 SUB, 0100 AND, 0101 OR, 
   *  0110 XOR , 0111 SHL, 1000 SHR
   */ 
  always @(posedge slow_clk) begin
  	case(ROM[PC][7:4])
	  4'b0001: R[ROM[PC][3:0]] <= R[ROM[PC][3:0]] + 1;	//INC 
	  4'b0010: R[ROM[PC][3:0]] <= R[ROM[PC][3:0]] + R[0];   //ADD
	  4'b0011: R[ROM[PC][3:0]] <= R[ROM[PC][3:0]] - R[0];   //SUB
	  4'b0100: R[ROM[PC][3:0]] <= R[ROM[PC][3:0]] & R[1];   //AND
	  4'b0101: R[ROM[PC][3:0]] <= R[ROM[PC][3:0]] | R[1];   //OR
	  4'b0110: R[ROM[PC][3:0]] <= R[ROM[PC][3:0]] ^ R[1];   //XOR
	  4'b0111: R[ROM[PC][3:0]] <= R[ROM[PC][3:0]] << 1;     //SHL
	  4'b1000: R[ROM[PC][3:0]] <= R[ROM[PC][3:0]] >> 1;     //SHR
	  default: ;
	endcase
	PC <= PC + 1;
	/* R0 is always a 0*/
	R[0] <= 32'b0; 
  end


  SB_RGBA_DRV RGB_DRIVER (
    .RGBLEDEN(1'b1			),
    .RGB0PWM (R[ROM[PC][3:0]][2]	),
    .RGB1PWM (R[ROM[PC][3:0]][1]	),
    .RGB2PWM (R[ROM[PC][3:0]][0]	),
    .CURREN  (1'b1 			),
    .RGB0    (led_green 		), //Actual Hardware connection
    .RGB1    (led_blue  		),
    .RGB2    (led_red   		)
  );
  defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";

endmodule
