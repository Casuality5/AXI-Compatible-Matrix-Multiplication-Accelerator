module Input_Packing_Unit_A(
    input logic CLK,
    input logic RST,
    input logic signed [15:0] UNPACKED_INPUT_A,
    output logic signed [255:0] PACKED_OUTPUT_A,
    output logic READY_A
    );

localparam CHUNK1   = 4'h0;
localparam CHUNK2   = 4'h1;
localparam CHUNK3   = 4'h2;
localparam CHUNK4   = 4'h3;
localparam CHUNK5   = 4'h4;
localparam CHUNK6   = 4'h5;
localparam CHUNK7   = 4'h6;
localparam CHUNK8   = 4'h7;
localparam CHUNK9   = 4'h8;
localparam CHUNK10  = 4'h9;
localparam CHUNK11  = 4'hA;
localparam CHUNK12  = 4'hB;
localparam CHUNK13  = 4'hC;
localparam CHUNK14  = 4'hD;
localparam CHUNK15  = 4'hE;
localparam CHUNK16  = 4'hF;

logic [255:0] INTERMEDIATE_PACKED_UNIT;    
logic [3:0] COUNT_A;   

    always_ff @ (posedge CLK) begin
        if (RST) begin
            COUNT_A <= 0;
            INTERMEDIATE_PACKED_UNIT <= 0;
            PACKED_OUTPUT_A <= 0;
            READY_A <= 0;
        end else begin
            case (COUNT_A)
                CHUNK1:  INTERMEDIATE_PACKED_UNIT[15:0]    <= UNPACKED_INPUT_A;
                CHUNK2:  INTERMEDIATE_PACKED_UNIT[31:16]   <= UNPACKED_INPUT_A;
                CHUNK3:  INTERMEDIATE_PACKED_UNIT[47:32]   <= UNPACKED_INPUT_A;
                CHUNK4:  INTERMEDIATE_PACKED_UNIT[63:48]   <= UNPACKED_INPUT_A;
                CHUNK5:  INTERMEDIATE_PACKED_UNIT[79:64]   <= UNPACKED_INPUT_A;
                CHUNK6:  INTERMEDIATE_PACKED_UNIT[95:80]   <= UNPACKED_INPUT_A;
                CHUNK7:  INTERMEDIATE_PACKED_UNIT[111:96]  <= UNPACKED_INPUT_A;
                CHUNK8:  INTERMEDIATE_PACKED_UNIT[127:112] <= UNPACKED_INPUT_A;
                CHUNK9:  INTERMEDIATE_PACKED_UNIT[143:128] <= UNPACKED_INPUT_A;
                CHUNK10: INTERMEDIATE_PACKED_UNIT[159:144] <= UNPACKED_INPUT_A;
                CHUNK11: INTERMEDIATE_PACKED_UNIT[175:160] <= UNPACKED_INPUT_A;
                CHUNK12: INTERMEDIATE_PACKED_UNIT[191:176] <= UNPACKED_INPUT_A;
                CHUNK13: INTERMEDIATE_PACKED_UNIT[207:192] <= UNPACKED_INPUT_A;
                CHUNK14: INTERMEDIATE_PACKED_UNIT[223:208] <= UNPACKED_INPUT_A;
                CHUNK15: INTERMEDIATE_PACKED_UNIT[239:224] <= UNPACKED_INPUT_A;
                CHUNK16: begin
                    PACKED_OUTPUT_A <= { UNPACKED_INPUT_A, INTERMEDIATE_PACKED_UNIT[239:0] };
                end
            endcase
            
            if (COUNT_A == CHUNK16) begin
                READY_A <= 1'b1;
            end else begin
                READY_A <= 1'b0;
            end

            COUNT_A <= COUNT_A + 1;
        end
    end
endmodule
