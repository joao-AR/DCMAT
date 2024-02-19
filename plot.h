#ifndef PLOT_H
#define PLOT_H
    void plot_config(char* draw_axis,char* erease_plot);
    void plot_print();
    void plot_func(char *expression);
    char* to_string(float value);
    float calc_values(float n1,float n2, char* op);
#endif