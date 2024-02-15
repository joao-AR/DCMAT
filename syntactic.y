%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
    #include <math.h>
    
    #include "settings.h"
    #include "plot.h"
    #include "stack.h"

    Stack_node *rpn = NULL; // init top Stack as NULL
    Stack_node *remove_rpn_node;

    // From lex.l
	extern char* yytext;
	extern int yyleng;
	extern int yychar;
	extern int line;
	extern int column;
	extern int last_new_line;
	extern int current_char_index;
    // END From lex.l

    float pi = 3.14159265;
    float e = 2.71828182;

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
    char* type_func;
    char* aux_rpn_value;
    float exp_result = 0;
    int function_difined = 1; // 0 = True 1 = False 
	//End Custom VAR

    void print_about();
    char* to_string(float value);

    extern int yylex();
	void yyerror(char const *s);
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
            stack_pop_all(&rpn);
            printf("%f\n",$1); 
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
            aux_rpn_value = to_string($1);
            rpn = stack_push(rpn,aux_rpn_value);  
        }
    |X 
        {
            $$ = h_view_lo;
            rpn = stack_push(rpn,"x");
        }
    |PI 
        {
            $$ = pi ;
        }
    |E 
        {
        $$ = e;
        }
    |Expression PLUS Expression 
        {
            $$ = $1 + $3; 
            rpn = stack_push(rpn,"+"); 
        }
    |Expression MINUS Expression 
        {
            $$ = $1 - $3; 
            rpn = stack_push(rpn,"-"); 
        }
    |Expression DIV Expression  
        {
            if($3 == 0){
                printf("ERROR division by ZERO\n");
                return 0;
            }else{
                $$ = $1 / $3;
                rpn = stack_push(rpn,"/"); 
            }
        }
    |Expression MULT Expression 
        {
            $$ = $1 * $3;
            rpn = stack_push(rpn,"*"); 
        }
    |Expression POW Expression 
        {
            $$ = pow($1,$3);
            rpn = stack_push(rpn,"^"); 
        }
    |Expression REST Expression 
        {
            $$ = fmod($1,$3);
            rpn = stack_push(rpn,"%"); 
        }
    |OP Expression CP 
        {
            $$ = $2;
        }
;
Function: 
    SEN OP Expression CP 
        {   
            function_difined = 0;
            exp_result = $3;
            type_func = "sin";
            rpn = stack_push(rpn,"SEN"); 
            $$ = sin($3 * pi / 180); // Convert degress to radians
        }
    
    | COS OP Expression CP 
        {   
            function_difined = 0;
            exp_result = $3;
            type_func = "cos";
            rpn = stack_push(rpn,"COS"); 
            $$ = cos($3 * pi / 180); // Convert degress to radians
        }
    | TAN OP Expression CP 
        {   
            function_difined = 0;
            exp_result = $3;
            type_func = "tan";
            rpn = stack_push(rpn,"TAN"); 
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
            if(function_difined == 0){
                plot_config(draw_axis,erease_plot);
                plot_manipulation(h_view_lo,h_view_hi,v_view_lo,v_view_hi,type_func,exp_result);
            }else{
                printf("\nNo Function defined!\n");
            }
            return 0;
        }
;

Plot: 
    PLOT OP Function CP SEMI END_INPUT
        {   
            plot_config(draw_axis,erease_plot);
            plot_manipulation(h_view_lo,h_view_hi,v_view_lo,v_view_hi,type_func,exp_result);
            return 0;
        } 
;
//------------- END PLOT

//------------- RPN
Rpn: RPN OP Rpn_expression CP SEMI END_INPUT 
    {   
        stack_reverse_print(rpn);
        stack_pop_all(&rpn);
        return 0;
    };

Rpn_term:
    VAR {
        rpn = stack_push(rpn,$1);  
    }
    |X 
        {
            rpn = stack_push(rpn,"x");
        }
    |PI 
        {
            aux_rpn_value = to_string(pi);
            rpn = stack_push(rpn,aux_rpn_value);  
        }
    |E 
        {   
            aux_rpn_value = to_string(e);
            rpn = stack_push(rpn,aux_rpn_value);  
        }

Rpn_expression:
    Rpn_term
    |Rpn_func
    |Factor 
        {
            aux_rpn_value = to_string($1);
            rpn = stack_push(rpn,aux_rpn_value);  
        }
    
    |Rpn_expression PLUS Rpn_expression 
        {
            rpn = stack_push(rpn,"+"); 
        }
    |Rpn_expression MINUS Rpn_expression 
        {
            rpn = stack_push(rpn,"-"); 
        }
    |Rpn_expression DIV Rpn_expression  
        {
            rpn = stack_push(rpn,"/"); 
        }
    |Rpn_expression MULT Rpn_expression 
        {
            rpn = stack_push(rpn,"*"); 
        }
    |Rpn_expression POW Rpn_expression 
        {
            rpn = stack_push(rpn,"^"); 
        }
    |Rpn_expression REST Rpn_expression 
        {
            rpn = stack_push(rpn,"%"); 
        }
    |OP Rpn_expression CP 
        {
            $$ = $2;
        }
;

Rpn_func:
    SEN OP Rpn_expression CP 
        {   
            rpn = stack_push(rpn,"SEN"); 
        }
    
    | COS OP Rpn_expression CP 
        {   
            rpn = stack_push(rpn,"COS"); 
        }
    | TAN OP Rpn_expression CP 
        {   
            rpn = stack_push(rpn,"TAN"); 
        }
//------------- END RPN
Integrate: INTEGRATE OP Factor INTERVAL Factor COMMA Function CP SEMI END_INPUT {printf("INTEGRATE\n"); return 0;}; 

Sum: SUM OP VAR COMMA Factor INTERVAL Factor COMMA Expression CP SEMI END_INPUT {printf("SOMATORIO\n"); return 0;}; 

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

Attr_val_simb: VAR ATRI Expression END_INPUT {printf("varaivel := expressao\n"); return 0;};

Attr_val_matrix: VAR ATRI Matrix END_INPUT{printf("varaivel := matrix\n"); return 0;};

Show_var: VAR SEMI END_INPUT{printf("variavel; \n"); return 0;};

Show_all_var: SHOW SYMBOLS SEMI END_INPUT{printf("show symbols;\n"); return 0;};

About: ABOUT SEMI END_INPUT {print_about(); return 0;};
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

char* to_string(float value){
    // Determine the maximum size needed for the string
    int size = snprintf(NULL, 0, "%f", value);

    // Allocate memory for the string
    char* result = (char*)malloc(size + 1);  // +1 for the null terminator

    // Convert float to string
    snprintf(result, size + 1, "%f", value);

    return result;
}
