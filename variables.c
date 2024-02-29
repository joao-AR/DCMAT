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
    Matrix *new_mtx = malloc(sizeof(Matrix));

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
        
        Matrix *mtx_var = (Matrix*) variable;

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
void print_matrix_var(const Matrix* mtx) {
    
    for (int l = 0; l < mtx->rows; l++) {
        for (int m = 0; m < mtx->cols; m++) {
            printf("%12.8lf ", mtx->data[l][m]);
        }
        printf("\n");
    }
}

void list_print(L_node *node){
    printf("\n");
    while (node){
        if(strcmp(node->var_type,"var")==0){
            printf("%s - FLOAT\n",node->var_name);
        }else{
            printf("%s - MATRIX [%d][%d]\n",node->var_name,node->mtx.rows,node->mtx.cols);
            // print_matrix_var(&node->mtx);
        }

        node = node->next;
    }
    
}


void list_print_var(L_node *node, char* name_var){
    printf("\n");
    while (node){
        if(strcmp(node->var_name,name_var)==0){
            if(strcmp(node->var_type,"var")==0 ){
                printf("%s - FLOAT\n",node->var_name);
                return;
            }else{
                printf("%s - MATRIX [%d][%d]\n",node->var_name,node->mtx.rows,node->mtx.cols);
                // print_matrix_var(&node->mtx);
                return;
            }
        }
        node = node->next;
    }
    printf("Variable Not Found!\n");
    return;
}

L_node* list_remove(L_node** node, char* name_var) {
    L_node* remove = NULL;
    L_node* aux = NULL;
    
    if (node == NULL || *node == NULL) {
        return NULL;  // Check for NULL pointer or empty list
    }

    // Check if the first node is the one to be removed
    if (strcmp((*node)->var_name, name_var) == 0) {
        remove = *node;
        *node = remove->next;
    } else {
        // Traverse the list to find the node to remove
        aux = *node;
        while (aux->next && strcmp(aux->next->var_name, name_var) != 0) {
            aux = aux->next;
        }

        // If the node is found, remove it
        if (aux->next) {
            remove = aux->next;
            aux->next = remove->next;
        }
    }

    return remove;
}


L_node* list_seach(L_node* node, char* name_var) {
    
    if (node == NULL) {
        return NULL;  // Check for NULL pointer or empty list
    }

    while (node){
        if(strcmp(node->var_name, name_var) == 0){
            return node;
        }
        node = node->next;
    }
    
    return NULL;
}