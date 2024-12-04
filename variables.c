#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "variables.h"
#include "operations.h"

F_var create_var(double value) {
    F_var var;
    var.value = value;
    return var;
}

void list_push_start(L_node **list, char* type_var, char* name, F_var variable) {
    if(list == NULL) return;

    L_node *node = (L_node*) malloc(sizeof(L_node));
    
    if(node == NULL) return ; 
    
    node->var = variable;

    node->var_name = (char*)malloc(strlen(name) + 1);
    if (node->var_name == NULL) {
        free(node); // Libera o nó se falhar a alocação
        return;
    }
    strcpy(node->var_name, name); // Copia a string 'name' para 'node->var_name'
    strcpy(node->var_type,"var");

    node->next = (*list);
    *list = node;
    return;
}

void list_push_matrix_start(L_node **list, char* name, char* mtx_str, int rows, int cols) {
    if (list == NULL) return;

    L_node *node = (L_node*)malloc(sizeof(L_node));
    if (node == NULL) return;

    node->mtx.cols = cols;
    node->mtx.rows = rows;

    // Alocar e copiar o nome
    node->var_name = (char*)malloc(strlen(name) + 1); // +1 para o terminador '\0'
    if (node->var_name == NULL) {
        free(node);
        return;
    }
    strcpy(node->var_name, name);

    strcpy(node->var_type, "mtx");

    // Inicializar a matriz
    node->mtx.data = (double**)malloc(rows * sizeof(double*));
    if (node->mtx.data == NULL) {
        free(node->var_name);
        free(node);
        return;
    }

    for (int i = 0; i < rows; i++) {
        node->mtx.data[i] = (double*)malloc(cols * sizeof(double));
        if (node->mtx.data[i] == NULL) {
            // Libera linhas previamente alocadas em caso de falha
            for (int k = 0; k < i; k++) {
                free(node->mtx.data[k]);
            }
            free(node->mtx.data);
            free(node->var_name);
            free(node);
            return;
        }

        // Inicializa todos os valores da linha com 0.0
        for (int j = 0; j < cols; j++) {
            node->mtx.data[i][j] = 0.0;
        }
    }

    // Preencher a matriz com os valores de mtx_str
    int i = 0, j = 0;
    char* token = strtok(mtx_str, " ");
    while (token) {
        if (strcmp(token, "|") == 0) {
            j++; // Avança para a próxima linha
            i = 0; // Reinicia a contagem de colunas
        } else {
            if (j < node->mtx.rows && i < node->mtx.cols) {
                node->mtx.data[j][i] = strtod(token, NULL);
                i++;
            }
        }
        token = strtok(NULL, " ");
    }

    // Inserir o nó na lista
    node->next = (*list);
    *list = node;
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


L_node* list_search(L_node* node, char* name_var) {
    
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

void free_list(L_node **list) {
    if (list == NULL || *list == NULL) {
        return; // Lista vazia ou ponteiro inválido
    }

    L_node *current = *list;
    L_node *next;

    while (current != NULL) {
        next = current->next; // Salva o próximo nó

        // Libera a memória associada ao nome da variável
        if (current->var_name != NULL) {
            free(current->var_name);
        }

        // Libera a memória associada à matriz, se for uma matriz
        if (strcmp(current->var_type, "mtx") == 0) {
            if (current->mtx.data != NULL) {
                for (int i = 0; i < current->mtx.rows; i++) {
                    if (current->mtx.data[i] != NULL) {
                        free(current->mtx.data[i]); // Libera cada linha da matriz
                    }
                }
                free(current->mtx.data); // Libera o array de ponteiros
            }
        }

        // Libera o nó atual
        free(current);
        current = next;
    }

    *list = NULL; // Garante que o ponteiro da lista seja nulo após liberar
}
