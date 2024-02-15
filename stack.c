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
        while(top){
            printf("%s ",top->value);
            top = top->next;
        }
} 

void stack_reverse_print(Stack_node *top) {
    Stack_node *aux_stack = NULL;

    // Stack Values in a aux Stack
    while (top) {
        Stack_node *temp = (Stack_node *)malloc(sizeof(Stack_node));
        temp->value = top->value;
        temp->next = aux_stack;
        aux_stack = temp;
        top = top->next;
    }

    // Pop and print values aux Stack
    while (aux_stack) {
        printf("%s ", aux_stack->value);
        Stack_node *temp = aux_stack;
        aux_stack = aux_stack->next;
        free(temp);
    }

    printf("\n");
}

void stack_pop_all(Stack_node **top){
    while(*top != NULL){
        Stack_node *remove = *top;
        *top = remove->next;
        free(remove);
    }
}