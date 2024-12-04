#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>

#include "stack.h"
#include "operations.h"
#include "variables.h"

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

void print_value(double num){ 
    if(precision == 0){
        printf("%.0lf\n",num);
    }else if(precision == 1){
        printf("%.1lf\n",num);
    }else if(precision == 2){
        printf("%.2lf\n",num);
    }else if(precision == 3){
        printf("%.3lf\n",num);
    }else if(precision == 4){
        printf("%.4lf\n",num);
    }else if(precision == 5){
        printf("%.5lf\n",num);
    }else if(precision == 6){
        printf("%.6lf\n",num);
    }else if(precision == 7){
        printf("%.7lf\n",num);
    }else if(precision == 8){
        printf("%.8lf\n",num);
    }
}

void print_value_mtx(double num){ 
    if(precision == 0){
        printf("%12.0lf ",num);
    }else if(precision == 1){
        printf("%12.1lf ",num);
    }else if(precision == 2){
        printf("%12.2lf ",num);
    }else if(precision == 3){
        printf("%12.3lf ",num);
    }else if(precision == 4){
        printf("%12.4lf ",num);
    }else if(precision == 5){
        printf("%12.5lf ",num);
    }else if(precision == 6){
        printf("%12.6lf ",num);
    }else if(precision == 7){
        printf("%13.7lf ",num);
    }else if(precision == 8){
        printf("%14.8lf ",num);
    }
}
double calc_values(double n1,double n2, char* op){
    
    double result = 0;

    if(strcmp(op,"+") == 0){
        result = n1 + n2;
        // printf("\n%f + %f = %f\n",n1,n2,result);
    }else if(strcmp(op,"-") == 0){
        result = n1 - n2;
    }else if(strcmp(op,"*") == 0){
        result = n1 * n2;
        // printf("\n%f * %f = %f\n",n1,n2,result);
    }else if(strcmp(op,"/") == 0){
        result = n1 / n2;
    }else if(strcmp(op,"^") == 0){
        result = pow(n1,n2);
        // printf("\npow(%f,%f) = %f\n",n1,n2,result);
    }else if(strcmp(op,"%") == 0){
        result =  fmod(n1,n2);
    }else if(strcmp(op, "SEN") == 0){
        result = sin(n2);
        // printf("-> Result sin(%f) = %f\n",n2,result);
    }else if(strcmp(op, "COS") == 0){
        result = cos(n2);
    }else if(strcmp(op, "TAN") == 0){
        result = tan(n2);
    }else if(strcmp(op, "ABS") == 0){
        result = fabs(n2);
    }
    return result;
}

bool is_operation_or_function(char* string, int type){

    // Simple Math Operations
    if(type == 1){
        if(strcmp(string, "+") == 0 || strcmp(string, "-") == 0 || strcmp(string, "*") == 0 || strcmp(string, "/") == 0 || strcmp(string, "^") == 0 || strcmp(string, "%") == 0){
            return true;
        }
    }else if(type == 2){ // Functions
        if(strcmp(string, "SEN") == 0 || strcmp(string, "COS") == 0 || strcmp(string, "TAN") == 0 ||strcmp(string, "ABS") == 0){
            return true;
        }
    }
    return false;
}


bool matrix_dim_error(int rows1, int cols1, int rows2,int cols2,char* op){

    if( ((strcmp(op,"+") == 0 || strcmp(op,"-") == 0 ) && (rows1 != rows2 || cols1 != cols2) ) 
        || strcmp(op,"*") == 0 &&  cols2 != rows1){
        printf("Incorrect dimensions for operator '%s' - have MATRIX [%d][%d] and MATRIX [%d][%d]\n",op,rows2,cols2,rows1,cols1);
        return true;
    }

    return false;
}

void sum_matrix(Matrix *mtx1, Matrix *mtx2,Matrix *result_mtx){
    //Populate Matrix
    for(int i = 0; i < mtx1->rows; i++){
        for(int j = 0; j < mtx1->cols; j++) result_mtx->data[i][j] = mtx1->data[i][j] + mtx2->data[i][j];
    }
}

