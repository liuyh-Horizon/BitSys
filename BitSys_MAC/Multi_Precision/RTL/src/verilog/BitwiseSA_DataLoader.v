`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 05:48:08 PM
// Design Name: 
// Module Name: BitwiseSA_DataLoader
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


module BitwiseSA_DataLoader
#(
    parameter IN_WIDTH      = 8
)
(
    input   wire                                sys_clk,        // System Clock 
    input   wire                                sys_rst_n,      // System Reset
    
    input   wire    [(IN_WIDTH-1):0]            date,
    input   wire                                date_valid,
    
    input   wire                                rst,

    output  wire    [(IN_WIDTH-1):0]            in,             // Input
    output  wire    [(IN_WIDTH-1):0]            in_start  
);

reg     [(IN_WIDTH-1):0]        date_reg        [(IN_WIDTH-1):0];
reg     [(IN_WIDTH-1):0]        date_start_reg  [(IN_WIDTH-1):0];

integer date_i;
always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if ( (!sys_rst_n) | (rst) )
            begin
                for (date_i=0; date_i<IN_WIDTH; date_i=date_i+1)
                    begin
                        date_reg[date_i]        <= 0;
                        date_start_reg[date_i]  <= 0;
                    end
            end
            else begin
                date_reg[0]         <= date_reg[1] | {7'd0, date[0]};
                date_start_reg[0]   <= date_start_reg[1] | {7'd0, date_valid};
                
                date_reg[1]         <= date_reg[2] | {6'd0, date[1], 1'd0};
                date_start_reg[1]   <= date_start_reg[2] | {6'd0, date_valid, 1'd0};
                
                date_reg[2]         <= date_reg[3] | {5'd0, date[2], 2'd0};
                date_start_reg[2]   <= date_start_reg[3] | {5'd0, date_valid, 2'd0};
                
                date_reg[3]         <= date_reg[4] | {4'd0, date[3], 3'd0};
                date_start_reg[3]   <= date_start_reg[4] | {4'd0, date_valid, 3'd0};
                
                date_reg[4]         <= date_reg[5] | {3'd0, date[4], 4'd0};
                date_start_reg[4]   <= date_start_reg[5] | {3'd0, date_valid, 4'd0};
                
                date_reg[5]         <= date_reg[6] | {2'd0, date[5], 5'd0};
                date_start_reg[5]   <= date_start_reg[6] | {2'd0, date_valid, 5'd0};
                
                date_reg[6]         <= date_reg[7] | {1'd0, date[6], 6'd0};
                date_start_reg[6]   <= date_start_reg[7] | {1'd0, date_valid, 6'd0};
                
                date_reg[7]         <= {date[7], 7'd0};
                date_start_reg[7]   <= {date_valid, 7'd0};
            end 
    end
    
assign in       = date_reg[0];
assign in_start = date_start_reg[0];

endmodule
