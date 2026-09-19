// and_df.v - Dataflow with continuous assignment delay
module and_df #(parameter delay_val = 3) (
    input  a,
    input  b,
    output y
);
    assign #delay_val y = a & b;
endmodule