Matrix* mult_mtx_by_factor(Matrix* mtx, double factor){
    
    for (int i = 0; i < mtx->rows; i++) {
        for (int j = 0; j < mtx->cols; j++) {
            mtx->data[i][j] = mtx->data[i][j] * factor;
        }
    }
    return mtx;
}


void sub_matrix(Matrix *mtx1, Matrix *mtx2, Matrix *result_mtx){
    //Populate Matrix
    for(int i = 0; i < mtx1->rows; i++){
        for(int j = 0; j < mtx1->cols; j++) result_mtx->data[i][j] = mtx1->data[i][j] - mtx2->data[i][j];
    }
}

void mult_matrix(Matrix *mtx1, Matrix *mtx2,Matrix *result_mtx){

    //Populate Matrix
    for (int i = 0; i < result_mtx->rows; i++) {
        for (int j = 0; j < result_mtx->cols; j++) {
            result_mtx->data[i][j] = 0.0;
            for (int k = 0; k < mtx1->cols; k++) {
                result_mtx->data[i][j] += mtx1->data[i][k] * mtx2->data[k][j];
            }
        }
    }
}   

Matrix* matrix_operations(Matrix *mtx1, Matrix *mtx2, char* op){
    
    bool error = false;

    //Initialize matrix
    Matrix *result_mtx = (Matrix*)malloc(sizeof(Matrix));
    
    
    if(strcmp(op,"*") == 0){
        result_mtx->rows = mtx2->rows;
        result_mtx->cols = mtx1->cols; // if mult [n,m] * [m,j] = [n,j]
        result_mtx->data = (double**) malloc(mtx2->rows * sizeof(double*));
    }else{
        result_mtx->rows = mtx1->rows;
        result_mtx->cols = mtx1->cols;
        result_mtx->data = (double**) malloc(mtx1->rows * sizeof(double*));
    }
    
    for(int i = 0; i < mtx1->rows ; i++) result_mtx->data[i] = (double*)malloc(mtx1->cols * sizeof(double));
    
    if(strcmp(op,"+") == 0){
        error = matrix_dim_error(mtx1->rows,mtx1->cols,mtx2->rows,mtx2->cols,op );
        if(error) return NULL;
        sum_matrix(mtx1,mtx2,result_mtx);

    }else if(strcmp(op,"-") == 0){
        error = matrix_dim_error(mtx1->rows,mtx1->cols,mtx2->rows,mtx2->cols,op );
        if(error) return NULL;
        sub_matrix(mtx1,mtx2,result_mtx);
    }else if(strcmp(op,"*") == 0){
        error = matrix_dim_error(mtx1->rows,mtx1->cols,mtx2->rows,mtx2->cols,op );
        if(error) return NULL;
        mult_matrix(mtx2,mtx1,result_mtx);
    }else{
        printf("Not accepted MATRIX operation '%s' \n",op);
    }

    return result_mtx;
}

