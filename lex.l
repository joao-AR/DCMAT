%{
    #include "syntactic.tab.h"
    #include <stdio.h>
    #include <string.h>

    #define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;

    void append(char *s, int len);

%}

%option noyywrap

ID				[A-Za-z][_A-Za-z0-9]*
INTEGER			[0-9]+
REAL            [0-9]+"."[0-9]+

%%

"about" {return ABOUT;}
"abs" {return ABS;}
"axis" {return AXIS;}
"connect_dots" {return CONNECT_DOTS;}
"cos" {return COS;}
"determinant" {return DETERMINANT;}
[eE] {return E;} // E = 2,71828182;
"erase" {return ERASE;}

"float" {return FLOAT;}
"h_view" {return H_VIEW;}
"integral_steps" {return INTEGRAL_STEPS;}
"integrate" {return INTEGRATE;}
"linear_system" {return LINEAR_SYSTEM;}
"matrix" {return MATRIX;}
"off" {return OFF;}
"on" {return ON;}

[pP][iI]   { return PI ; } // PI = 3,14159265
"plot" {return PLOT;}
"precision" {return PRECISION;}
"quit" {return QUIT; }
"reset" {return RESET;}
"sen" {return SEN;}
"set" {return SET;}

"settings" {return SETTINGS;}
"show" {return SHOW;}
"solve" {return SOLVE;}
"sum" {return SUM;}
"symbols" {return SYMBOLS;}
"tan" {return TAN;}
"v_view" {return V_VIEW;}
"x" {return X;}


"+" {return PLUS;}
"-" {return MINUS;}
"*" {return MULT;}
"/" {return DIV;}
"^" {return POW;}
"%" {return REST;}
"(" {return OP;}
")" {return CP;}
":" {return INTERVAL;}
"=" {return EQUAL;}
":=" {return ATRI;}
"[" {return OB;}
"]" {return CB;}
";" {return SEMI;}
"," {return COMMA;}

{INTEGER} {yylval.dval = atof(yytext); return INTEGER;}
{REAL} {yylval.dval = atof(yytext); return REAL;}
{ID} {return ID;}

[\n] {return END_INPUT;}
[ \t] {} //ignore white spaces
. {printf("invalid Symbol: %s\n",yytext);}
%%

