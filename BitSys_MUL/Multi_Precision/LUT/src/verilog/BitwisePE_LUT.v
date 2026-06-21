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
    
    input   wire                            in_0,           // 1-bit Input 0
    input   wire                            in_1,           // 1-bit Input 1
    input   wire                            in_0_valid,     // Input 0 valid signal
    input   wire                            in_1_valid,     // Input 1 valid signal
    
    input   wire                            pattern,        // Control the Bitwise PE switch between AND/0 or AND/XNOR
    
    output  reg                             result,         // 1-bit Output of Bitwise PE
    output  reg                             result_valid,   // Output valid signal of Bitwise PE
    
    output  reg                             in_0_out,       // Input 0 to the next Bitwise PE
    output  reg                             in_1_out,       // Input 1 to the next Bitwise PE
    output  reg                             in_0_valid_out, // Input 0 valid signal to the next Bitwise PE
    output  reg                             in_1_valid_out  // Input 1 valid signal to the next Bitwise PE
);

generate

    case (REGION) // Two types of Bitwise PE. Type 1 placed one the diagonal of Bitwise Systolc Array. Othe Bitwise PE should be type 0
    
        0   :   begin // Type 0: Switching between AND/0
                    
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
                       .I4(pattern),    // 1-bit LUT input
                       .I5(1'b1)        // 1-bit LUT input (fast MUX select only available to O6 output)
                    );
                    
                    always @(posedge sys_clk)
                        begin
                            result          <= O5;
                            result_valid    <= O6;
                            in_0_out        <= in_0;
                            in_1_out        <= in_1;
                            in_0_valid_out  <= in_0_valid;
                            in_1_valid_out  <= in_1_valid;
                        end
                end
                
        1   :   begin // Type 1: Switching between AND/XNOR
                    
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
                       .I4(pattern),    // 1-bit LUT input
                       .I5(1'b1)        // 1-bit LUT input (fast MUX select only available to O6 output)
                    );
                    
                    always @(posedge sys_clk)
                        begin
                            result          <= O5;
                            result_valid    <= O6;
                            in_0_out        <= in_0;
                            in_1_out        <= in_1;
                            in_0_valid_out  <= in_0_valid;
                            in_1_valid_out  <= in_1_valid;
                        end
                end
    endcase
    
endgenerate

endmodule
