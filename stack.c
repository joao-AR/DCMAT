#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "stack.h" 
#include "operations.h"

void stack_push(Stack_node **stack, double value){
    if( stack == NULL) return;
    Stack_node *new_rpn = malloc(sizeof(Stack_node));
    if( new_rpn == NULL) return;
    
    new_rpn->var.value = value;
    strcpy(new_rpn->var_type,"var");

    new_rpn->next = (*stack);
    *stack = new_rpn;
}

void stack_push_matrix(Stack_node **stack, Matrix* mtx){
    if( stack == NULL) return;
    Stack_node *new_mtx = malloc(sizeof(Stack_node));
    if( new_mtx == NULL) return;
    
    strcpy(new_mtx->var_type,"mtx");
    
    new_mtx->mtx.data = (double**) malloc(mtx->rows * sizeof(double*));
    
    new_mtx->mtx.cols = mtx->cols;
    new_mtx->mtx.rows = mtx->rows;

    for(int i = 0; i < mtx->rows ; i++){
        new_mtx->mtx.data[i] = (double*)malloc(mtx->cols * sizeof(double));
    }

    //Copy mtx to new_mtx
    for (int i = 0; i < mtx->rows; i++){
        for (int j = 0; j < mtx->cols; j++){
            new_mtx->mtx.data[i][j] = mtx->data[i][j];
        }
    }

    new_mtx->next = (*stack);
    *stack = new_mtx;
}

Stack_node* stack_pop(Stack_node **top){
    if(*top != NULL){
        Stack_node *remove = *top;
        *top = remove->next;
        return remove;
    }
    return NULL;
}


void stack_print(Stack_node *stack){
        printf("STACK\n");
        while(stack){
            if(strcmp(stack->var_type,"var")==0) printf("float val: %lf\n",stack->var.value); 
            if(strcmp(stack->var_type,"mtx") == 0) print_matrix(&stack->mtx);
            stack = stack->next;
        }
        printf("END STACK\n");
} 


void stack_pop_all(Stack_node **top){
    while(*top != NULL){
        Stack_node *remove = *top;
        *top = remove->next;
        free(remove);
    }
}