`timescale 1ns / 1ps

module tiny_cpu_tb;

  // Clock and DUT signals
  reg CLK = 0;
  wire led_red, led_green, led_blue;


  // Instantiate the tiny_cpu
  tiny_cpu dut (
      .CLK      (CLK),
      .led_red  (led_red),
      .led_green(led_green),
      .led_blue (led_blue)
  );

  // Generate clock (adjust period as needed)
  always #10 CLK = ~CLK;  // 50 MHz clock

  // Track register values for verification
  integer cycle_count = 0;
  integer error_count = 0;
  integer slow_clock_cycles = 0;

  initial begin
    $dumpvars(0, tiny_cpu_tb);  // Dump all variables for waveform viewing

    // Wait for initial values to settle
    #100;

    // Monitor the execution for a number of slow clock cycles
    for (
        slow_clock_cycles = 0; slow_clock_cycles < 20; slow_clock_cycles = slow_clock_cycles + 1
    ) begin
      // Wait for a rising edge of the slow clock
      @(posedge dut.slow_clk);

      $display("Slow cycle %0d: PC=%0d, IR=%h, LEDs: R=%b, G=%b, B=%b", slow_clock_cycles, dut.PC,
               dut.IR, led_red, led_green, led_blue);

      // Display register values
      if (slow_clock_cycles > 0) begin
        $display("  Registers: x1=%h, x2=%h, x3=%h, x4=%h, x5=%h", dut.R[1], dut.R[2], dut.R[3],
                 dut.R[4], dut.R[5]);
      end
    end

    // Final verification
    $display("\n=== Final Results ===");
    $display("x1 (should be 5): %h", dut.R[1]);
    $display("x2 (should be 3): %h", dut.R[2]);
    $display("x3 (should be 8): %h", dut.R[3]);  // 5 + 3 = 8
    $display("x4 (should be 0): %h", dut.R[4]);
    $display("x5 (should be 9): %h", dut.R[5]);

    // Test LType & SType
    $display("x6 (after SW/LW should be 2A/42): %h", dut.R[1]);
    $display("x7 (base address, should be 0): %h", dut.R[2]);
    $display("x8 (load value, should be 2A/42): %h", dut.R[3]);
    $display("x9 (copy of x3, should be 2A/42): %h", dut.R[4]);




    // Verify expected results
    assert (dut.R[1] === 32'h5)
    else begin
      error_count++;
      $error("x1 should be 5, got %h", dut.R[1]);
    end

    assert (dut.R[2] === 32'h3)
    else begin
      error_count++;
      $error("x2 should be 3, got %h", dut.R[2]);
    end

    assert (dut.R[3] === 32'h8)
    else begin
      error_count++;
      $error("x3 should be 8, got %h", dut.R[3]);
    end

    // STYPE & LTYPE

    assert (dut.R[1] === 32'h2A)
    else begin
      error_count++;
      $error("x1 should be 2A/42, got %h", dut.R[1]);
    end

    assert (dut.R[2] === 32'h0)
    else begin
      error_count++;
      $error("x2 should be 0, got %h", dut.R[2]);
    end

    assert (dut.R[3] === 32'h2A)
    else begin
      error_count++;
      $error("x3 should be 2A/42, got %h", dut.R[3]);
    end

    assert (dut.R[4] === 32'h2A)
    else begin
      error_count++;
      $error("x4 should be 2A/42, got %h", dut.R[4]);
    end

    $display("\nTest completed with %0d errors", error_count);

    if (error_count == 0) begin
      $display("TEST PASSED!");
    end else begin
      $display("TEST FAILED!");
    end

    $finish;
  end

endmodule
