// cla64_hier.v
// BONUS -- open-ended. No detailed scaffold is provided; this is meant to
// be a genuine design exercise. Not required for lab submission.
//
// You will likely need to modify cla4.v (or add signals alongside it) so
// that block-generate/block-propagate summaries of its own Gi, Pi signals
// are exposed as outputs, since the second-level lookahead unit below
// needs them. As with every module in this lab from Task 2 onward, every
// gate/assign you add should carry an explicit delay.
//
// Starting point (from Tutorial 3, Q4(d)):
//   - Reuse 16 four-bit CLA blocks (your cla4.v) -- their internal logic
//     doesn't change.
//   - For each block k, define:
//       Gblk_k = "this block produces a carry regardless of its incoming
//                 carry" -- a Boolean function of that block's own 4
//                 bit-level Gi, Pi signals.
//       Pblk_k = "an incoming carry sails straight through this whole
//                 block" -- likewise a function of its own Gi, Pi.
//   - Build a second-level lookahead unit -- structurally identical to
//     cla4.v, just one level up -- that computes each block's carry-in
//     directly from Gblk_0..Gblk_15, Pblk_0..Pblk_15, and cin, instead of
//     rippling block to block.
//
// To test this, wire it into dut.v as a fourth option (copy the pattern
// used for the other three) and run it through the same tb.v. Compare
// your final delay to cla64_blocked.v from Task 4.

