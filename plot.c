#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "stack.h"
#include "operations.h"
double pi = 3.14159265;
double e = 2.71828182;
char plot [25][80]; // The plot matrix

//From Settings
    extern double h_view_lo;
    extern double h_view_hi; 
    extern double v_view_lo;
    extern double v_view_hi;
    extern int precision;
    extern int integral_steps;
    extern char* draw_axis;
    extern char* erease_plot;
    extern char* connect_dots;
//End From Settigns 

//This Function Draw the plot axis and Erease the old plot according to the settings
void plot_config(){
    // True = 0
    int axis = strcmp(draw_axis,"ON"); 
    int erese = strcmp(erease_plot,"ON"); 

    // Draw plot axis
    for(int i = 0; i < 25; i++){
        for(int j = 0; j < 80; j++){
            
            if(axis == 0){ // ON

                if(i == 12){
                    plot[i][j] = '-';
                }else if(erese == 0 || erese != 0 && plot[i][j] != '*' ){ 
                    plot[i][j] = ' ';
                }

                if(j == 40){plot[i][j] = '|';}
                
            }else{
                if(erese == 0 || erese != 0 && plot[i][j] != '*' ){
                    plot[i][j] = ' ';
                } 
            }
        }
    }
}

void plot_print(){

    printf("\n\n");
    for(int i = 0; i < 25; i++){
        for(int j = 0; j < 80; j++){
            printf("%c",plot[i][j]);
        }
        printf("\n");
    }  
    printf("\n\n");
}

void plot_func(char* expression){
    size_t len = strlen(expression);
    char *exp = (char*)malloc(len + 1);

    if (exp == NULL) {
        fprintf(stderr, "Erro ao alocar memória.\n");
        return;
    }

    strcpy(exp, expression);
    plot_config();
    for (int i = 0; i < 25; i++) {
        for (int j = 0; j < 80; j++) {
            double x_val = h_view_lo + j * (h_view_hi - h_view_lo) / 79; // 79 = 80 - 1
            double calc_val = calc_rpn_plot(x_val, exp, "x") * -1;
            double y_val = v_view_lo + i * (v_view_hi - v_view_lo) / 24; // 24 = 25 - 1 

            if (fabs(y_val - calc_val) < 0.2) {
                plot[i][j] = '*';
            }
        }
    }
    free(exp);
    plot_print();
}

