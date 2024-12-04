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
    extern void yylex_destroy();
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
    bool is_rpn = false;
    bool is_sum = false;
    bool have_x = false;
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
                
            }else{
                printf("Matrix limits out of boundaries.\n");
            }

            if(mtx_str != NULL ) free(mtx_str);
            if(name_mtx_var != NULL ){
                free(name_mtx_var);
                name_mtx_var = NULL;
            }
                

            print_matrix(&list->mtx);
            // Reset 
            mtx_str = calloc(1,sizeof(char*));
            g_mtx_cols = 1;
            mtx_rows = 1;
            mtx_columns = 0;

            return 0;
        } 
    | Expression END_INPUT
        {   
            if(have_x == true){
                printf("The x variable cannot be present on expressions.\n");
                have_x = false;
            }else{
                calc_rpn_std(exp_str,list);
            }
            
            if (exp_str_last != NULL) free(exp_str_last); // Libera memória da última expressão
            
            exp_str_last = strdup(exp_str); // Cria cópia de exp_str
            
           // Libera e realoca exp_str e rpn_string
            if (exp_str != NULL) free(exp_str);
            if (rpn_string != NULL) free(rpn_string);

            exp_str = calloc(1,sizeof(char) * 100); // Aloca espaço suficiente
            rpn_string = calloc(1,sizeof(char) * 100); // Aloca espaço suficiente

            strcpy(exp_str,"");
            strcpy(rpn_string,"");
            return 0;   
        }
    | PLUS Expression END_INPUT
        {   
            if(have_x == true){
                printf("The x variable cannot be present on expressions.\n");
                have_x = false;
            }else{
                calc_rpn_std(exp_str,list);
            }
            if (exp_str_last != NULL) free(exp_str_last); // Libera memória da última expressão
            
            exp_str_last = strdup(exp_str); // Cria cópia de exp_str
            free(exp_str); 
            exp_str = calloc(1,sizeof(char) * 100);
            strcpy(exp_str,"");
            return 0;
        }
    | Show_Settings 
    | Reset_Settings 
    | Set_View
    | Set_Axis 
    | Set_Erase_Plot
    | Set_Connected_Dosts
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
            mtx_str = calloc(1,sizeof(char*));
            g_mtx_cols = 1;
            mtx_rows = 1;
            mtx_columns = 0;
            return 0;
        }
    | Integrate 
    | Inc_Sum
    | Rpn 
        {   
            free(rpn_string); 
            rpn_string = calloc(1,sizeof(char*));
            strcpy(rpn_string,"");
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
Inc_Sum:
    {
        is_sum = true;
    } 
    Sum 
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

Set_Connected_Dosts:
    SET CONNECT_DOTS ON SEMI END_INPUT{return 0;}
    |SET CONNECT_DOTS OFF SEMI END_INPUT {return 0;}
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
            L_node *var_node = list_search(list, $1);
            if(var_node && strcmp(var_node->var_type,"var") == 0 ){// if var is a FLOAT VAR it put in a str
                char* temp = to_string(var_node->var.value);
                char* temp2 = concat_strings(exp_str,temp);
                if(exp_str != NULL) free(exp_str);
                exp_str = temp2;
                free(temp);
                $$ = var_node->var.value;

            }else if(var_node && strcmp(var_node->var_type,"mtx") == 0){
                char* temp = concat_strings(exp_str,var_node->var_name);
                if(exp_str != NULL) free(exp_str);
                exp_str = temp;

            }else if(is_rpn == false && is_sum == false){
                printf("Undefined symbol [%s]\n",$1);
                free($1);
                return 0;
            }

            if(is_sum && var_node == NULL){
                char* temp = concat_strings(exp_str,$1);
                if(exp_str != NULL) free(exp_str);
                exp_str = temp;

            }
            char* temp = concat_strings(rpn_string,$1);
            if(rpn_string != NULL) free(rpn_string);
            rpn_string = temp;

            free($1);
        } 
    |MINUS VAR 
        {   
            L_node *var_node = list_search(list, $2);

            if(var_node && strcmp(var_node->var_type,"var") == 0 ){// if var is a FLOART VAR it put in a str
                
                char* temp = to_string(var_node->var.value);
                char* temp2 = concat_strings(exp_str,temp);
                char* temp3 = concat_strings(temp2,"-1 *");
                if(exp_str != NULL) free(exp_str);
                exp_str = temp3;
                free(temp);
                free(temp2);
            
            }else if(var_node && strcmp(var_node->var_type,"mtx") == 0){
                char* temp = concat_strings(exp_str,$2);
                char* temp2 = concat_strings(temp,"-1 *");
                if(exp_str != NULL) free(exp_str);
                exp_str = temp2;
                free(temp);

            }else if(is_rpn == false && is_sum == false){
                printf("Undefined symbol [%s]\n",$2);
                free($2);
                return 0;
            }

            if(is_sum && var_node == NULL){
                char* temp = concat_strings(exp_str,$2);
                if(exp_str != NULL) free(exp_str);
                exp_str = temp;
            }
            
            char* temp = concat_strings(rpn_string,$2); 
            char* temp2 = concat_strings(temp,$2); 
            if(rpn_string != NULL) free(rpn_string);

            rpn_string = temp2;
            free(temp);
            free($2);
        }
    |Function
    |Expression_term 
    |Factor 
        {   
            $$ = $1;
            char *temp = to_string($1);
            char *temp2 = concat_strings(exp_str, temp);
            free(exp_str);
            free(rpn_string);
            exp_str = temp2;
            rpn_string = strdup(temp2);
            free(temp);
        }
    |Expression PLUS Expression 
        {   
            $$ = $1 + $3;
            char *temp = concat_strings(exp_str,"+");
            free(exp_str);
            free(rpn_string);
            exp_str = temp;
            rpn_string = strdup(temp);

        }
    |Expression MINUS Expression 
        {   
            $$ = $1 - $3;
            char *temp = concat_strings(exp_str,"-");
            free(exp_str);
            free(rpn_string);
            exp_str = temp;
            rpn_string = strdup(temp);
        }
    |Expression DIV Expression  
        {
            if($3 == 0){
                printf("ERROR division by ZERO\n");
                return 0;
            }else{
                $$ = $1 / $3;
                char *temp = concat_strings(exp_str,"/");
                free(exp_str);
                free(rpn_string);
                exp_str = temp;
                rpn_string = strdup(temp);
            }
        }
    |Expression MULT Expression 
        {   
            $$ = $1 * $3;
            char *temp = concat_strings(exp_str,"*");
            free(exp_str);
            free(rpn_string);
            exp_str = temp;
            rpn_string = strdup(temp);
        }
    |Expression POW Expression 
        {   
            $$ = pow($1,$3);
            char *temp = concat_strings(exp_str,"^");
            free(exp_str);
            free(rpn_string);
            exp_str = temp;
            rpn_string = strdup(temp);
        }
    |Expression REST Expression 
        {   
            $$ = fmod($1,$3);
            char *temp = concat_strings(exp_str,"%");
            free(exp_str);
            free(rpn_string);
            exp_str = temp;
            rpn_string = strdup(temp);
        }
    |OP Expression CP 
        {
            $$ = $2;
        }
