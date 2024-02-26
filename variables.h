#ifndef VARIABLE_H 
#define VARIABLE_H
    #include "operations.h"

    typedef struct float_var{
        double value;
        }F_var;

    typedef struct matrix_var{
        double** data;
        int rows;
        int cols;
    }M_var;

    typedef struct list{   
        char* var_name;
        F_var var;
        M_var mtx;
        char var_type[4];
        struct list *prev;
        struct list *next;
    }L_node;

    void* create_var(double value);
    void* create_matrix(Matrix mtx);
    void list_push_start(L_node **list, char* type_var,char* name, void* variable);
    void list_print(L_node *node);

#endif