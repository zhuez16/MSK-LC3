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
reg push;
initial sw=3'b000;
init run(.CLK(clk),.SW(sw),.SG(SG),.AN(AN),.finished(finished),.one_step(push));
initial clk=0;
always #5 clk=~clk;
initial push=0;
always #500 push=~push;
endmodule
