%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

extern int yylineno;

int yylex();
void yyerror(const char *s){ printf("Erro %s encontrado na linha %d\n", s, yylineno); }


%}

%union{
  float num;
  int cmp;
  char str[100];
}

%token <num> NUM
%token <str> STRING
%token RUN END DEF IF ELSE WHILE FOR PRINT KEYINPUT
%token <cmp> CMP

%right '='
%left '+' '-'
%left '*' '/'
%left CMP


%%


%%

#include "lex.yy.c"

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <inputfile.tbs>\n", argv[0]);
        return 1;
    }

    const char *dot = strrchr(argv[1], '.');
    if (!dot || strcmp(dot, ".tbs") != 0) {
        printf("Error: Incorrect input file format.\n");
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (!file) {
        perror("Error opening file");
        return 1;
    }

    yyin = file;

    yyparse();

    fclose(file);
    return 0;
}
