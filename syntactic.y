%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
    #include <math.h>
    
    #include "settings.h"
    #include "plot.h"
    #include "stack.h"
    #include "operations.h"
    
    // From lex.l
	extern char* yytext;
	extern int yyleng;
	extern int yychar;
	extern int line;
	extern int column;
	extern int last_new_line;
	extern int current_char_index;
    // END From lex.l

    extern float pi;
    extern float e;

    //From Settings
    extern float h_view_lo;
    extern float h_view_hi; 
    extern float v_view_lo;
    extern float v_view_hi;
    extern int precision;
    extern int integral_steps;
    extern char* draw_axis;
    extern char* erease_plot;
    extern char* connect_dots;
    //End From Settigns 

    //From plot.c
    extern char plot;
    
    //Custom VAR
    char* aux_string;
    char* rpn_string;
    char* exp_str;
    char* exp_str_last; // Used to save the last expression, plot;
	//End Custom VAR
    
    extern int yylex();
	void yyerror(char const *s);

    // Custom Functions
    void print_about();

%}

%union{
    double dval;
    char *sval;
}

%type <dval> Expression Factor Function
%type <sval> Rpn_expression Rpn_func Rpn_term
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
%token  RPN
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
%token  <sval> VAR
%token END_INPUT 
%%

first: 
    Quit
    | Attr_val_simb
    | Attr_val_matrix
    | Expression END_INPUT
        {   
            
            strcpy(exp_str_last,exp_str);
            free(exp_str); 
            
            exp_str = malloc(sizeof(char*));
            print_value($1);
            return 0;
        } 
    | Show_Settings 
    | Reset_Settings 
    | Set_View
    | Set_Axis 
    | Set_Erase_Plot
    | Plot_last 
    | Plot 
    | Matrix 
    | Integrate 
    | Sum
    | Rpn 
        { 
            free(rpn_string); 
            rpn_string = malloc(sizeof(char*));
        }
    | Set_integral_steps 
    | Show_matrix
    | About 
    | Solve_determinant
    | Solve_linear_system
    | Show_var
    | Show_all_var
    | Set_float_precision
    | END_INPUT {return 0;}
;

Quit: 
    QUIT 
    {
        exit(0);
    }
;

//------------- SETTINGS

Show_Settings: 
    SHOW SETTINGS SEMI END_INPUT 
    {
        print_settings(); 
        return 0;
    }
;

Reset_Settings: 
    RESET SETTINGS SEMI END_INPUT 
    {   
        reset_settings();
        return 0;
    }
;

Set_View: 
    SET H_VIEW OB Factor CB INTERVAL OB Factor CB SEMI END_INPUT // set h_view [valor float] :  [valor float];
        { 
            set_view($4,$8,'h'); 
            return 0;
        }
    
    |SET V_VIEW OB Factor CB INTERVAL OB Factor CB SEMI END_INPUT  // set v_view [valor float] :  [valor float];
        {
            set_view($4,$8,'v');
            return 0;
        }
;

Set_Axis: 
    SET AXIS ON SEMI END_INPUT 
        {
            set_axis("ON");
            return 0;
        }
    
    |SET AXIS OFF SEMI END_INPUT
        {
            set_axis("OFF");
            return 0;
        }
;

Set_Erase_Plot:
    SET ERASE PLOT ON SEMI END_INPUT 
        {
            set_erease_plot("ON");
            return 0;
        }
    |SET ERASE PLOT OFF SEMI END_INPUT 
        {
            set_erease_plot("OFF");
            return 0;
        }
;

Set_integral_steps: 
    SET INTEGRAL_STEPS INTEGER SEMI END_INPUT 
        {
            set_integral_steps($3);
            return 0;
        }
;

Set_float_precision: 
    SET FLOAT PRECISION INTEGER SEMI END_INPUT 
        {
            set_float_precision($4);
            return 0;
        }
;

//------------- END SETTINGS