;

Expression_term:
    X 
        {
            char* temp = concat_strings(exp_str,"x");
            if(exp_str != NULL) free(exp_str);
            exp_str = temp;

            char* temp2 = concat_strings(rpn_string,"x");
            if(rpn_string != NULL) free(rpn_string);
            rpn_string = temp2;
            
            have_x = true;
        }
    | MINUS X 
        {   
            char* temp = concat_strings(exp_str,"x");
            char* temp2 = concat_strings(temp,"-1 *");
            if(exp_str != NULL) free(exp_str);
            exp_str = temp2;

            char* temp3 = concat_strings(rpn_string,"x");
            char* temp4 = concat_strings(temp3,"-1 *"); 
            if(rpn_string != NULL) free(rpn_string);
            rpn_string = temp4;

            free(temp);
            free(temp3);
        }
    |PI 
        {
            char* temp = to_string(pi);
            char* temp2 = concat_strings(exp_str,temp);
            if(exp_str != NULL) free(exp_str);
            if(rpn_string != NULL) free(rpn_string);
            exp_str = temp2;
            rpn_string = strdup(temp2);
            free(temp);
        }
    |E 
        {
            char* temp =  to_string(e);
            char* temp2 = concat_strings(exp_str,temp);

            if(exp_str != NULL) free(exp_str);
            if(rpn_string != NULL) free(rpn_string);
            exp_str = temp2;
            rpn_string = strdup(temp2);
            free(temp);
        }
;

