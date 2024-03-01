#ifndef STACK_H
#define STACK_H
    #include "variables.h"

    typedef struct stack_node{   
        F_var var;
        Matrix mtx;
        char var_type[4];
        struct stack_node *next;
    }Stack_node;
    
    void stack_push(Stack_node **stack, double value);
    void stack_push_matrix(Stack_node **stack, Matrix* mtx);
    Stack_node* stack_pop(Stack_node **top);
    void stack_print(Stack_node *top);
    void stack_pop_all(Stack_node **top);

#endif