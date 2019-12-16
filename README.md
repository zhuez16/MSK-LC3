# MSK-LC3

内存被缩小到仅有128*16的LC-3
支持ADD,AND,NOT,LD/ST,LDR/STR,LDI/STI,LEA,BR指令。另设HALT表示程序结束。

包含两个示例比特流：求R0、R1的GCD、将R0右移一位。

程序运行完成后可以将reg的数据输入到7段数码管上。

电路板：NEXYS4 DDR 型号： xc7a100tcsg324-1

参考书目：Introduction to Computing Systems: From bits & gates to C & beyond by Yale N. Patt.
