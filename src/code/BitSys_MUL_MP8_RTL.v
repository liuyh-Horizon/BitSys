`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2026 06:55:41 PM
// Design Name: 
// Module Name: BitSys_MUL_MP8_RTL
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


module BitSys_MUL_MP8_RTL
#(
    parameter IN_WIDTH      = 8,
    parameter IN_PRECI      = 2,
    parameter REGION_NUM    = 4,
    parameter OUT_WIDTH     = 2*IN_WIDTH
)
(
    input   wire                                sys_clk,        // System Clock 
    input   wire                                sys_rst_n,      // System Reset
    
    input   wire    [(IN_PRECI-1):0]            precision,      // Input Precision
    
    input   wire    [(IN_WIDTH-1):0]            in_0,           // 8-bit Input 0
    input   wire    [(IN_WIDTH-1):0]            in_1,           // 8-bit Input 1
    input   wire    [(IN_WIDTH-1):0]            in_0_valid,     // 8-bit valid signal controls the Input 0 data streaming
    input   wire    [(IN_WIDTH-1):0]            in_1_valid,     // 8-bit valid signal controls the Input 1 data streaming
                                                                // If valid is all 1, systolic working
                                                                // If valid is all 0, systolic holds the current statement and pauses processing.
    
    input   wire                                is_signed,      // Setting signed/unsigned multiplication
    
    output  wire    [(OUT_WIDTH-1):0]           result,         // 16-bit output of MUL Result
    output  wire                                result_valid,   //  1-bit output of MUL Result Valid
    
    output  wire    [(IN_WIDTH-1):0]            in_0_out,       // 8-bit Input 0 to the next BitSys MUL
    output  wire    [(IN_WIDTH-1):0]            in_1_out,       // 8-bit Input 1 to the next BitSys MUL
    output  wire    [(IN_WIDTH-1):0]            in_0_valid_out, // 8-bit Input 0 valid signal to the next BitSys MUL
    output  wire    [(IN_WIDTH-1):0]            in_1_valid_out  // 8-bit Input 1 valid signal to the next BitSys MUL
);

// Internal Signals

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

// Connecting the two inputs first row and first column of the BitPE array

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

// Connecting the BitPE array in a systolic manner

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

genvar out_i;
generate // Connecting the outputs of the last row and last column of the BitPE array to the module outputs for following BitSys MULs
    for (out_i=0; out_i<IN_WIDTH; out_i=out_i+1)
        begin
            assign in_0_out[out_i]          = mul_sys_out_0[IN_WIDTH-1][out_i];
            assign in_0_valid_out[out_i]    = mul_sys_out_0_valid[IN_WIDTH-1][out_i];
            
            assign in_1_out[out_i]          = mul_sys_out_1[out_i][IN_WIDTH-1];
            assign in_1_valid_out[out_i]    = mul_sys_out_1_valid[out_i][IN_WIDTH-1];
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
                    if (OPTIMIZE==1)
                        begin
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_0_0
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
                            
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_0_1
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
                        else begin
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_0_0
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
                            
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_0_1
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
        end
            
    for (region_1_i=0; region_1_i<(IN_WIDTH/4); region_1_i=region_1_i+1)
        begin
            for (region_1_j=0; region_1_j<(IN_WIDTH/4); region_1_j=region_1_j+1)
                begin
                    if (OPTIMIZE==1)
                        begin
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_1_0_0
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
                            
                            LUT_units_Optimized #( .REGION(0)) 
                            LUT_units_region_1_0_1
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
                            
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_1_1_0
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
                            
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_1_1_1
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
                        else begin
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_1_0_0
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
                            
                            LUT_units #( .REGION(0)) 
                            LUT_units_region_1_0_1
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
                            
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_1_1_0
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
                            
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_1_1_1
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
        end
                
    for (region_2_i=0; region_2_i<(IN_WIDTH/8); region_2_i=region_2_i+1)
        begin
            for (region_2_j=0; region_2_j<(IN_WIDTH/8); region_2_j=region_2_j+1)
                begin
                    if (OPTIMIZE==1)
                        begin
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_2_0_0
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
                            
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_2_0_1
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
                            
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_2_1_0
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
                            
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_2_1_1
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
                            
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_2_2_0
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
                            
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_2_2_1
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
                            
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_2_3_0
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
                            
                            LUT_units_Optimized #( .REGION(0) ) 
                            LUT_units_region_2_3_1
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
                        else begin
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_2_0_0
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
                            
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_2_0_1
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
                            
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_2_1_0
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
                            
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_2_1_1
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
                            
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_2_2_0
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
                            
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_2_2_1
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
                            
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_2_3_0
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
                            
                            LUT_units #( .REGION(0) ) 
                            LUT_units_region_2_3_1
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
        end
                        
    for (region_3_i=0; region_3_i<IN_WIDTH; region_3_i=region_3_i+1)
        begin
            if (OPTIMIZE==1)
                begin
                    LUT_units_Optimized #( .REGION(1) ) 
                    LUT_units_region_3
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
                else begin
                    LUT_units #( .REGION(1) ) 
                    LUT_units_region_3
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
        end
endgenerate

reg     [1:0]       diagonal_0;
reg     [3:0]       diagonal_1;
reg     [5:0]       diagonal_2;
reg     [6:0]       diagonal_3;
reg     [8:0]       diagonal_4;
reg     [9:0]       diagonal_5;
reg     [10:0]      diagonal_6;
reg     [11:0]      diagonal_7;
reg     [12:0]      diagonal_8;
reg     [13:0]      diagonal_9;
reg     [14:0]      diagonal_10;
reg     [15:0]      diagonal_11;
reg     [15:0]      diagonal_12;
reg     [15:0]      diagonal_13;
reg     [15:0]      diagonal_14;

wire    [3:0]       diagonal_1_buf;
wire    [6:0]       diagonal_3_buf;
wire    [9:0]       diagonal_5_buf;
wire    [11:0]      diagonal_7_buf;
wire    [13:0]      diagonal_9_buf;
wire    [15:0]      diagonal_11_buf;
wire    [15:0]      diagonal_13_buf;

reg                 diagonal_0_valid;
reg                 diagonal_1_valid;
reg                 diagonal_2_valid;
reg                 diagonal_3_valid;
reg                 diagonal_4_valid;
reg                 diagonal_5_valid;
reg                 diagonal_6_valid;
reg                 diagonal_7_valid;
reg                 diagonal_8_valid;
reg                 diagonal_9_valid;
reg                 diagonal_10_valid;
reg                 diagonal_11_valid;
reg                 diagonal_12_valid;
reg                 diagonal_13_valid;
reg                 diagonal_14_valid;

wire    [1:0]       diagonal_0_sum;

wire    [1:0]       diagonal_0_0;

assign diagonal_0_0   = ((precision==0) & (is_signed)) ? {~and_out[0][0],1'b1} : {1'b0, and_out[0][0]};

assign diagonal_0_sum = diagonal_0_0;

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_0          <= 0;
                diagonal_0_valid    <= 0;
            end
            else begin
                if (and_out_valid[0][0])
                    begin
                        diagonal_0          <= diagonal_0_sum;
                        diagonal_0_valid    <= 1;
                    end
                    else begin
                        diagonal_0          <= 0;
                        diagonal_0_valid    <= 0;
                    end
            end 
    end

wire    [2:0]       diagonal_1_sum;

wire    [2:0]       diagonal_1_0, diagonal_1_1;

assign diagonal_1_0   = ((precision==1) & (is_signed)) ? 
                                {{(3){and_out[1][0]}}} : {2'b0, and_out[1][0]};
assign diagonal_1_1   = ((precision==1) & (is_signed)) ? 
                                {{(3){and_out[0][1]}}} : {2'b0, and_out[0][1]};

assign diagonal_1_sum = diagonal_1_0 + diagonal_1_1;

assign diagonal_1_buf = {diagonal_1_sum, 1'b0} + {{(2){diagonal_0[1]}}, diagonal_0};

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_1          <= 0;
                diagonal_1_valid    <= 0;
            end
            else begin
                if (and_out_valid[1][0] & and_out_valid[0][1] & diagonal_0_valid)
                    begin
                        diagonal_1          <= (precision==0) ? {2'd0, diagonal_1_buf[1:0]} : diagonal_1_buf;
                        diagonal_1_valid    <= 1;
                    end
                    else begin
                        diagonal_1          <= 0;
                        diagonal_1_valid    <= 0;
                    end
            end 
    end

wire    [2:0]       diagonal_2_sum;

wire    [2:0]       diagonal_2_0, diagonal_2_1, diagonal_2_2;

assign diagonal_2_0   = {2'b0, and_out[2][0]};
assign diagonal_2_1   = ((precision==0) & (is_signed)) ? 
                            { {(2){~and_out[1][1]}},1'b1 } : {2'b0, and_out[1][1]};
assign diagonal_2_2   = {2'b0, and_out[0][2]};

assign diagonal_2_sum = diagonal_2_0 + diagonal_2_1 + diagonal_2_2;

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_2          <= 0;
                diagonal_2_valid    <= 0;
            end
            else begin
                if (and_out_valid[2][0] & and_out_valid[1][1] & and_out_valid[0][2] & diagonal_1_valid)
                    begin
                        diagonal_2          <= {diagonal_2_sum[2], diagonal_2_sum, 2'b0} + {{(2){diagonal_1[3]}}, diagonal_1};
                        diagonal_2_valid    <= 1;
                    end
                    else begin
                        diagonal_2          <= 0;
                        diagonal_2_valid    <= 0;
                    end
            end 
    end

wire    [3:0]       diagonal_3_sum;

wire    [3:0]       diagonal_3_0, diagonal_3_1, diagonal_3_2, diagonal_3_3;

assign diagonal_3_0 = ((precision==2) & (is_signed)) ? 
                            {{(4){and_out[3][0]}}} : {3'b0, and_out[3][0]};
assign diagonal_3_1 = {3'b0, and_out[2][1]};
assign diagonal_3_2 = {3'b0, and_out[1][2]};
assign diagonal_3_3 = ((precision==2) & (is_signed)) ? 
                            {{(4){and_out[0][3]}}} : {3'b0, and_out[0][3]};
                            
assign  diagonal_3_sum = diagonal_3_0 + diagonal_3_1 + diagonal_3_2 + diagonal_3_3;

assign diagonal_3_buf = {diagonal_3_sum, 3'b0} + {diagonal_2[5], diagonal_2};

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_3          <= 0;
                diagonal_3_valid    <= 0;
            end
            else begin
                if (and_out_valid[3][0] & and_out_valid[2][1] & and_out_valid[1][2] & and_out_valid[0][3] & diagonal_2_valid)
                    begin
                        diagonal_3          <= ( (precision==0) || (precision==1) ) ? {3'd0, diagonal_3_buf[3:0]} : diagonal_3_buf;
                        diagonal_3_valid    <= 1;
                    end
                    else begin
                        diagonal_3          <= 0;
                        diagonal_3_valid    <= 0;
                    end
            end 
    end

wire    [3:0]       diagonal_4_sum;

wire    [3:0]       diagonal_4_0, diagonal_4_1, diagonal_4_2, diagonal_4_3, diagonal_4_4;

assign diagonal_4_0 = {3'b0, and_out[4][0]};
assign diagonal_4_1 = ((precision==2) & (is_signed)) ? 
                            {{(4){and_out[3][1]}}} : {3'b0, and_out[3][1]};
assign diagonal_4_2 = ((precision==0) & (is_signed)) ? 
                            { {(3){~and_out[2][2]}},1'b1 } : {3'b0, and_out[2][2]};
assign diagonal_4_3 = ((precision==2) & (is_signed)) ? 
                            {{(4){and_out[1][3]}}} : {3'b0, and_out[1][3]};
assign diagonal_4_4 = {3'b0, and_out[0][4]};
                            
assign  diagonal_4_sum = diagonal_4_0 + diagonal_4_1 + diagonal_4_2 + diagonal_4_3 + diagonal_4_4;

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_4          <= 0;
                diagonal_4_valid    <= 0;
            end
            else begin
                if (and_out_valid[4][0] & and_out_valid[3][1] & and_out_valid[2][2] & and_out_valid[1][3] & and_out_valid[0][4] & diagonal_3_valid)
                    begin
                        diagonal_4          <= {diagonal_4_sum[3], diagonal_4_sum, 4'b0} + {{(2){diagonal_3[6]}}, diagonal_3};
                        diagonal_4_valid    <= 1;
                    end
                    else begin
                        diagonal_4          <= 0;
                        diagonal_4_valid    <= 0;
                    end
            end 
    end

wire    [3:0]       diagonal_5_sum;

wire    [3:0]       diagonal_5_0, diagonal_5_1, diagonal_5_2, diagonal_5_3, diagonal_5_4, diagonal_5_5;

assign diagonal_5_0 = {3'b0, and_out[5][0]};
assign diagonal_5_1 = {3'b0, and_out[4][1]};
assign diagonal_5_2 = ( ( (precision==1) | (precision==2) ) & (is_signed) ) ? 
                            {{(4){and_out[3][2]}}} : {3'b0, and_out[3][2]};
assign diagonal_5_3 = ( ( (precision==1) | (precision==2) ) & (is_signed) ) ? 
                            {{(4){and_out[2][3]}}} : {3'b0, and_out[2][3]};
assign diagonal_5_4 = {3'b0, and_out[1][4]};
assign diagonal_5_5 = {3'b0, and_out[0][5]};
                            
assign  diagonal_5_sum = diagonal_5_0 + diagonal_5_1 + diagonal_5_2 + diagonal_5_3 + diagonal_5_4 + diagonal_5_5;

assign diagonal_5_buf = {diagonal_5_sum[3], diagonal_5_sum, 5'b0} + {diagonal_4[8], diagonal_4};

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_5          <= 0;
                diagonal_5_valid    <= 0;
            end
            else begin
                if (and_out_valid[5][0] & and_out_valid[4][1] & and_out_valid[3][2] & and_out_valid[2][3] & and_out_valid[1][4] & and_out_valid[0][5] & diagonal_4_valid)
                    begin
                        diagonal_5          <= (precision==0) ? {4'd0, diagonal_5_buf[5:0]} : diagonal_5_buf;
                        diagonal_5_valid    <= 1;
                    end
                    else begin
                        diagonal_5          <= 0;
                        diagonal_5_valid    <= 0;
                    end
            end 
    end

wire    [3:0]       diagonal_6_sum;

wire    [3:0]       diagonal_6_0, diagonal_6_1, diagonal_6_2, diagonal_6_3, diagonal_6_4, diagonal_6_5, diagonal_6_6;

assign diagonal_6_0 = {3'b0, and_out[6][0]};
assign diagonal_6_1 = {3'b0, and_out[5][1]};
assign diagonal_6_2 = {3'b0, and_out[4][2]};
assign diagonal_6_3 = ((precision==0) & (is_signed)) ? 
                            { {(3){~and_out[3][3]}},1'b1 } : {3'b0, and_out[3][3]};
assign diagonal_6_4 = {3'b0, and_out[2][4]};
assign diagonal_6_5 = {3'b0, and_out[1][5]};
assign diagonal_6_6 = {3'b0, and_out[0][6]};
                            
assign  diagonal_6_sum = diagonal_6_0 + diagonal_6_1 + diagonal_6_2 + diagonal_6_3 + diagonal_6_4 + diagonal_6_5 + diagonal_6_6;

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_6          <= 0;
                diagonal_6_valid    <= 0;
            end
            else begin
                if (and_out_valid[6][0] & and_out_valid[5][1] & and_out_valid[4][2] & and_out_valid[3][3] & and_out_valid[2][4] & and_out_valid[1][5] & and_out_valid[0][6] & diagonal_5_valid)
                    begin
                        diagonal_6          <= {diagonal_6_sum, 6'b0} + {diagonal_5[9], diagonal_5};
                        diagonal_6_valid    <= 1;
                    end
                    else begin
                        diagonal_6          <= 0;
                        diagonal_6_valid    <= 0;
                    end
            end 
    end

wire    [4:0]       diagonal_7_sum;

wire    [4:0]       diagonal_7_0, diagonal_7_1, diagonal_7_2, diagonal_7_3, diagonal_7_4, diagonal_7_5, diagonal_7_6, diagonal_7_7;

assign diagonal_7_0 = ((precision==3) & (is_signed)) ? 
                            {{(5){and_out[7][0]}}} : {4'b0, and_out[7][0]};
assign diagonal_7_1 = {4'b0, and_out[6][1]};
assign diagonal_7_2 = {4'b0, and_out[5][2]};
assign diagonal_7_3 = {4'b0, and_out[4][3]};
assign diagonal_7_4 = {4'b0, and_out[3][4]};
assign diagonal_7_5 = {4'b0, and_out[2][5]};
assign diagonal_7_6 = {4'b0, and_out[1][6]};
assign diagonal_7_7 = ((precision==3) & (is_signed)) ? 
                            {{(5){and_out[0][7]}}} : {4'b0, and_out[0][7]};
                            
assign diagonal_7_sum = diagonal_7_0 + diagonal_7_1 + diagonal_7_2 + diagonal_7_3 + diagonal_7_4 + diagonal_7_5 + diagonal_7_6 + diagonal_7_7;

assign diagonal_7_buf = {diagonal_7_sum, 7'b0} + {diagonal_6[10], diagonal_6};

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_7          <= 0;
                diagonal_7_valid    <= 0;
            end
            else begin
                if (and_out_valid[7][0] & and_out_valid[6][1] & and_out_valid[5][2] & and_out_valid[4][3] & and_out_valid[3][4] & and_out_valid[2][5] & and_out_valid[1][6] & and_out_valid[0][7] & diagonal_6_valid)
                    begin
                        diagonal_7          <= ( (precision==0) || (precision==1) || (precision==2) ) ? {4'd0, diagonal_7_buf[7:0]} : diagonal_7_buf;
                        diagonal_7_valid    <= 1;
                    end
                    else begin
                        diagonal_7          <= 0;
                        diagonal_7_valid    <= 0;
                    end
            end 
    end

wire    [3:0]       diagonal_8_sum;

wire    [3:0]       diagonal_8_0, diagonal_8_1, diagonal_8_2, diagonal_8_3, diagonal_8_4, diagonal_8_5, diagonal_8_6;

assign diagonal_8_0 = ((precision==3) & (is_signed)) ? 
                            {{(4){and_out[7][1]}}} : {3'b0, and_out[7][1]};
assign diagonal_8_1 = {3'b0, and_out[6][2]};
assign diagonal_8_2 = {3'b0, and_out[5][3]};
assign diagonal_8_3 = ((precision==0) & (is_signed)) ? 
                            { {(3){~and_out[4][4]}},1'b1 } : {3'b0, and_out[4][4]};
assign diagonal_8_4 = {3'b0, and_out[3][5]};
assign diagonal_8_5 = {3'b0, and_out[2][6]};
assign diagonal_8_6 = ((precision==3) & (is_signed)) ? 
                            {{(4){and_out[1][7]}}} : {3'b0, and_out[1][7]};
                            
assign  diagonal_8_sum = diagonal_8_0 + diagonal_8_1 + diagonal_8_2 + diagonal_8_3 + diagonal_8_4 + diagonal_8_5 + diagonal_8_6;

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_8          <= 0;
                diagonal_8_valid    <= 0;
            end
            else begin
                if (and_out_valid[7][1] & and_out_valid[6][2] & and_out_valid[5][3] & and_out_valid[4][4] & and_out_valid[3][5] & and_out_valid[2][6] & and_out_valid[1][7] & diagonal_7_valid)
                    begin
                        diagonal_8          <= {diagonal_8_sum[3], diagonal_8_sum, 8'b0} + {diagonal_7[11], diagonal_7};
                        diagonal_8_valid    <= 1;
                    end
                    else begin
                        diagonal_8          <= 0;
                        diagonal_8_valid    <= 0;
                    end
            end 
    end

wire    [3:0]       diagonal_9_sum;

wire    [3:0]       diagonal_9_0, diagonal_9_1, diagonal_9_2, diagonal_9_3, diagonal_9_4, diagonal_9_5;

assign diagonal_9_0 = ((precision==3) & (is_signed)) ? 
                            {{(4){and_out[7][2]}}} : {3'b0, and_out[7][2]};
assign diagonal_9_1 = {3'b0, and_out[6][3]};
assign diagonal_9_2 = ((precision==1) & (is_signed)) ? 
                            {{(4){and_out[5][4]}}} : {3'b0, and_out[5][4]};
assign diagonal_9_3 = ((precision==1) & (is_signed)) ? 
                            {{(4){and_out[4][5]}}} : {3'b0, and_out[4][5]};
assign diagonal_9_4 = {3'b0, and_out[3][6]};
assign diagonal_9_5 = ((precision==3) & (is_signed)) ? 
                            {{(4){and_out[2][7]}}} : {3'b0, and_out[2][7]};
                            
assign  diagonal_9_sum = diagonal_9_0 + diagonal_9_1 + diagonal_9_2 + diagonal_9_3 + diagonal_9_4 + diagonal_9_5;

assign diagonal_9_buf = {diagonal_9_sum[3], diagonal_9_sum, 9'b0} + {diagonal_8[12], diagonal_8};

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_9          <= 0;
                diagonal_9_valid    <= 0;
            end
            else begin
                if (and_out_valid[7][2] & and_out_valid[6][3] & and_out_valid[5][4] & and_out_valid[4][5] & and_out_valid[3][6] & and_out_valid[2][7] & diagonal_8_valid)
                    begin
                        diagonal_9          <= (precision==0) ? {4'd0, diagonal_9_buf[9:0]} : diagonal_9_buf;
                        diagonal_9_valid    <= 1;
                    end
                    else begin
                        diagonal_9          <= 0;
                        diagonal_9_valid    <= 0;
                    end
            end 
    end

wire    [3:0]       diagonal_10_sum;

wire    [3:0]       diagonal_10_0, diagonal_10_1, diagonal_10_2, diagonal_10_3, diagonal_10_4;

assign diagonal_10_0 = ((precision==3) & (is_signed)) ? 
                            {{(4){and_out[7][3]}}} : {3'b0, and_out[7][3]};
assign diagonal_10_1 = {3'b0, and_out[6][4]};
assign diagonal_10_2 = ((precision==0) & (is_signed)) ? 
                            { {(3){~and_out[5][5]}},1'b1 } : {3'b0, and_out[5][5]};
assign diagonal_10_3 = {3'b0, and_out[4][6]};
assign diagonal_10_4 = ((precision==3) & (is_signed)) ? 
                            {{(4){and_out[3][7]}}} : {3'b0, and_out[3][7]};
                            
assign  diagonal_10_sum = diagonal_10_0 + diagonal_10_1 + diagonal_10_2 + diagonal_10_3 + diagonal_10_4;

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_10          <= 0;
                diagonal_10_valid    <= 0;
            end
            else begin
                if (and_out_valid[7][3] & and_out_valid[6][4] & and_out_valid[5][5] & and_out_valid[4][6] & and_out_valid[3][7] & diagonal_9_valid)
                    begin
                        diagonal_10          <= {diagonal_10_sum[3], diagonal_10_sum, 10'b0} + {diagonal_9[13], diagonal_9};
                        diagonal_10_valid    <= 1;
                    end
                    else begin
                        diagonal_10          <= 0;
                        diagonal_10_valid    <= 0;
                    end
            end 
    end

wire    [3:0]       diagonal_11_sum;

wire    [3:0]       diagonal_11_0, diagonal_11_1, diagonal_11_2, diagonal_11_3;

assign diagonal_11_0 = ( ( (precision==2) | (precision==3) ) & (is_signed)) ? 
                            {{(4){and_out[7][4]}}} : {3'b0, and_out[7][4]};
assign diagonal_11_1 = {3'b0, and_out[6][5]};
assign diagonal_11_2 = {3'b0, and_out[5][6]};
assign diagonal_11_3 = ( ( (precision==2) | (precision==3) ) & (is_signed)) ? 
                            {{(4){and_out[4][7]}}} : {3'b0, and_out[4][7]};
                            
assign  diagonal_11_sum = diagonal_11_0 + diagonal_11_1 + diagonal_11_2 + diagonal_11_3;

assign diagonal_11_buf = {diagonal_11_sum[3], diagonal_11_sum, 11'b0} + {diagonal_10[14], diagonal_10};

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_11          <= 0;
                diagonal_11_valid    <= 0;
            end
            else begin
                if (and_out_valid[7][4] & and_out_valid[6][5] & and_out_valid[5][6] & and_out_valid[4][7] & diagonal_10_valid)
                    begin
                        diagonal_11          <= ( (precision==0) || (precision==1) ) ? {4'd0, diagonal_11_buf[11:0]} : diagonal_11_buf;
                        diagonal_11_valid    <= 1;
                    end
                    else begin
                        diagonal_11          <= 0;
                        diagonal_11_valid    <= 0;
                    end
            end 
    end

wire    [2:0]       diagonal_12_sum;

wire    [2:0]       diagonal_12_0, diagonal_12_1, diagonal_12_2;

assign diagonal_12_0 = ( ( (precision==2) | (precision==3) ) & (is_signed)) ? 
                            {{(3){and_out[7][5]}}} : {2'b0, and_out[7][5]};
assign diagonal_12_1 = ((precision==0) & (is_signed)) ? 
                            { {(2){~and_out[6][6]}},1'b1 } : {2'b0, and_out[6][6]};
assign diagonal_12_2 = ( ( (precision==2) | (precision==3) ) & (is_signed)) ? 
                            {{(3){and_out[5][7]}}} : {2'b0, and_out[5][7]};
                            
assign  diagonal_12_sum = diagonal_12_0 + diagonal_12_1 + diagonal_12_2;

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_12          <= 0;
                diagonal_12_valid    <= 0;
            end
            else begin
                if (and_out_valid[7][5] & and_out_valid[6][6] & and_out_valid[5][7] & diagonal_11_valid)
                    begin
                        diagonal_12          <= {diagonal_12_sum[2], diagonal_12_sum, 12'b0} + diagonal_11;
                        diagonal_12_valid    <= 1;
                    end
                    else begin
                        diagonal_12          <= 0;
                        diagonal_12_valid    <= 0;
                    end
            end 
    end

wire    [2:0]       diagonal_13_sum;

wire    [2:0]       diagonal_13_0, diagonal_13_1;

assign diagonal_13_0 = ( ( (precision==1) | (precision==2) | (precision==3) ) & (is_signed)) ? 
                            {{(3){and_out[7][6]}}} : {2'b0, and_out[7][6]};
assign diagonal_13_1 = ( ( (precision==1) | (precision==2) | (precision==3) ) & (is_signed)) ? 
                            {{(3){and_out[6][7]}}} : {2'b0, and_out[6][7]};
                            
assign  diagonal_13_sum = diagonal_13_0 + diagonal_13_1;

assign diagonal_13_buf = {diagonal_13_sum, 13'b0} + diagonal_12;

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_13          <= 0;
                diagonal_13_valid    <= 0;
            end
            else begin
                if (and_out_valid[7][6] & and_out_valid[6][7] & diagonal_12_valid)
                    begin
                        diagonal_13          <= (precision==0) ? {2'd0, diagonal_13_buf[13:0]} : diagonal_13_buf;
                        diagonal_13_valid    <= 1;
                    end
                    else begin
                        diagonal_13          <= 0;
                        diagonal_13_valid    <= 0;
                    end
            end 
    end

wire    [1:0]       diagonal_14_sum;

wire    [1:0]       diagonal_14_0;

assign diagonal_14_0 = ((precision==0) & (is_signed)) ? 
                            { {(1){~and_out[7][7]}},1'b1 } : {1'b0, and_out[7][7]};
                            
assign  diagonal_14_sum = diagonal_14_0;

always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            begin
                diagonal_14          <= 0;
                diagonal_14_valid    <= 0;
            end
            else begin
                if (and_out_valid[7][7] & diagonal_13_valid)
                    begin
                        diagonal_14          <= {diagonal_14_sum, 14'b0} + diagonal_13;
                        diagonal_14_valid    <= 1;
                    end
                    else begin
                        diagonal_14          <= 0;
                        diagonal_14_valid    <= 0;
                    end
            end 
    end
    
assign result = diagonal_14;
assign result_valid = diagonal_14_valid;

endmodule
