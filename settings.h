#ifndef SETTINGS_H
#define SETTINGS_H

    void print_settings();

    void set_view(float lo, float hi,char type);
    void set_axis(char* value);
    void set_erease_plot(char* value);
    void set_connect_dots(char* value);
    void set_integral_steps(float value);
    void set_float_precision(float value);
    
    void reset_settings();
#endif