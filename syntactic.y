%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
    #include <math.h>

    #include "settings.h"

    void print_about();
	extern char* yytext;
	extern int yyleng;
	extern int yychar;

	extern int line;
	extern int column;
	
	extern int last_new_line;
	extern int current_char_index;

    float pi = 3.14159265;
    float e = 2.71828182;

	char *cadeia;


    char plot [25][80];

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

    //Custom
    char* type_func;
    float exp_result = 0;
    void plot_func(char* draw_axis, float h_view_lo,float h_view_hi,float v_view_lo,float v_view_hi,char* type_func,float exp_result);
	extern int yylex();

	void yyerror(char const *s);
%}

%union{
    double dval;
}

%type <dval> Expression Factor Function

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
%token  ID
%token END_INPUT 
%%

first: 
    Quit
    | Attr_val_simb
    | Attr_val_matrix
    | Calc_exp 
    | Calc_func 
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
Calc_exp: 
    Expression END_INPUT
    {
        printf("%f\n",$1); 
        return 0;
    }
;

Expression: 
    Factor {$$ = $1;}
    |X {$$ = h_view_lo + 0 * (v_view_hi - h_view_lo) / (80 - 1);}
    |PI {$$ = pi ;}
    |E {$$ = e;}
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
    |Expression POW Expression {$$ = pow($1,$3);}
    |Expression REST Expression {$$ = fmod($1,$3);}
    |OP Expression CP {$$ = $2;}
;

//------------- END Expressions 

Factor: 
    INTEGER 
    |REAL
    |MINUS Factor {$$ = -$2;}
;

Calc_func: Function END_INPUT 
    {
        printf("%f\n", $1); 
        return 0;
    }
    ;

Function: 
    SEN OP Expression CP 
        {   
            // printf("\n X= %f\n",$3);
            exp_result = $3;
            type_func = "sin";
            $$ = sin($3 * pi / 180); // Convert degress to radians
        }
    
    | COS OP Expression CP 
        {   
            exp_result = $3;
            type_func = "cos";
            $$ = cos($3 * pi / 180); // Convert degress to radians
        }
    | TAN OP Expression CP 
        {   
            exp_result = $3;
            type_func = "tan";
            $$ = tan($3 * pi / 180); // Convert degress to radians
        }
;


Plot_last: 
    PLOT SEMI END_INPUT
        {   
            // plot_func(h_view_lo,h_view_hi,v_view_lo,v_view_hi);
            return 0;
        }
;

Plot: 
    PLOT OP Function CP SEMI END_INPUT
        {
            plot_func(draw_axis,h_view_lo,h_view_hi,v_view_lo,v_view_hi,type_func,exp_result);

            // printf("Plota a Função: %f\n", $3); 
            return 0;
        } 
;

Rpn: RPN OP Expression CP SEMI END_INPUT{printf("RPN\n"); return 0;};

Integrate: INTEGRATE OP Factor INTERVAL Factor COMMA Function CP SEMI END_INPUT {printf("INTEGRATE\n"); return 0;}; 

Sum: SUM OP ID COMMA Factor INTERVAL Factor COMMA Expression CP SEMI END_INPUT {printf("SOMATORIO\n"); return 0;}; 

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

Attr_val_simb: ID ATRI Expression END_INPUT {printf("varaivel := expressao\n"); return 0;};

Attr_val_matrix: ID ATRI Matrix END_INPUT{printf("varaivel := matrix\n"); return 0;};

Show_var: ID SEMI END_INPUT{printf("variavel; \n"); return 0;};

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

void plot_func(char* draw_axis, float h_view_lo,float h_view_hi,float v_view_lo,float v_view_hi,char* type_func,float exp_result){
    
    printf("\n\n");
    // Draw plot axis
    for(int i = 0; i < 25; i++){
        for(int j = 0; j < 80; j++){
            if(strcmp("OFF",draw_axis)==0){
                plot[i][j] = ' ';
            }else{
                if(i == 12){
                    plot[i][j] = '-';
                    
                }
                if(j == 40){
                    plot[i][j] = '|';
                }else if(i != 12){
                    plot[i][j] = ' ';
                }
            }
        }
    }

    //grafico invertido AJUSTAR
    for(int i = 0; i < 25; i++){
        for(int j = 0; j < 80; j++){
            double x_val = h_view_lo + j * (h_view_hi - h_view_lo) / 79; // 79 = 80 - 1
            double y_val = v_view_lo + i * (v_view_hi - v_view_lo) / 24; // 24 = 24 - 1 

            // Adjust to the Three Rule of X 
            if(x_val < 0){  
                if(h_view_lo >= 0){
                    h_view_lo  = h_view_lo  * -1;
                    exp_result = exp_result * -1;
                }
            }

            // Three Rule of X and Y
            double proportional_x = exp_result * x_val / h_view_lo;
            /* double proportional_y = y_val * proportional_x / x_val; */
            // End Three Rules

            double calc_val;
            /* printf("\nX = %f * %f / %f\n",exp_result,valor_atual,h_view_lo);
            printf("%d) x_val [ %f ] proportional_x[ %f ]\n",j,x_val,proportional_x); */
            
            if(strcmp("sin",type_func) == 0){

                calc_val = sin(proportional_x )*-1;

            }else if(strcmp("cos",type_func) == 0){

                calc_val = cos(proportional_x)*-1;

            }else if(strcmp("tan",type_func ) == 0){

                calc_val = tan(proportional_x)*-1;
            }

            // Atribuir '*' onde o valor de y está próximo do seno de x
            if (fabs(y_val - calc_val) < 0.2) {
                plot[i][j] = '*';
            }
        }
    }

    for(int i = 0; i < 25; i++){
        for(int j = 0; j < 80; j++){
            printf("%c",plot[i][j]);
        }
        printf("\n");
    }  
    printf("\n");
}

