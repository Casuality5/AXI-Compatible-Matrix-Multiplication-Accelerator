module Tensor_Input_Skewer(
    input logic CLK,
    input logic RST,
    input logic SKEW,
    input logic signed [255:0] PACKED_INPUT_A, PACKED_INPUT_B,
    output logic SKEW_DONE,
    output logic signed [447:0] SKEWED_OUTPUT_A, SKEWED_OUTPUT_B
    );
    
    
    always_ff @(posedge CLK) begin
        if (RST ||!SKEW) begin
            SKEWED_OUTPUT_A <= 0;
            SKEWED_OUTPUT_B <= 0;
            SKEW_DONE       <= 0;
            end else begin
            
                    SKEWED_OUTPUT_A <= {PACKED_INPUT_A[255:240], PACKED_INPUT_A[239:224], PACKED_INPUT_A[223:208], PACKED_INPUT_A[207:192],64'b0,
                                        PACKED_INPUT_A[191:176], PACKED_INPUT_A[175:160], PACKED_INPUT_A[159:144], PACKED_INPUT_A[143:128],64'b0,
                                        PACKED_INPUT_A[127:112], PACKED_INPUT_A[111:96],  PACKED_INPUT_A[95:80],   PACKED_INPUT_A[79:64]  ,64'b0,
                                        PACKED_INPUT_A[63:48],   PACKED_INPUT_A[47:32],   PACKED_INPUT_A[31:16],   PACKED_INPUT_A[15:0]};
                    
                    SKEWED_OUTPUT_B <= {PACKED_INPUT_B[255:240], PACKED_INPUT_B[191:176], PACKED_INPUT_B[127:112], PACKED_INPUT_B[63:48],  64'b0,
                                        PACKED_INPUT_B[239:224], PACKED_INPUT_B[175:160], PACKED_INPUT_B[111:96],  PACKED_INPUT_B[47:32],  64'b0,
                                        PACKED_INPUT_B[223:208], PACKED_INPUT_B[159:144], PACKED_INPUT_B[95:80],   PACKED_INPUT_B[31:16],  64'b0,
                                        PACKED_INPUT_B[207:192], PACKED_INPUT_B[143:128], PACKED_INPUT_B[79:64],   PACKED_INPUT_B[15:0]};
                    
                    SKEW_DONE <= 1;
                    end
                    end
                    
endmodule
