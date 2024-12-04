#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "stack.h" 
#include "operations.h"

void stack_push(Stack_node **stack, double value){
    if( stack == NULL) return;
        
    Stack_node *new_rpn = calloc(1, sizeof(Stack_node));
    if( new_rpn == NULL) return;
    
    new_rpn->var.value = value;
    strcpy(new_rpn->var_type,"var");

    new_rpn->next = (*stack);
    *stack = new_rpn;
}

void stack_push_matrix(Stack_node** stack, Matrix* mtx) {
    if (stack == NULL || mtx == NULL) return;

    Stack_node* new_mtx = malloc(sizeof(Stack_node));
    if (new_mtx == NULL) {
        fprintf(stderr, "Failed to allocate memory for stack node.\n");
        return;
    }

    // Inicializa os valores do nó
    strcpy(new_mtx->var_type, "mtx");
    new_mtx->mtx.rows = mtx->rows;
    new_mtx->mtx.cols = mtx->cols;

    // Aloca memória para as linhas da matriz
    // new_mtx->mtx.data = (double**)malloc(mtx->rows * sizeof(double*));
    new_mtx->mtx.data = malloc(mtx->rows * sizeof(double*));

    if (new_mtx->mtx.data == NULL) {
        free(new_mtx);
        fprintf(stderr, "Failed to allocate memory for matrix rows.\n");
        return;
    }

    // Aloca as colunas e copia os dados
    for (int i = 0; i < mtx->rows; i++) {
        // new_mtx->mtx.data[i] = (double*)malloc(mtx->cols * sizeof(double));
        new_mtx->mtx.data[i] = malloc(mtx->cols * sizeof(double));

        if (new_mtx->mtx.data[i] == NULL) {
            // Libera todas as linhas previamente alocadas em caso de falha
            for (int j = 0; j < i; j++) {
                free(new_mtx->mtx.data[j]);
            }
            free(new_mtx->mtx.data);
            free(new_mtx);
            fprintf(stderr, "Failed to allocate memory for matrix columns.\n");
            return;
        }

        // Copia os dados da matriz original
        // for (int j = 0; j < mtx->cols; j++) {
        //     new_mtx->mtx.data[i][j] = mtx->data[i][j];
        // }

        memcpy(new_mtx->mtx.data[i], mtx->data[i], mtx->cols * sizeof(double));

    }

    // Insere o novo nó no topo da pilha
    new_mtx->next = *stack;
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

void free_matrix_stack(Matrix* mtx) {
    if (mtx == NULL || mtx->data == NULL) return;

    // Libera as linhas da matriz
    for (int i = 0; i < mtx->rows; i++) {
        free(mtx->data[i]);
    }

    // Libera o array de ponteiros
    free(mtx->data);
    mtx->data = NULL;
    mtx->rows = 0;
    mtx->cols = 0;
}


void stack_pop_all(Stack_node** top) {
    if (top == NULL || *top == NULL) return;

    while (*top != NULL) {
        Stack_node* remove = *top;
        *top = remove->next;

        // Verifica se o tipo do nó é "mtx" e libera a memória associada
        if (strcmp(remove->var_type, "mtx") == 0) {
            free_matrix_stack(&remove->mtx);
        }
        free(remove);
    }
}