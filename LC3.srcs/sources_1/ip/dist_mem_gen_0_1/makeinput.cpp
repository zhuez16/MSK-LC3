#include<cstdio>
using namespace std;

int main()
{
	freopen("tmp.txt","w",stdout);
	printf("memory_initialization_radix=16;\nmemory_initialization_vector=2C20 1020 0202 903F 1021 1260 0202 927F 1261 1260 0415 947F 14A1 1602 0804 1DA1 7580 1482 0FFA 240E 1486 0406 6580 1DBF 1602 09F9 1002 0FF7 1620 1060 12E0 0FE9 F025 0040 FFC0");
	for (int i=37;i<=128;i++)
		printf(" 0000");
	return 0;
}
