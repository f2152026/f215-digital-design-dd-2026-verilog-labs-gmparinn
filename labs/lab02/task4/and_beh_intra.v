// and_beh_intra.v - Behavioral with intra-assignment delay
module and_beh_intra #(parameter delay_val = 3) (
    input      a,
    input      b,
    output reg y
);
    always @(*) begin
        y = #delay_val a & b;
    end
endmodule