void calc_rpn_std(char *expression, L_node *list) {
    double num;
    Stack_node *n1, *n2, *stack = NULL;
    L_node *m1;
    Matrix *n3;
    
    // Copia a expressão para não modificar a original
    char *expression_copy = strdup(expression);
    if (expression_copy == NULL) {
        perror("Erro ao alocar memória para a cópia da expressão");
        return;
    }

    char *token = strtok(expression_copy, " ");

    while (token) { 
        if (is_operation_or_function(token, 1)) {
            n1 = stack_pop(&stack);
            n2 = stack_pop(&stack);

            if (!n1 || !n2) {
                printf("Erro: Operação com operandos insuficientes\n");
                if (n1) free(n1);
                if (n2) free(n2);
                free(expression_copy);
                return;
            }

            if (strcmp(n1->var_type, "var") == 0 && strcmp(n2->var_type, "var") == 0) {  
                num = calc_values(n2->var.value, n1->var.value, token);
                stack_push(&stack, num);

            } else if (strcmp(n1->var_type, "mtx") == 0 && strcmp(n2->var_type, "var") == 0) { 
                if (strcmp(token, "*") != 0) {
                    printf("Incorrect type for operator '%s' - have MATRIX and FLOAT\n", token);
                    free(n1);
                    free(n2);
                    free(expression_copy);
                    return;
                }

                n3 = mult_mtx_by_factor(&n1->mtx, n2->var.value);
                stack_push_matrix(&stack, n3);
                free_matrix(n3); // Libera a matriz alocada por mult_mtx_by_factor

            } else if (strcmp(n1->var_type, "var") == 0 && strcmp(n2->var_type, "mtx") == 0) { 
                if (strcmp(token, "*") != 0) {
                    printf("Incorrect type for operator '%s' - have FLOAT and MATRIX\n", token);
                    free(n1);
                    free(n2);
                    free(expression_copy);
                    return;
                }

                n3 = mult_mtx_by_factor(&n2->mtx, n1->var.value);
                stack_push_matrix(&stack, n3);
                free_matrix(n3);

            } else { // |MATRIX MATRIX|
                n3 = matrix_operations(&n1->mtx, &n2->mtx, token);
                if (!n3) {
                    free(n1);
                    free(n2);
                    free(expression_copy);
                    return;
                }
                stack_push_matrix(&stack, n3);
                free_matrix(n3);
            }

            free(n1);
            free(n2);

        } else if (is_operation_or_function(token, 2)) {
            n1 = stack_pop(&stack);

            if (!n1) {
                printf("Erro: Operação com operandos insuficientes\n");
                free(expression_copy);
                return;
            }

            num = calc_values(0, n1->var.value, token);
            stack_push(&stack, num);
            free(n1);

        } else {
            if (is_in_list(list, token) == 1) { 
                m1 = list_search(list, token);
                stack_push_matrix(&stack, &m1->mtx);
            } else {
                num = atof(token);
                stack_push(&stack, num);
            }
        }

        token = strtok(NULL, " ");
    }

    // Imprime o resultado final
    if (stack) {
        if (strcmp(stack->var_type, "var") == 0) {
            print_value(stack->var.value);
        } else if (strcmp(stack->var_type, "mtx") == 0) {
            print_matrix(&stack->mtx);
        }
    }

    // Libera o restante da pilha
    while (stack) {
        if(&stack->mtx) free_matrix(&stack->mtx);
        n1 = stack_pop(&stack);
        if (n1) free(n1);
    }

    // Libera a cópia da expressão
    free(expression_copy);
}


Stack_node* calc_rpn_attr(char *expression, L_node *list){
    double num;
    Stack_node *n1, *n2, *stack = NULL;
    
    L_node *m1,*m2;

    Matrix *n3;
    
    expression = strtok(expression," ");

    while (expression){ 
        if(is_operation_or_function(expression,1)){
            
            n1 = stack_pop(&stack);
            n2 = stack_pop(&stack);

            if(strcmp(n1->var_type,"var") == 0 && strcmp(n2->var_type,"var") == 0 ){  // |FLOAT FLOAT|
                num = calc_values(n2->var.value,n1->var.value,expression);
                stack_push(&stack,num);
            
            }else if(strcmp(n1->var_type,"mtx") == 0 && strcmp(n2->var_type,"var") == 0 ){ //  |MATRIX FLOAT|
                if(strcmp(expression,"*") != 0){ printf("Incorrect type for operator '%s' - have MATRIX and FLOAT\n",expression); return NULL;}

                n3 = mult_mtx_by_factor(&n1->mtx, n2->var.value);
                print_matrix(n3);
                stack_push_matrix(&stack,n3);
                
            }else if(strcmp(n1->var_type,"var") == 0 && strcmp(n2->var_type,"mtx") == 0 ){ //  |FLOAT MATRIX|
                if(strcmp(expression,"*") != 0) {printf("Incorrect type for operator '%s' - have  FLOAT and MATRIX\n",expression); return NULL;}
                n3 = mult_mtx_by_factor(&n2->mtx, n1->var.value);
                stack_push_matrix(&stack,n3);

            }else{ //|MATRIX MATRIX|
                n3 = matrix_operations(&n1->mtx,&n2->mtx,expression);
                if(n3 == NULL) return NULL;
                stack_push_matrix(&stack,n3);
            }
            
            free(n1);
            free(n2);
    
        }else if(is_operation_or_function(expression,2)){
                n1 = stack_pop(&stack);
                num = calc_values(0,n1->var.value,expression);
                stack_push(&stack,num);
                free(n1);
            
        }else{
            
            if(is_in_list(list,expression) == 1){ // If is in the list it's a Matrix
                m1 = list_search(list,expression);
                stack_push_matrix(&stack, &m1->mtx);
            }else{
                num = atof(expression);
                stack_push(&stack, num);
            }
        }
        
        expression = strtok(NULL," ");
    }
    
    
    return stack; 
}


