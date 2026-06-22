`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 05:33:36 PM
// Design Name: 
// Module Name: BitwisePE_RTL
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


module BitwisePE_RTL
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

    case (REGION)
    
        0   :   begin
                    always @(posedge sys_clk)
                        begin
                            if (in_0_valid & in_1_valid)
                                begin
                                    case ({pattern, in_0, in_1})
                                    
                                        3'b000  :   begin
                                                        result  <= 1'b0;
                                                    end
                                    
                                        3'b001  :   begin
                                                        result  <= 1'b0;
                                                    end
                                    
                                        3'b010  :   begin
                                                        result  <= 1'b0;
                                                    end
                                    
                                        3'b011  :   begin
                                                        result  <= 1'b0;
                                                    end
                                    
                                        3'b100  :   begin
                                                        result  <= 1'b0;
                                                    end
                                    
                                        3'b101  :   begin
                                                        result  <= 1'b0;
                                                    end
                                    
                                        3'b110  :   begin
                                                        result  <= 1'b0;
                                                    end
                                    
                                        3'b111  :   begin
                                                        result  <= 1'b1;
                                                    end
                                        
                                    endcase
                                    
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
    
        1   :   begin
                    always @(posedge sys_clk)
                        begin
                            if (in_0_valid & in_1_valid)
                                begin
                                    case ({pattern, in_0, in_1})
                                    
                                        3'b000  :   begin
                                                        result  <= 1'b1;
                                                    end
                                    
                                        3'b001  :   begin
                                                        result  <= 1'b0;
                                                    end
                                    
                                        3'b010  :   begin
                                                        result  <= 1'b0;
                                                    end
                                    
                                        3'b011  :   begin
                                                        result  <= 1'b1;
                                                    end
                                    
                                        3'b100  :   begin
                                                        result  <= 1'b0;
                                                    end
                                    
                                        3'b101  :   begin
                                                        result  <= 1'b0;
                                                    end
                                    
                                        3'b110  :   begin
                                                        result  <= 1'b0;
                                                    end
                                    
                                        3'b111  :   begin
                                                        result  <= 1'b1;
                                                    end
                                        
                                    endcase
                                    
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
    endcase
            
endgenerate

endmodule
