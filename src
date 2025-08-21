`timescale 1ns / 1ps
module Autocorrelation #(
parameter integer SIZE = 256,
parameter integer DELAY = 48,
parameter integer DATA_WIDTH = 16,
parameter integer MODE = 1 // 0 = CONV, 1 = CORR (flip coeff in MAC)
)(
input wire clk,
input wire rst,
input wire signed [DATA_WIDTH-1:0] data_in,
input wire coeff_load_en, // assert when streaming coeffs
input wire signed [DATA_WIDTH-1:0] coeff_in, // coeff stream
output reg signed [2*DATA_WIDTH-1:0] data_out
);


// Memories
reg signed [DATA_WIDTH-1:0] coeff_mem [0:SIZE-1];
reg signed [DATA_WIDTH-1:0] shift_reg [0:SIZE-1];


// Coeff load control
reg [$clog2(SIZE)-1:0] coeff_index = 0;
reg coeff_loaded = 0;


integer i, j;
reg signed [2*DATA_WIDTH-1:0] acc;
reg signed [2*DATA_WIDTH-1:0] prod;


// ---------------- Coeff loader (natural order unless load reversed externally) ----------------
always @(posedge clk or posedge rst) begin
if (rst) begin
coeff_index <= 0;
coeff_loaded <= 1'b0;
end else begin
if (!coeff_loaded && coeff_load_en) begin
coeff_mem[coeff_index] <= coeff_in; // natural order
coeff_index <= coeff_index + 1;
if (coeff_index == SIZE-1) coeff_loaded <= 1'b1;
end
end
end


// ---------------- Shift register (newest at index 0) -----------------
always @(posedge clk or posedge rst) begin
if (rst) begin
for (i = 0; i < SIZE; i = i + 1)
shift_reg[i] <= '0;
end else begin
for (i = SIZE-1; i > 0; i = i - 1)
shift_reg[i] <= shift_reg[i-1];
shift_reg[0] <= data_in;
end
end


// ---------------- MAC: supports convolution (MODE=0) or correlation (MODE=1) --------------
always @(posedge clk or posedge rst) begin
if (rst) begin
acc <= '0;
data_out <= '0;
end else if (coeff_loaded) begin
acc = '0; // clear accumulator
for (j = 0; j < SIZE; j = j + 1) begin
if (j + DELAY < SIZE) begin
if (MODE == 0) begin
// convolution: natural coeff index
prod = $signed(shift_reg[j + DELAY]) * $signed(coeff_mem[j]);
end else begin
// correlation: use flipped coefficient index
prod = $signed(shift_reg[j + DELAY]) * $signed(coeff_mem[SIZE-1 - j]);
end
acc = acc + prod;
end
end
data_out <= acc;
end
end


endmodule
