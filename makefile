all: main.l main.y
	clear
	flex -i main.l
	bison -d main.y
	gcc main.tab.c lex.yy.c -lfl -o testbasic1
	./testbasic1 input.tbs