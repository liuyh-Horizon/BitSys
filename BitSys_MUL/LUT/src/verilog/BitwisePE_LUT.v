`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 05:48:08 PM
// Design Name: 
// Module Name: BitwisePE_LUT
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


module BitwisePE_LUT
#(
    parameter REGION        = 0
)
(
    input   wire                            sys_clk,        // System Clock 
    
    input   wire                            in_0,           // Input 0
    input   wire                            in_1,           // Input 1
    input   wire                            in_0_start,     
    input   wire                            in_1_start,     // Start Signal control the working statement
    
    input   wire                            pattern,        // Width or height of input matrix
    
    output  reg                             result,         // Output of LUT Unit Result
    output  reg                             result_valid,   // Output of LUT Unit Result Valid
    
    output  reg                             in_0_out,       // Input 0 to next LUT Unit
    output  reg                             in_1_out,       // Input 1 to next LUT Unit
    output  reg                             in_0_start_out, // Input 0 enable the working of next LUT Unit
    output  reg                             in_1_start_out  // Input 1 enable the working of next LUT Unit
);

generate

    case (REGION)
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
                       .I2(in_0_start), // 1-bit LUT input
                       .I3(in_1_start), // 1-bit LUT input
                       .I4(pattern),    // 1-bit LUT input
                       .I5(1'b1)        // 1-bit LUT input (fast MUX select only available to O6 output)
                    );
                    
                    always @(posedge sys_clk)
                        begin
                            result          <= O5;
                            result_valid    <= O6;
                            in_0_out        <= in_0;
                            in_1_out        <= in_1;
                            in_0_start_out  <= in_0_start;
                            in_1_start_out  <= in_1_start;
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
                       .I2(in_0_start), // 1-bit LUT input
                       .I3(in_1_start), // 1-bit LUT input
                       .I4(pattern),    // 1-bit LUT input
                       .I5(1'b1)        // 1-bit LUT input (fast MUX select only available to O6 output)
                    );
                    
                    always @(posedge sys_clk)
                        begin
                            result          <= O5;
                            result_valid    <= O6;
                            in_0_out        <= in_0;
                            in_1_out        <= in_1;
                            in_0_start_out  <= in_0_start;
                            in_1_start_out  <= in_1_start;
                        end
                end
    endcase
    
endgenerate

endmodule