module cla64_hier(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // TODO: your hierarchical design goes here.
  wire [63:0] p, g;
  wire [15:0] Gblk, Pblk;
  wire [16:0] cinblk;   // cinblk[0]=cin, cinblk[k]=carry into block k (k=1..15), cinblk[16]=cout

  assign cinblk[0] = cin;

  // bit-level P/G (needed only to build the block-level Gblk/Pblk below)
  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin : gen_pg
      xor #(2) (p[i], a[i], b[i]);
      and #(2) (g[i], a[i], b[i]);
    end
  endgenerate

  // block generate/propagate: does block k produce/pass a carry on its own?
  genvar k;
  generate
    for (k = 0; k < 16; k = k + 1) begin : gen_blk_pg
      wire t1, t2, t3;
      and #(2) (t1, p[4*k+3], g[4*k+2]);
      and #(2) (t2, p[4*k+3], p[4*k+2], g[4*k+1]);
      and #(2) (t3, p[4*k+3], p[4*k+2], p[4*k+1], g[4*k]);
      or  #(2) (Gblk[k], g[4*k+3], t1, t2, t3);
      and #(2) (Pblk[k], p[4*k], p[4*k+1], p[4*k+2], p[4*k+3]);
    end
  endgenerate

  // second-level lookahead: each block's carry-in, computed directly
  // from Gblk/Pblk and cin -- no rippling between blocks.
  assign #(2) cinblk[1] = Gblk[0] | (Pblk[0] & cin);
  assign #(2) cinblk[2] = Gblk[1] | (Pblk[1] & Gblk[0]) | (Pblk[0] & Pblk[1] & cin);
  assign #(2) cinblk[3] = Gblk[2] | (Pblk[2] & Gblk[1]) | (Pblk[1] & Pblk[2] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & cin);
  assign #(2) cinblk[4] = Gblk[3] | (Pblk[3] & Gblk[2]) | (Pblk[2] & Pblk[3] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & cin);
  assign #(2) cinblk[5] = Gblk[4] | (Pblk[4] & Gblk[3]) | (Pblk[3] & Pblk[4] & Gblk[2]) | (Pblk[2] & Pblk[3] & Pblk[4] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & cin);
  assign #(2) cinblk[6] = Gblk[5] | (Pblk[5] & Gblk[4]) | (Pblk[4] & Pblk[5] & Gblk[3]) | (Pblk[3] & Pblk[4] & Pblk[5] & Gblk[2]) | (Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & cin);
  assign #(2) cinblk[7] = Gblk[6] | (Pblk[6] & Gblk[5]) | (Pblk[5] & Pblk[6] & Gblk[4]) | (Pblk[4] & Pblk[5] & Pblk[6] & Gblk[3]) | (Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Gblk[2]) | (Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & cin);
  assign #(2) cinblk[8] = Gblk[7] | (Pblk[7] & Gblk[6]) | (Pblk[6] & Pblk[7] & Gblk[5]) | (Pblk[5] & Pblk[6] & Pblk[7] & Gblk[4]) | (Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Gblk[3]) | (Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Gblk[2]) | (Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & cin);
  assign #(2) cinblk[9] = Gblk[8] | (Pblk[8] & Gblk[7]) | (Pblk[7] & Pblk[8] & Gblk[6]) | (Pblk[6] & Pblk[7] & Pblk[8] & Gblk[5]) | (Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Gblk[4]) | (Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Gblk[3]) | (Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Gblk[2]) | (Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & cin);
  assign #(2) cinblk[10] = Gblk[9] | (Pblk[9] & Gblk[8]) | (Pblk[8] & Pblk[9] & Gblk[7]) | (Pblk[7] & Pblk[8] & Pblk[9] & Gblk[6]) | (Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Gblk[5]) | (Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Gblk[4]) | (Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Gblk[3]) | (Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Gblk[2]) | (Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & cin);
  assign #(2) cinblk[11] = Gblk[10] | (Pblk[10] & Gblk[9]) | (Pblk[9] & Pblk[10] & Gblk[8]) | (Pblk[8] & Pblk[9] & Pblk[10] & Gblk[7]) | (Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Gblk[6]) | (Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Gblk[5]) | (Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Gblk[4]) | (Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Gblk[3]) | (Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Gblk[2]) | (Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & cin);
  assign #(2) cinblk[12] = Gblk[11] | (Pblk[11] & Gblk[10]) | (Pblk[10] & Pblk[11] & Gblk[9]) | (Pblk[9] & Pblk[10] & Pblk[11] & Gblk[8]) | (Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Gblk[7]) | (Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Gblk[6]) | (Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Gblk[5]) | (Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Gblk[4]) | (Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Gblk[3]) | (Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Gblk[2]) | (Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & cin);
  assign #(2) cinblk[13] = Gblk[12] | (Pblk[12] & Gblk[11]) | (Pblk[11] & Pblk[12] & Gblk[10]) | (Pblk[10] & Pblk[11] & Pblk[12] & Gblk[9]) | (Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Gblk[8]) | (Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Gblk[7]) | (Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Gblk[6]) | (Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Gblk[5]) | (Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Gblk[4]) | (Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Gblk[3]) | (Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Gblk[2]) | (Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & cin);
  assign #(2) cinblk[14] = Gblk[13] | (Pblk[13] & Gblk[12]) | (Pblk[12] & Pblk[13] & Gblk[11]) | (Pblk[11] & Pblk[12] & Pblk[13] & Gblk[10]) | (Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Gblk[9]) | (Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Gblk[8]) | (Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Gblk[7]) | (Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Gblk[6]) | (Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Gblk[5]) | (Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Gblk[4]) | (Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Gblk[3]) | (Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Gblk[2]) | (Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & cin);
  assign #(2) cinblk[15] = Gblk[14] | (Pblk[14] & Gblk[13]) | (Pblk[13] & Pblk[14] & Gblk[12]) | (Pblk[12] & Pblk[13] & Pblk[14] & Gblk[11]) | (Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Gblk[10]) | (Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Gblk[9]) | (Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Gblk[8]) | (Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Gblk[7]) | (Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Gblk[6]) | (Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Gblk[5]) | (Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Gblk[4]) | (Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Gblk[3]) | (Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Gblk[2]) | (Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & cin);
  assign #(2) cinblk[16] = Gblk[15] | (Pblk[15] & Gblk[14]) | (Pblk[14] & Pblk[15] & Gblk[13]) | (Pblk[13] & Pblk[14] & Pblk[15] & Gblk[12]) | (Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & Gblk[11]) | (Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & Gblk[10]) | (Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & Gblk[9]) | (Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & Gblk[8]) | (Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & Gblk[7]) | (Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & Gblk[6]) | (Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & Gblk[5]) | (Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & Gblk[4]) | (Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & Gblk[3]) | (Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & Gblk[2]) | (Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & Gblk[1]) | (Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & Gblk[0]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & cin);

  assign cout = cinblk[16];

  // sixteen 4-bit CLA blocks -- each one's internal (bit-level) carry
  // logic is unchanged; only its carry-IN now comes from the second-level
  // unit above instead of the previous block's cout.
  cla4 block0  (.a(a[3:0]),   .b(b[3:0]),   .cin(cinblk[0]),  .sum(sum[3:0]),   .cout());
  cla4 block1  (.a(a[7:4]),   .b(b[7:4]),   .cin(cinblk[1]),  .sum(sum[7:4]),   .cout());
  cla4 block2  (.a(a[11:8]),  .b(b[11:8]),  .cin(cinblk[2]),  .sum(sum[11:8]),  .cout());
  cla4 block3  (.a(a[15:12]), .b(b[15:12]), .cin(cinblk[3]),  .sum(sum[15:12]), .cout());
  cla4 block4  (.a(a[19:16]), .b(b[19:16]), .cin(cinblk[4]),  .sum(sum[19:16]), .cout());
  cla4 block5  (.a(a[23:20]), .b(b[23:20]), .cin(cinblk[5]),  .sum(sum[23:20]), .cout());
  cla4 block6  (.a(a[27:24]), .b(b[27:24]), .cin(cinblk[6]),  .sum(sum[27:24]), .cout());
  cla4 block7  (.a(a[31:28]), .b(b[31:28]), .cin(cinblk[7]),  .sum(sum[31:28]), .cout());
  cla4 block8  (.a(a[35:32]), .b(b[35:32]), .cin(cinblk[8]),  .sum(sum[35:32]), .cout());
  cla4 block9  (.a(a[39:36]), .b(b[39:36]), .cin(cinblk[9]),  .sum(sum[39:36]), .cout());
  cla4 block10 (.a(a[43:40]), .b(b[43:40]), .cin(cinblk[10]), .sum(sum[43:40]), .cout());
  cla4 block11 (.a(a[47:44]), .b(b[47:44]), .cin(cinblk[11]), .sum(sum[47:44]), .cout());
  cla4 block12 (.a(a[51:48]), .b(b[51:48]), .cin(cinblk[12]), .sum(sum[51:48]), .cout());
  cla4 block13 (.a(a[55:52]), .b(b[55:52]), .cin(cinblk[13]), .sum(sum[55:52]), .cout());
  cla4 block14 (.a(a[59:56]), .b(b[59:56]), .cin(cinblk[14]), .sum(sum[59:56]), .cout());
  cla4 block15 (.a(a[63:60]), .b(b[63:60]), .cin(cinblk[15]), .sum(sum[63:60]), .cout());

endmodule
