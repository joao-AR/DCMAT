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

    extern double pi;
    extern double e;

    //From Settings
    extern double h_view_lo;
    extern double h_view_hi; 
    extern double v_view_lo;
    extern double v_view_hi;
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

%type <dval> Expression Expression_term Factor Function 
%type <sval> Sum
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

            
            if(mtx_rows <= 10 && g_mtx_cols <=10){
                list_push_matrix_start(&list,name_mtx_var,mtx_str,mtx_rows, g_mtx_cols);
                free(mtx_str);
                free(name_mtx_var);
            }else{
                printf("Matrix limits out of boundaries.\n");
            }


            // Reset 
            mtx_str = malloc(sizeof(char*));
            g_mtx_cols = 1;
            mtx_rows = 1;
            mtx_columns = 0;

            return 0;
        }
    | Expression END_INPUT
        {   
            calc_rpn_std(exp_str,list);
            strcpy(exp_str_last,exp_str);
            free(exp_str); 
            
            exp_str = malloc(sizeof(char*));
            return 0;
        }
    | PLUS Expression END_INPUT
        {   
            calc_rpn_std(exp_str,list);
            strcpy(exp_str_last,exp_str);
            free(exp_str); 
            
            exp_str = malloc(sizeof(char*));
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
            if(mtx_rows <= 10 && g_mtx_cols <=10){
                mtx = new_matrix(mtx_rows,g_mtx_cols);
                populate_matrix(&mtx, mtx_str);
            }else{
                printf("Matrix limits out of boundaries.\n");
            }
            
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
    SET H_VIEW  Factor  INTERVAL  Factor  SEMI END_INPUT // set h_view [valor float] :  [valor float];
        { 
            set_view($3,$5,'h'); 
            return 0;
        }
    
    |SET V_VIEW Factor INTERVAL Factor SEMI END_INPUT  // set v_view [valor float] :  [valor float];
        {
            set_view($3,$5,'v');
            return 0;
        }
    |SET H_VIEW PLUS Factor INTERVAL Factor SEMI END_INPUT // set h_view [valor float] :  [valor float];
        { 
            set_view($4,$6,'h'); 
            return 0;
        }
    
    |SET V_VIEW PLUS Factor INTERVAL Factor SEMI END_INPUT  // set v_view [valor float] :  [valor float];
        {
            set_view($4,$6,'v');
            return 0;
        }
    |SET H_VIEW  Factor  INTERVAL  PLUS Factor  SEMI END_INPUT // set h_view [valor float] :  [valor float];
        { 
            set_view($3,$6,'h'); 
            return 0;
        }
    
    |SET V_VIEW Factor INTERVAL PLUS Factor SEMI END_INPUT  // set v_view [valor float] :  [valor float];
        {
            set_view($3,$6,'v');
            return 0;
        }
    |SET H_VIEW PLUS Factor INTERVAL PLUS Factor  SEMI END_INPUT // set h_view [valor float] :  [valor float];
        { 
            set_view($4,$7,'h'); 
            return 0;
        }
    
    |SET V_VIEW PLUS Factor INTERVAL PLUS Factor SEMI END_INPUT  // set v_view [valor float] :  [valor float];
        {
            set_view($4,$7,'v');
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
    |SET INTEGRAL_STEPS MINUS INTEGER SEMI END_INPUT 
        {
            printf("ERROR: integral_steps must be positive non-zero integer\n");
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
            L_node *var_node = list_seach(list, $1);
            if(var_node && strcmp(var_node->var_type,"var") == 0 ){// if var is a FLOAR VAR it put in a str
                aux_string = to_string(var_node->var.value);
                exp_str = concat_strings(exp_str,aux_string);
                rpn_string = concat_strings(rpn_string,aux_string); 

            }else if(var_node && strcmp(var_node->var_type,"mtx") == 0){
                exp_str = concat_strings(exp_str,var_node->var_name);
                rpn_string = concat_strings(rpn_string,var_node->var_name); 

            }else{
                printf("Var not Found %s\n",$1);
                return 0;
            }
        }
    |MINUS VAR 
        {
            L_node *var_node = list_seach(list, $2);
            if(var_node && strcmp(var_node->var_type,"var") == 0 ){// if var is a FLOAR VAR it put in a str
                aux_string = to_string(var_node->var.value);
                rpn_string = concat_strings(rpn_string,aux_string); 
                exp_str = concat_strings(exp_str,aux_string);
                rpn_string = concat_strings(rpn_string,"-1 *"); 
                exp_str = concat_strings(exp_str,"-1 *");
            
            }else if(var_node && strcmp(var_node->var_type,"mtx") == 0){
                exp_str = concat_strings(exp_str,var_node->var_name);
                rpn_string = concat_strings(rpn_string,var_node->var_name); 
                rpn_string = concat_strings(rpn_string,"-1 *"); 
                exp_str = concat_strings(exp_str,"-1 *");

            }else{
                printf("Var not Found %s\n",$2);
                return 0;
            }
        }
    |Function
    |Expression_term
    |Factor 
        {
            aux_string = to_string($1); 
            exp_str = concat_strings(exp_str,aux_string);
            rpn_string = concat_strings(rpn_string,aux_string); 
        }
    |Expression PLUS Expression 
        {
            exp_str = concat_strings(exp_str,"+");
            rpn_string = concat_strings(rpn_string,"+"); 

        }
    |Expression MINUS Expression 
        {
            exp_str = concat_strings(exp_str,"-"); 
            rpn_string = concat_strings(rpn_string,"-"); 
        }
    |Expression DIV Expression  
        {
            if($3 == 0){
                printf("ERROR division by ZERO\n");
                return 0;
            }else{
                exp_str = concat_strings(exp_str,"/");
                rpn_string = concat_strings(rpn_string,"/"); 
            }
        }
    |Expression MULT Expression 
        {
            exp_str = concat_strings(exp_str,"*"); 
            rpn_string = concat_strings(rpn_string,"*"); 
        }
    |Expression POW Expression 
        {
            exp_str = concat_strings(exp_str,"^"); 
            rpn_string = concat_strings(rpn_string,"^"); 
        }
    |Expression REST Expression 
        {
            exp_str = concat_strings(exp_str,"%");
            rpn_string = concat_strings(rpn_string,"%"); 
        }
    |OP Expression CP 
        {
            $$ = $2;
        }
;

Expression_term:
    X 
        {
            exp_str = concat_strings(exp_str,"x");
            rpn_string = concat_strings(rpn_string,"x"); 
        }
    | MINUS X 
        {   
            exp_str = concat_strings(exp_str,"x");
            rpn_string = concat_strings(rpn_string,"x"); 
             rpn_string = concat_strings(rpn_string,"-1 *"); 
                exp_str = concat_strings(exp_str,"-1 *");
        }
    |PI 
        {
            aux_string = to_string(pi);
            exp_str = concat_strings(exp_str,aux_string);
            rpn_string = concat_strings(rpn_string,aux_string); 
        }
    |E 
        {
            aux_string = to_string(e);
            exp_str = concat_strings(exp_str,aux_string);
            rpn_string = concat_strings(rpn_string,aux_string); 
        }
;


Function: 
    SEN OP Expression CP 
        {   
            exp_str = concat_strings(exp_str,"SEN"); 
            rpn_string = concat_strings(rpn_string,"SEN"); 
        }
    
    | COS OP Expression CP 
        { 
            exp_str = concat_strings(exp_str,"COS"); 
            rpn_string = concat_strings(rpn_string,"COS"); 
        }
    | TAN OP Expression CP 
        {   
            exp_str = concat_strings(exp_str,"TAN"); 
            rpn_string = concat_strings(rpn_string,"TAN"); 
        }
    | ABS OP Expression CP 
        {
            exp_str = concat_strings(exp_str,"ABS"); 
            rpn_string = concat_strings(rpn_string,"ABS"); 
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

Rpn: RPN OP Expression CP SEMI END_INPUT 
    {   
        printf("%s\n",rpn_string);
        return 0;
    }
;

//------------- END RPN

Integrate: 
    INTEGRATE OP Factor INTERVAL Factor COMMA Expression CP SEMI END_INPUT 
        {   
            if($3 > $5){
                printf("ERROR: lower limit must be smaller than upper limit\n");
            }else{
                riemann_sum($3,$5,exp_str);
            }
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
            print_value(det_res);

        }
        return 0;
    }
;

Solve_linear_system: 
    SOLVE LINEAR_SYSTEM SEMI END_INPUT 
        {
            solve_linear_system(&mtx);
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
            print_value($3);
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
            name_mtx_var = (char*)malloc(sizeof(strlen($1)+1));
            strcpy(name_mtx_var,$1);
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



