#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "variables.h"

void* create_var(char *name, double value){
    F_var *new_var = malloc(sizeof(F_var));

    new_var->value = value;
    new_var->var_name = (char*)malloc(sizeof(name));
    strcpy(new_var->var_name,name);
    return new_var;
}

void list_push_start(L_node **list, void* variable){
    
    F_var* var;

    if(list == NULL) return;

    L_node *node = (L_node*) malloc(sizeof(L_node));

    if(node == NULL) return ;

    var = (F_var*) variable;
    node->var.value = var->value;
    node->var.var_name = (char*)malloc(sizeof(var->var_name));
    strcpy(node->var.var_name,var->var_name);

    node->next = NULL;

    
    node->next = (*list);
    *list = node;
    return ;
}

void list_print(L_node *node){
    
    while (node){
        printf("%s = %lf\n",node->var.var_name,node->var.value);
        node = node->next;
    }
    
}
