%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

extern int yylineno;

typedef struct vars{
  char id[100];
  int type; //1-int, 2-float, 3-string, 4-intArr, 5-flArr
  int intval;
  float flval;
  char strval[1000];
  int *intarr;
  float *flarr;
  struct vars * prox;
  
}vars;

vars *insertINT(vars*l, char n[]){
  vars*new = (vars*)malloc(sizeof(vars));
  strcpy(new->id,n);
  new->prox = l;
  new->nodetype = 1;
  return new;
}

vars *insertINTarr(vars*l, char n[], int size){
  vars*new = (vars*)malloc(sizeof(vars));
  strcpy(new->id,n);
  new->intarr = (int*)malloc(size * sizeof(int));
  new->prox = l;
  new->nodetype = 4;
}

vars *insertFL(vars*l, char n[]){
  vars*new = (vars*)malloc(sizeof(vars));
  strcpy(new->id,n);
  new->prox = l;
  new->nodetype = 2;
  return new;
}

vars *insertFLarr(vars*l, char n[], int size){
  vars*new = (vars*)malloc(sizeof(vars));
  strcpy(new->id,n);
  new->flarr = (float*)malloc(size * sizeof(float));
  new->prox = l;
  new->nodetype = 5;
}

vars *search(vars*l, char n[]){
  vars*aux = l;
  while aux != NULL{
    if(strcmp(n,aux->id) == 0)
      return aux;
    aux = aux->prox;
  }
  return aux;
}

typedef struct ast{
  int type;
  struct ast *l;
  struct ast *r;
}Ast;

typedef struct var{
int type;
char value[100];
int size;
}var;

typedef struct intval{
  int type;
  int value;
}intval;

typedef struct flval{
  int type;
  float value;
}flval;

typedef struct strval{
  int type;
  char value[1000];
}strval;

typedef struct flow{
  int type;
  ast *cond;
  ast *tru;
  ast *el;
}flow;

typedef struct symasgn{
  int type;
  char s[100];
  ast *v;
  int pos;
}symasgn;

vars *l1;
vars *aux;

ast * newast(int type, ast *l, ast *r){
  ast *a = (ast*)malloc(sizeof(ast));
  if(!a){
    printf("no space");
    exit(0);
  }
  a->type = type;
  a->l = l;
  a->r = r;
  return a;
}

ast * newvar(int type, char id[100]){
  var *a = (var*)malloc(sizeof(var));
  if(!a){
    printf("no space");
    exit(0);
  }
  a->type = type;
  strcpy(a->value,id);
  return (ast *)a;
}

ast * newINTarr(int type, char id[100], int size){
  var *a = (var*)malloc(sizeof(var));
  if(!a){
    printf("no space");
    exit(0);
  }
  a->type = type;
  strcpy(a->value, id);
  return (ast *)a;
}

ast * newFLarr(int type, char id[100], int size){
  var *a = (var*)malloc(sizeof(var));
  if(!a){
    printf("no space");
    exit(0);
  }
  a->type = type;
  strcpy(a->value, id);
  return (ast *)a;
}

ast * newstr(int type, char str[1000]){
  strval *a = (strval*)malloc(sizeof(strval));
  if(!a) {
		printf("no space");
		exit(0);
	}
  a->type = type;
  strcpy(a->value, str);
  return (ast *)a;
}

ast * newint(int i){
  intval *a = (intval*)malloc(sizeof(intval));
  if(!a){
    printf("no space");
    exit(0);
  }
  a->type = 1;
  a->value = i;
  return (ast *)a;
}

ast * newFL(float f){
  flval *a = (flval*)malloc(sizeof(flval));
  if(!a){
    printf("no space");
    exit(0);
  }
  a->type = 2;
  a->value = f;
  return (ast *)a;
}

ast * newflow(int type, ast *cond, ast *tru, ast *el){
  flow a* = (flow*)malloc(sizeof(flow));
  if(!a){
    printf("no space");
    exit(0);
  }
  a->type = type;
  a->cond = cond;
  a->tru = tru;
  a->el = el;
  return (ast *)a;
}

ast * newsagn(char s[100], ast *v){
  symasgn *a = (symasgn*)malloc(sizeof(symasgn));
  if(!a){
    printf("no space");
    exit(0);
  }
  a->type = '=';
  strcpy(a->s, s);
  a->v = v;
  return (ast *)a;
}

ast * newasgnarr(char s[100], ast *v, int index){
  symasgn *a = (symasgn*)malloc(sizeof(symasgn));
  if(!a){
    printf("no space");
    exit(0);
  }
  a->type = '=';
  strcpy(a->s, s);
  a->v = v;
  a->pos = index;
  return (ast *)a;
}



int yylex();
void yyerror(const char *s){ printf("Erro %s encontrado na linha %d\n", s, yylineno); }


%}

%union{
  int i;
  float fl;
  int fn;
  char str[100];
  ast *a;
}

%token <i> INT
%token <fl> FLOAT
%token <str> STRING
%token RUN END DEF IF ELSE WHILE FOR PRINT KEYINPUT
%token <fn> CMP

%right '='
%left '+' '-'
%left '*' '/'
%left CMP

%type <a> exp list stmt prog exp1;

%nonassoc IFX VARPREC DECLPREC NEG VET

%%


%%

#include "lex.yy.c"

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s na linha %d\n", s, yylineno);
} 

int main() {

    yyparse();
    return 0;
}
