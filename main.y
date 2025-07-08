%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

extern int yylineno;

int yylex();
void yyerror(const char *s){ printf("Erro %s encontrado na linha %d\n", s, yylineno); }

typedef enum { AST_NUM, AST_VAR, AST_BINOP, AST_ASSIGN, AST_IF } ASTNodeType;

typedef struct ASTNode {
    ASTNodeType type;
    union {
        float num;
        char var[100];
        struct {
            int op;
            struct ASTNode *left, *right;
        } binop;
        struct {
            char var[100];
            struct ASTNode *value;
        } assign;
        struct {
            struct ASTNode* cond;
            struct ASTNodeList* then_branch;
            struct ASTNodeList* else_branch;
        } ifelse;
    };
} ASTNode;

typedef struct ASTNodeList {
    struct ASTNode* node;
    struct ASTNodeList* next;
} ASTNodeList;

ASTNode* new_num(float n) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = AST_NUM;
    node->num = n;
    return node;
}
ASTNode* new_var(const char* name) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = AST_VAR;
    strncpy(node->var, name, 99);
    node->var[99] = '\0';
    return node;
}
ASTNode* new_binop(int op, ASTNode* left, ASTNode* right) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = AST_BINOP;
    node->binop.op = op;
    node->binop.left = left;
    node->binop.right = right;
    return node;
}
ASTNode* new_assign(const char* name, ASTNode* value) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = AST_ASSIGN;
    strncpy(node->assign.var, name, 99);
    node->assign.var[99] = '\0';
    node->assign.value = value;
    return node;
}
ASTNode* new_if(ASTNode* cond, ASTNodeList* then_branch, ASTNodeList* else_branch) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = AST_IF;
    node->ifelse.cond = cond;
    node->ifelse.then_branch = then_branch;
    node->ifelse.else_branch = else_branch;
    return node;
}

ASTNodeList* new_stmt_list(ASTNode* node, ASTNodeList* next) {
    ASTNodeList* list = malloc(sizeof(ASTNodeList));
    list->node = node;
    list->next = next;
    return list;
}

void print_ast(ASTNode* node, int indent) {
    if (!node) return;
    for (int i = 0; i < indent; ++i) printf("  ");
    switch (node->type) {
        case AST_NUM:
            printf("NUM: %f\n", node->num);
            break;
        case AST_VAR:
            printf("VAR: %s\n", node->var);
            break;
        case AST_BINOP:
            printf("BINOP: '%c'\n", node->binop.op);
            print_ast(node->binop.left, indent + 1);
            print_ast(node->binop.right, indent + 1);
            break;
        case AST_ASSIGN:
            printf("ASSIGN: %s =\n", node->assign.var);
            print_ast(node->assign.value, indent + 1);
            break;
        case AST_IF:
            printf("IF\n");
            for (int i = 0; i < indent + 1; ++i) printf("  ");
            printf("COND:\n");
            print_ast(node->ifelse.cond, indent + 2);
            for (int i = 0; i < indent + 1; ++i) printf("  ");
            printf("THEN:\n");
            print_ast(node->ifelse.then_branch, indent + 2);
            if (node->ifelse.else_branch) {
                for (int i = 0; i < indent + 1; ++i) printf("  ");
                printf("ELSE:\n");
                print_ast(node->ifelse.else_branch, indent + 2);
            }
            break;
    }
}

%}

%union{
  float num;
  int cmp;
  char str[100];
  struct ASTNode* ast;
  struct ASTNodeList* next;
}

%token <num> NUM
%token <str> STRING
%token START END DEF IF ELSE WHILE FOR PRINT SCAN
%token <cmp> CMP
%type <ast> program expr stmt
%type <next>  stmt_list

%right '='
%left '+' '-'
%left '*' '/'
%left CMP


%%

program
    : stmt_list { $$ = $1; }
    ;

stmt
    : STRING '=' expr                { $$ = new_assign($1, $3); }
    | expr                           { $$ = $1; }
    | IF expr stmt_list ELSE stmt_list { $$ = new_if($2, $3, $5); }
    | IF expr stmt_list                { $$ = new_if($2, $3, NULL); }
    ;

stmt_list
    : stmt                        { $$ = new_stmt_list($1, NULL); }
    | stmt_list stmt              { $$ = new_stmt_list($2, $1); }
    ;
    
expr
    : NUM                { $$ = new_num($1); }
    | STRING             { $$ = new_var($1); }
    | expr '+' expr      { $$ = new_binop('+', $1, $3); }
    | expr '-' expr      { $$ = new_binop('-', $1, $3); }
    | expr '*' expr      { $$ = new_binop('*', $1, $3); }
    | expr '/' expr      { $$ = new_binop('/', $1, $3); }
    ;

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

    ASTNode* root = NULL;
    yyparse(&root);

    fclose(file);

    if (root) {
        print_ast(root, 0);
    }
    return 0;
}