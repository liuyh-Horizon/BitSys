`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 02:21:15 AM
// Design Name: 
// Module Name: BitSys_MAC
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


module BitSys_MAC
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
    
    input   wire                                mac_rst,        // Reset the MAC
    
    input   wire    [(IN_PRECI-1):0]            precision,      // Input Precision
    input   wire                                is_signed,      // Setting signed/unsigned multiplication
    input   wire    [(ACCU_LENGTH-1):0]         accu_length,
    
    input   wire    [(IN_WIDTH-1):0]            in_0,           // Input 0
    input   wire    [(IN_WIDTH-1):0]            in_1,           // Input 1
    input   wire                                in_valid,
    
    output  wire    [(ACCU_WIDTH-1):0]          mac_out,        // Output of MAC Result
    output  wire                                mac_out_valid   // Output of MAC Result Valid
);
    
wire    [(OUT_WIDTH-1):0]           result;         // Output of MUL Result
wire                                result_valid;   // Output of MUL Result Valid

BitSys_MUL
#(
    .IN_WIDTH(IN_WIDTH),
    .IN_PRECI(IN_PRECI)
)
BitSys_MUL_inst
(
    .sys_clk(sys_clk),              // System Clock 
    .sys_rst_n(sys_rst_n),          // System Reset
    
    .mul_rst(mac_rst),              // Reset the MUL
    
    .precision(precision),          // Input Precision
    .is_signed(is_signed),          // Setting signed/unsigned multiplication
        
    .in_0(in_0),                    // Input 0
    .in_1(in_1),                    // Input 1
    .in_valid(in_valid),
    
    .result(result),                // Output of MUL Result
    .result_valid(result_valid)     // Output of MUL Result Valid
);
    
ReduceAccuMP
#(
    .IN_WIDTH(IN_WIDTH),
    .IN_PRECI(IN_PRECI),
    .ACCU_LENGTH(ACCU_LENGTH)
)
ReduceAccuMP
(
    .sys_clk(sys_clk),              // System Clock 
    .sys_rst_n(sys_rst_n),          // System Reset
    
    .accu_rst(mac_rst),             // Reset the accumulator
    
    .precision(precision),          // Input Precision
    .is_signed(is_signed),          // Setting signed/unsigned multiplication
    .accu_length(accu_length),
    
    .result(result),                // Input of MUL Result
    .result_valid(result_valid),    // Input of MUL Result Valid
    
    .accu_out(mac_out),
    .accu_out_valid(mac_out_valid)
);

endmodule
