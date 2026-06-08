module Input_Packing_Unit_B(
    input logic CLK,
    input logic RST,
    input logic signed [15:0] UNPACKED_INPUT_B,
    output logic signed [255:0] PACKED_OUTPUT_B,
    output logic READY_B
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
logic [3:0] COUNT_B;

    always_ff @ (posedge CLK) begin
        if (RST) begin
            COUNT_B <= 0;
            INTERMEDIATE_PACKED_UNIT <= 0;
            PACKED_OUTPUT_B <= 0;
            READY_B <= 0;
        end else begin
            case (COUNT_B)
                CHUNK1:  INTERMEDIATE_PACKED_UNIT[15:0]    <= UNPACKED_INPUT_B;
                CHUNK2:  INTERMEDIATE_PACKED_UNIT[31:16]   <= UNPACKED_INPUT_B;
                CHUNK3:  INTERMEDIATE_PACKED_UNIT[47:32]   <= UNPACKED_INPUT_B;
                CHUNK4:  INTERMEDIATE_PACKED_UNIT[63:48]   <= UNPACKED_INPUT_B;
                CHUNK5:  INTERMEDIATE_PACKED_UNIT[79:64]   <= UNPACKED_INPUT_B;
                CHUNK6:  INTERMEDIATE_PACKED_UNIT[95:80]   <= UNPACKED_INPUT_B;
                CHUNK7:  INTERMEDIATE_PACKED_UNIT[111:96]  <= UNPACKED_INPUT_B;
                CHUNK8:  INTERMEDIATE_PACKED_UNIT[127:112] <= UNPACKED_INPUT_B;
                CHUNK9:  INTERMEDIATE_PACKED_UNIT[143:128] <= UNPACKED_INPUT_B;
                CHUNK10: INTERMEDIATE_PACKED_UNIT[159:144] <= UNPACKED_INPUT_B;
                CHUNK11: INTERMEDIATE_PACKED_UNIT[175:160] <= UNPACKED_INPUT_B;
                CHUNK12: INTERMEDIATE_PACKED_UNIT[191:176] <= UNPACKED_INPUT_B;
                CHUNK13: INTERMEDIATE_PACKED_UNIT[207:192] <= UNPACKED_INPUT_B;
                CHUNK14: INTERMEDIATE_PACKED_UNIT[223:208] <= UNPACKED_INPUT_B;
                CHUNK15: INTERMEDIATE_PACKED_UNIT[239:224] <= UNPACKED_INPUT_B;
                CHUNK16: begin
                    PACKED_OUTPUT_B <= { UNPACKED_INPUT_B, INTERMEDIATE_PACKED_UNIT[239:0] };
                end
            endcase
            
            if (COUNT_B == CHUNK16) begin
                READY_B <= 1'b1;
            end else begin
                READY_B <= 1'b0;
            end

            COUNT_B <= COUNT_B + 1;
        end
    end
endmodule
