%option yylineno

%{

%}

NUM [0-9]+\.?[0-9]+
WORD [a-zA-Z]+([a-zA-Z]|[0-9])*
STRING  \"([^\\\"]|\\.)*\"

DEF "def"

COMM "##".*
%x ML_COMM

ADDONE "++"
MINUSONE "--"

IF "if"
ELSE "else"

WHILE "while"
FOR "for"

PRINT "print"
KEYINPUT "input"

RUN "RUN"
END "END"

IGNORE [\ \t\s.]


%%
{DEF}       { return DEF; }

{ADDONE}    { return ADDONE; }
{MINUSONE}  { return MINUSONE; }

{IF}        { return IF; }
{ELSE}      { return ELSE; }
{WHILE}     { return WHILE; }
{FOR}       { return FOR; }

{PRINT}     { return PRINT; }
{KEYINPUT}  { return KEYINPUT; }

{RUN}       { return RUN; }
{END}       { return RUN; }

{NUM}     { yylval.fl = atof(yytext); return NUM; }

{WORD}       { strcpy(yylval.text, yytext); return WORD; }

{COMM} {;}

{STRING}    { for(int count=0;count<strlen(yytext);count++){
                yytext[count] = yytext[count+1];
                }
                yytext[strlen(yytext)-1] = '\0';
                strcpy(yylval.text, yytext);
                return STRING;
            }

{IGNORE}    {}

#>>                 { BEGIN(ML_COMM); }
<ML_COMM><<#        { BEGIN(INITIAL); }
<ML_COMM>.|\n       ;
<ML_COMM><<EOF>>    { printf("Erro, comentário multi-linha não fechado.\n"); exit(1); }

[+-/|*=^:;,\[\](){}]    { return *yytext; }

">"  {yylval.fn = 1; return CMP; }
"<"  {yylval.fn = 2; return CMP; }
"!=" {yylval.fn = 3; return CMP; }
"==" {yylval.fn = 4; return CMP; }
">=" {yylval.fn = 5; return CMP; }
"<=" {yylval.fn = 6; return CMP; }
"||" {yylval.fn = 7; return CMP; }
"&&" {yylval.fn = 8; return CMP; }

[\n]        {yylineno++;}
%%
