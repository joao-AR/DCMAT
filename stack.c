#include <stdio.h>
#include <stdlib.h>

#include "stack.h" 

Stack_node* stack_push(Stack_node *top, char* value){
    Stack_node *new_rpn = malloc(sizeof(Stack_node));

    if(new_rpn){
        new_rpn->value = value;
        new_rpn->next = top;
        return new_rpn;
    }else{
        printf("Stack Error alocation\n");
    }
    return NULL;
}

Stack_node* stack_pop(Stack_node **top){
    if(*top != NULL){
        Stack_node *remove = *top;
        *top = remove->next;
        return remove;
    }else{
        printf("Pilha vazia\n");
    }
    return NULL;
}


void stack_print(Stack_node *top){
    printf("\nSTACK\n");
    while(top){
        printf("[%s]\n",top->value);
        top = top->next;
    }
} 