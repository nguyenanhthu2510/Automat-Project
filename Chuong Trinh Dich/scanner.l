%{
#include "parser.tab.h"
#include <stdlib.h> // for atoi

#include <cstring>

void showError();
%}

/* This tells flex to quit when it reaches EOF */
%option noyywrap

name [a-zA-Z0-9]+
%%

[0-9]+    { yylval.val = atoi(yytext); return NUM; }
[+-]      { yylval.sym = yytext[0]; return OPA; }
[*/]      { yylval.sym = yytext[0]; return OPM; }
{name}    { yylval.str = strdup(yytext); return NAME; }
"="       { yylval.sym = yytext[0]; return ASN; }
"%"       { yylval.sym = yytext[0]; return REMAINER; }
"("       { return LP; }
")"       { return RP; }
"\n"     { return STOP; }
<<EOF>>   { return 0; }
[ \t\n]+  { }
.         { showError(); return OTHER; }
%%

void showError(){
    printf("Other input");
}