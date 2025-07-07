all: main.l main.y
	clear
	bison -d main.y
	flex main.l
	gcc -lfl main.tab.c -o maintest
	./maintest