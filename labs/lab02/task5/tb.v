// tb.v

// Self-checking testbench for alu.v.

module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  reg  [3:0] expected;
  integer errors;

  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  initial begin

    errors = 0;

    // Same operands, first ADD then SUB: changing only op should update result.
    t_a = 4'd7; t_b = 4'd3; t_op = 0;
    #5;
    expected = t_a + t_b;
    if (t_result !== expected) begin
      $display("FAIL: a=%0d b=%0d op=%b got=%0d expected=%0d",
               t_a, t_b, t_op, t_result, expected);
      errors = errors + 1;
    end

    t_op = 1;
    #5;
    expected = t_a - t_b;
    if (t_result !== expected) begin
      $display("FAIL: a=%0d b=%0d op=%b got=%0d expected=%0d",
               t_a, t_b, t_op, t_result, expected);
      errors = errors + 1;
    end

    // Change operands and test ADD again.
    t_a = 4'd5; t_b = 4'd2; t_op = 0;
    #5;
    expected = t_a + t_b;
    if (t_result !== expected) begin
      $display("FAIL: a=%0d b=%0d op=%b got=%0d expected=%0d",
               t_a, t_b, t_op, t_result, expected);
      errors = errors + 1;
    end

    // Change operands and test SUB again.
    t_a = 4'd12; t_b = 4'd5; t_op = 1;
    #5;
    expected = t_a - t_b;
    if (t_result !== expected) begin
      $display("FAIL: a=%0d b=%0d op=%b got=%0d expected=%0d",
               t_a, t_b, t_op, t_result, expected);
      errors = errors + 1;
    end

    $display("Summary: %0d passed out of 4", 4-errors);

    $finish;

  end

endmodule
