`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/11 19:35:28
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
 
module test(
    );
reg clk;
reg [2:0] sw;
wire [7:0] SG;
wire [3:0] AN;
wire finished;
initial sw=3'b000;
control_unit run(.CLK(clk),.SW(sw),.SG(SG),.AN(AN),.finished(finished));
initial clk=0;
always #5 clk=~clk;
endmodule
