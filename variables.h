#ifndef VARIABLE_H 
#define VARIABLE_H

    #include <stdbool.h>
    typedef struct float_var{
        double value;
        }F_var;

    typedef struct matrix{
        double** data;
        int rows;
        int cols;
    } Matrix;

    typedef struct list{   
        char* var_name;
        F_var var;
        Matrix mtx;
        char var_type[4];
        struct list *next;
    }L_node;

    void* create_var(double value);
    void list_push_start(L_node **list, char* type_var,char* name, void* variable);
    void list_push_matrix_start(L_node **list,char* name, char* mtx_str, int rows, int cols);
    void list_print(L_node *node);
    void list_print_var(L_node *node, char* name_var);
    L_node* list_remove(L_node **node,char* name_var);
    L_node* list_seach(L_node* node, char* name_var);
    void list_print_debug(L_node *node);
    int is_in_list(L_node* node, char* name_var);

#endif