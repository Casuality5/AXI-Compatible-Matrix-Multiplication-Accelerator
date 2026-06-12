module Tensor_DataPath(
    input logic CLK,
    input logic RST,
    input logic signed [15:0] UNPACKED_INPUT_A,
    input logic signed [15:0] UNPACKED_INPUT_B,
    
    output logic READY_A,
    output logic READY_B,
    
    input logic SKEW,
    output logic SKEW_DONE,
    
    input logic [8:0] ADDRESS,
    input logic WD,
    input logic RE,
    input logic VALID_BUFFER_IN,
    output logic VALID_BUFFER_OUT,
    
    input logic CLR,
    input logic VALID_TR,
    output logic VALID_OUT_TR,
    
    input logic VALID_IN_ARRAY,
    input logic SACLR,
    output logic VALID,
    
    input logic START,
    input logic [8:0] ADDR,
    input logic OUURE,
    output logic DONE,
    
    output logic signed [33:0] ACCUMULATE_OUT
);

    logic signed [255:0] packed_output_a;
    logic signed [255:0] packed_output_b;
    logic signed [447:0] skewed_output_a;
    logic signed [447:0] skewed_output_b;
    logic [447:0] matrix_a_read;
    logic [447:0] matrix_b_read;
    logic signed [15:0] row_out [0:3];
    logic signed [15:0] col_out [0:3];
    logic signed [33:0] accumulate_out_array [0:3][0:3];

    Input_Packing_Unit_A input_packing_unit_a_inst (
        .CLK(CLK),
        .RST(RST),
        .UNPACKED_INPUT_A(UNPACKED_INPUT_A),
        .PACKED_OUTPUT_A(packed_output_a),
        .READY_A(READY_A)
    );

    Input_Packing_Unit_B input_packing_unit_b_inst (
        .CLK(CLK),
        .RST(RST),
        .UNPACKED_INPUT_B(UNPACKED_INPUT_B),
        .PACKED_OUTPUT_B(packed_output_b),
        .READY_B(READY_B)
    );

    Tensor_Input_Skewer tensor_input_skewer_inst (
        .CLK(CLK),
        .RST(RST),
        .SKEW(SKEW),
        .PACKED_INPUT_A(packed_output_a),
        .PACKED_INPUT_B(packed_output_b),
        .SKEW_DONE(SKEW_DONE),
        .SKEWED_OUTPUT_A(skewed_output_a),
        .SKEWED_OUTPUT_B(skewed_output_b)
    );

    Tensor_Buffer tensor_buffer_inst (
        .CLK(CLK),
        .RST(RST),
        .ADDRESS(ADDRESS),
        .MATRIX_A(skewed_output_a),
        .MATRIX_B(skewed_output_b),
        .WD(WD),
        .RE(RE),
        .VALID_BUFFER_IN(VALID_BUFFER_IN),
        .VALID_BUFFER_OUT(VALID_BUFFER_OUT),
        .MATRIX_A_READ(matrix_a_read),
        .MATRIX_B_READ(matrix_b_read)
    );

    Tensor_Registers tensor_registers_inst (
        .CLK(CLK),
        .RST(RST),
        .CLR(CLR),
        .SRCA(matrix_a_read),
        .SRCB(matrix_b_read),
        .VALID_TR(VALID_TR),
        .VALID_OUT_TR(VALID_OUT_TR),
        .ROW_OUT(row_out),
        .COL_OUT(col_out)
    );

    Systolic_Array systolic_array_inst (
        .CLK(CLK),
        .RST(RST),
        .VALID_IN_ARRAY(VALID_IN_ARRAY),
        .CLR(SACLR),
        .W_A(row_out),
        .W_B(col_out),
        .ACCUMULATE_OUT(accumulate_out_array),
        .VALID(VALID)
    );

    Output_Unpacking_Unit output_unpacking_unit_inst (
        .CLK(CLK),
        .RST(RST),
        .START(START),
        .ADDR(ADDR),
        .RE(OUURE),
        .ACCUMULATE_IN(accumulate_out_array),
        .DONE(DONE),
        .ACCUMULATE_OUT(ACCUMULATE_OUT)
    );

endmodule
