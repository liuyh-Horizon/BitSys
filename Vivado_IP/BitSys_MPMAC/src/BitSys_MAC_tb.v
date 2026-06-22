`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 02:30:57 AM
// Design Name: 
// Module Name: BitSys_MAC_tb
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


module BitSys_MAC_tb;

    parameter BIT_1 = 0;
    parameter BIT_2 = 1;
    parameter BIT_4 = 2;
    parameter BIT_8 = 3;

    parameter IN_WIDTH      = 8;
    parameter IN_PRECI      = 2;
    parameter OUT_WIDTH     = 2*IN_WIDTH;
    parameter ACCU_LENGTH   = 16;
    parameter ACCU_WIDTH    = OUT_WIDTH + ACCU_LENGTH;
    
    parameter RANDOM_NUM    = 100000;
    
    reg                                 sys_clk;        // System Clock 
    reg                                 sys_rst_n;      // System Reset
    
    reg                                 mac_rst;        // Reset the MAC
    
    reg     [(IN_PRECI-1):0]            precision;      // Input Precision
    reg                                 is_signed;      // Setting signed/unsigned multiplication
    reg     [(ACCU_LENGTH-1):0]         accu_length;
    
    reg     [(IN_WIDTH-1):0]            in_0;           // Input 0
    reg     [(IN_WIDTH-1):0]            in_1;           // Input 1
    reg                                 in_valid;
    
    
    
    wire    [(ACCU_WIDTH-1):0]          mac_out;        // Output of MAC Result
    wire                                mac_out_valid;  // Output of MAC Result Valid
    
    BitSys_MAC
    #(
        .IN_WIDTH(IN_WIDTH),
        .IN_PRECI(IN_PRECI),
        .ACCU_LENGTH(ACCU_LENGTH)
    )
    BitSys_MAC_inst
    (
        .sys_clk(sys_clk),              // System Clock 
        .sys_rst_n(sys_rst_n),          // System Reset
        
        .mac_rst(mac_rst),              // Reset the MAC
        
        .precision(precision),          // Input Precision
        .is_signed(is_signed),          // Setting signed/unsigned multiplication
        .accu_length(accu_length),
            
        .in_0(in_0),                    // Input 0
        .in_1(in_1),                    // Input 1
        .in_valid(in_valid),
        
        .mac_out(mac_out),              // Output of MAC Result
        .mac_out_valid(mac_out_valid)   // Output of MAC Result Valid
    );

    initial 
        begin
            sys_clk     = 1'b0;
            sys_rst_n   = 1'b0;
            
            #100;
            sys_rst_n   = 1'b1;
        end
        
    always #5 sys_clk = !sys_clk;
    
    /******** BIT 1 ********/
    
    wire        [1:0]           expected_1bit_output            [(IN_WIDTH-1):0];
    genvar expected_bit1_out_i;
    generate
        for (expected_bit1_out_i=0; expected_bit1_out_i<(IN_WIDTH/1); expected_bit1_out_i=expected_bit1_out_i+1)
            begin
                assign expected_1bit_output[expected_bit1_out_i] = {~in_0[expected_bit1_out_i], 1'b1} * {~in_1[expected_bit1_out_i], 1'b1};
            end
    endgenerate
    
    reg         [(ACCU_WIDTH-1):0]      expect_1bit_output_sum;
    integer expected_bit1_sum_i;
    always @(*) 
        begin
            expect_1bit_output_sum = 0;
            for (expected_bit1_sum_i=0; expected_bit1_sum_i<IN_WIDTH; expected_bit1_sum_i=expected_bit1_sum_i+1) 
                begin
                    expect_1bit_output_sum = expect_1bit_output_sum + 
                                             {{(ACCU_WIDTH-2){expected_1bit_output[expected_bit1_sum_i][1]}}, expected_1bit_output[expected_bit1_sum_i]};
                end
        end
        
    reg         [(ACCU_WIDTH-1):0]      expect_1bit_output;
    always @(negedge sys_rst_n or posedge sys_clk) 
        begin
            if ((!sys_rst_n) | mac_rst)
                begin
                    expect_1bit_output <= 0;
                end
                else begin
                    if (in_valid)
                        begin
                            expect_1bit_output <= expect_1bit_output + expect_1bit_output_sum;
                        end
                        else begin
                            expect_1bit_output <= expect_1bit_output;
                        end
                end
        end
    
    /******** BIT 2 Unsigned ********/
    
    wire        [3:0]           expected_2bit_unsigned_output               [(IN_WIDTH/2-1):0];
    genvar expected_bit2_unsigned_out_i;
    generate
        for (expected_bit2_unsigned_out_i=0; expected_bit2_unsigned_out_i<(IN_WIDTH/2); expected_bit2_unsigned_out_i=expected_bit2_unsigned_out_i+1)
            begin
                assign expected_2bit_unsigned_output[expected_bit2_unsigned_out_i] 
                            = {2'b0, in_0[((expected_bit2_unsigned_out_i+1)*2-1):(expected_bit2_unsigned_out_i*2)]} 
                            * {2'b0, in_1[((expected_bit2_unsigned_out_i+1)*2-1):(expected_bit2_unsigned_out_i*2)]};
            end
    endgenerate
    
    reg         [(ACCU_WIDTH-1):0]      expect_2bit_unsigned_output_sum;
    integer expected_bit2_unsigned_sum_i;
    always @(*) 
        begin
            expect_2bit_unsigned_output_sum = 0;
            for (expected_bit2_unsigned_sum_i=0; expected_bit2_unsigned_sum_i<IN_WIDTH/2; expected_bit2_unsigned_sum_i=expected_bit2_unsigned_sum_i+1) 
                begin
                    expect_2bit_unsigned_output_sum = expect_2bit_unsigned_output_sum + 
                                             {{(ACCU_WIDTH-4){1'b0}}, expected_2bit_unsigned_output[expected_bit2_unsigned_sum_i]};
                end
        end
        
    reg         [(ACCU_WIDTH-1):0]      expect_2bit_unsigend_output;
    always @(negedge sys_rst_n or posedge sys_clk) 
        begin
            if ((!sys_rst_n) | mac_rst)
                begin
                    expect_2bit_unsigend_output <= 0;
                end
                else begin
                    if (in_valid)
                        begin
                            expect_2bit_unsigend_output <= expect_2bit_unsigend_output + expect_2bit_unsigned_output_sum;
                        end
                        else begin
                            expect_2bit_unsigend_output <= expect_2bit_unsigend_output;
                        end
                end
        end
    
    /******** BIT 2 Signed ********/
    
    wire        [3:0]           expected_2bit_signed_output                 [(IN_WIDTH/2-1):0];
    genvar expected_bit2_signed_out_i;
    generate
        for (expected_bit2_signed_out_i=0; expected_bit2_signed_out_i<(IN_WIDTH/2); expected_bit2_signed_out_i=expected_bit2_signed_out_i+1)
            begin
                assign expected_2bit_signed_output[expected_bit2_signed_out_i] 
                            = {{(2){in_0[(expected_bit2_signed_out_i+1)*2-1]}}, in_0[((expected_bit2_signed_out_i+1)*2-1):(expected_bit2_signed_out_i*2)]} 
                            * {{(2){in_1[(expected_bit2_signed_out_i+1)*2-1]}}, in_1[((expected_bit2_signed_out_i+1)*2-1):(expected_bit2_signed_out_i*2)]};
            end
    endgenerate
    
    reg         [(ACCU_WIDTH-1):0]      expect_2bit_signed_output_sum;
    integer expected_bit2_signed_sum_i;
    always @(*) 
        begin
            expect_2bit_signed_output_sum = 0;
            for (expected_bit2_signed_sum_i=0; expected_bit2_signed_sum_i<IN_WIDTH/2; expected_bit2_signed_sum_i=expected_bit2_signed_sum_i+1) 
                begin
                    expect_2bit_signed_output_sum = expect_2bit_signed_output_sum + 
                                             {{(ACCU_WIDTH-4){expected_2bit_signed_output[expected_bit2_signed_sum_i][3]}}, expected_2bit_signed_output[expected_bit2_signed_sum_i]};
                end
        end
        
    reg         [(ACCU_WIDTH-1):0]      expect_2bit_sigend_output;
    always @(negedge sys_rst_n or posedge sys_clk) 
        begin
            if ((!sys_rst_n) | mac_rst)
                begin
                    expect_2bit_sigend_output <= 0;
                end
                else begin
                    if (in_valid)
                        begin
                            expect_2bit_sigend_output <= expect_2bit_sigend_output + expect_2bit_signed_output_sum;
                        end
                        else begin
                            expect_2bit_sigend_output <= expect_2bit_sigend_output;
                        end
                end
        end
    
    /******** BIT 4 Unsigned ********/
    
    wire        [7:0]           expected_4bit_unsigned_output               [(IN_WIDTH/4-1):0];
    genvar expected_bit4_unsigned_out_i;
    generate
        for (expected_bit4_unsigned_out_i=0; expected_bit4_unsigned_out_i<(IN_WIDTH/4); expected_bit4_unsigned_out_i=expected_bit4_unsigned_out_i+1)
            begin
                assign expected_4bit_unsigned_output[expected_bit4_unsigned_out_i] 
                            = {4'b0, in_0[((expected_bit4_unsigned_out_i+1)*4-1):(expected_bit4_unsigned_out_i*4)]} 
                            * {4'b0, in_1[((expected_bit4_unsigned_out_i+1)*4-1):(expected_bit4_unsigned_out_i*4)]};
            end
    endgenerate
    
    reg         [(ACCU_WIDTH-1):0]      expect_4bit_unsigned_output_sum;
    integer expected_bit4_unsigned_sum_i;
    always @(*) 
        begin
            expect_4bit_unsigned_output_sum = 0;
            for (expected_bit4_unsigned_sum_i=0; expected_bit4_unsigned_sum_i<IN_WIDTH/4; expected_bit4_unsigned_sum_i=expected_bit4_unsigned_sum_i+1) 
                begin
                    expect_4bit_unsigned_output_sum = expect_4bit_unsigned_output_sum + 
                                             {{(ACCU_WIDTH-8){1'b0}}, expected_4bit_unsigned_output[expected_bit4_unsigned_sum_i]};
                end
        end
        
    reg         [(ACCU_WIDTH-1):0]      expect_4bit_unsigend_output;
    always @(negedge sys_rst_n or posedge sys_clk) 
        begin
            if ((!sys_rst_n) | mac_rst)
                begin
                    expect_4bit_unsigend_output <= 0;
                end
                else begin
                    if (in_valid)
                        begin
                            expect_4bit_unsigend_output <= expect_4bit_unsigend_output + expect_4bit_unsigned_output_sum;
                        end
                        else begin
                            expect_4bit_unsigend_output <= expect_4bit_unsigend_output;
                        end
                end
        end
    
    /******** BIT 4 Signed ********/
    
    wire        [7:0]           expected_4bit_signed_output                 [(IN_WIDTH/4-1):0];
    genvar expected_bit4_signed_out_i;
    generate
        for (expected_bit4_signed_out_i=0; expected_bit4_signed_out_i<(IN_WIDTH/4); expected_bit4_signed_out_i=expected_bit4_signed_out_i+1)
            begin
                assign expected_4bit_signed_output[expected_bit4_signed_out_i] 
                            = {{(4){in_0[(expected_bit4_signed_out_i+1)*4-1]}}, in_0[((expected_bit4_signed_out_i+1)*4-1):(expected_bit4_signed_out_i*4)]} 
                            * {{(4){in_1[(expected_bit4_signed_out_i+1)*4-1]}}, in_1[((expected_bit4_signed_out_i+1)*4-1):(expected_bit4_signed_out_i*4)]};
            end
    endgenerate
    
    reg         [(ACCU_WIDTH-1):0]      expect_4bit_signed_output_sum;
    integer expected_bit4_signed_sum_i;
    always @(*) 
        begin
            expect_4bit_signed_output_sum = 0;
            for (expected_bit4_signed_sum_i=0; expected_bit4_signed_sum_i<IN_WIDTH/4; expected_bit4_signed_sum_i=expected_bit4_signed_sum_i+1) 
                begin
                    expect_4bit_signed_output_sum = expect_4bit_signed_output_sum + 
                                             {{(ACCU_WIDTH-8){expected_4bit_signed_output[expected_bit4_signed_sum_i][7]}}, expected_4bit_signed_output[expected_bit4_signed_sum_i]};
                end
        end
        
    reg         [(ACCU_WIDTH-1):0]      expect_4bit_sigend_output;
    always @(negedge sys_rst_n or posedge sys_clk) 
        begin
            if ((!sys_rst_n) | mac_rst)
                begin
                    expect_4bit_sigend_output <= 0;
                end
                else begin
                    if (in_valid)
                        begin
                            expect_4bit_sigend_output <= expect_4bit_sigend_output + expect_4bit_signed_output_sum;
                        end
                        else begin
                            expect_4bit_sigend_output <= expect_4bit_sigend_output;
                        end
                end
        end
    
    /******** BIT 8 Unsigned ********/
    
    wire        [15:0]          expected_8bit_unsigned_output               [(IN_WIDTH/8-1):0];
    genvar expected_bit8_unsigned_out_i;
    generate
        for (expected_bit8_unsigned_out_i=0; expected_bit8_unsigned_out_i<(IN_WIDTH/8); expected_bit8_unsigned_out_i=expected_bit8_unsigned_out_i+1)
            begin
                assign expected_8bit_unsigned_output[expected_bit8_unsigned_out_i] 
                            = {8'b0, in_0[((expected_bit8_unsigned_out_i+1)*8-1):(expected_bit8_unsigned_out_i*8)]} 
                            * {8'b0, in_1[((expected_bit8_unsigned_out_i+1)*8-1):(expected_bit8_unsigned_out_i*8)]};
            end
    endgenerate
    
    reg         [(ACCU_WIDTH-1):0]      expect_8bit_unsigned_output_sum;
    integer expected_bit8_unsigned_sum_i;
    always @(*) 
        begin
            expect_8bit_unsigned_output_sum = 0;
            for (expected_bit8_unsigned_sum_i=0; expected_bit8_unsigned_sum_i<IN_WIDTH/8; expected_bit8_unsigned_sum_i=expected_bit8_unsigned_sum_i+1) 
                begin
                    expect_8bit_unsigned_output_sum = expect_8bit_unsigned_output_sum + 
                                             {{(ACCU_WIDTH-16){1'b0}}, expected_8bit_unsigned_output[expected_bit8_unsigned_sum_i]};
                end
        end
        
    reg         [(ACCU_WIDTH-1):0]      expect_8bit_unsigend_output;
    always @(negedge sys_rst_n or posedge sys_clk) 
        begin
            if ((!sys_rst_n) | mac_rst)
                begin
                    expect_8bit_unsigend_output <= 0;
                end
                else begin
                    if (in_valid)
                        begin
                            expect_8bit_unsigend_output <= expect_8bit_unsigend_output + expect_8bit_unsigned_output_sum;
                        end
                        else begin
                            expect_8bit_unsigend_output <= expect_8bit_unsigend_output;
                        end
                end
        end
    
    /******** BIT 8 Signed ********/
    
    wire        [15:0]           expected_8bit_signed_output                 [(IN_WIDTH/8-1):0];
    genvar expected_bit8_signed_out_i;
    generate
        for (expected_bit8_signed_out_i=0; expected_bit8_signed_out_i<(IN_WIDTH/8); expected_bit8_signed_out_i=expected_bit8_signed_out_i+1)
            begin
                assign expected_8bit_signed_output[expected_bit8_signed_out_i] 
                            = {{(8){in_0[(expected_bit8_signed_out_i+1)*8-1]}}, in_0[((expected_bit8_signed_out_i+1)*8-1):(expected_bit8_signed_out_i*8)]} 
                            * {{(8){in_1[(expected_bit8_signed_out_i+1)*8-1]}}, in_1[((expected_bit8_signed_out_i+1)*8-1):(expected_bit8_signed_out_i*8)]};
            end
    endgenerate
    
    reg         [(ACCU_WIDTH-1):0]      expect_8bit_signed_output_sum;
    integer expected_bit8_signed_sum_i;
    always @(*) 
        begin
            expect_8bit_signed_output_sum = 0;
            for (expected_bit8_signed_sum_i=0; expected_bit8_signed_sum_i<IN_WIDTH/8; expected_bit8_signed_sum_i=expected_bit8_signed_sum_i+1) 
                begin
                    expect_8bit_signed_output_sum = expect_8bit_signed_output_sum + 
                                             {{(ACCU_WIDTH-16){expected_8bit_signed_output[expected_bit8_signed_sum_i][15]}}, expected_8bit_signed_output[expected_bit8_signed_sum_i]};
                end
        end
        
    reg         [(ACCU_WIDTH-1):0]      expect_8bit_sigend_output;
    always @(negedge sys_rst_n or posedge sys_clk) 
        begin
            if ((!sys_rst_n) | mac_rst)
                begin
                    expect_8bit_sigend_output <= 0;
                end
                else begin
                    if (in_valid)
                        begin
                            expect_8bit_sigend_output <= expect_8bit_sigend_output + expect_8bit_signed_output_sum;
                        end
                        else begin
                            expect_8bit_sigend_output <= expect_8bit_sigend_output;
                        end
                end
        end
    
    integer test_i;
    reg     [7:0]   test_step;
    reg     [31:0]  cnt;
    reg     [31:0]  error_cnt;
    reg     [31:0]  accu_cnt;
    always @(negedge sys_rst_n or posedge sys_clk) 
        begin
            if (!sys_rst_n)
                begin
                    test_step           <= 15;
                    cnt                 <= 0;
                    accu_cnt            <= 0;
                    error_cnt           <= 0;
                    precision           <= BIT_1;
                    accu_length         <= 1024;
                    in_0                <= 0;
                    in_1                <= 0;
                    in_valid            <= 0;
                    mac_rst             <= 0;
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
                                if (accu_cnt<accu_length)
                                    begin
                                        precision       <= BIT_1;
                                        in_0            <= $random & 8'hFF;
                                        in_1            <= $random & 8'hFF;
                                        in_valid        <= 1;
                                        mac_rst         <= 0;
                                        is_signed       <= 1;
                                        accu_cnt        <= accu_cnt+1;
                                        test_step       <= 0; 
                                    end
                                    else begin
                                        precision       <= BIT_1;
                                        in_0            <= in_0;
                                        in_1            <= in_1;
                                        in_valid        <= 0;
                                        mac_rst         <= 0;
                                        is_signed       <= 1;
                                        accu_cnt        <= 0;
                                        test_step       <= 1; 
                                    end
                            end
        
                        1:  begin
                                if (mac_out_valid) 
                                    begin
                                        mac_rst             <= 1;
                                        
                                        if (mac_out!=expect_1bit_output)
                                            begin
                                                error_cnt       <= error_cnt+1;
                                                $display("\n    Expect ", expect_1bit_output, ", but got ", mac_out, "\n");
                                            end
                                            
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 0; 
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 2; 
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                                $display("\n=== Bit 2 Unsigned Test ===");
                                            end
                                    end
                                    else begin
                                        mac_rst         <= 0;
                                        test_step       <= 1; 
                                    end
                            end
        
                        2:  begin
                                if (accu_cnt<accu_length)
                                    begin
                                        precision       <= BIT_2;
                                        in_0            <= $random & 8'hFF;
                                        in_1            <= $random & 8'hFF;
                                        in_valid        <= 1;
                                        mac_rst         <= 0;
                                        is_signed       <= 0;
                                        accu_cnt        <= accu_cnt+1;
                                        test_step       <= 2; 
                                    end
                                    else begin
                                        precision       <= BIT_2;
                                        in_0            <= in_0;
                                        in_1            <= in_1;
                                        in_valid        <= 0;
                                        mac_rst         <= 0;
                                        is_signed       <= 0;
                                        accu_cnt        <= 0;
                                        test_step       <= 3; 
                                    end
                            end
        
                        3:  begin
                                if (mac_out_valid) 
                                    begin
                                        mac_rst             <= 1;
                                        
                                        if (mac_out!=expect_2bit_unsigend_output)
                                            begin
                                                error_cnt       <= error_cnt+1;
                                                $display("\n    Expect ", expect_2bit_unsigend_output, ", but got ", mac_out, "\n");
                                            end
                                            
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 2; 
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 4; 
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                                $display("\n=== Bit 2 Signed Test ===");
                                            end
                                    end
                                    else begin
                                        mac_rst         <= 0;
                                        test_step       <= 3; 
                                    end
                            end
        
                        4:  begin
                                if (accu_cnt<accu_length)
                                    begin
                                        precision       <= BIT_2;
                                        in_0            <= $random & 8'hFF;
                                        in_1            <= $random & 8'hFF;
                                        in_valid        <= 1;
                                        mac_rst         <= 0;
                                        is_signed       <= 1;
                                        accu_cnt        <= accu_cnt+1;
                                        test_step       <= 4; 
                                    end
                                    else begin
                                        precision       <= BIT_2;
                                        in_0            <= in_0;
                                        in_1            <= in_1;
                                        in_valid        <= 0;
                                        mac_rst         <= 0;
                                        is_signed       <= 1;
                                        accu_cnt        <= 0;
                                        test_step       <= 5; 
                                    end
                            end
        
                        5:  begin
                                if (mac_out_valid) 
                                    begin
                                        mac_rst             <= 1;
                                        
                                        if (mac_out!=expect_2bit_sigend_output)
                                            begin
                                                error_cnt       <= error_cnt+1;
                                                $display("\n    Expect ", expect_2bit_sigend_output, ", but got ", mac_out, "\n");
                                            end
                                            
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 4; 
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 6; 
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                                $display("\n=== Bit 4 Unsigned Test ===");
                                            end
                                    end
                                    else begin
                                        mac_rst         <= 0;
                                        test_step       <= 5; 
                                    end
                            end
        
                        6:  begin
                                if (accu_cnt<accu_length)
                                    begin
                                        precision       <= BIT_4;
                                        in_0            <= $random & 8'hFF;
                                        in_1            <= $random & 8'hFF;
                                        in_valid        <= 1;
                                        mac_rst         <= 0;
                                        is_signed       <= 0;
                                        accu_cnt        <= accu_cnt+1;
                                        test_step       <= 6; 
                                    end
                                    else begin
                                        precision       <= BIT_4;
                                        in_0            <= in_0;
                                        in_1            <= in_1;
                                        in_valid        <= 0;
                                        mac_rst         <= 0;
                                        is_signed       <= 0;
                                        accu_cnt        <= 0;
                                        test_step       <= 7; 
                                    end
                            end
        
                        7:  begin
                                if (mac_out_valid) 
                                    begin
                                        mac_rst             <= 1;
                                        
                                        if (mac_out!=expect_4bit_unsigend_output)
                                            begin
                                                error_cnt       <= error_cnt+1;
                                                $display("\n    Expect ", expect_4bit_unsigend_output, ", but got ", mac_out, "\n");
                                            end
                                            
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 6; 
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 8; 
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                                $display("\n=== Bit 4 Signed Test ===");
                                            end
                                    end
                                    else begin
                                        mac_rst         <= 0;
                                        test_step       <= 7; 
                                    end
                            end
        
                        8:  begin
                                if (accu_cnt<accu_length)
                                    begin
                                        precision       <= BIT_4;
                                        in_0            <= $random & 8'hFF;
                                        in_1            <= $random & 8'hFF;
                                        in_valid        <= 1;
                                        mac_rst         <= 0;
                                        is_signed       <= 1;
                                        accu_cnt        <= accu_cnt+1;
                                        test_step       <= 8; 
                                    end
                                    else begin
                                        precision       <= BIT_4;
                                        in_0            <= in_0;
                                        in_1            <= in_1;
                                        in_valid        <= 0;
                                        mac_rst         <= 0;
                                        is_signed       <= 1;
                                        accu_cnt        <= 0;
                                        test_step       <= 9; 
                                    end
                            end
        
                        9:  begin
                                if (mac_out_valid) 
                                    begin
                                        mac_rst             <= 1;
                                        
                                        if (mac_out!=expect_4bit_sigend_output)
                                            begin
                                                error_cnt       <= error_cnt+1;
                                                $display("\n    Expect ", expect_4bit_sigend_output, ", but got ", mac_out, "\n");
                                            end
                                            
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 8; 
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 10; 
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                                $display("\n=== Bit 8 Unsigned Test ===");
                                            end
                                    end
                                    else begin
                                        mac_rst         <= 0;
                                        test_step       <= 9; 
                                    end
                            end
        
                        10: begin
                                if (accu_cnt<accu_length)
                                    begin
                                        precision       <= BIT_8;
                                        in_0            <= $random & 8'hFF;
                                        in_1            <= $random & 8'hFF;
                                        in_valid        <= 1;
                                        mac_rst         <= 0;
                                        is_signed       <= 0;
                                        accu_cnt        <= accu_cnt+1;
                                        test_step       <= 10; 
                                    end
                                    else begin
                                        precision       <= BIT_8;
                                        in_0            <= in_0;
                                        in_1            <= in_1;
                                        in_valid        <= 0;
                                        mac_rst         <= 0;
                                        is_signed       <= 0;
                                        accu_cnt        <= 0;
                                        test_step       <= 11; 
                                    end
                            end
        
                        11: begin
                                if (mac_out_valid) 
                                    begin
                                        mac_rst             <= 1;
                                        
                                        if (mac_out!=expect_8bit_unsigend_output)
                                            begin
                                                error_cnt       <= error_cnt+1;
                                                $display("\n    Expect ", expect_8bit_unsigend_output, ", but got ", mac_out, "\n");
                                            end
                                            
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 10; 
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 12; 
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                                $display("\n=== Bit 8 Signed Test ===");
                                            end
                                    end
                                    else begin
                                        mac_rst         <= 0;
                                        test_step       <= 11; 
                                    end
                            end
        
                        12: begin
                                if (accu_cnt<accu_length)
                                    begin
                                        precision       <= BIT_8;
                                        in_0            <= $random & 8'hFF;
                                        in_1            <= $random & 8'hFF;
                                        in_valid        <= 1;
                                        mac_rst         <= 0;
                                        is_signed       <= 1;
                                        accu_cnt        <= accu_cnt+1;
                                        test_step       <= 12; 
                                    end
                                    else begin
                                        precision       <= BIT_8;
                                        in_0            <= in_0;
                                        in_1            <= in_1;
                                        in_valid        <= 0;
                                        mac_rst         <= 0;
                                        is_signed       <= 1;
                                        accu_cnt        <= 0;
                                        test_step       <= 13; 
                                    end
                            end
        
                        13: begin
                                if (mac_out_valid) 
                                    begin
                                        mac_rst             <= 1;
                                        
                                        if (mac_out!=expect_8bit_sigend_output)
                                            begin
                                                error_cnt       <= error_cnt+1;
                                                $display("\n    Expect ", expect_8bit_sigend_output, ", but got ", mac_out, "\n");
                                            end
                                            
                                        if (cnt<RANDOM_NUM)
                                            begin
                                                cnt             <= cnt + 1;
                                                test_step       <= 12; 
                                            end
                                            else begin
                                                cnt             <= 0;
                                                test_step       <= 14; 
                                                $display("Total Error Number: %0d", error_cnt);
                                                error_cnt       <= 0;
                                            end
                                    end
                                    else begin
                                        mac_rst         <= 0;
                                        test_step       <= 13; 
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

