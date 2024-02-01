%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

    void print_about();
	extern char* yytext;
	extern int yyleng;
	extern int yychar;

	extern int line;
	extern int column;
	
	extern int last_new_line;
	extern int current_char_index;

	char *cadeia;

	extern int yylex();
    extern


	void yyerror(char const *s);
%}


%locations
%define parse.lac full
%define parse.error verbose

%token  ABOUT
%token  ABS
%token  AXIS
%token  CONNECT_DOTS
%token  COS
%token  DETERMINANT
%token  E // E = 2,71828182;
%token  ERASE

%token  FLOAT
%token  H_VIEW
%token  INTEGRAL_STEPS
%token  INTEGRATE
%token  LINEAR_SYSTEM
%token  MATRIX
%token  OFF
%token  ON

%token  PI // PI = 3,14159265
%token  PLOT
%token  PRECISION
%token  QUIT
%token  RESET
%token  SEN
%token  SET

%token  SETTINGS
%token  SHOW
%token  SOLVE
%token  SUM
%token  SYMBOLS
%token  TAN
%token  V_VIEW
%token  X

%token  PLUS
%token  MINUS
%token  MULT
%token  DIV
%token  EXP
%token  REST
%token  OP
%token  CP
%token  INTERVAL
%token  EQUAL
%token  ATRI
%token  OB
%token  CB
%token  SEMI
%token  COMMA

%token  INTEGER
%token  REAL
%token  ID
%token First_grau_func

%%

first: About|Show_Settings|Reset_Settings|Set_H_View|Set_V_View|Set_Axis_On|Set_Axis_Off|Plot_last|Function|Quit ;
Quit: QUIT {exit(0);};
Show_Settings: SHOW SETTINGS SEMI {return 0;};
Reset_Settings: RESET SETTINGS SEMI {return 0;};
Set_H_View: SET H_VIEW OB REAL CB INTERVAL OB REAL CB SEMI {return 0;}; // set h_view [valor float] :  [valor float];
Set_V_View: SET V_VIEW OB REAL CB INTERVAL OB REAL CB SEMI {return 0;}; // set v_view [valor float] :  [valor float];
Set_Axis_On: SET AXIS ON SEMI {return 0;};
Set_Axis_Off: SET AXIS OFF SEMI {return 0;};
Expression: 
    Term | 
    Expression PLUS Term ;

Term: Factor ;
Factor: INTEGER;
Function: Factor PLUS Factor {printf("soma\n"); return 0;};
/* Funcao_Segundo_Grau:
Funcao_Exponencial: */

Plot_last: PLOT SEMI {return 0;};
/* Plot:   */
About: ABOUT SEMI {print_about(); return 0;}
%%

int main(int argc, char** argv){
    while (1) {
        printf("> ");
        yyparse();
    }
	return 0;
}

void yyerror(char const *s){
    int i;
	char c;

    printf("error:syntax: %s\n", yytext);
}



void print_about(){
    printf("+----------------------------------------------+\n");    
    printf("|          João Pedro Alves Rodrigues          |\n");
    printf("|          Matricula:   000000000000           |\n");
    printf("+----------------------------------------------+\n");
}