//------------- Expressions 

Expression:
    Function
    |Factor 
        {
            $$ = $1; 
            aux_string = to_string($1); 
            exp_str = concat_strings(exp_str,aux_string);
        }
    |X 
        {
            $$ = h_view_lo;
            exp_str = concat_strings(exp_str,"x");
        }
    |PI 
        {
            $$ = pi ;
            aux_string = to_string(pi);
            exp_str = concat_strings(exp_str,aux_string);
        }
    |E 
        {
            $$ = e;
            aux_string = to_string(e);
            exp_str = concat_strings(exp_str,aux_string);
        }
    |Expression PLUS Expression 
        {
            $$ = $1 + $3; 
            exp_str = concat_strings(exp_str,"+");

        }
    |Expression MINUS Expression 
        {
            $$ = $1 - $3; 
            exp_str = concat_strings(exp_str,"-"); 
        }
    |Expression DIV Expression  
        {
            if($3 == 0){
                printf("ERROR division by ZERO\n");
                return 0;
            }else{
                $$ = $1 / $3;
                exp_str = concat_strings(exp_str,"/");
            }
        }
    |Expression MULT Expression 
        {
            $$ = $1 * $3;
            exp_str = concat_strings(exp_str,"*"); 
        }
    |Expression POW Expression 
        {
            $$ = pow($1,$3);
            exp_str = concat_strings(exp_str,"^"); 
        }
    |Expression REST Expression 
        {
            $$ = fmod($1,$3);
            exp_str = concat_strings(exp_str,"%");
        }
    |OP Expression CP 
        {
            $$ = $2;
        }
;

Function: 
    SEN OP Expression CP 
        {   
            exp_str = concat_strings(exp_str,"SEN"); 
            $$ = sin($3 * pi / 180); // Convert degress to radians
        }
    
    | COS OP Expression CP 
        { 
            exp_str = concat_strings(exp_str,"COS"); 
            $$ = cos($3 * pi / 180); // Convert degress to radians
        }
    | TAN OP Expression CP 
        {   
            exp_str = concat_strings(exp_str,"TAN"); 
            $$ = tan($3 * pi / 180); // Convert degress to radians
        }
;

Factor: 
    INTEGER 
    |REAL
    |MINUS Factor {$$ = -$2;}
;

//------------- END Expressions 

//------------- Plot
// Plot the last functions passed 
Plot_last: 
    PLOT SEMI END_INPUT
        {   
            if(strlen(exp_str_last) > 0){
                plot_func(exp_str_last);
            }else{
                printf("\nNo Function defined!\n");
            }
            return 0;
        }
;

Plot: 
    PLOT OP Expression CP SEMI END_INPUT
        {   
            plot_func(exp_str);
            return 0;
        } 
;
//------------- END PLOT

//------------- RPN
Rpn: RPN OP Rpn_expression CP SEMI END_INPUT 
    {   
        printf("%s\n",rpn_string);
        return 0;
    }
;

Rpn_term:
    VAR {
        rpn_string = concat_strings(rpn_string,$1);  
    }
    |X 
        {
            rpn_string = concat_strings(rpn_string,"x");
        }
    |PI 
        {
            aux_string = to_string(pi);
            rpn_string = concat_strings(rpn_string,aux_string);  
        }
    |E 
        {   
            aux_string = to_string(e);
            rpn_string = concat_strings(rpn_string,aux_string);   
        }
;

