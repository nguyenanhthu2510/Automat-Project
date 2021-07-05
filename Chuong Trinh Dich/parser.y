%{
#include <cstdlib> // for atoi
#include <iostream>
#include <string>
#include <map>
#include <list>
#include <math.h>
using namespace std;

int yylex();
extern int yyparse();

extern FILE *yyin;

void yyerror(const char *s);

/* Storage variable name */
map<string, int> test;
%}

/* Tell bison to give descriptive error messages. */
%error-verbose

/* These are the different "semantic values" that a token can have. */
%union {
  int val; 
  char sym;
  char * str;
};

%token OTHER
%token <val> NUM
%token <sym> OPA OPM REMAINER ASN
%token <str> NAME
%token LP RP STOP

%type <val> exp term sfactor factor sfactorz 

%start S
%%
  /* Note: YYACCEPT is a macro that tells bison to stop parsing. */

S:  
    stmt STOP S
    | 
;

stmt:
    NAME ASN exp { 
      test[$1] = $3;
      cout << test[$1] << endl;
    }
    | exp { cout << $1 << endl; }
;

exp:
    exp OPA term { $$ = ($2 == '+' ? $1 + $3 : $1 - $3); }
    | term                 { $$ = $1; }
;

term: 
    term OPM sfactorz { $$ = ($2 == '*' ? $1 * $3 : $1 / $3); }
    | sfactorz             { $$ = $1; }
;

sfactorz:
    sfactorz REMAINER sfactor { $$ = fmod($1,$3); }
    | sfactor             { $$ = $1; }
;

sfactor:
    OPA factor    { $$ = ($1 == '+' ? $2 : -$2); }
    | factor               { $$ = $1; }
;

factor:
    NUM { $$ = $1; }
    | NAME { $$ = test[$1]; cout << $1 << test[$1] << endl; }
    | LP exp RP { $$ = $2; }
;
%%

int main(int, char**) {
    // open a file handle to a particular file:
    FILE *myfile = fopen("text", "r");

    // make sure it's valid:
    if (!myfile) {
        cout << "I can't open text file!" << endl;
    return -1;
    }

    // Set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;

    // Parse through the input:
    yyparse();

}

void yyerror(const char *s) {
    cout << "EEK, parse error!  Message: " << s << endl;
    // might as well halt now:
    exit(-1);
}
