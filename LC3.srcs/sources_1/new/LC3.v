`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/08 18:33:38
// Design Name: 
// Module Name: LC3
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

/*module memory(
input [15:0] bus,
input [15:0] new,
input [1:0] type,
input WE,
input clk,
output [15:0] out
);
parameter bus_to_out=2'b00;
parameter bus_to_MDR=2'b01;
parameter new_to_mem_bus=2'b10;
reg [15:0] MAR;
reg [15:0] MDR;
wire [15:0] tmp;
always@(*)
begin
    case (type)
        bus_to_out:
        begin
            MAR=bus;
            MDR=tmp;
        end
        bus_to_MDR:
        begin
            MAR=bus;
            MDR=tmp;
        end
    endcase
end
assign out=tmp;
endmodule*/



module REG_FILE(
input [2:0] DR,
input [15:0] newreg,
input [2:0] SR1,
input [2:0] SR2,
input LDREG,
input clk,
input [2:0] SWs,
output reg [15:0] SR1OUT,
output reg [15:0] SR2OUT,
output [7:0] SGs,
output [3:0] ANs
);
reg [15:0] regfile[0:7];
reg [1:0] p;
reg [3:0] out;
reg [3:0] ANout;
reg [16:0] count;
initial count=16'b0;
initial p=2'b00;
initial regfile[0]=16'd84;
initial regfile[1]=16'd96;
initial regfile[2]=16'b0;
initial regfile[3]=16'b0;
initial regfile[4]=16'b0;
initial regfile[5]=16'b0;
initial regfile[6]=16'b0;
initial regfile[7]=16'b0;
always@(*)
begin
    SR1OUT=regfile[SR1];
    SR2OUT=regfile[SR2];
end
always@(posedge clk)
begin
    if (count>11'd1000)
    begin
        count<=0;
        case (p)
            2'b00:
            begin
                out<=regfile[SWs][3:0];
                ANout=4'b1110;
            end
            2'b01:
            begin
                out<=regfile[SWs][7:4];
                ANout=4'b1101;
            end
            2'b10:
            begin
                out<=regfile[SWs][11:8];
                ANout=4'b1011;
            end
            2'b11:
            begin
                out<=regfile[SWs][15:12];
                ANout=4'b0111;
            end
        endcase
        p<=p+1;
    end
    else
        count<=count+1;
        
    if (LDREG==1)
    begin
        regfile[DR]=newreg;
    end
end
assign ANs=ANout;
dist_mem_gen_1 print(.a(out),.spo(SGs));
endmodule

module signal_edge(
input clk,
input button,
output button_redge);
reg button_r1,button_r2;
always@(posedge clk)
    button_r1<=button;
always@(posedge clk)
    button_r2<=button_r1;
assign button_redge=button_r1&(~button_r2);
endmodule

module init(
input CLK,
input [2:0] SW,
input run_to_halt,
input one_step,
output [7:0] SG,
output [3:0] AN,
output finished
);
wire out;
reg new_clk;
wire wd;
signal_edge(.clk(CLK),.button(one_step),.button_redge(out));
control_unit(.CLK(new_clk),.SW(SW),.SG(SG),.AN(AN),.finished(finished),.wd(wd));
always@(*)
begin
    if (run_to_halt==1)
        new_clk=CLK;
    else
        if (wd==1)
            new_clk=out;
        else
            new_clk=CLK;
end
endmodule

module control_unit(
input CLK,
input [2:0] SW,
output [7:0] SG,
output [3:0] AN,
output finished,
output wd
    );
reg [6:0] GateMAR;
reg [15:0] GateMDR;
reg [15:0] pc;
reg [15:0] IR;
wire [15:0] MDR;
reg [1:0] memtype;
reg [15:0] GateALU;
reg [15:0] ADDPC;
reg [2:0] DR;
reg [15:0] newreg;
reg [2:0] SR1;
reg [2:0] SR2;
reg [15:0] SR2MUX;
reg LDREG;
reg N,Z,P;
reg [1:0] type;
wire [15:0] SR1OUT;
wire [15:0] SR2OUT;
reg WE;
reg [15:0] SEXTPC;
parameter F1=6'b010000;
parameter F2=6'b010001;
parameter ADD=6'b000001;
parameter AND=6'b000101;
parameter NOT=6'b001001;
parameter BR=6'b000000;
parameter LD=6'b000010;
parameter LDI=6'b001010;
parameter LDR=6'b000110;
parameter LEA=6'b001110;
parameter ST=6'b000011;
parameter STI=6'b001011;
parameter STR=6'b000111;
parameter HALT=6'b001111;
parameter ADD1=6'b010010;
parameter ADD2=6'b010011;
parameter AND1=6'b010100;
parameter AND2=6'b010101;
parameter NOT1=6'b010110;
parameter NOT2=6'b010111;
parameter LD1=6'b011000;
parameter WD=6'b011001;
parameter ST1=6'b011010;
parameter LDR1=6'b011011;
parameter LDR2=6'b011100;
parameter STR1=6'b011101;
parameter LDI1=6'b011110;
parameter LDI2=6'b011111;
parameter STI1=6'b100000;
parameter STI2=6'b100001;
parameter start=6'b111111;
parameter changePC=6'b100010;
reg [5:0] curstate=start;
wire os_redge;
/*always@(*)
begin
    if (CLK==1)
    begin
    if (curstate==F1)
        curstate=F2;
    else if (curstate==F2)
    begin
        case (IR[15:12])
            4'b0001: curstate=ADD;
            4'b0101: curstate=AND;
            4'b0000: curstate=BR;
            4'b0010: curstate=LD;
            4'b1010: curstate=LDI;
            4'b0110: curstate=LDR;
            4'b1110: curstate=LEA;
            4'b0011: curstate=ST;
            4'b1011: curstate=STI;
            4'b0111: curstate=STR;
            4'b1111: curstate=HALT;
        endcase
    end
    else if (curstate==WD)
    begin
        curstate=F1;
    end
    else if (curstate==ADD)
        curstate=ADD1;
    else if (curstate==ADD1)
        curstate=ADD2;
    else if (curstate==ADD2)
        curstate=F1;
    else if (curstate==AND)
        curstate=AND1;
    else if (curstate==AND1)
        curstate=WD;
    else if (curstate==NOT)
        curstate=NOT1;
    else if (curstate==NOT1)
        curstate=WD;
    else if (curstate==ST)
        curstate=ST1;
    else if (curstate==ST1)
        curstate=WD;
    else if (curstate==LDR)
        curstate=LDR1;
    else if (curstate==LDR1)
        curstate=LDR2;
    else if (curstate==LDR2)
        curstate=WD;
    else if (curstate==STR)
        curstate=STR1;
    else if (curstate==STR1)
        curstate=WD;
    else if (curstate==LEA)
        curstate=WD;
    else if (curstate==LDI)
        curstate=LDI1;
    else if (curstate==LDI1)
        curstate=LDI2;
    else if (curstate==LDI2)
        curstate=WD;
    else if (curstate==BR)
        curstate=F1;
    else
        curstate=curstate;
    end
end*/
always@(posedge CLK)
begin
    if (newreg[14:0]>0 && newreg[15]==0)
    begin
        N=0;Z=0;P=1;
    end
    else if (newreg[15]==1)
    begin
        N=1;Z=0;P=0;
    end
    else
    begin
        N=0;Z=1;P=0;
    end
    
    if (curstate==start) // set up all the registers.
    begin
        GateMAR<=7'b0;
        GateMDR<=16'b0;
        pc<=16'b0;
        IR<=16'b0;
        memtype<=2'b0;
        GateALU<=16'b0;
        ADDPC<=16'b0;
        DR<=3'b0;
        newreg<=16'b0;
        SR1<=3'b0;
        SR2<=3'b0;
        SR2MUX<=16'b0;
        LDREG<=0;
        type<=0;
        WE<=0;
        SEXTPC<=0;
        curstate<=F1;
    end
    else if (curstate==F1)
    begin
        GateMAR<=pc[6:0];
        type<=0;
        WE<=0;
        pc<=pc+1;
        curstate=F2;
    end
    else if (curstate==F2)
    begin
        IR<=MDR;
        case (MDR[15:12])
            4'b0001: curstate<=ADD;
            4'b0101: curstate<=AND;
            4'b0000: curstate<=BR;
            4'b0010: curstate<=LD;
            4'b1010: curstate<=LDI;
            4'b0110: curstate<=LDR;
            4'b1110: curstate<=LEA;
            4'b0011: curstate<=ST;
            4'b1011: curstate<=STI;
            4'b0111: curstate<=STR;
            4'b1111: curstate<=HALT;
            4'b1001: curstate<=NOT;
        endcase
    end
    else if (curstate==WD)
    begin
        WE<=0;
        LDREG<=0;
        curstate<=F1;
    end
    else if (curstate==ADD)
    begin
        LDREG<=0;
        SR1<=IR[8:6];
        SR2<=IR[2:0];
        curstate<=ADD1;
    end
    else if (curstate==ADD1)
    begin
        if (IR[5]==0)
            SR2MUX<=SR2OUT;
        else
        begin
            if (IR[4]==0)
                SR2MUX[15:5]<=11'b0;
            else
                SR2MUX[15:5]<=11'b11111111111;
            SR2MUX[4:0]<=IR[4:0];
        end
        curstate<=ADD2;
    end
    else if (curstate==ADD2)
    begin
        newreg<=SR2MUX+SR1OUT;
        LDREG<=1;
        DR<=IR[11:9];
        curstate<=WD;
    end
    else if (curstate==AND)
    begin
        LDREG<=0;
        SR1<=IR[8:6];
        SR2<=IR[2:0];
        curstate<=AND1;
    end
    else if (curstate==AND1)
    begin
        if (IR[5]==0)
            SR2MUX<=SR2OUT;
        else
        begin
            if (IR[4]==0)
                SR2MUX[15:5]<=11'b0;
            else
                SR2MUX[15:5]<=11'b11111111111;
            SR2MUX[4:0]=IR[4:0];
        end
        curstate<=AND2;
    end
    else if (curstate==AND2)
    begin
        newreg<=SR2MUX&SR1OUT;
        LDREG<=1;
        DR<=IR[11:9];
        curstate<=WD;
    end
    else if (curstate==NOT)
    begin
        LDREG<=0;
        SR1<=IR[8:6];
        curstate<=NOT1;
    end
    else if (curstate==NOT1)
    begin
        DR<=IR[11:9];
        newreg<=~SR1OUT;
        LDREG<=1;
        curstate<=WD;
    end
    else if (curstate==LD)
    begin
        if (IR[8]==0)
            SEXTPC[15:9]<=7'b0;
        else
            SEXTPC[15:9]<=7'b1111111;
        SEXTPC[8:0]=IR[8:0];
        GateMAR<=pc[6:0]+IR[6:0];
        GateMDR<=16'b0;
        type<=2'b00;
        WE<=0;
        curstate<=LD1;
    end
    else if (curstate==LD1)
    begin
        DR<=IR[11:9];
        newreg<=MDR;
        SR1<=0;
        SR2<=0;
        LDREG=1;
        curstate<=WD;
    end
    else if (curstate==ST)
    begin
        SR1<=IR[11:9];
        curstate<=ST1;
    end
    else if (curstate==ST1)
    begin
        if (IR[8]==0)
            SEXTPC[15:9]<=7'b0;
        else
            SEXTPC[15:9]<=7'b1111111;
        SEXTPC[8:0]=IR[8:0];
        GateMAR<=pc[6:0]+IR[6:0];
        GateMDR<=SR1;
        type<=2'b01;
        WE<=1;
        curstate<=WD;
    end
    else if (curstate==LDR)
    begin
        SR2<=IR[8:6];
        curstate<=LDR1;
    end
    else if (curstate==LDR1)
    begin
        if (IR[5]==0)
            SEXTPC[15:6]<=10'b0;
        else
            SEXTPC[15:6]<=10'b1111111111;
        SEXTPC[5:0]=IR[5:0];
        GateMAR<=SR2OUT[6:0]+IR[6:0];
        GateMDR<=16'b0;
        type<=2'b00;
        WE<=0;
        curstate<=LDR2;
    end
    else if (curstate==LDR2)
    begin
        DR<=IR[11:9];
        newreg<=MDR;
        LDREG<=1;
        curstate<=WD;
    end
    else if (curstate==STR)
    begin
        SR2<=IR[8:6];
        SR1<=IR[11:9];
        curstate<=STR1;
    end
    else if (curstate==STR1)
    begin
        if (IR[5]==0)
            SEXTPC[15:6]<=10'b0;
        else
            SEXTPC[15:6]<=10'b1111111111;
        SEXTPC[5:0]=IR[5:0];
        GateMAR<=SR2OUT[6:0]+IR[6:0];
        GateMDR<=SR1OUT;
        type<=2'b01;
        WE<=1;
        curstate<=WD;
    end
    else if (curstate==LEA)
    begin
        if (IR[8]==0)
            SEXTPC[15:9]<=7'b0;
        else
            SEXTPC[15:9]<=7'b1111111;
        SEXTPC[8:0]=IR[8:0];
        newreg<=pc+IR;
        DR<=IR[11:9];
        LDREG<=1;
        curstate<=WD;
    end
    else if (curstate==LDI)
    begin
        if (IR[8]==0)
            SEXTPC[15:9]<=7'b0;
        else
            SEXTPC[15:9]<=7'b1111111;
        SEXTPC[8:0]=IR[8:0];
        GateMAR<=pc[6:0]+IR[6:0];
        GateMDR<=16'b0;
        type<=2'b00;
        WE<=0;
        curstate<=LDI1;
    end
    else if (curstate==LDI1)
    begin
        GateMAR<=MDR[6:0];
        type<=2'b00;
        WE<=0;
        curstate<=LDI2;
    end
    else if (curstate==LDI2)
    begin
        DR<=IR[11:9];
        newreg<=MDR;
        LDREG<=1;
        curstate=WD;
    end
    else if (curstate==STI)
    begin
        if (IR[8]==0)
            SEXTPC[15:9]<=7'b0;
        else
            SEXTPC[15:9]<=7'b1111111;
        SEXTPC[8:0]=IR[8:0];
        GateMAR<=pc[6:0]+IR[6:0];
        GateMDR<=16'b0;
        type<=2'b00;
        WE<=0;
        curstate<=STI1;
    end
    else if (curstate==STI1)
    begin
        SR2<=IR[11:9];
        LDREG<=0;
        curstate<=STI2;
    end
    else if (curstate==STI2)
    begin
        GateMAR<=MDR[6:0];
        GateMDR<=SR2OUT;
        type<=2'b01;
        WE<=1;
        curstate<=WD;
    end
    else if (curstate==BR)
    begin
        if (IR[11]&N==1 || IR[10]&Z==1 || IR[9]&P==1)
        begin
            if (IR[8]==0) SEXTPC[15:9]=7'b0;
            else SEXTPC[15:9]<=7'b1111111;
            SEXTPC[8:0]<=IR[8:0];
            curstate<=changePC;
        end
        else curstate<=WD;
    end
    else if (curstate==changePC)
    begin
        pc<=pc+SEXTPC;
        curstate<=WD;
    end
    else if (curstate==HALT)
        curstate<=HALT;
    else
        curstate<=F1;
end
assign finished=(curstate==HALT);
assign wd=(curstate==F1);
dist_mem_gen_0 run(.a(GateMAR),.d(GateMDR),.clk(~CLK),.we(WE),.spo(MDR));
//memory fetchmem(.bus(GateMAR),.new(GateMDR),.type(type),.WE(WE),.out(MDR));
REG_FILE fetchreg(.DR(DR),.SGs(SG),.SWs(SW),.ANs(AN),.newreg(newreg),.SR1(SR1),.SR2(SR2),.LDREG(LDREG),.clk(~CLK),.SR1OUT(SR1OUT),.SR2OUT(SR2OUT));
endmodule

/*
0010 0000 0100 0000
*/