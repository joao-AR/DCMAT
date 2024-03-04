#ifndef OPERATIONS_H
#define OPERATIONS_H

    #include "variables.h"
    //Math functions
    void print_value(double num);
    void riemann_sum(double inf,double sup,char *expression);
    double calc_values(double n1,double n2, char* op);
    void calc_rpn_std(char *expression, L_node *list); // Standard implementation for calc RPN

    double calc_rpn_plot (double x,char *expression,char* var);
    void sum(char *var, int inf, int sup, char *expression);

    // Matrix
        Matrix new_matrix( int rows, int cols);
        void free_matrix(Matrix* mtx);
        void populate_matrix(Matrix* mtx, char* mtx_str);
        void print_matrix(const Matrix* mtx);
        double solve_determinant(Matrix mtx, int n);
        void submatrix(Matrix mtx, Matrix *temp ,int p, int q, int n);
        bool is_mult_float_matrix(char* op, int type, int last_type);
        void solve_linear_system(Matrix *mtx);
    //Strings
    char* concat_strings(const char* str1, const char* str2);
    char* to_string(double value);

#endif