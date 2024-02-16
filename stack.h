#ifndef STACK_H
#define STACK_H
    
    typedef struct stack_node{   
        float value;
        struct stack_node *next;
    }Stack_node;
    
    Stack_node* stack_push(Stack_node *top, float value);
    Stack_node* stack_pop(Stack_node **top);
    void stack_print(Stack_node *top);
    void stack_pop_all(Stack_node **top);
    void stack_reverse_print(Stack_node *top);

#endif