double calc_rpn_plot(double x, char *expression, char *var) {
    double num;
    Stack_node *n1, *n2, *stack = NULL;

    // Cria uma cópia da string para evitar modificar a original
    char *expr_copy = strdup(expression);
    if (expr_copy == NULL) {
        fprintf(stderr, "Erro ao alocar memória.\n");
        return 0;
    }

    char *token = strtok(expr_copy, " ");
    while (token) {
        if (is_operation_or_function(token, 1)) {
            n1 = stack_pop(&stack);
            n2 = stack_pop(&stack);

            // Verifica se os elementos retirados da pilha são válidos
            if (n1 == NULL || n2 == NULL) {
                fprintf(stderr, "Erro: Pilha vazia ao realizar operação binária.\n");
                free(expr_copy);
                stack_pop_all(&stack);
                break;
                return 0;
            }

            num = calc_values(n2->var.value, n1->var.value, token);
            stack_push(&stack, num);
            free(n1);
            free(n2);

        } else if (is_operation_or_function(token, 2)) {
            n1 = stack_pop(&stack);

            // Verifica se o elemento retirado da pilha é válido
            if (n1 == NULL) {
                fprintf(stderr, "Erro: Pilha vazia ao realizar operação unária.\n");
                free(expr_copy);
                stack_pop_all(&stack);
                return 0;
            }

            num = calc_values(0, n1->var.value, token);
            stack_push(&stack, num);
            free(n1);

        } else if (strcmp(token, var) == 0) {
            num = x;
            stack_push(&stack, num);

        } else {
            num = atof(token);
            stack_push(&stack, num);
        }

        token = strtok(NULL, " ");
    }

    free(expr_copy);
    stack_pop_all(&stack); // Libera qualquer memória restante na pilha
    return num;
}


void riemann_sum(double inf,double sup,char *expression){
    double delta_x = (sup - inf) / integral_steps;
    double result = 0.0;
    double x_i = 0.0; // median point
    
    size_t len =  strlen(expression);
    char *exp = (char*)malloc(len+1);

    strcpy(exp,expression);

    for(int i = 0 ; i < integral_steps; i++ ){
        x_i = inf + i * delta_x;
        
        result += calc_rpn_plot(x_i,exp,"x");
        strcpy(exp,expression);
    }
    result =  result * delta_x;
    free(exp);
    printf("%f\n",result);
}




void sum(char *var, int inf, int sup, char *expression){ 
    size_t len =  strlen(expression);
    char *exp = (char*)malloc(len+1);
    double result = 0.0;
    strcpy(exp,expression);

    for(int i = inf; i <= sup; i++){
        result += calc_rpn_plot(i,exp,var);
        strcpy(exp,expression);
    }

    free(exp);
    print_value(result);
} 

// --------- Matrix

Matrix new_matrix(int rows, int cols) {
    Matrix mtx;
    mtx.rows = rows;
    mtx.cols = cols;

    mtx.data = (double**)calloc(rows, sizeof(double*)); // Aloca memória para as linhas
    for(int i = 0; i < rows; i++){
        mtx.data[i] = (double*)calloc(cols, sizeof(double)); // Aloca memória para as colunas
    }

    return mtx;
}

