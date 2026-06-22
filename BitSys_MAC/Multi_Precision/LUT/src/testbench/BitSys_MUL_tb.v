`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 11:04:09 PM
// Design Name: 
// Module Name: BitSys_MUL_tb
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


module BitSys_MUL_tb;

    parameter BIT_1 = 0;
    parameter BIT_2 = 1;
    parameter BIT_4 = 2;
    parameter BIT_8 = 3;

    parameter IN_WIDTH      = 8;
    parameter IN_PRECI      = 2;
    parameter BIT1_EN       = 1;
    parameter OPTIMIZE      = 0;
    parameter REGION_NUM    = 4;
    parameter OUT_WIDTH     = 2*IN_WIDTH;
    
    parameter RANDOM_NUM    = 100000;
    
    reg                                 sys_clk;        // System Clock 
    reg                                 sys_rst_n;      // System Reset
    
    reg     [(IN_PRECI-1):0]            precision;      // Input Precision
    
    reg     [(IN_WIDTH-1):0]            in_0;           // Input 0
    reg     [(IN_WIDTH-1):0]            in_1;           // Input 1
    reg                                 in_valid;
    
    reg                                 mul_rst;        // Reset the MUL
    
    reg                                 is_signed;      // Setting signed/unsigned multiplication
    
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
        
        .mul_rst(mul_rst),              // Reset the MUL
        
        .precision(precision),          // Input Precision
        .is_signed(is_signed),          // Setting signed/unsigned multiplication
            
        .in_0(in_0),                    // Input 0
        .in_1(in_1),                    // Input 1
        .in_valid(in_valid),
        
        .result(result),                // Output of MUL Result
        .result_valid(result_valid)     // Output of MUL Result Valid
    );

    initial 
        begin
            sys_clk     = 1'b0;
            sys_rst_n   = 1'b0;
            
            #100;
            sys_rst_n   = 1'b1;
        end
        
    always #5 sys_clk = !sys_clk;
    
    wire        [1:0]           expected_1bit_output            [(IN_WIDTH-1):0];
    wire        [1:0]           actual_1bit_output              [(IN_WIDTH-1):0];
    genvar expected_bit1_out_i;
    generate
        for (expected_bit1_out_i=0; expected_bit1_out_i<(IN_WIDTH/1); expected_bit1_out_i=expected_bit1_out_i+1)
            begin
                assign expected_1bit_output[expected_bit1_out_i] = {~in_0[expected_bit1_out_i], 1'b1} * {~in_1[expected_bit1_out_i], 1'b1};
                assign actual_1bit_output[expected_bit1_out_i]   = result[((expected_bit1_out_i+1)*2-1):(expected_bit1_out_i*2)];
            end
    endgenerate
    
    wire        [3:0]           expected_2bit_unsigned_output               [(IN_WIDTH/2-1):0];
    wire        [3:0]           actual_2bit_unsigned_output                 [(IN_WIDTH/2-1):0];
    genvar expected_bit2_unsigned_out_i;
    generate
        for (expected_bit2_unsigned_out_i=0; expected_bit2_unsigned_out_i<(IN_WIDTH/2); expected_bit2_unsigned_out_i=expected_bit2_unsigned_out_i+1)
            begin
                assign expected_2bit_unsigned_output[expected_bit2_unsigned_out_i] 
                            = {2'b0, in_0[((expected_bit2_unsigned_out_i+1)*2-1):(expected_bit2_unsigned_out_i*2)]} 
                            * {2'b0, in_1[((expected_bit2_unsigned_out_i+1)*2-1):(expected_bit2_unsigned_out_i*2)]};
                assign actual_2bit_unsigned_output[expected_bit2_unsigned_out_i]
                            = result[((expected_bit2_unsigned_out_i+1)*4-1):(expected_bit2_unsigned_out_i*4)];
            end
    endgenerate
    
    wire        [3:0]           expected_2bit_signed_output                 [(IN_WIDTH/2-1):0];
    wire        [3:0]           actual_2bit_signed_output                   [(IN_WIDTH/2-1):0];
    genvar expected_bit2_signed_out_i;
    generate
        for (expected_bit2_signed_out_i=0; expected_bit2_signed_out_i<(IN_WIDTH/2); expected_bit2_signed_out_i=expected_bit2_signed_out_i+1)
            begin
                assign expected_2bit_signed_output[expected_bit2_signed_out_i] 
                            = {{(2){in_0[(expected_bit2_signed_out_i+1)*2-1]}}, in_0[((expected_bit2_signed_out_i+1)*2-1):(expected_bit2_signed_out_i*2)]} 
                            * {{(2){in_1[(expected_bit2_signed_out_i+1)*2-1]}}, in_1[((expected_bit2_signed_out_i+1)*2-1):(expected_bit2_signed_out_i*2)]};
                assign actual_2bit_signed_output[expected_bit2_signed_out_i]
                            = result[((expected_bit2_signed_out_i+1)*4-1):(expected_bit2_signed_out_i*4)];
            end
    endgenerate
    
    wire        [7:0]           expected_4bit_unsigned_output               [(IN_WIDTH/4-1):0];
    wire        [7:0]           actual_4bit_unsigned_output                 [(IN_WIDTH/4-1):0];
    genvar expected_bit4_unsigned_out_i;
    generate
        for (expected_bit4_unsigned_out_i=0; expected_bit4_unsigned_out_i<(IN_WIDTH/4); expected_bit4_unsigned_out_i=expected_bit4_unsigned_out_i+1)
            begin
                assign expected_4bit_unsigned_output[expected_bit4_unsigned_out_i] 
                            = {4'b0, in_0[((expected_bit4_unsigned_out_i+1)*4-1):(expected_bit4_unsigned_out_i*4)]} 
                            * {4'b0, in_1[((expected_bit4_unsigned_out_i+1)*4-1):(expected_bit4_unsigned_out_i*4)]};
                assign actual_4bit_unsigned_output[expected_bit4_unsigned_out_i]
                            = result[((expected_bit4_unsigned_out_i+1)*8-1):(expected_bit4_unsigned_out_i*8)];
            end
    endgenerate
    
    wire        [7:0]           expected_4bit_signed_output                 [(IN_WIDTH/4-1):0];
    wire        [7:0]           actual_4bit_signed_output                   [(IN_WIDTH/4-1):0];
    genvar expected_bit4_signed_out_i;
    generate
        for (expected_bit4_signed_out_i=0; expected_bit4_signed_out_i<(IN_WIDTH/4); expected_bit4_signed_out_i=expected_bit4_signed_out_i+1)
            begin
                assign expected_4bit_signed_output[expected_bit4_signed_out_i] 
                            = {{(4){in_0[(expected_bit4_signed_out_i+1)*4-1]}}, in_0[((expected_bit4_signed_out_i+1)*4-1):(expected_bit4_signed_out_i*4)]} 
                            * {{(4){in_1[(expected_bit4_signed_out_i+1)*4-1]}}, in_1[((expected_bit4_signed_out_i+1)*4-1):(expected_bit4_signed_out_i*4)]};
                assign actual_4bit_signed_output[expected_bit4_signed_out_i]
                            = result[((expected_bit4_signed_out_i+1)*8-1):(expected_bit4_signed_out_i*8)];
            end
    endgenerate
    
    wire        [15:0]          expected_8bit_unsigned_output               [(IN_WIDTH/8-1):0];
    wire        [15:0]          actual_8bit_unsigned_output                 [(IN_WIDTH/8-1):0];
    genvar expected_bit8_unsigned_out_i;
    generate
        for (expected_bit8_unsigned_out_i=0; expected_bit8_unsigned_out_i<(IN_WIDTH/8); expected_bit8_unsigned_out_i=expected_bit8_unsigned_out_i+1)
            begin
                assign expected_8bit_unsigned_output[expected_bit8_unsigned_out_i] 
                            = {8'b0, in_0[((expected_bit8_unsigned_out_i+1)*8-1):(expected_bit8_unsigned_out_i*8)]} 
                            * {8'b0, in_1[((expected_bit8_unsigned_out_i+1)*8-1):(expected_bit8_unsigned_out_i*8)]};
                assign actual_8bit_unsigned_output[expected_bit8_unsigned_out_i]
                            = result[((expected_bit8_unsigned_out_i+1)*16-1):(expected_bit8_unsigned_out_i*16)];
            end
    endgenerate
    
    wire        [15:0]           expected_8bit_signed_output                 [(IN_WIDTH/8-1):0];
    wire        [15:0]           actual_8bit_signed_output                   [(IN_WIDTH/8-1):0];
    genvar expected_bit8_signed_out_i;
    generate
        for (expected_bit8_signed_out_i=0; expected_bit8_signed_out_i<(IN_WIDTH/8); expected_bit8_signed_out_i=expected_bit8_signed_out_i+1)
            begin
                assign expected_8bit_signed_output[expected_bit8_signed_out_i] 
                            = {{(8){in_0[(expected_bit8_signed_out_i+1)*8-1]}}, in_0[((expected_bit8_signed_out_i+1)*8-1):(expected_bit8_signed_out_i*8)]} 
                            * {{(8){in_1[(expected_bit8_signed_out_i+1)*8-1]}}, in_1[((expected_bit8_signed_out_i+1)*8-1):(expected_bit8_signed_out_i*8)]};
                assign actual_8bit_signed_output[expected_bit8_signed_out_i]
                            = result[((expected_bit8_signed_out_i+1)*16-1):(expected_bit8_signed_out_i*16)];
            end
    endgenerate
    
    integer test_i;
    reg     [7:0]   test_step;
    reg     [31:0]  cnt;
    reg     [31:0]  error_cnt;
    always @(negedge sys_rst_n or posedge sys_clk) 
        begin
            if (!sys_rst_n)
                begin
                    test_step           <= 15;
                    cnt                 <= 0;
                    error_cnt           <= 0;
                    precision           <= BIT_1;
                    in_0                <= 0;
                    in_1                <= 0;
                    in_valid            <= 0;
                    mul_rst             <= 0;
                    is_signed           <= 0;
                    test_i              <= 0;
                end
                else begin
                    case (test_step)
                    
                        15: begin
                                $display("\n=== Bit 1 Test ===");
                                test_step       <= 0; // Move to next step to wait for config done
                            end
        
                        0:  begin
                                precision       <= BIT_1;
                                in_0            <= $random & 8'hFF;
                                in_1            <= $random & 8'hFF;
                                in_valid        <= 1;
                                mul_rst         <= 0;
                                is_signed       <= 1;
                                test_step       <= 1; // Move to next step to wait for config done
                            end
        
                        1:  begin
                                precision       <= BIT_1;
                                in_0            <= in_0;
                                in_1            <= in_1;
                                in_valid        <= 0;
                                is_signed       <= 1;
                                
                                if (result_valid) 
                                    begin
                                        mul_rst             <= 1;
                                        for (test_i=0; test_i<(IN_WIDTH/1); test_i=test_i+1)
                                            begin
                                                if (expected_1bit_output[test_i]!=actual_1bit_output[test_i])
                                                    begin
                                                        error_cnt       <= error_cnt+1;
                                                        $display("\n    Input 0: %b", in_0);
                                                        $display("    Input 1: %b", in_1);
                                                        $display("    Expect ", expected_1bit_output[test_i], " in position.", test_i, ", but got ", actual_1bit_output[test_i], "\n");
                                                    end
                                            end
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 0; // Move to next step to load weights
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 2; // Move to next step to load weights
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                                $display("\n=== Bit 2 Unsigned Test ===");
                                            end
                                    end
                                    else begin
                                        mul_rst         <= 0;
                                        test_step       <= 1; // Stay in this step until config done
                                    end
                            end
        
                        2:  begin
                                precision       <= BIT_2;
                                in_0            <= $random & 8'hFF;
                                in_1            <= $random & 8'hFF;
                                in_valid        <= 1;
                                mul_rst         <= 0;
                                is_signed       <= 0;
                                test_step       <= 3; // Move to next step to wait for config done
                            end
        
                        3:  begin
                                precision       <= BIT_2;
                                in_0            <= in_0;
                                in_1            <= in_1;
                                in_valid        <= 0;
                                is_signed       <= 0;
                                
                                if (result_valid) 
                                    begin
                                        mul_rst             <= 1;
                                        for (test_i=0; test_i<(IN_WIDTH/2); test_i=test_i+1)
                                            begin
                                                if (expected_2bit_unsigned_output[test_i]!=actual_2bit_unsigned_output[test_i])
                                                    begin
                                                        error_cnt       <= error_cnt+1;
                                                        $display("\n    Input 0: %b", in_0);
                                                        $display("    Input 1: %b", in_1);
                                                        $display("    Expect ", expected_2bit_unsigned_output[test_i], " in position.", test_i, ", but got ", actual_2bit_unsigned_output[test_i], "\n");
                                                    end
                                            end
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 2; // Move to next step to load weights
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 4; // Move to next step to load weights  
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                                $display("\n=== Bit 2 Signed Test ===");
                                            end
                                    end
                                    else begin
                                        mul_rst         <= 0;
                                        test_step       <= 3; // Stay in this step until config done
                                    end
                            end
        
                        4:  begin
                                precision       <= BIT_2;
                                in_0            <= $random & 8'hFF;
                                in_1            <= $random & 8'hFF;
                                in_valid        <= 1;
                                mul_rst         <= 0;
                                is_signed       <= 1;
                                test_step       <= 5; // Move to next step to wait for config done
                            end
        
                        5:  begin
                                precision       <= BIT_2;
                                in_0            <= in_0;
                                in_1            <= in_1;
                                in_valid        <= 0;
                                is_signed       <= 1;
                                
                                if (result_valid) 
                                    begin
                                        mul_rst             <= 1;
                                        for (test_i=0; test_i<(IN_WIDTH/2); test_i=test_i+1)
                                            begin
                                                if (expected_2bit_signed_output[test_i]!=actual_2bit_signed_output[test_i])
                                                    begin
                                                        error_cnt       <= error_cnt+1;
                                                        $display("\n    Input 0: %b", in_0);
                                                        $display("    Input 1: %b", in_1);
                                                        $display("    Expect ", expected_2bit_signed_output[test_i], " in position.", test_i, ", but got ", actual_2bit_signed_output[test_i], "\n");
                                                    end
                                            end
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 4; // Move to next step to load weights
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 6; // Move to next step to load weights
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                                $display("\n=== Bit 4 Unsigned Test ===");
                                            end
                                    end
                                    else begin
                                        mul_rst         <= 0;
                                        test_step       <= 5; // Stay in this step until config done
                                    end
                            end
        
                        6:  begin
                                precision       <= BIT_4;
                                in_0            <= $random & 8'hFF;
                                in_1            <= $random & 8'hFF;
                                in_valid        <= 1;
                                mul_rst         <= 0;
                                is_signed       <= 0;
                                test_step       <= 7; // Move to next step to wait for config done
                            end
        
                        7:  begin
                                precision       <= BIT_4;
                                in_0            <= in_0;
                                in_1            <= in_1;
                                in_valid        <= 0;
                                is_signed       <= 0;
                                
                                if (result_valid) 
                                    begin
                                        mul_rst             <= 1;
                                        for (test_i=0; test_i<(IN_WIDTH/4); test_i=test_i+1)
                                            begin
                                                if (expected_4bit_unsigned_output[test_i]!=actual_4bit_unsigned_output[test_i])
                                                    begin
                                                        error_cnt       <= error_cnt+1;
                                                        $display("\n    Input 0: %b", in_0);
                                                        $display("    Input 1: %b", in_1);
                                                        $display("    Expect ", expected_4bit_unsigned_output[test_i], " in position.", test_i, ", but got ", actual_4bit_unsigned_output[test_i], "\n");
                                                    end
                                            end
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 6; // Move to next step to load weights
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 8; // Move to next step to load weights
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                                $display("\n=== Bit 4 Signed Test ===");
                                            end
                                    end
                                    else begin
                                        mul_rst         <= 0;
                                        test_step       <= 7; // Stay in this step until config done
                                    end
                            end
        
                        8:  begin
                                precision       <= BIT_4;
                                in_0            <= $random & 8'hFF;
                                in_1            <= $random & 8'hFF;
                                in_valid        <= 1;
                                mul_rst         <= 0;
                                is_signed       <= 1;
                                test_step       <= 9; // Move to next step to wait for config done
                            end
        
                        9:  begin
                                precision       <= BIT_4;
                                in_0            <= in_0;
                                in_1            <= in_1;
                                in_valid        <= 0;
                                is_signed       <= 1;
                                
                                if (result_valid) 
                                    begin
                                        mul_rst             <= 1;
                                        for (test_i=0; test_i<(IN_WIDTH/4); test_i=test_i+1)
                                            begin
                                                if (expected_4bit_signed_output[test_i]!=actual_4bit_signed_output[test_i])
                                                    begin
                                                        error_cnt       <= error_cnt+1;
                                                        $display("\n    Input 0: %b", in_0);
                                                        $display("    Input 1: %b", in_1);
                                                        $display("    Expect ", expected_4bit_signed_output[test_i], " in position.", test_i, ", but got ", actual_4bit_signed_output[test_i], "\n");
                                                    end
                                            end
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 8; // Move to next step to load weights
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 10; // Move to next step to load weights
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                                $display("\n=== Bit 8 Unsigned Test ===");
                                            end
                                    end
                                    else begin
                                        mul_rst         <= 0;
                                        test_step       <= 9; // Stay in this step until config done
                                    end
                            end
        
                        10: begin
                                precision       <= BIT_8;
                                in_0            <= $random & 8'hFF;
                                in_1            <= $random & 8'hFF;
                                in_valid        <= 1;
                                mul_rst         <= 0;
                                is_signed       <= 0;
                                test_step       <= 11; // Move to next step to wait for config done
                            end
        
                        11: begin
                                precision       <= BIT_8;
                                in_0            <= in_0;
                                in_1            <= in_1;
                                in_valid        <= 0;
                                is_signed       <= 0;
                                
                                if (result_valid) 
                                    begin
                                        mul_rst             <= 1;
                                        for (test_i=0; test_i<(IN_WIDTH/8); test_i=test_i+1)
                                            begin
                                                if (expected_8bit_unsigned_output[test_i]!=actual_8bit_unsigned_output[test_i])
                                                    begin
                                                        error_cnt       <= error_cnt+1;
                                                        $display("\n    Input 0: %b", in_0);
                                                        $display("    Input 1: %b", in_1);
                                                        $display("    Expect ", expected_8bit_unsigned_output[test_i], " in position.", test_i, ", but got ", actual_8bit_unsigned_output[test_i], "\n");
                                                    end
                                            end
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 10; // Move to next step to load weights
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 12; // Move to next step to load weights
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                                $display("\n=== Bit 8 Signed Test ===");
                                            end
                                    end
                                    else begin
                                        mul_rst         <= 0;
                                        test_step       <= 11; // Stay in this step until config done
                                    end
                            end
        
                        12: begin
                                precision       <= BIT_8;
                                in_0            <= $random & 8'hFF;
                                in_1            <= $random & 8'hFF;
                                in_valid        <= 1;
                                mul_rst         <= 0;
                                is_signed       <= 1;
                                test_step       <= 13; // Move to next step to wait for config done
                            end
        
                        13: begin
                                precision       <= BIT_8;
                                in_0            <= in_0;
                                in_1            <= in_1;
                                in_valid        <= 0;
                                is_signed       <= 1;
                                
                                if (result_valid) 
                                    begin
                                        mul_rst             <= 1;
                                        for (test_i=0; test_i<(IN_WIDTH/8); test_i=test_i+1)
                                            begin
                                                if (expected_8bit_signed_output[test_i]!=actual_8bit_signed_output[test_i])
                                                    begin
                                                        error_cnt       <= error_cnt+1;
                                                        $display("\n    Input 0: %b", in_0);
                                                        $display("    Input 1: %b", in_1);
                                                        $display("    Expect ", expected_8bit_signed_output[test_i], " in position.", test_i, ", but got ", actual_8bit_signed_output[test_i], "\n");
                                                    end
                                            end
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 12; // Move to next step to load weights
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 14; // Move to next step to load weights
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                            end
                                    end
                                    else begin
                                        mul_rst         <= 0;
                                        test_step       <= 13; // Stay in this step until config done
                                    end
                            end
        
                        14: begin
                                $display("\n=== Test Finished ===");
                                $finish;
                            end
        
                    endcase
                end
        end 
endmodule
