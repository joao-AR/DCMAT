#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "variables.h"
#include "operations.h"

void* create_var(double value){
    F_var *new_var = malloc(sizeof(F_var));
    new_var->value = value;
    return new_var;
} 

void list_push_start(L_node **list, char* type_var,char* name, void* variable){
    
    if(list == NULL) return;

    L_node *node = (L_node*) malloc(sizeof(L_node));
    
    if(node == NULL) return ; 
    
    F_var* var;
    var = (F_var*) variable;
    node->var.value = var->value;
    node->var_name = (char*)malloc(sizeof(name));
    strcpy(node->var_name,name);
    strcpy(node->var_type,"var");

    node->next = (*list);
    *list = node;
    return;
}

void list_push_matrix_start(L_node **list,char* name, char* mtx_str, int rows, int cols){
    
    if(list == NULL) return;

    L_node *node = (L_node*) malloc(sizeof(L_node));
    
    if(node == NULL) return ; 
    
    node->mtx.cols = cols;
    node->mtx.rows = rows;

    node->var_name = (char*)malloc(sizeof(name));
    strcpy(node->var_name,name);

    strcpy(node->var_type,"mtx");

    //Initialize matrix

    node->mtx.data = (double**) malloc(rows * sizeof(double*));
    for(int i = 0; i < rows; i++){
        node->mtx.data[i] = (double*)malloc(cols * sizeof(double));
    }

    // Populate Matrix
    int i = 0;
    int j = 0;

    char* token = strtok(mtx_str, " ");

    while (token) {
        if (strcmp(token, "|") == 0) {
            j++;
            i = 0;
        } else {
            if (j < node->mtx.rows && i < node->mtx.cols) {
                node->mtx.data[j][i] = strtod(token, NULL);
                i++;
            }
        }
        token = strtok(NULL, " ");
    }
    
    node->next = (*list);
    *list = node;
    return;
}

void list_print_debug(L_node *node){
    printf("DEBUG LISTA PRINT\n");
    while (node){
        if(strcmp(node->var_type,"var")==0){
            printf("%s - FLOAT\n",node->var_name);
        }else{
            printf("%s - MATRIX [%d][%d]\n",node->var_name,node->mtx.rows,node->mtx.cols);
        
            for (int i = 0; i < node->mtx.rows; i++)
            {
                for (int j = 0; j < node->mtx.cols; j++)
                {
                    printf("%lf ",node->mtx.data[i][j]);
                }
                printf("\n");
            }
            
        }
    printf("FIM DEBUG LISTA PRINT\n");
        node = node->next;
    }
    
}

void list_print(L_node *node){
    printf("\n");
    while (node){
        if(strcmp(node->var_type,"var")==0){
            printf("%s - FLOAT\n",node->var_name);
        }else{
            printf("%s - MATRIX [%d][%d]\n",node->var_name,node->mtx.rows,node->mtx.cols);
        }

        node = node->next;
    }
    
}

void list_print_var(L_node *node, char* name_var){
    printf("\n");
    while (node){
        if(strcmp(node->var_name,name_var)==0){
            if(strcmp(node->var_type,"var")==0 ){
                printf("%s = %lf\n",node->var_name,node->var.value);
            }else{
                print_matrix(&node->mtx);
            }
            return;
        }
        node = node->next;
    }
    printf("Undefined symbol\n");
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

int is_in_list(L_node* node, char* name_var){
    // 0 = False 1 = True
    if (node == NULL) {
        return 0; 
    }

    while (node){
        if(strcmp(node->var_name, name_var) == 0){
            return 1;
        }
        node = node->next;
    }
    return 0;
}