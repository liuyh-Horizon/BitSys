`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2026 07:05:57 PM
// Design Name: 
// Module Name: BitPE_RTL
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

module BitPE_RTL
#(
    parameter DIAGONAL          = 0,        // 1 for BitPE on diagonal, 0 for BitPE on non-diagonal
    parameter AND               = 1,        // BitPE working on AND mode
    parameter XNOR              = 0         // BitPE working on XNOR mode
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
    case (DIAGONAL)
    
        0   :   begin // If the BitPE is on the non-diagonal, it only supports AND and ZERO mode, and the result is valid only when both in_0 and in_1 are valid
                    always @(posedge sys_clk or negedge sys_rst_n)
                        begin
                            if (!sys_rst_n)
                                begin
                                    result          <= 0;
                                    result_valid    <= 0;
                                    in_0_out        <= 0;
                                    in_1_out        <= 0;
                                    in_0_valid_out  <= 0;
                                    in_1_valid_out  <= 0;
                                end
                            else begin
                                if (in_0_valid & in_1_valid)
                                    begin
                                        result          <= (mode == AND) ? (in_0 & in_1): 0; // If mode is AND, the result is the AND of in_0 and in_1; if mode is ZERO, the result is always 0
                                        result_valid    <= 1;
                                        in_0_out        <= in_0;
                                        in_1_out        <= in_1;
                                        in_0_valid_out  <= in_0_valid;
                                        in_1_valid_out  <= in_1_valid;
                                    end
                                    else begin
                                        result          <= 0;
                                        result_valid    <= 0;
                                        in_0_out        <= 0;
                                        in_1_out        <= 0;
                                        in_0_valid_out  <= 0;
                                        in_1_valid_out  <= 0;
                                    end
                            end
                        end
                end
    
        1   :   begin // If the BitPE is on the diagonal, it supports AND and XNOR mode, and the result is valid only when both in_0 and in_1 are valid
                    always @(posedge sys_clk or negedge sys_rst_n)
                        begin
                            if (!sys_rst_n)
                                begin
                                    result          <= 0;
                                    result_valid    <= 0;
                                    in_0_out        <= 0;
                                    in_1_out        <= 0;
                                    in_0_valid_out  <= 0;
                                    in_1_valid_out  <= 0;
                                end
                            else begin
                                if (in_0_valid & in_1_valid)
                                    begin
                                        result          <= (mode == XNOR) ? ~(in_0 ^ in_1): (in_0 & in_1); // If mode is XNOR, the result is the XNOR of in_0 and in_1; if mode is AND, the result is the AND of in_0 and in_1
                                        result_valid    <= 1;
                                        in_0_out        <= in_0;
                                        in_1_out        <= in_1;
                                        in_0_valid_out  <= in_0_valid;
                                        in_1_valid_out  <= in_1_valid;
                                    end
                                    else begin
                                        result          <= 0;
                                        result_valid    <= 0;
                                        in_0_out        <= 0;
                                        in_1_out        <= 0;
                                        in_0_valid_out  <= 0;
                                        in_1_valid_out  <= 0;
                                    end
                            end
                        end
                end
    endcase
endgenerate

endmodule
