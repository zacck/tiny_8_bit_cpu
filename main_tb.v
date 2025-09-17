`timescale 1ns / 1ps

module tb_tiny_cpu; 

reg CLK = 0; 
wire led_red, led_green, led_blue; 

tiny_cpu dut (
	.CLK(CLK),
	.led_red(led_red), 
	.led_green(led_green), 
	.led_blue(led_blue)
);


//12 mhz clock 
always #42 CLK = ~CLK;

initial begin 
	dut.R[0] <= 0;
end

initial begin
	$display("T=%0t | slow_clk=%b | PC=%0d | Instr=%b | R1=%0d | R2=%0d | LEDs={R:%b G:%b B:%b}",
		$time, dut.slow_clk, dut.PC, 
		dut.ROM[dut.PC],
		dut.R[1], dut.R[2],
		led_red, led_green, led_blue);
end

 
integer i;

initial begin
	$dumpvars(0, tb_tiny_cpu);

	/* run cpu for some cycles say 5 */
	for(i = 0; i < 50; i = i + 1) begin
		@(posedge CLK); 

		/* R0 is always 0 */
		if(dut.R[0] !== 0) begin
			$display("Error R[0] = %d, expected 0", dut.R[0]);
			if(!`APIO_SIM) $fatal(1, "R0 changed value!");
		end

		if({led_red, led_green, led_blue} !== dut.R[dut.ROM[dut.PC][3:0]][2:0]) begin
			$display("Error LED state mismatch");
			if(!`APIO_SIM) $fatal(2,"FAIL: Led Mismatch | expected=%b got=%b (PC=%0d)", 
				dut.R[dut.ROM[dut.PC][3:0]][2:0],
				{led_red, led_green, led_blue},
				dut.PC); 
		end

		if(dut.PC == 3 && dut.R[1] !== 1) begin
			$display("INC instruction not computed"); 
			if(!`APIO_SIM) $fatal(3, "FAIL expected R[1] = 1 after INC got %0d", 
				dut.R[1]);
		end 
		
	end
	

	$display("All tests Passed");
	$finish;
end

endmodule
