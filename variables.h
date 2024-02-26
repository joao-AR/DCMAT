#ifndef VARIABLE_H 
#define VARIABLE_H
    typedef struct float_var{
        char* var_name;
        double value;
        }F_var;

    typedef struct matrix_var{
        char* var_name;
        double** data;
        int rows;
        int cols;
    }M_var;

    typedef struct list{   
        F_var var;
        // M_var mtx;
        char var_type[4];
        struct list *prev;
        struct list *next;
    }L_node;

    void* create_var(char *name, double value);
    void list_push_start(L_node **list, void* variable);
    void list_print(L_node *node);

#endif