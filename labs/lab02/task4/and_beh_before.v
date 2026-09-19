// and_beh_before.v - Behavioral with delay before assignment
module and_beh_before #(parameter delay_val = 3) (
    input      a,
    input      b,
    output reg y
);
    always @(*) begin
        #delay_val y = a & b;
    end
endmodule