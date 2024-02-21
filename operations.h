#ifndef OPERATIONS_H
#define OPERATIONS_H

    //Math functions
    void print_value(float num);
    void riemann_sum(float inf,float sup,char *expression);
    float calc_values(float n1,float n2, char* op);
    float calc_rpn (float x,char *expression);
    // void sum(char *var, int inf, int sup, char *expression);

    //Strings
    char* concat_strings(const char* str1, const char* str2);
    char* to_string(float value);

#endif