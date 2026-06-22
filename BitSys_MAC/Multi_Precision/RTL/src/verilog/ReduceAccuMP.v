`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 02:19:09 AM
// Design Name: 
// Module Name: ReduceAccuMP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ReduceAccuMP
#(
    parameter IN_WIDTH      = 8,
    parameter IN_PRECI      = 2,
    parameter OUT_WIDTH     = 2*IN_WIDTH,
    parameter ACCU_LENGTH   = 16,
    parameter ACCU_WIDTH    = OUT_WIDTH + ACCU_LENGTH
)
(
    input   wire                                sys_clk,        // System Clock 
    input   wire                                sys_rst_n,      // System Reset
    
    input   wire                                accu_rst,       // Reset the accumulator
    
    input   wire    [(IN_PRECI-1):0]            precision,      // Input Precision
    input   wire                                is_signed,      // Setting signed/unsigned multiplication
    input   wire    [(ACCU_LENGTH-1):0]         accu_length,
    
    input   wire    [(OUT_WIDTH-1):0]           result,         // Input of MUL Result
    input   wire                                result_valid,   // Input of MUL Result Valid
    
    output  reg     [(ACCU_WIDTH-1):0]          accu_out,       // Output of accumulator Result
    output  reg                                 accu_out_valid  // Output of accumulator Result Valid
); 
 
reg    signed       [2:0]       sum_1bit            [((OUT_WIDTH/2)-1):0];
reg                             sum_1bit_valid;

integer sum_1bit_i;
always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                for (sum_1bit_i=0; sum_1bit_i<(OUT_WIDTH/2); sum_1bit_i=sum_1bit_i+1)
                    begin
                        sum_1bit[sum_1bit_i]  <= 0;
                    end
                sum_1bit_valid      <= 0;
            end
            else begin
                if (result_valid)
                    begin
                        sum_1bit[0]  <= ( (precision==0) && (is_signed)) ?  {{2'b0, result[0]} - {1'b0, result[1], 1'b0}} :
                                                                            {{2'b0, result[0]} + {1'b0, result[1], 1'b0}} ;
                                                            
                        sum_1bit[1]  <= ( ( (precision==0) || (precision==1) ) && (is_signed) ) ?   {{2'b0, result[2]} - {1'b0, result[3], 1'b0}} :
                                                                                                    {{2'b0, result[2]} + {1'b0, result[3], 1'b0}} ;
                                                                                                    
                        sum_1bit[2]  <= ( (precision==0) && (is_signed)) ?  {{2'b0, result[4]} - {1'b0, result[5], 1'b0}} :
                                                                            {{2'b0, result[4]} + {1'b0, result[5], 1'b0}} ;
                                                            
                        sum_1bit[3]  <= ( ( (precision==0) || (precision==1) || (precision==2) ) && (is_signed) ) ? {{2'b0, result[6]} - {1'b0, result[7], 1'b0}} :
                                                                                                                    {{2'b0, result[6]} + {1'b0, result[7], 1'b0}} ;
                                                                                                    
                        sum_1bit[4]  <= ( (precision==0) && (is_signed)) ?  {{2'b0, result[8]} - {1'b0, result[9], 1'b0}} :
                                                                            {{2'b0, result[8]} + {1'b0, result[9], 1'b0}} ;
                                                            
                        sum_1bit[5]  <= ( ( (precision==0) || (precision==1) ) && (is_signed) ) ?   {{2'b0, result[10]} - {1'b0, result[11], 1'b0}} :
                                                                                                    {{2'b0, result[10]} + {1'b0, result[11], 1'b0}} ;
                                                                                                    
                        sum_1bit[6]  <= ( (precision==0) && (is_signed)) ?  {{2'b0, result[12]} - {1'b0, result[13], 1'b0}} :
                                                                            {{2'b0, result[12]} + {1'b0, result[13], 1'b0}} ;
                                                            
                        sum_1bit[7]  <= ( is_signed ) ? {{2'b0, result[14]} - {1'b0, result[15], 1'b0}} :
                                                        {{2'b0, result[14]} + {1'b0, result[15], 1'b0}} ;
                                                        
                        sum_1bit_valid      <= 1;
                    end
                    else begin
                        for (sum_1bit_i=0; sum_1bit_i<(OUT_WIDTH/2); sum_1bit_i=sum_1bit_i+1)
                            begin
                                sum_1bit[sum_1bit_i]  <= sum_1bit[sum_1bit_i];
                            end
                        sum_1bit_valid      <= 0;
                    end
            end
    end
    
reg    signed       [4:0]       sum_2bit            [((OUT_WIDTH/4)-1):0];
reg                             sum_2bit_valid;

integer sum_2bit_i;
always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if ( (!sys_rst_n) | (accu_rst) )
            begin
                for (sum_2bit_i=0; sum_2bit_i<(OUT_WIDTH/4); sum_2bit_i=sum_2bit_i+1)
                    begin
                        sum_2bit[sum_2bit_i]  <= 0;
                    end
                sum_2bit_valid      <= 0;
            end
            else begin
                if (sum_1bit_valid)
                    begin
                        sum_2bit[0]  <= (precision==0) ?    {{{(2){sum_1bit[0][2]}}, sum_1bit[0]} + {{(2){sum_1bit[1][2]}}, sum_1bit[1]}} :
                                                            {{{(2){sum_1bit[0][2]}}, sum_1bit[0]} + {sum_1bit[1], 2'b0}} ;
                                                            
                        sum_2bit[1]  <= (precision==0) ?    {{{(2){sum_1bit[2][2]}}, sum_1bit[2]} + {{(2){sum_1bit[3][2]}}, sum_1bit[3]}} :
                                                            {{{(2){sum_1bit[2][2]}}, sum_1bit[2]} + {sum_1bit[3], 2'b0}} ;
                                                                                                    
                        sum_2bit[2]  <= (precision==0) ?    {{{(2){sum_1bit[4][2]}}, sum_1bit[4]} + {{(2){sum_1bit[5][2]}}, sum_1bit[5]}} :
                                                            {{{(2){sum_1bit[4][2]}}, sum_1bit[4]} + {sum_1bit[5], 2'b0}} ;
                                                            
                        sum_2bit[3]  <= (precision==0) ?    {{{(2){sum_1bit[6][2]}}, sum_1bit[6]} + {{(2){sum_1bit[7][2]}}, sum_1bit[7]}} :
                                                            {{{(2){sum_1bit[6][2]}}, sum_1bit[6]} + {sum_1bit[7], 2'b0}} ;
                                                        
                        sum_2bit_valid      <= 1;
                    end
                    else begin
                        for (sum_2bit_i=0; sum_2bit_i<(OUT_WIDTH/4); sum_2bit_i=sum_2bit_i+1)
                            begin
                                sum_2bit[sum_2bit_i]  <= sum_2bit[sum_2bit_i];
                            end
                        sum_2bit_valid      <= 0;
                    end
            end
    end
    
reg    signed       [8:0]       sum_3bit            [((OUT_WIDTH/8)-1):0];
reg                             sum_3bit_valid;

integer sum_3bit_i;
always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if ( (!sys_rst_n) | (accu_rst) )
            begin
                for (sum_3bit_i=0; sum_3bit_i<(OUT_WIDTH/8); sum_3bit_i=sum_3bit_i+1)
                    begin
                        sum_3bit[sum_3bit_i]  <= 0;
                    end
                sum_3bit_valid      <= 0;
            end
            else begin
                if (sum_2bit_valid)
                    begin
                        sum_3bit[0]  <= ( (precision==0) || (precision==1) ) ?  {{{(4){sum_2bit[0][4]}}, sum_2bit[0]} + {{(4){sum_2bit[1][4]}}, sum_2bit[1]}} :
                                                                                {{{(4){sum_2bit[0][4]}}, sum_2bit[0]} + {sum_2bit[1], 4'b0}} ;
                                                            
                        sum_3bit[1]  <= ( (precision==0) || (precision==1) ) ?  {{{(4){sum_2bit[2][4]}}, sum_2bit[2]} + {{(4){sum_2bit[3][4]}}, sum_2bit[3]}} :
                                                                                {{{(4){sum_2bit[2][4]}}, sum_2bit[2]} + {sum_2bit[3], 4'b0}} ;
                                                        
                        sum_3bit_valid  <= 1;
                    end
                    else begin
                        for (sum_3bit_i=0; sum_3bit_i<(OUT_WIDTH/8); sum_3bit_i=sum_3bit_i+1)
                            begin
                                sum_3bit[sum_3bit_i]  <= sum_3bit[sum_3bit_i];
                            end
                        sum_3bit_valid  <= 0;
                    end
            end
    end
    
reg    signed       [16:0]      sum_4bit            [((OUT_WIDTH/16)-1):0];
reg                             sum_4bit_valid;

integer sum_4bit_i;
always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if ( (!sys_rst_n) | (accu_rst) )
            begin
                for (sum_4bit_i=0; sum_4bit_i<(OUT_WIDTH/16); sum_4bit_i=sum_4bit_i+1)
                    begin
                        sum_4bit[sum_4bit_i]  <= 0;
                    end
                sum_4bit_valid      <= 0;
            end
            else begin
                if (sum_3bit_valid)
                    begin
                        sum_4bit[0]     <= ( (precision==0) || (precision==1) || (precision==2) ) ? {{{(8){sum_3bit[0][8]}}, sum_3bit[0]} + {{(8){sum_3bit[1][8]}}, sum_3bit[1]}} :
                                                                                                    {{{(8){sum_3bit[0][8]}}, sum_3bit[0]} + {sum_3bit[1], 8'b0}} ;
                                                        
                        sum_4bit_valid  <= 1;
                    end
                    else begin
                        for (sum_4bit_i=0; sum_4bit_i<(OUT_WIDTH/16); sum_4bit_i=sum_4bit_i+1)
                            begin
                                sum_4bit[sum_4bit_i]  <= sum_4bit[sum_4bit_i];
                            end
                        sum_4bit_valid  <= 0;
                    end
            end
    end
    
wire   signed       [(ACCU_WIDTH-1):0]      sum;
wire                                        sum_valid;

assign sum = {{((ACCU_WIDTH-17)){sum_4bit[0][16]}}, sum_4bit[0]};
assign sum_valid = sum_4bit_valid;

reg     [(ACCU_LENGTH-1):0]     sum_cnt;

reg    signed       [(ACCU_WIDTH-1):0]      accu_sum;

integer sum_i;
always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if ( (!sys_rst_n) | (accu_rst) )
            begin
                sum_cnt         <= 0;
                accu_out        <= 0;
                accu_sum        <= 0;
                accu_out_valid  <= 0;
            end
            else begin
                if (sum_valid)
                    begin                            
                        if ( (sum_cnt+1)<accu_length )
                            begin
                                accu_sum        <= accu_sum + sum;
                                sum_cnt         <= sum_cnt + 1;
                                accu_out        <= accu_sum;
                                accu_out_valid  <= 0;
                            end
                            else begin
                                accu_sum        <= 0;
                                sum_cnt         <= 0;
                                accu_out        <= accu_sum + sum;
                                accu_out_valid  <= 1;
                            end
                    end
                    else begin
                        accu_sum        <= accu_sum;
                        sum_cnt         <= sum_cnt;
                        accu_out        <= accu_sum;
                        accu_out_valid  <= 0;
                    end
            end
    end
    
endmodule