// Function to free the memory allocated for a matrix
void free_matrix(Matrix* mtx) {
    // Verifica se o ponteiro é nulo
    if (mtx == NULL || mtx->data == NULL) return;

    // Libera cada linha da matriz
    for (int i = 0; i < mtx->rows; i++) {
        if (mtx->data[i] != NULL) { // Verifica se a linha foi alocada
            free(mtx->data[i]);
            mtx->data[i] = NULL; // Evita ponteiros pendentes
        }
    }

    // Libera o array de ponteiros
    free(mtx->data);
    mtx->data = NULL;

    // Redefine as dimensões da matriz
    mtx->rows = 0;
    mtx->cols = 0;
}

// Function to populate a matrix structure from a string
void populate_matrix(Matrix* mtx, char* mtx_str) {
    int i = 0;
    int j = 0;

    char* token = strtok(mtx_str, " ");

    while (token) {
        if (strcmp(token, "|") == 0) {
            j++;
            i = 0;
        } else {
            if (j < mtx->rows && i < mtx->cols) {
                mtx->data[j][i] = strtod(token, NULL);
                i++;
            }
        }
        token = strtok(NULL, " ");
    }
}

void print_matrix_container(int size){
    printf("+-");
    for(int i = 0; i < size -2; i++){
        printf(" ");
    }
    printf("-+\n");
}

// Function to print the matrix
void print_matrix(const Matrix* mtx) {
    int size_matrix = 0;
    if(precision == 8){
        size_matrix = mtx->cols * 15;
    }else if(precision == 7){
        size_matrix = mtx->cols * 14;
    }else{
        size_matrix = mtx->cols * 13;
    }
    printf("\n");
    print_matrix_container(size_matrix);
    for (int i = 0; i < mtx->rows; i++) {
        printf("|");
        for (int j = 0; j < mtx->cols; j++) {
            if(!mtx->data[i][j]){
                print_value_mtx(0.000000000);

            }else{
                print_value_mtx(mtx->data[i][j]);
            }
        }
        printf("|"); 
        printf("\n");
    }
    print_matrix_container(size_matrix);
}



// ---------- Solve Determiant
void submatrix(Matrix mtx, Matrix *temp ,int p, int q, int n){
    int i = 0, j = 0;

    for (int row = 0; row < n; row++){
        for (int col = 0; col < n; col++){
            if (row != p && col != q){
                temp->data[i][j++] = mtx.data[row][col];

                if (j == n - 1) {
                    j = 0;
                    i++;
                }
            }
        }
    }
}

double solve_determinant(Matrix mtx, int n){ 

    if (mtx.cols != mtx.rows) {
        printf("Matrix format incorrect!\n");
        return 0;
    }

    double det_result = 0; 

    // Base case 1x1
    if (n == 1) return mtx.data[0][0];

    Matrix temp = new_matrix(mtx.rows, mtx.cols);

    int sign = 1; 

    for (int f = 0; f < n; f++){
        
        submatrix(mtx, &temp, 0, f, n);
        det_result += sign * mtx.data[0][f] * solve_determinant(temp, n - 1);

        sign = -sign;
    }

    free_matrix(&temp);
    return det_result;
}
// ---------- END Solve Determiant


void solve_linear_system(Matrix *mtx) {
    int cols = mtx->cols;
    int rows = mtx->rows;

    for (int i = 0; i < rows; i++) {
        // Partial pivoting to ensure a non-zero pivot
        for (int k = i + 1; k < rows; k++) {
            if (mtx->data[k][i] > mtx->data[i][i]) {
                for (int j = 0; j <= rows; j++) {
                    double temp = mtx->data[i][j];
                    mtx->data[i][j] = mtx->data[k][j];
                    mtx->data[k][j] = temp;
                }
            }
        }

        // Gauss
        for (int k = i + 1; k < rows; k++) {
            double factor = mtx->data[k][i] / mtx->data[i][i];
            for (int j = i; j <= rows; j++) {
                mtx->data[k][j] -= factor * mtx->data[i][j];
            }
        }
    }

    // Is indeterminate System ?
    for (int i = 0; i < rows; i++) {
        int isZeroRow = 1;
        for (int j = 0; j <= rows; j++) {
            if (mtx->data[i][j] != 0) {
                isZeroRow = 0;
                break;
            }
        }
        if (isZeroRow && mtx->data[i][rows] == 0) {
            printf("SPI - The Linear System has infinitely many solutions\n");
            return;
        }
    }

    // Find Solutions
    double solutions[rows];
    for (int i = rows - 1; i >= 0; i--) {
        solutions[i] = mtx->data[i][rows] / mtx->data[i][i];
        for (int j = i - 1; j >= 0; j--) {
            mtx->data[j][rows] -= mtx->data[j][i] * solutions[i];
        }
    }

    if(isinf(solutions[0])){
        printf("SI - The Linear System has no solution\n");
        return;
    }

    // Print Solution
    printf("\n");
    for (int i = 0; i < rows; i++) {
        printf("%f\n", solutions[i]);
    }
    printf("\n");
}

