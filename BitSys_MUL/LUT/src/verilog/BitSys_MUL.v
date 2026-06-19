`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 11:00:41 PM
// Design Name: 
// Module Name: BitSys_MUL
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


module BitSys_MUL
#(
    parameter IN_WIDTH      = 8,
    parameter IN_PRECI      = 2,
    parameter BIT1_EN       = 1,
    parameter OPTIMIZE      = 0,
    parameter REGION_NUM    = 4,
    parameter OUT_WIDTH     = 2*IN_WIDTH
)
(
    input   wire                                sys_clk,        // System Clock 
    input   wire                                sys_rst_n,      // System Reset
    
    input   wire    [(IN_PRECI-1):0]            precision,      // Input Precision
    
    input   wire    [(IN_WIDTH-1):0]            in_0,           // Input 0
    input   wire    [(IN_WIDTH-1):0]            in_1,           // Input 1
    input   wire                                in_valid,
    
    input   wire                                rst,            // Reset the MUL
    
    input   wire                                is_signed,      // Setting signed/unsigned multiplication
    
    output  wire    [(OUT_WIDTH-1):0]           result,         // Output of MUL Result
    output  wire                                result_valid    // Output of MUL Result Valid
);

wire    [(IN_WIDTH-1):0]            in_0_loaded;
wire    [(IN_WIDTH-1):0]            in_1_loaded;
wire    [(IN_WIDTH-1):0]            in_0_start_loaded;
wire    [(IN_WIDTH-1):0]            in_1_start_loaded;

BitwiseSA_DataLoader 
#( 
    .IN_WIDTH(IN_WIDTH) 
)
BitwiseSA_DataLoader_0
(
    .sys_clk(sys_clk),             
    .sys_rst_n(sys_rst_n),        
        
    .date(in_0),
    .date_valid(in_valid),
    
    .rst(rst),
    
    .in(in_0_loaded),            
    .in_start(in_0_start_loaded)  
);

BitwiseSA_DataLoader 
#( 
    .IN_WIDTH(IN_WIDTH) 
)
BitwiseSA_DataLoader_1
(
    .sys_clk(sys_clk),             
    .sys_rst_n(sys_rst_n),        
        
    .date(in_1),
    .date_valid(in_valid),
    
    .rst(rst),
    
    .in(in_1_loaded),            
    .in_start(in_1_start_loaded)  
);

BitwiseSA_LUT
#(
    .IN_WIDTH(IN_WIDTH),
    .IN_PRECI(IN_PRECI),
    .REGION_NUM(REGION_NUM)
)
BitwiseSA
(
    .sys_clk(sys_clk),                  // System Clock 
    .sys_rst_n(sys_rst_n),              // System Reset
    
    .precision(precision),              // Input Precision
    
    .in_0(in_0_loaded),                 // Input 0
    .in_1(in_1_loaded),                 // Input 1
    .in_0_start(in_0_start_loaded),     
    .in_1_start(in_1_start_loaded),     // Start Signal control the working statement
                                        // If start is 1, systolic working
                                        // If start is 0, systolic holds the current statement and pauses processing.
    
    .is_signed(is_signed),              // Setting signed/unsigned multiplication
    
    .result(result),                    // Output of MUL Result
    .result_valid(result_valid)         // Output of MUL Result Valid
);

endmodule