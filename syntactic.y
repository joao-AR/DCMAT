%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
    #include <math.h>
    
    #include "settings.h"
    #include "plot.h"
    #include "stack.h"
    #include "operations.h"
    #include "variables.h"
    
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
    
    Matrix mtx;
    char* mtx_str; 
    int mtx_rows = 1 ;  // Matrix Lines
    int mtx_columns = 0; // Matrix Columns
    int g_mtx_cols = 1;// Greater Matrix Columns

    double det_res;

    Matrix mtx_var;
    char* name_mtx_var;
    L_node *list = NULL;
    L_node *remove_node_list;
	//End Custom VAR
    
    extern int yylex();
	void yyerror(char const *s);

    // Custom Functions
    void print_about();
    void free_all();


%}

%union{
    double dval;
    char *sval;
}

%type <dval> Expression Factor Function 
%type <sval> Rpn_expression Rpn_func Rpn_term Sum
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
        {   
            
            free_matrix(&mtx_var);// clear old matrix

            mtx_var = new_matrix(mtx_rows,g_mtx_cols);
            populate_matrix(&mtx_var, mtx_str);
            free(mtx_str);
            
            void* new_mtx = create_matrix(mtx_var);
            list_push_start(&list,"mtx",name_mtx_var,new_mtx);
            
            // Reset 
            mtx_str = malloc(sizeof(char*));
            g_mtx_cols = 1;
            mtx_rows = 1;
            mtx_columns = 0;
            free(name_mtx_var);

            return 0;
        }
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
        {   
            free_matrix(&mtx);
            mtx = new_matrix(mtx_rows,g_mtx_cols);
            populate_matrix(&mtx, mtx_str);
            free(mtx_str); 
            mtx_str = malloc(sizeof(char*));
            g_mtx_cols = 1;
            mtx_rows = 1;
            mtx_columns = 0;
            return 0;
        }
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
        free_all();
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
    VAR
        {   
            exp_str = concat_strings(exp_str,$1);
        }
    |Function
    |Factor 
        {
            $$ = $1; 
            aux_string = to_string($1); 
            exp_str = concat_strings(exp_str,aux_string);
        }
    |X 
        {
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
            sum($3, $5,$7,exp_str);
            return 0;
        }
; 

Matrix:
    MATRIX EQUAL OB OB  Matrix_column CB Matrix_line CB SEMI END_INPUT 
        {   
            if(mtx_columns > g_mtx_cols){
                g_mtx_cols = mtx_columns;
            } 
        }
    
    | MATRIX EQUAL OB OB  Matrix_column CB CB SEMI END_INPUT 
        {   
            if(mtx_columns > g_mtx_cols){
                g_mtx_cols = mtx_columns;
            } 
        }
    |

;

Matrix_line: 
    { mtx_str = concat_strings(mtx_str, "|");   }
    COMMA OB Matrix_column CB 
        {   
            mtx_str = concat_strings(mtx_str, "|");
            mtx_rows++;
        }
    | Matrix_line COMMA OB  Matrix_column CB 
        {   
            mtx_str = concat_strings(mtx_str, "|");
            mtx_rows++;
        }
;

Matrix_column: 
    Matrix_value 
        { 
            if(mtx_columns > g_mtx_cols){
                g_mtx_cols = mtx_columns;
            } 
            mtx_columns = 0;
        }
;

Matrix_value:
    COMMA Factor 
        {      
            aux_string = to_string($2);
            mtx_str = concat_strings(mtx_str, aux_string);
            mtx_columns++;
        }
    | Matrix_value COMMA Factor 
        {   
            aux_string = to_string($3);
            mtx_str = concat_strings(mtx_str, aux_string);
            mtx_columns++;
        }
    | Factor
    {
        aux_string = to_string($1);
        mtx_str = concat_strings(mtx_str, aux_string);
        mtx_columns++;
    }
;

Show_matrix: SHOW MATRIX SEMI END_INPUT 
    {   
        if(mtx.rows == 0){
            printf("No Matrix Defined!\n");
        }else{
            printf("\n");
            print_matrix(&mtx);
        }
        return 0;
    }
;

Solve_determinant: 
    SOLVE DETERMINANT SEMI END_INPUT 
    {   
        if(mtx.rows == 0){
            printf("No Matrix Defined!\n");
        }else{
            printf("\n");
            det_res = solve_determinant(mtx, mtx.rows);
            printf("%lf",det_res);
        }
        return 0;
    }
;

Solve_linear_system: 
    SOLVE LINEAR_SYSTEM SEMI END_INPUT 
        {
            printf("SOLVE linear SYSTEM\n"); 
            return 0;
        }
;

Attr_val_simb: 
    VAR ATRI Expression SEMI END_INPUT 
        {   
            remove_node_list = list_remove(&list,$1);
            if(remove_node_list) free(remove_node_list);
            void* new_var = create_var($3);
            list_push_start(&list,"var",$1,new_var);
            return 0;
        }
;

Attr_val_matrix: 
    VAR ATRI OB OB  Matrix_column CB Matrix_line CB SEMI END_INPUT
        {   
            

            name_mtx_var = (char*)malloc(sizeof(strlen($1)+1));
            strcpy(name_mtx_var,$1);

            remove_node_list = list_remove(&list,name_mtx_var);
            if(remove_node_list) free(remove_node_list);

            if(mtx_columns > g_mtx_cols){
                g_mtx_cols = mtx_columns;
            } 
        }
    |VAR ATRI OB OB  Matrix_column CB CB SEMI END_INPUT
        {
            if(mtx_columns > g_mtx_cols){
                g_mtx_cols = mtx_columns;
            } 
        }
;

Show_var: 
    VAR SEMI END_INPUT 
        {   
            list_print_var(list,$1);
            return 0;
        }
;

Show_all_var: 
    SHOW SYMBOLS SEMI END_INPUT 
        {
            list_print(list);
            return 0;
        }
;

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
        mtx_str = malloc(sizeof(char*));
        printf("> ");
        yyparse();
    } 
    free_all();
	return 0;
}

void free_all(){
    free(rpn_string);
    free(exp_str);
    free(exp_str_last);
    free(mtx_str);
    free_matrix(&mtx);
    free(name_mtx_var);
    free_matrix(&mtx_var);
    free(remove_node_list);
}
void yyerror(char const *s){
    int i;
	char c;
    if(strcmp(yytext,"\n")==0 || strcmp(yytext," ")==0){
        printf("SYNTAX ERROR: Incomplete command\n");

    }else{
        printf("SYNTAX ERROR: [%s]\n", yytext);
    }
    return;
}


void print_about(){
    printf("+----------------------------------------------+\n");    
    printf("|          João Pedro Alves Rodrigues          |\n");
    printf("|          Matricula:   000000000000           |\n");
    printf("+----------------------------------------------+\n");
}



