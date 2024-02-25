#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>

#include "stack.h"
#include "operations.h"

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

void print_value(float num){
    if(precision == 0){
        printf("%.0f\n",num);
    }else if(precision == 1){
        printf("%.1f\n",num);
    }else if(precision == 2){
        printf("%.2f\n",num);
    }else if(precision == 3){
        printf("%.3f\n",num);
    }else if(precision == 4){
        printf("%.4f\n",num);
    }else if(precision == 5){
        printf("%.5f\n",num);
    }else{
        printf("%.6f\n",num);
    }
}

float calc_values(float n1,float n2, char* op){
    
    float result = 0;

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
    }else if(strcmp(op,"%%") == 0){
        result =  fmod(n1,n2);
    }else if(strcmp(op, "SEN") == 0){
        result = sin(n2);
        // printf("-> Result sin(%f) = %f\n",n2,result);

    }else if(strcmp(op, "COS") == 0){
        result = cos(n2);
    }else if(strcmp(op, "TAN") == 0){
        result = tan(n2);
    }
    return result;
}

bool is_operation_or_function(char* string, int type){

    // Simple Math Operations
    if(type == 1){
        if(strcmp(string, "+") == 0 || strcmp(string, "-") == 0 || strcmp(string, "*") == 0 || strcmp(string, "/") == 0 || strcmp(string, "^") == 0 || strcmp(string, "%%") == 0){
            return true;
        }
    }else if(type == 2){ // Functions
        if(strcmp(string, "SEN") == 0 || strcmp(string, "COS") == 0 || strcmp(string, "TAN") == 0){
            return true;
        }
    }
    return false;
}

float calc_rpn (float x,char *expression,char* var){
    /* printf("xis = %f\n",x); */
    float num;
    Stack_node *n1,*n2, *stack = NULL; 

    expression = strtok(expression," ");
    while(expression){
        if(is_operation_or_function(expression,1)){
            n1 = stack_pop(&stack);
            n2 = stack_pop(&stack); 
            num = calc_values(n2->value,n1->value,expression);
            stack = stack_push(stack,num);
            free(n1);
            free(n2);

        }else if(is_operation_or_function(expression,2)){
            n1 = stack_pop(&stack);
            num = calc_values(0,n1->value,expression);
            stack = stack_push(stack,num);
            free(n1);

        }else if(strcmp(expression, var) == 0 ){
            num = x;
            stack = stack_push(stack,num);
        }else{
            num = atof(expression);
            stack = stack_push(stack,num);
        }
        expression = strtok(NULL," ");
    }
    
    return num;
}

void riemann_sum(float inf,float sup,char *expression){
    float delta_x = (sup - inf) / integral_steps;
    float result = 0.0;
    float x_i = 0.0; // median point
    
    size_t len =  strlen(expression);
    char *exp = (char*)malloc(len+1);

    strcpy(exp,expression);

    for(int i = 0 ; i < integral_steps; i++ ){
        x_i = inf + i * delta_x;
        
        result += calc_rpn(x_i,exp,"x");
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
        result += calc_rpn(i,exp,var);
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

    mtx.data = (double**) malloc(rows * sizeof(double*));
    for(int i = 0; i < rows; i++){
        mtx.data[i] = (double*)malloc(cols * sizeof(double));
    }

    return mtx;
}

// Function to free the memory allocated for a matrix
void free_matrix(Matrix* mtx) {
    for (int i = 0; i < mtx->rows; i++) {
        free(mtx->data[i]);
    }
    free(mtx->data);
    mtx->data = NULL;
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

// Function to print the matrix
void print_matrix(const Matrix* mtx) {
    
    for (int l = 0; l < mtx->rows; l++) {
        for (int m = 0; m < mtx->cols; m++) {
            printf("%12.8lf ", mtx->data[l][m]);
        }
        printf("\n");
    }
}


// ---------- Strings Operations

char* to_string(float value){
    // Determine the maximum size needed for the string
    int size = snprintf(NULL, 0, "%f", value);

    // Allocate memory for the string
    char* result = (char*)malloc(size + 1);  // +1 for the null terminator

    // Convert float to string
    snprintf(result, size + 1, "%f", value);

    return result;
}

char* concat_strings(const char* str1, const char* str2) {

    size_t size = strlen(str1) + strlen(str2) + 2;

    char* result = (char*)malloc(size);
    if (!result) {
        // Tratamento de erro se a alocação falhar
        exit(EXIT_FAILURE);
    }

    strcpy(result, str1);
    strcat(result, " ");// space between str1 and str2
    strcat(result, str2);

    return result;
}
