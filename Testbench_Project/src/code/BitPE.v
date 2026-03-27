`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/10/2026 04:59:16 PM
// Design Name: 
// Module Name: BitPE
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


module BitPE
#(
    parameter LUT_BASED         = 0,        // 1 for LUT-based BitPE, 0 for RTL-based BitPE
    parameter DIAGONAL          = 0         // 1 for BitPE on diagonal, 0 for BitPE on non-diagonal
)
(
    input   wire                            sys_clk,        // System Clock 
    input   wire                            sys_rst_n,      // Active Low Reset
    
    input   wire                            in_0,           // 1-bit Input 0
    input   wire                            in_1,           // 1-bit Input 1
    input   wire                            mode,           // Swith between ZERO/AND or XNOR/AND mode
    input   wire                            in_0_valid,     // 1-bit valid signal control the Input 0 data streaming 
    input   wire                            in_1_valid,     // 1-bit valid signal control the Input 1 data streaming
    
    output  reg                             result,         // 1-bit Output of BitPE Result
    output  reg                             result_valid,   // 1-bit Output of BitPE Result Valid
    
    output  reg                             in_0_out,       // 1-bit Input 0 to the next BitPE
    output  reg                             in_1_out,       // 1-bit Input 1 to the next BitPE
    output  reg                             in_0_valid_out, // 1-bit Input 0 valid signal to the next BitPE
    output  reg                             in_1_valid_out  // 1-bit Input 1 valid signal to the next BitPE
);

generate
    if (LUT_BASED)
        begin
            // LUT-based BitPE Implementation
            BitPE_LUT 
            #(
                .DIAGONAL(DIAGONAL)
            )
            BitPE 
            (
                .sys_clk(sys_clk),
                .sys_rst_n(sys_rst_n),
                .in_0(in_0),
                .in_1(in_1),
                .mode(mode),
                .in_0_valid(in_0_valid),
                .in_1_valid(in_1_valid),
                .result(result),
                .result_valid(result_valid),
                .in_0_out(in_0_out),
                .in_1_out(in_1_out),
                .in_0_valid_out(in_0_valid_out),
                .in_1_valid_out(in_1_valid_out)
            );
        end
    else
        begin
            // RTL-based BitPE Implementation
            BitPE_RTL 
            #(
                .DIAGONAL(DIAGONAL)
            )
            BitPE 
            (
                .sys_clk(sys_clk),
                .sys_rst_n(sys_rst_n),
                .in_0(in_0),
                .in_1(in_1),
                .mode(mode),
                .in_0_valid(in_0_valid),
                .in_1_valid(in_1_valid),
                .result(result),
                .result_valid(result_valid),
                .in_0_out(in_0_out),
                .in_1_out(in_1_out),
                .in_0_valid_out(in_0_valid_out),
                .in_1_valid_out(in_1_valid_out)
            );
        end
endgenerate
endmodule
