%option yylineno

%{

%}
LINENUM [0-9]+
NUM [0-9]+\.?[0-9]+
WORD [a-zA-Z_]+([a-zA-Z_]|[0-9])*
STRING  \"([^\\\"]|\\.)*\"

FN "fn"
LET "let"
GOTO "goto"

COMM "##".*
%x ML_COMM

ADDONE "++"
MINUSONE "--"

IF "if"
ELSE "else"

WHILE "while"
FOR "for"

PRINT "print"
INPUT "input"

START "START"
END "END"

IGNORE [\ \t\s.]


%%
{FN}        { return FN; }
{LET}       { return LET; }
{GOTO}      { return GOTO; }

{ADDONE}    { return ADDONE; }
{MINUSONE}  { return MINUSONE; }

{IF}        { return IF; }
{ELSE}      { return ELSE; }
{WHILE}     { return WHILE; }
{FOR}       { return FOR; }

{PRINT}     { return PRINT; }
{INPUT}      { return INPUT; }

{START}     { return START; }
{END}       { return END; }

{LINENUM}   { yylval.linenum = atoi(yytext); return LINENUM; }
{NUM}       { yylval.num = atof(yytext); return NUM; }

{WORD}      { strcpy(yylval.text, yytext); return WORD; }

{COMM}      {;}

{STRING}    { for(int count=0;count<strlen(yytext);count++){
                yytext[count] = yytext[count+1];
                }
                yytext[strlen(yytext)-1] = '\0';
                strcpy(yylval.str, yytext);
                return STRING;
            }

{IGNORE}    {}

#>>                 { BEGIN(ML_COMM); }
<ML_COMM><<#        { BEGIN(INITIAL); }
<ML_COMM>.|\n       ;
<ML_COMM><<EOF>>    { printf("Erro, comentário multi-linha não fechado.\n"); exit(1); }

[+-/|*=^:;,\[\](){}]    { return *yytext; }

">"  {yylval.cmp = 1; return CMP; }
"<"  {yylval.cmp = 2; return CMP; }
"!=" {yylval.cmp = 3; return CMP; }
"==" {yylval.cmp = 4; return CMP; }
">=" {yylval.cmp = 5; return CMP; }
"<=" {yylval.cmp = 6; return CMP; }
"||" {yylval.cmp = 7; return CMP; }
"&&" {yylval.cmp = 8; return CMP; }

[\n]        {yylineno++;}
%%
