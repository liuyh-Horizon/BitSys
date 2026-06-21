`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 05:48:08 PM
// Design Name: 
// Module Name: BitwiseSA_LUT
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


module BitwiseSA_RTL
#(
    parameter IN_WIDTH      = 8,
    parameter IN_PRECI      = 2,
    parameter REGION_NUM    = 4,
    parameter OUT_WIDTH     = 2*IN_WIDTH
)
(
    input   wire                                sys_clk,        // System Clock 
    
    input   wire    [(IN_PRECI-1):0]            precision,      // Input Precision
    
    input   wire    [(IN_WIDTH-1):0]            in_0,           // Input 0
    input   wire    [(IN_WIDTH-1):0]            in_1,           // Input 1
    input   wire    [(IN_WIDTH-1):0]            in_0_valid,     
    input   wire    [(IN_WIDTH-1):0]            in_1_valid,     // Valid Signal control the working statement
                                                                // If valid is 1, systolic working
                                                                // If valid is 0, systolic holds the current statement and pauses processing.

    output  wire    [(IN_WIDTH*IN_WIDTH-1):0]   systolic_out,
    output  wire    [(IN_WIDTH*IN_WIDTH-1):0]   systolic_out_valid
);

wire    mul_sys_in_0            [(IN_WIDTH-1):0][(IN_WIDTH-1):0];
wire    mul_sys_in_1            [(IN_WIDTH-1):0][(IN_WIDTH-1):0];

wire    mul_sys_in_0_valid      [(IN_WIDTH-1):0][(IN_WIDTH-1):0];
wire    mul_sys_in_1_valid      [(IN_WIDTH-1):0][(IN_WIDTH-1):0];

wire    mul_sys_out_0           [(IN_WIDTH-1):0][(IN_WIDTH-1):0];
wire    mul_sys_out_1           [(IN_WIDTH-1):0][(IN_WIDTH-1):0];

wire    mul_sys_out_0_valid     [(IN_WIDTH-1):0][(IN_WIDTH-1):0];
wire    mul_sys_out_1_valid     [(IN_WIDTH-1):0][(IN_WIDTH-1):0];

wire    and_out                 [(IN_WIDTH-1):0][(IN_WIDTH-1):0];
wire    and_out_valid           [(IN_WIDTH-1):0][(IN_WIDTH-1):0];

genvar out_i, out_j;
generate
    for (out_i=0; out_i<IN_WIDTH;  out_i=out_i+1)
        begin
            for (out_j=0; out_j<IN_WIDTH;  out_j=out_j+1)
                begin
                    assign systolic_out[out_i*IN_WIDTH+out_j]       = and_out[out_i][out_j];
                    assign systolic_out_valid[out_i*IN_WIDTH+out_j] = and_out_valid[out_i][out_j];
                end
        end
endgenerate

assign mul_sys_in_0[0][0] = in_0[0];
assign mul_sys_in_1[0][0] = in_1[0];

assign mul_sys_in_0_valid[0][0] = in_0_valid[0];
assign mul_sys_in_1_valid[0][0] = in_1_valid[0];

genvar input_i;
generate
    for (input_i=1; input_i<IN_WIDTH; input_i=input_i+1)
        begin
            assign mul_sys_in_0[0][input_i] = in_0[input_i];
            assign mul_sys_in_1[0][input_i] = mul_sys_out_1[0][input_i-1];
            
            assign mul_sys_in_0[input_i][0] = mul_sys_out_0[input_i-1][0];
            assign mul_sys_in_1[input_i][0] = in_1[input_i];
            
            assign mul_sys_in_0_valid[0][input_i] = in_0_valid[input_i];
            assign mul_sys_in_1_valid[0][input_i] = mul_sys_out_1_valid[0][input_i-1];
            
            assign mul_sys_in_0_valid[input_i][0] = mul_sys_out_0_valid[input_i-1][0];
            assign mul_sys_in_1_valid[input_i][0] = in_1_valid[input_i];
        end
endgenerate

genvar array_i, array_j;
generate
    for (array_i=1; array_i<IN_WIDTH; array_i=array_i+1)
        begin
            for (array_j=1; array_j<IN_WIDTH; array_j=array_j+1)
                begin
                    assign mul_sys_in_0[array_i][array_j] = mul_sys_out_0[array_i-1][array_j];
                    assign mul_sys_in_1[array_i][array_j] = mul_sys_out_1[array_i][array_j-1];
                    
                    assign mul_sys_in_0_valid[array_i][array_j] = mul_sys_out_0_valid[array_i-1][array_j];
                    assign mul_sys_in_1_valid[array_i][array_j] = mul_sys_out_1_valid[array_i][array_j-1];
                end
        end
endgenerate

wire    [(REGION_NUM-1):0]   patterns;

assign patterns = (precision==0) ? 4'b0000 :
                  (precision==1) ? 4'b0011 :
                  (precision==2) ? 4'b0111 :
                                   4'b1111 ;

genvar region_0_i, region_0_j;
genvar region_1_i, region_1_j;
genvar region_2_i, region_2_j;
genvar region_3_i;

generate
    for (region_0_i=0; region_0_i<(IN_WIDTH/2); region_0_i=region_0_i+1)
        begin
            for (region_0_j=0; region_0_j<(IN_WIDTH/2); region_0_j=region_0_j+1)
                begin
                    BitwisePE_RTL 
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_0_0
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_0_i+(IN_WIDTH/2)][region_0_j]),
                        .in_1(mul_sys_in_1[region_0_i+(IN_WIDTH/2)][region_0_j]),
                        .in_0_valid(mul_sys_in_0_valid[region_0_i+(IN_WIDTH/2)][region_0_j]),
                        .in_1_valid(mul_sys_in_1_valid[region_0_i+(IN_WIDTH/2)][region_0_j]),
                
                        .pattern(patterns[3]),
                        
                        .result(and_out[region_0_i+(IN_WIDTH/2)][region_0_j]),
                        .result_valid(and_out_valid[region_0_i+(IN_WIDTH/2)][region_0_j]),
                        
                        .in_0_out(mul_sys_out_0[region_0_i+(IN_WIDTH/2)][region_0_j]),
                        .in_1_out(mul_sys_out_1[region_0_i+(IN_WIDTH/2)][region_0_j]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_0_i+(IN_WIDTH/2)][region_0_j]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_0_i+(IN_WIDTH/2)][region_0_j])
                    );
                    
                    BitwisePE_RTL
                    #( 
                        .REGION(0) 
                    )  
                    BitwisePE_RTL_region_0_1
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_0_i][region_0_j+(IN_WIDTH/2)]),
                        .in_1(mul_sys_in_1[region_0_i][region_0_j+(IN_WIDTH/2)]),
                        .in_0_valid(mul_sys_in_0_valid[region_0_i][region_0_j+(IN_WIDTH/2)]),
                        .in_1_valid(mul_sys_in_1_valid[region_0_i][region_0_j+(IN_WIDTH/2)]),
                
                        .pattern(patterns[3]),
                        
                        .result(and_out[region_0_i][region_0_j+(IN_WIDTH/2)]),
                        .result_valid(and_out_valid[region_0_i][region_0_j+(IN_WIDTH/2)]),
                        
                        .in_0_out(mul_sys_out_0[region_0_i][region_0_j+(IN_WIDTH/2)]),
                        .in_1_out(mul_sys_out_1[region_0_i][region_0_j+(IN_WIDTH/2)]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_0_i][region_0_j+(IN_WIDTH/2)]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_0_i][region_0_j+(IN_WIDTH/2)])
                    );
                end
        end
            
    for (region_1_i=0; region_1_i<(IN_WIDTH/4); region_1_i=region_1_i+1)
        begin
            for (region_1_j=0; region_1_j<(IN_WIDTH/4); region_1_j=region_1_j+1)
                begin
                    BitwisePE_RTL 
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_1_0_0
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_1_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_1_j+(IN_WIDTH/2)]),
                        .in_1(mul_sys_in_1[region_1_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_1_j+(IN_WIDTH/2)]),
                        .in_0_valid(mul_sys_in_0_valid[region_1_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_1_j+(IN_WIDTH/2)]),
                        .in_1_valid(mul_sys_in_1_valid[region_1_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_1_j+(IN_WIDTH/2)]),
                
                        .pattern(patterns[2]),
                        
                        .result(and_out[region_1_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_1_j+(IN_WIDTH/2)]),
                        .result_valid(and_out_valid[region_1_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_1_j+(IN_WIDTH/2)]),
                        
                        .in_0_out(mul_sys_out_0[region_1_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_1_j+(IN_WIDTH/2)]),
                        .in_1_out(mul_sys_out_1[region_1_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_1_j+(IN_WIDTH/2)]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_1_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_1_j+(IN_WIDTH/2)]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_1_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_1_j+(IN_WIDTH/2)])
                    );
                    
                    BitwisePE_RTL
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_1_0_1
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_1_i+(IN_WIDTH/2)][region_1_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .in_1(mul_sys_in_1[region_1_i+(IN_WIDTH/2)][region_1_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .in_0_valid(mul_sys_in_0_valid[region_1_i+(IN_WIDTH/2)][region_1_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .in_1_valid(mul_sys_in_1_valid[region_1_i+(IN_WIDTH/2)][region_1_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                
                        .pattern(patterns[2]),
                        
                        .result(and_out[region_1_i+(IN_WIDTH/2)][region_1_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .result_valid(and_out_valid[region_1_i+(IN_WIDTH/2)][region_1_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        
                        .in_0_out(mul_sys_out_0[region_1_i+(IN_WIDTH/2)][region_1_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .in_1_out(mul_sys_out_1[region_1_i+(IN_WIDTH/2)][region_1_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_1_i+(IN_WIDTH/2)][region_1_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_1_i+(IN_WIDTH/2)][region_1_j+(IN_WIDTH/2)+(IN_WIDTH/4)])
                    );
                    
                    BitwisePE_RTL
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_1_1_0
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_1_i+(IN_WIDTH/4)][region_1_j]),
                        .in_1(mul_sys_in_1[region_1_i+(IN_WIDTH/4)][region_1_j]),
                        .in_0_valid(mul_sys_in_0_valid[region_1_i+(IN_WIDTH/4)][region_1_j]),
                        .in_1_valid(mul_sys_in_1_valid[region_1_i+(IN_WIDTH/4)][region_1_j]),
                
                        .pattern(patterns[2]),
                        
                        .result(and_out[region_1_i+(IN_WIDTH/4)][region_1_j]),
                        .result_valid(and_out_valid[region_1_i+(IN_WIDTH/4)][region_1_j]),
                        
                        .in_0_out(mul_sys_out_0[region_1_i+(IN_WIDTH/4)][region_1_j]),
                        .in_1_out(mul_sys_out_1[region_1_i+(IN_WIDTH/4)][region_1_j]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_1_i+(IN_WIDTH/4)][region_1_j]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_1_i+(IN_WIDTH/4)][region_1_j])
                    );
                    
                    BitwisePE_RTL
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_1_1_1
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_1_i][region_1_j+(IN_WIDTH/4)]),
                        .in_1(mul_sys_in_1[region_1_i][region_1_j+(IN_WIDTH/4)]),
                        .in_0_valid(mul_sys_in_0_valid[region_1_i][region_1_j+(IN_WIDTH/4)]),
                        .in_1_valid(mul_sys_in_1_valid[region_1_i][region_1_j+(IN_WIDTH/4)]),
                
                        .pattern(patterns[2]),
                        
                        .result(and_out[region_1_i][region_1_j+(IN_WIDTH/4)]),
                        .result_valid(and_out_valid[region_1_i][region_1_j+(IN_WIDTH/4)]),
                        
                        .in_0_out(mul_sys_out_0[region_1_i][region_1_j+(IN_WIDTH/4)]),
                        .in_1_out(mul_sys_out_1[region_1_i][region_1_j+(IN_WIDTH/4)]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_1_i][region_1_j+(IN_WIDTH/4)]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_1_i][region_1_j+(IN_WIDTH/4)])
                    );
                end
        end
                
    for (region_2_i=0; region_2_i<(IN_WIDTH/8); region_2_i=region_2_i+1)
        begin
            for (region_2_j=0; region_2_j<(IN_WIDTH/8); region_2_j=region_2_j+1)
                begin
                    BitwisePE_RTL 
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_2_0_0
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .in_1(mul_sys_in_1[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .in_0_valid(mul_sys_in_0_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .in_1_valid(mul_sys_in_1_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                
                        .pattern(patterns[1]),
                        
                        .result(and_out[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .result_valid(and_out_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        
                        .in_0_out(mul_sys_out_0[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .in_1_out(mul_sys_out_1[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)])
                    );
                    
                    BitwisePE_RTL
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_2_0_1
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .in_1(mul_sys_in_1[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .in_0_valid(mul_sys_in_0_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .in_1_valid(mul_sys_in_1_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                
                        .pattern(patterns[1]),
                        
                        .result(and_out[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .result_valid(and_out_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        
                        .in_0_out(mul_sys_out_0[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .in_1_out(mul_sys_out_1[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/4)+(IN_WIDTH/8)])
                    );
                    
                    BitwisePE_RTL
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_2_1_0
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_2_i+(IN_WIDTH/2)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/8)]),
                        .in_1(mul_sys_in_1[region_2_i+(IN_WIDTH/2)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/8)]),
                        .in_0_valid(mul_sys_in_0_valid[region_2_i+(IN_WIDTH/2)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/8)]),
                        .in_1_valid(mul_sys_in_1_valid[region_2_i+(IN_WIDTH/2)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/8)]),
                
                        .pattern(patterns[1]),
                        
                        .result(and_out[region_2_i+(IN_WIDTH/2)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/8)]),
                        .result_valid(and_out_valid[region_2_i+(IN_WIDTH/2)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/8)]),
                        
                        .in_0_out(mul_sys_out_0[region_2_i+(IN_WIDTH/2)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/8)]),
                        .in_1_out(mul_sys_out_1[region_2_i+(IN_WIDTH/2)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/8)]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_2_i+(IN_WIDTH/2)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/8)]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_2_i+(IN_WIDTH/2)][region_2_j+(IN_WIDTH/2)+(IN_WIDTH/8)])
                    );
                    
                    BitwisePE_RTL
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_2_1_1
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)]),
                        .in_1(mul_sys_in_1[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)]),
                        .in_0_valid(mul_sys_in_0_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)]),
                        .in_1_valid(mul_sys_in_1_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)]),
                
                        .pattern(patterns[1]),
                        
                        .result(and_out[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)]),
                        .result_valid(and_out_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)]),
                        
                        .in_0_out(mul_sys_out_0[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)]),
                        .in_1_out(mul_sys_out_1[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_2_i+(IN_WIDTH/2)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/2)])
                    );
                    
                    BitwisePE_RTL
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_2_2_0
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_2_i+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/4)]),
                        .in_1(mul_sys_in_1[region_2_i+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/4)]),
                        .in_0_valid(mul_sys_in_0_valid[region_2_i+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/4)]),
                        .in_1_valid(mul_sys_in_1_valid[region_2_i+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/4)]),
                
                        .pattern(patterns[1]),
                        
                        .result(and_out[region_2_i+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/4)]),
                        .result_valid(and_out_valid[region_2_i+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/4)]),
                        
                        .in_0_out(mul_sys_out_0[region_2_i+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/4)]),
                        .in_1_out(mul_sys_out_1[region_2_i+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/4)]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_2_i+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/4)]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_2_i+(IN_WIDTH/4)+(IN_WIDTH/8)][region_2_j+(IN_WIDTH/4)])
                    );
                    
                    BitwisePE_RTL
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_2_2_1
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_2_i+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .in_1(mul_sys_in_1[region_2_i+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .in_0_valid(mul_sys_in_0_valid[region_2_i+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .in_1_valid(mul_sys_in_1_valid[region_2_i+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                
                        .pattern(patterns[1]),
                        
                        .result(and_out[region_2_i+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .result_valid(and_out_valid[region_2_i+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        
                        .in_0_out(mul_sys_out_0[region_2_i+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .in_1_out(mul_sys_out_1[region_2_i+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_2_i+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/4)+(IN_WIDTH/8)]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_2_i+(IN_WIDTH/4)][region_2_j+(IN_WIDTH/4)+(IN_WIDTH/8)])
                    );
                    
                    BitwisePE_RTL
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_2_3_0
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_2_i+(IN_WIDTH/8)][region_2_j]),
                        .in_1(mul_sys_in_1[region_2_i+(IN_WIDTH/8)][region_2_j]),
                        .in_0_valid(mul_sys_in_0_valid[region_2_i+(IN_WIDTH/8)][region_2_j]),
                        .in_1_valid(mul_sys_in_1_valid[region_2_i+(IN_WIDTH/8)][region_2_j]),
                
                        .pattern(patterns[1]),
                        
                        .result(and_out[region_2_i+(IN_WIDTH/8)][region_2_j]),
                        .result_valid(and_out_valid[region_2_i+(IN_WIDTH/8)][region_2_j]),
                        
                        .in_0_out(mul_sys_out_0[region_2_i+(IN_WIDTH/8)][region_2_j]),
                        .in_1_out(mul_sys_out_1[region_2_i+(IN_WIDTH/8)][region_2_j]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_2_i+(IN_WIDTH/8)][region_2_j]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_2_i+(IN_WIDTH/8)][region_2_j])
                    );
                    
                    BitwisePE_RTL
                    #( 
                        .REGION(0) 
                    ) 
                    BitwisePE_RTL_region_2_3_1
                    (
                        .sys_clk(sys_clk),
                        
                        .in_0(mul_sys_in_0[region_2_i][region_2_j+(IN_WIDTH/8)]),
                        .in_1(mul_sys_in_1[region_2_i][region_2_j+(IN_WIDTH/8)]),
                        .in_0_valid(mul_sys_in_0_valid[region_2_i][region_2_j+(IN_WIDTH/8)]),
                        .in_1_valid(mul_sys_in_1_valid[region_2_i][region_2_j+(IN_WIDTH/8)]),
                
                        .pattern(patterns[1]),
                        
                        .result(and_out[region_2_i][region_2_j+(IN_WIDTH/8)]),
                        .result_valid(and_out_valid[region_2_i][region_2_j+(IN_WIDTH/8)]),
                        
                        .in_0_out(mul_sys_out_0[region_2_i][region_2_j+(IN_WIDTH/8)]),
                        .in_1_out(mul_sys_out_1[region_2_i][region_2_j+(IN_WIDTH/8)]),
                        .in_0_valid_out(mul_sys_out_0_valid[region_2_i][region_2_j+(IN_WIDTH/8)]),
                        .in_1_valid_out(mul_sys_out_1_valid[region_2_i][region_2_j+(IN_WIDTH/8)])
                    );
                end
        end
                        
    for (region_3_i=0; region_3_i<IN_WIDTH; region_3_i=region_3_i+1)
        begin
            BitwisePE_RTL 
            #( 
                .REGION(1) 
            ) 
            BitwisePE_RTL_region_3
            (
                .sys_clk(sys_clk),
                
                .in_0(mul_sys_in_0[region_3_i][region_3_i]),
                .in_1(mul_sys_in_1[region_3_i][region_3_i]),
                .in_0_valid(mul_sys_in_0_valid[region_3_i][region_3_i]),
                .in_1_valid(mul_sys_in_1_valid[region_3_i][region_3_i]),
                
                .pattern(patterns[0]),
                
                .result(and_out[region_3_i][region_3_i]),
                .result_valid(and_out_valid[region_3_i][region_3_i]),
                
                .in_0_out(mul_sys_out_0[region_3_i][region_3_i]),
                .in_1_out(mul_sys_out_1[region_3_i][region_3_i]),
                .in_0_valid_out(mul_sys_out_0_valid[region_3_i][region_3_i]),
                .in_1_valid_out(mul_sys_out_1_valid[region_3_i][region_3_i])
            );
        end
endgenerate

endmodule
