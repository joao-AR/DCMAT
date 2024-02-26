#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "variables.h"


void* create_var(double value){
    F_var *new_var = malloc(sizeof(F_var));
    new_var->value = value;
    return new_var;
} 

void* create_matrix(Matrix mtx){
    M_var *new_mtx = malloc(sizeof(M_var));

    new_mtx->rows = mtx.rows;
    new_mtx->cols = mtx.cols;

    new_mtx->data = (double**)malloc(sizeof(mtx.data));

    new_mtx->data = mtx.data;
    return new_mtx;
}

void list_push_start(L_node **list, char* type_var,char* name, void* variable){
    
    if(list == NULL) return;

    L_node *node = (L_node*) malloc(sizeof(L_node));
    
    if(node == NULL) return ; 
    
    if(strcmp(type_var,"var")==0){
        F_var* var;
        var = (F_var*) variable;
        node->var.value = var->value;
        node->var_name = (char*)malloc(sizeof(name));
        strcpy(node->var_name,name);
        strcpy(node->var_type,"var");
    
    }else if(strcmp(type_var,"mtx")==0){
        
        M_var *mtx_var = (M_var*) variable;

        node->mtx.cols = mtx_var->cols;
        node->mtx.rows = mtx_var->rows;

        node->var_name = (char*)malloc(sizeof(name));
        strcpy(node->var_name,name);

        node->mtx.data = (double**)malloc(sizeof(mtx_var->data));
        node->mtx.data = mtx_var->data;
        strcpy(node->var_type,"mtx");
    }

    node->next = NULL;

    node->next = (*list);
    *list = node;
    return ;
}

// Function to print the matrix
void print_matrix_var(const M_var* mtx) {
    
    for (int l = 0; l < mtx->rows; l++) {
        for (int m = 0; m < mtx->cols; m++) {
            printf("%12.8lf ", mtx->data[l][m]);
        }
        printf("\n");
    }
}

void list_print(L_node *node){
    
    while (node){
        if(strcmp(node->var_type,"var")==0){
            printf("%s = %lf\n",node->var_name,node->var.value);
        }else{
            printf("%s [%d][%d]\n",node->var_name,node->mtx.rows,node->mtx.cols);
            // print_matrix_var(&node->mtx);
        }

        node = node->next;
    }
    
}

// void list_search(L_node *node, char* name_var){
    
//     while (node){
//         if(strcmp(node->var_type,"var")==0){
//             printf("%s = %lf\n",node->var_name,node->var.value);
//         }else{
//             printf("%s [%d][%d]\n",node->var_name,node->mtx.rows,node->mtx.cols);
//             // print_matrix_var(&node->mtx);
//         }

//         node = node->next;
//     }
    
// }
