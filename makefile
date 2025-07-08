all: main.l main.y
	clear
	flex main.l
	bison -d main.y
	gcc -lfl main.tab.c -o testbasic1
	./testbasic1