// ---------- Strings Operations
char* matrix_to_string(Matrix *mtx) {
    if (mtx == NULL || mtx->data == NULL) {
        return NULL; // Verifica se a matriz é válida
    }

    // Aloca memória inicial suficiente para o buffer (tamanho arbitrário inicial)
    size_t buffer_size = 256; 
    char* mtx_str = (char*)malloc(buffer_size);
    if (mtx_str == NULL) {
        fprintf(stderr, "Erro: Falha ao alocar memória para mtx_str.\n");
        return NULL;
    }
    mtx_str[0] = '\0'; // Inicializa a string vazia

    for (int i = 0; i < mtx->rows; i++) {
        for (int j = 0; j < mtx->cols; j++) {
            // Converte o número em string
            char* value_str = to_string(mtx->data[i][j]);
            if (value_str == NULL) {
                free(mtx_str);
                return NULL;
            }

            // Concatena o valor à string
            size_t required_size = strlen(mtx_str) + strlen(value_str) + 2; // +1 para espaço ou '|', +1 para '\0'
            if (required_size > buffer_size) {
                buffer_size *= 2; // Duplica o buffer
                char* new_mtx_str = (char*)realloc(mtx_str, buffer_size);
                if (new_mtx_str == NULL) {
                    free(value_str);
                    free(mtx_str);
                    return NULL;
                }
                mtx_str = new_mtx_str;
            }

            strcat(mtx_str, value_str);
            strcat(mtx_str, " "); // Adiciona espaço entre os valores
            free(value_str);
        }

        // Adiciona o delimitador de linha '|'
        if (i < mtx->rows - 1) {
            size_t required_size = strlen(mtx_str) + 2; // +1 para '|', +1 para '\0'
            if (required_size > buffer_size) {
                buffer_size *= 2;
                char* new_mtx_str = (char*)realloc(mtx_str, buffer_size);
                if (new_mtx_str == NULL) {
                    free(mtx_str);
                    return NULL;
                }
                mtx_str = new_mtx_str;
            }
            strcat(mtx_str, "|");
        }
    }

    return mtx_str;
}


char* to_string(double value){ 
     // Calcula o tamanho necessário para armazenar a string formatada
    int len = snprintf(NULL, 0, "%f", value);

    // Aloca memória suficiente para a string (incluindo o terminador nulo)
    char* result = (char*)malloc(len + 1);  // +1 para '\0'
    if (result == NULL) {
        fprintf(stderr, "Erro: Falha ao alocar memória.\n");
        exit(1);  // Termina o programa em caso de erro
    }

    // Formata o valor na string alocada
    snprintf(result, len + 1, "%f", value);

    return result;  // Retorna o ponteiro para a string alocada
}

char* concat_strings(const char* str1, const char* str2) {
    // Validações
    if (str1 == NULL) str1 = ""; // Trate str1 como string vazia se for NULL
    if (str2 == NULL) str2 = ""; // Trate str2 como string vazia se for NULL

    // Calcula o tamanho necessário
    size_t size = strlen(str1) + strlen(str2) + 2; // +2 para espaço e '\0'

    // Aloca a memória para o resultado
    char* result = (char*)malloc(size);
    if (!result) {
        perror("Erro ao alocar memória");
        exit(EXIT_FAILURE);
    }

    // Copia e concatena as strings
    strcpy(result, str1);
    strcat(result, " "); // Adiciona espaço entre as strings
    strcat(result, str2);

    return result;
}
