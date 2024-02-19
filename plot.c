#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "stack.h"

float pi = 3.14159265;
float e = 2.71828182;
char plot [25][80]; // The plot matrix

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

//This Function Draw the plot axis and Erease the old plot according to the settings
void plot_config(){
    // True = 0
    int axis = strcmp(draw_axis,"ON"); 
    int erese = strcmp(erease_plot,"ON"); 

    // Draw plot axis
    for(int i = 0; i < 25; i++){
        for(int j = 0; j < 80; j++){
            
            if(axis == 0){ // ON

                if(i == 12){
                    plot[i][j] = '-';
                }else if(erese == 0 || erese != 0 && plot[i][j] != '*' ){ 
                    plot[i][j] = ' ';
                }

                if(j == 40){plot[i][j] = '|';}
                
            }else{
                if(erese == 0 || erese != 0 && plot[i][j] != '*' ){
                    plot[i][j] = ' ';
                } 
            }
        }
    }
}

void plot_print(){

    printf("\n\n");
    for(int i = 0; i < 25; i++){
        for(int j = 0; j < 80; j++){
            printf("%c",plot[i][j]);
        }
        printf("\n");
    }  
    printf("\n\n");
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
        result = sin(n2 );
    }else if(strcmp(op, "COS") == 0){
        result = cos(n2);
    }else if(strcmp(op, "TAN") == 0){
        result = tan(n2);
    }
    return result;
}

float calc_rpn (char *expression,int j){

    float num;
    Stack_node *n1,*n2, *stack = NULL; 

    expression = strtok(expression," ");
    while(expression){
        if(strcmp(expression, "+") == 0 || strcmp(expression, "-") == 0 
        || strcmp(expression, "*") == 0 || strcmp(expression, "/") == 0
        || strcmp(expression, "^") == 0 || strcmp(expression, "%%") == 0
        ){
            n1 = stack_pop(&stack);
            n2 = stack_pop(&stack); 
            num = calc_values(n2->value,n1->value,expression);
            stack = stack_push(stack,num);
            free(n1);
            free(n2);
        }else if(strcmp(expression, "SEN") == 0 || strcmp(expression, "COS") == 0 || strcmp(expression, "TAN") == 0){
            n1 = stack_pop(&stack);
            num = calc_values(0,n1->value,expression);
            stack = stack_push(stack,num);
            free(n1);
        }else if(strcmp(expression, "x") == 0 ){
            num = h_view_lo + j * (h_view_hi - h_view_lo) / 79; // 79 = 80 - 1
            stack = stack_push(stack,num);
        }else{
            num = atof(expression);
            stack = stack_push(stack,num);
        }
        expression = strtok(NULL," ");
    }
    
    return num;
}

void plot_func(char* expression){
    size_t len =  strlen(expression);
    char *exp = (char*)malloc(len+1);

    // printf("expression : [%s]\n",expression);
    strcpy(exp,expression);
    plot_config();
    for(int i = 0; i < 25; i++){
        for(int j = 0; j < 80; j++){
            
            // printf("expression : [%s]\n",exp);
            float x_val = calc_rpn(exp,j) * -1;
            float y_val = v_view_lo + i * (v_view_hi - v_view_lo) / 24; // 24 = 24 - 1 
            strcpy(exp,expression);

            if (fabs(y_val - x_val) < 0.2) {
                plot[i][j] = '*';
            }
        }
    }
    free(exp);
    plot_print();
}

