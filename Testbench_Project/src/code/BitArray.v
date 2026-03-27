`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/10/2026 04:59:16 PM
// Design Name: 
// Module Name: BitArray
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


module BitArray
#(
    parameter IN_WIDTH      = 8,
    parameter PRECI_WIDTH   = 2,
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
endmodule
