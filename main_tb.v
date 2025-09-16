`timescale 1ns / 1ps

module tb_tiny_cpu; 


reg CLK = 0; 
wire led_red, led_green, led_blue; 

tiny_cpu #() dut (
	.CLK(CLK),
	.led_red(led_red), 
	.led_green(led_green), 
	.led_blue(led_blue)
);


//12 mhz clock 
always #42 CLK = ~CLK;

reg expected_led = 0; 

integer i; 

initial begin
	$dumpvars(0, tb_tiny_cpu);

	// simulate 20 clock cycles
	for(i = 0; i < 20; i = i + 1) begin 
		@(posedge CLK); 

	 $finish; 
	end 
end

endmodule
