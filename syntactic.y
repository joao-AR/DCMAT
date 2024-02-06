%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
    #include <math.h>

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

	void yyerror(char const *s);
%}

%union{
    double dval;
}

%type <dval> Expression Factor 

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

%left  PLUS MINUS
%left  MULT DIV REST
%left  POW 

%token  OP
%token  CP
%token  INTERVAL
%token  EQUAL
%token  ATRI
%token  OB
%token  CB
%token  SEMI
%token  COMMA

%token  <dval> INTEGER
%token  <dval> REAL
%token  ID
%token First_grau_func
%token END_INPUT 
%%

first:  About|Show_Settings|Reset_Settings|Set_H_View|Set_V_View|Set_Axis_On|Set_Axis_Off|Plot_last|Calc_exp|Quit | END_INPUT{return 0;} ;
Quit: QUIT {exit(0);};
Show_Settings: SHOW SETTINGS SEMI {return 0;};
Reset_Settings: RESET SETTINGS SEMI {return 0;};
Set_H_View: SET H_VIEW OB REAL CB INTERVAL OB REAL CB SEMI {return 0;}; // set h_view [valor float] :  [valor float];
Set_V_View: SET V_VIEW OB REAL CB INTERVAL OB REAL CB SEMI {return 0;}; // set v_view [valor float] :  [valor float];
Set_Axis_On: SET AXIS ON SEMI {return 0;};
Set_Axis_Off: SET AXIS OFF SEMI {return 0;};

Calc_exp: Expression END_INPUT
    {
        printf("R = %f\n",$1); 
        return 0;
    }
    
;

Expression: 
    Factor {$$ = $1;}
    |MINUS Factor {$$ = -$2;}
    |Expression PLUS Expression {$$ = $1 + $3;}
    |Expression MINUS Expression {$$ = $1 - $3;}
    |Expression DIV Expression 
        {
            if($3 == 0){
                printf("ERROR division by ZERO\n");
                return 0;
            }else{
                $$ = $1 / $3;
            }
        }
    |Expression MULT Expression {$$ = $1 * $3;}
    |Expression POW Expression { /*$$ = pow($1,$3);*/}
    |OP Expression CP {$$ = $2;}
    |Expression REST Expression { /*$$ = $1 % $3;*/}
;
    
Factor: 
    INTEGER 
    |REAL
;



/* Function: Factor PLUS Factor {printf("soma\n"); return 0;}; */
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