Rpn_expression:
    Rpn_term
    |Rpn_func
    |Factor 
        {   
            aux_string = to_string($1);
            rpn_string = concat_strings(rpn_string,aux_string);
        }
    
    |Rpn_expression PLUS Rpn_expression 
        {
            rpn_string = concat_strings(rpn_string,"+"); 
        }
    |Rpn_expression MINUS Rpn_expression 
        {
            rpn_string = concat_strings(rpn_string,"-"); 
        }
    |Rpn_expression DIV Rpn_expression  
        {
            rpn_string = concat_strings(rpn_string,"/"); 
        }
    |Rpn_expression MULT Rpn_expression 
        {
            rpn_string = concat_strings(rpn_string,"*"); 
        }
    |Rpn_expression POW Rpn_expression 
        {
            rpn_string = concat_strings(rpn_string,"^"); 
        }
    |Rpn_expression REST Rpn_expression 
        {
            rpn_string = concat_strings(rpn_string,"%"); 
        }
    |OP Rpn_expression CP 
        {
            $$ = $2;
        }
;

Rpn_func:
    SEN OP Rpn_expression CP 
        {   
            rpn_string = concat_strings(rpn_string,"SEN"); 
        }
    
    | COS OP Rpn_expression CP 
        {   
            rpn_string = concat_strings(rpn_string,"COS"); 
        }
    | TAN OP Rpn_expression CP 
        {   
            rpn_string = concat_strings(rpn_string,"TAN");  
        }
;
//------------- END RPN
Integrate: 
    INTEGRATE OP Factor INTERVAL Factor COMMA Expression CP SEMI END_INPUT 
        {   
            riemann_sum($3,$5,exp_str);
            return 0;
        }
; 

Sum: 
    SUM OP VAR COMMA INTEGER INTERVAL INTEGER COMMA Expression CP SEMI END_INPUT 
        {   
            // sum(char *var, int inf, int sup, char *expression);
            printf("SOMATORIO\n"); 
            return 0;
        }
; 

Matrix: 
    OB INTEGER Matrix_Value CB SEMI END_INPUT{printf("matrix[%f]",$2); return 0;}
    |OB INTEGER Matrix_Value CB COMMA OB INTEGER Matrix_Value CB SEMI END_INPUT{printf("matrix[%f][%f]",$2,$7); return 0;}
;

Matrix_Value: 
    %empty 
    | COMMA INTEGER Matrix_Value
;

Show_matrix: SHOW MATRIX SEMI END_INPUT{printf("SHOW MATRIX\n"); return 0;}
;

Solve_determinant: SOLVE DETERMINANT SEMI END_INPUT{printf("SOLVE DETERMINANT\n"); return 0;}

Solve_linear_system: SOLVE LINEAR_SYSTEM SEMI END_INPUT{printf("SOLVE linear SYSTEM\n"); return 0;}

Attr_val_simb: 
    VAR ATRI Expression SEMI END_INPUT 
        {
            printf("%s := %f;\n",$1,$3); 
            return 0;
        }
;

Attr_val_matrix: 
    VAR ATRI Matrix END_INPUT
        {
            printf("varaivel := matrix\n"); 
            return 0;
        }
;

Show_var: VAR SEMI END_INPUT{printf("variavel; \n"); return 0;};

Show_all_var: SHOW SYMBOLS SEMI END_INPUT{printf("show symbols;\n"); return 0;};

About: 
    ABOUT SEMI END_INPUT 
        {
            print_about(); 
            return 0;
        }
;
%%


int main(int argc, char** argv){ 
    exp_str_last = malloc(sizeof(char*));
    while (1) {
        rpn_string = malloc(sizeof(char*));
        exp_str = malloc(sizeof(char*));
        printf("> ");
        yyparse();
    } 

    
    free(rpn_string);
    free(exp_str);
    free(exp_str_last);
	return 0;
}

void yyerror(char const *s){
    int i;
	char c;
    if(strcmp(yytext,"\n")==0 || strcmp(yytext,"")==0){
        printf("SYNTAX ERROR: Incomplete command\n");

    }else{
        printf("SYNTAX ERROR: [%s]\n", yytext);
    }
    return ;
}


void print_about(){
    printf("+----------------------------------------------+\n");    
    printf("|          João Pedro Alves Rodrigues          |\n");
    printf("|          Matricula:   000000000000           |\n");
    printf("+----------------------------------------------+\n");
}

