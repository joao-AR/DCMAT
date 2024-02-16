#include <stdio.h>
#include <string.h>
#include <math.h>


char plot [25][80]; // The plot matrix

//This Function Draw the plot axis and Erease the old plot according to the settings
void plot_config(char* draw_axis,char* erease_plot){
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

char* to_string(float value){
    // Determine the maximum size needed for the string
    int size = snprintf(NULL, 0, "%f", value);

    // Allocate memory for the string
    char* result = (char*)malloc(size + 1);  // +1 for the null terminator

    // Convert float to string
    snprintf(result, size + 1, "%f", value);

    return result;
}

void plot_manipulation(float h_view_lo,float h_view_hi,float v_view_lo,float v_view_hi,char* type_func,float exp_result){

    for(int i = 0; i < 25; i++){
        for(int j = 0; j < 80; j++){
            double x_val = h_view_lo + j * (h_view_hi - h_view_lo) / 79; // 79 = 80 - 1
            double y_val = v_view_lo + i * (v_view_hi - v_view_lo) / 24; // 24 = 24 - 1 

            // Adjust to the Three Rule of X 
            if(x_val < 0){  
                if(h_view_lo >= 0){
                    h_view_lo  = h_view_lo  * -1;
                    exp_result = exp_result * -1;
                }
            }

            // Three Rule of X and Y
            double proportional_x = exp_result * x_val / h_view_lo;
            /* double proportional_y = y_val * proportional_x / x_val; */
            // End Three Rule

            double calc_val;
            
            if(strcmp("sin",type_func) == 0){

                calc_val = sin(proportional_x )*-1;

            }else if(strcmp("cos",type_func) == 0){

                calc_val = cos(proportional_x)*-1;

            }else if(strcmp("tan",type_func ) == 0){

                calc_val = tan(proportional_x)*-1;
            }

            // Atribuir '*' onde o valor de y está próximo do seno de x
            if (fabs(y_val - calc_val) < 0.2) {
                plot[i][j] = '*';
            }
        }
    }

    plot_print();
}

