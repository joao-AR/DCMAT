#include <stdlib.h>
#include <stdio.h>
#include <string.h>

double h_view_lo = -6.5;
double h_view_hi =  6.5;

double v_view_lo = -3.5;
double v_view_hi =  3.5;

int precision = 6;
int integral_steps = 1000;

char* draw_axis = "ON";
char* erease_plot = "ON";
char* connect_dots = "OFF";

void print_settings(){
    
    printf("h_view_lo: %.6f\n",h_view_lo);
    printf("h_view_hi: %.6f\n",h_view_hi);
    
    printf("v_view_lo: %.6f\n",v_view_lo);
    printf("v_view_hi: %.6f\n",v_view_hi);

    printf("float precision: %d\n",precision);
    printf("integral_steps: %d\n",integral_steps);

    printf("Draw Axis: %s\n",draw_axis);
    printf("Erease Plot: %s\n",erease_plot);
    printf("Connect Dots: %s\n",connect_dots);
}

void set_view(double lo, double hi,char type){

    if(lo > hi){
        printf("ERROR: %c_view_lo most be smaller than %c_view_hi\n",type,type);
        return;
    }

    if(type == 'h'){
        h_view_lo = lo;
        h_view_hi = hi;
    }else if (type == 'v'){
        v_view_lo = lo;
        v_view_hi = hi;
    }
}

void set_axis(char* value){
    draw_axis = value;
}

void set_erease_plot(char* value){
    erease_plot = value;
}

void set_connect_dots(char* value){
    connect_dots = value;
}

void set_integral_steps(double value){
    integral_steps = (int)value;
}

void set_float_precision(double value){
    if(value <= 8){
        precision = (int)value;
    }else{
        printf("ERROR: float precision must be from 0 to 8\n");
    }
}

void reset_settings(){
    h_view_lo = -6.5;
    h_view_hi =  6.5;

    v_view_lo = -3.5;
    v_view_hi =  3.5;

    precision = 6;
    integral_steps = 1000;

    draw_axis = "ON";
    erease_plot = "ON";
    connect_dots = "OFF";
}