`timescale 1ns / 1ps
module pream_Pay #(
parameter signed A = 16384,
parameter SAMPLES_PER_BIT = 16,
parameter PREAMBLE_LEN = 16,
parameter PAYLOAD_BITS = 12,
parameter REPEAT_TIMES = 10
)(
input wire clk,
input wire rst,
output reg signed [15:0] I_out,
output reg signed [15:0] Q_out,
output reg done
);


reg [1:0] temp_mem [0:1054];
reg [10:0] counter;
reg [1:0] symbol;


initial begin
$readmemb("sim/bin.mem", temp_mem);
end


always @(posedge clk or posedge rst) begin
if (rst) begin
counter <= 0;
done <= 1'b0;
end else begin
if (counter < 1505) begin
counter <= counter + 1;
done <= 1'b0;
end else begin
counter <= 0;
done <= 1'b1; // pulse done when sequence wraps
end
end
end


always @(*) begin
symbol = temp_mem[counter][1:0];
case (symbol)
2'b00: begin I_out = -A; Q_out = -A; end
2'b01: begin I_out = -A; Q_out = A; end
2'b10: begin I_out = A; Q_out = -A; end
2'b11: begin I_out = A; Q_out = A; end
default: begin I_out = 0; Q_out = 0; end
endcase
end


endmodule
