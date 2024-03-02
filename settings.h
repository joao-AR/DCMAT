#ifndef SETTINGS_H
#define SETTINGS_H

    void print_settings();

    void set_view(double lo, double hi,char type);
    void set_axis(char* value);
    void set_erease_plot(char* value);
    void set_connect_dots(char* value);
    void set_integral_steps(double value);
    void set_float_precision(double value);
    
    void reset_settings();
#endif