#ifndef STACK_H
#define STACK_H
    
    typedef struct stack_node{   
        char* value;
        struct stack_node *next;
    }Stack_node;
    

    Stack_node* stack_push(Stack_node *top, char* value);
    Stack_node* stack_pop(Stack_node **top);
    void stack_print(Stack_node *top);

#endif