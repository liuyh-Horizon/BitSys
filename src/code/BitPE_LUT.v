`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2026 07:05:57 PM
// Design Name: 
// Module Name: BitPE_LUT
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

module BitPE_LUT
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
    
        0   :   begin
                    
                    wire    O5, O6;
    
                    LUT6_2 
                    #(
                        .INIT(64'b11110000_00000000_11110000_00000000_10000000_00000000_00000000_00000000)
                    )
                    Region_0_LUT 
                    (
                        .O6(O6),         // 1-bit LUT6 output
                        .O5(O5),         // 1-bit lower LUT5 output
                        .I0(in_0),       // 1-bit LUT input
                        .I1(in_1),       // 1-bit LUT input
                        .I2(in_0_valid), // 1-bit LUT input
                        .I3(in_1_valid), // 1-bit LUT input
                        .I4(mode),       // 1-bit LUT input
                        .I5(1'b1)        // 1-bit LUT input (fast MUX select only available to O6 output)
                    );
                    
                    always @(posedge sys_clk or negedge sys_rst_n)
                        begin
                            if (!sys_rst_n)
                                begin
                                    result          <= 1'b0;
                                    result_valid    <= 1'b0;
                                    in_0_out        <= 1'b0;
                                    in_1_out        <= 1'b0;
                                    in_0_valid_out  <= 1'b0;
                                    in_1_valid_out  <= 1'b0;
                                end
                                else begin
                                    result          <= O5;
                                    result_valid    <= O6;
                                    in_0_out        <= in_0;
                                    in_1_out        <= in_1;
                                    in_0_valid_out  <= in_0_valid;
                                    in_1_valid_out  <= in_1_valid;
                                end
                        end
                end
    
        1   :   begin
                    
                    wire    O5, O6;
    
                    LUT6_2 
                    #(
                        .INIT(64'b11110000_00000000_11110000_00000000_10000000_00000000_10010000_00000000)
                    )
                    Region_1_LUT 
                    (
                        .O6(O6),         // 1-bit LUT6 output
                        .O5(O5),         // 1-bit lower LUT5 output
                        .I0(in_0),       // 1-bit LUT input
                        .I1(in_1),       // 1-bit LUT input
                        .I2(in_0_valid), // 1-bit LUT input
                        .I3(in_1_valid), // 1-bit LUT input
                        .I4(mode),       // 1-bit LUT input
                        .I5(1'b1)        // 1-bit LUT input (fast MUX select only available to O6 output)
                    );
                    
                    always @(posedge sys_clk or negedge sys_rst_n)
                        begin
                            if (!sys_rst_n)
                                begin
                                    result          <= 1'b0;
                                    result_valid    <= 1'b0;
                                    in_0_out        <= 1'b0;
                                    in_1_out        <= 1'b0;
                                    in_0_valid_out  <= 1'b0;
                                    in_1_valid_out  <= 1'b0;
                                end
                                else begin
                                    result          <= O5;
                                    result_valid    <= O6;
                                    in_0_out        <= in_0;
                                    in_1_out        <= in_1;
                                    in_0_valid_out  <= in_0_valid;
                                    in_1_valid_out  <= in_1_valid;
                                end
                        end
                end
    
    endcase
endgenerate

endmodule