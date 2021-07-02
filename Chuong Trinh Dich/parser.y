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
bool keepgoing = true;

/* Additional functions */
void updateVal(char * s, int val);
int result();

/* Storage variable name */
// list<string, int> ST;
// list<string, int>::iterator st;
list<string> ST;
list<string>::iterator st;

map<string, int> lst;
map<string, int>::iterator it;

list<char> op;
list<char>::iterator opr;
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

%type <val> exp term sfactor factor sfactorz summary

%start S
%%
  /* Note: YYACCEPT is a macro that tells bison to stop parsing. */

S:  
    stmt
    // { YYACCEPT; }
    // {keepgoing = true;}
    | { keepgoing = false; }
;

stmt:
    summary
    | exp STOP S
;

summary:
    NAME ASN exp STOP S { updateVal($1, $3); }
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
    | NAME oper NAME {
      // if (std::find(ST.begin(), ST.end(), $1) == ST.end()) {
      //   // cout << "hello $1 = " << $1 << endl;;
      //   ST.push_back($1);
      // }
      // if (std::find(ST.begin(), ST.end(), $3) == ST.end()) {
      //   // cout << "hello $3 = " << $3 << endl;
      //   ST.push_back($3);
      // }
      ST.push_back($1);
      ST.push_back($3);
      // for(st = ST.begin(); st != ST.end(); ++st) {
      //   cout << '\t' << *st << endl;
      // }
      // cout << '\t' << "----" << endl;
    }
    | LP exp RP { $$ = $2; }
;

oper:
    OPA {
      if ($1 == '+') { op.push_back('+'); }
      else { op.push_back('-'); }
    }
    | OPM {
      if ($1 == '*') { op.push_back('*'); } 
      else { op.push_back('/'); }
    }
    | REMAINER {
      op.push_back('%');
    }
;
%%

void updateVal(char * s, int val) {
    // lst.push_back(val);
    // for(it = lst.begin(); it != lst.end(); ++it) {
    //   cout << '\t' << *it;
    // }
    // cout << '\n';
    lst[s] = val;
}

int result() {
    int re = 0;
    opr = op.begin();
    for (st = ST.begin(); st != ST.end(); st++) {
      it = lst.find(*st);
      switch (*opr) {
        case '+':
          re = re + it->second;
          break;
        case '-':
          re = re - it->second;
          break;
        case '*':
          re = re * it->second;
          break;
        case '/':
          re = re / it->second;
          break;
        case '%':
          re = re % it->second;
          break;
      }
      ++opr;
    }
    return re;
}

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

    // initialize
    op.push_back('+');

    // Parse through the input:
    yyparse();
    cout << "result = " << result() << endl;
}

void yyerror(const char *s) {
    cout << "EEK, parse error!  Message: " << s << endl;
    // might as well halt now:
    exit(-1);
}