Function: 
    SEN OP Expression CP 
        {   
            char* temp = concat_strings(exp_str,"SEN");
            if(exp_str != NULL) free(exp_str);
            if(rpn_string != NULL) free(rpn_string);
            exp_str = temp;
            rpn_string = strdup(temp); 
        }
    
    | COS OP Expression CP 
        { 
            char* temp = concat_strings(exp_str,"COS");
            if(exp_str != NULL) free(exp_str);
            if(rpn_string != NULL) free(rpn_string);
            exp_str = temp;
            rpn_string = strdup(temp); 
        }
    | TAN OP Expression CP 
        {   
            char* temp = concat_strings(exp_str,"TAN");
            if(exp_str != NULL) free(exp_str);
            if(rpn_string != NULL) free(rpn_string);
            exp_str = temp;
            rpn_string = strdup(temp); 
        }
    | ABS OP Expression CP 
        {
            char* temp = concat_strings(exp_str,"ABS");
            if(exp_str != NULL) free(exp_str);
            if(rpn_string != NULL) free(rpn_string);
            exp_str = temp;
            rpn_string = strdup(temp); 
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

Rpn:
    {
        is_rpn = true;
        
    }
    RPN OP Expression CP SEMI END_INPUT 
    {      
        printf("%s\n",rpn_string);
        is_rpn = false;
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
            sum($3,$5,$7,exp_str);
            is_sum = false;
            free($3);
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
    { 
        char* temp = concat_strings(mtx_str, "|");  
        if(mtx_str != NULL) free(mtx_str);
        mtx_str = temp;

    }
    COMMA OB Matrix_column CB 
        {   
            char* temp = concat_strings(mtx_str, "|");
            if(mtx_str != NULL) free(mtx_str);
            mtx_str = temp;
            mtx_rows++;
        }
    | Matrix_line COMMA OB  Matrix_column CB 
        {   
            char* temp = concat_strings(mtx_str, "|");
            if(mtx_str != NULL) free(mtx_str);
            mtx_str = temp;
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
            char* temp = to_string($2);
            char* temp2 = concat_strings(mtx_str, temp);
            if(mtx_str != NULL) free(mtx_str);
            mtx_str = temp2;
            free(temp);
            mtx_columns++;
        }
    | Matrix_value COMMA Factor 
        {   
            char* temp = to_string($3);
            char* temp2 = concat_strings(mtx_str, temp);
            if(mtx_str != NULL) free(mtx_str);
            mtx_str = temp2;
            free(temp);
            mtx_columns++;
        }
    | Factor
    {
        char* temp = to_string($1);
        char* temp2 = concat_strings(mtx_str, temp);
        if(mtx_str != NULL) free(mtx_str);
        mtx_str = temp2;
        free(temp);
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
            // If there is alrady a var with the same name, delete it and replace for the new one
            remove_node_list = list_remove(&list,$1);
            if(remove_node_list){
                free(remove_node_list->var_name);
                free(remove_node_list);
            } 
                
            Stack_node *value_rpn = calc_rpn_attr(exp_str,list);
            
            if(strcmp (value_rpn->var_type,"mtx")==0 ){
                char* temp = matrix_to_string(&value_rpn->mtx);
                if(mtx_str) free(mtx_str);
                mtx_str = temp;

                if(&mtx) free_matrix(&mtx);

                if(mtx_rows <= 10 && g_mtx_cols <=10){
                    mtx = new_matrix(value_rpn->mtx.rows,value_rpn->mtx.cols);
                    populate_matrix(&mtx, mtx_str);
                }else{
                    printf("Matrix limits out of boundaries.\n");
                }

                list_push_matrix_start(&list,$1,mtx_str,value_rpn->mtx.rows, value_rpn->mtx.cols);
                print_matrix(&value_rpn->mtx);
                // free(value_rpn);
                free(mtx_str);
            }else{
                F_var new_var = create_var(value_rpn->var.value);
                list_push_start(&list,"var",$1,new_var);
                print_value(value_rpn->var.value);
            }
            stack_pop_all(&value_rpn);
            free($1);
            return 0;
        }
;

Attr_val_matrix: 
    VAR ATRI OB OB  Matrix_column CB Matrix_line CB SEMI END_INPUT
        {   
            
            if(name_mtx_var != NULL) free(name_mtx_var);

            name_mtx_var = calloc(1,strlen($1) + 1); // Aloca memória suficiente para a string + '\0'
            strcpy(name_mtx_var,$1);

            remove_node_list = list_remove(&list,name_mtx_var);
            if(remove_node_list) free(remove_node_list);

            if(mtx_columns > g_mtx_cols){
                g_mtx_cols = mtx_columns;
            }

            free($1);
        }
    |VAR ATRI OB OB  Matrix_column CB CB SEMI END_INPUT
        {   
            name_mtx_var = (char*)calloc(1,sizeof(strlen($1)+1));
            strcpy(name_mtx_var,$1);
            if(mtx_columns > g_mtx_cols){
                g_mtx_cols = mtx_columns;
            } 
            free($1);
        }
;

Show_var: 
    VAR SEMI END_INPUT 
        {   
            list_print_var(list,$1);
            free($1);
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
    exp_str_last = calloc(1,sizeof(char) * 100);
    while (1) {
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
    if(!mtx_str) free(mtx_str);
    free_matrix(&mtx);
    if (name_mtx_var != NULL) free(name_mtx_var);
    free_matrix(&mtx_var); 
    if (!remove_node_list) free(remove_node_list); 
    free_list(&list);
    yylex_destroy();
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
    printf("\n+----------------------------------------------+\n");
    printf("|                                              |\n");    
    printf("|          Matricula:   202000560523           |\n");
    printf("|          João Pedro Alves Rodrigues          |\n");
    printf("|                                              |\n");    
    printf("+----------------------------------------------+\n");
}



