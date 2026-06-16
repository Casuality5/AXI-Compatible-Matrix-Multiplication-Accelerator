module Output_Buffer(
    input  logic CLK,
    input  logic RST,
    input  logic START,
    input  logic [8:0] ADDR,
    input  logic RE,
    input  logic signed [33:0] ACCUMULATE_IN [0:3][0:3],

    output logic DONE,
    output logic signed [33:0] READ_OUT
);

    logic signed [33:0] MEM [0:15];
    logic [8:0] COUNTER;

    logic START_D;
    logic START_PULSE;

    integer i, j;
    integer idx;
    
    always_ff @(posedge CLK) begin
        if (RST)
            START_D <= 1'b0;
        else
            START_D <= START;
    end

    assign START_PULSE = START & ~START_D;
    
    always_ff @(posedge CLK) begin
        if (RST) begin
            COUNTER <= 9'd0;
            DONE    <= 1'b0;
        end
        else begin
            DONE <= 1'b0;

            if (START_PULSE) begin

                idx = COUNTER;

                for (i = 0; i < 4; i++) begin
                    for (j = 0; j < 4; j++) begin
                        MEM[idx] <= ACCUMULATE_IN[i][j];
                        idx = idx + 1;
                    end
                end

                COUNTER <= COUNTER + 9'd16;
                DONE    <= 1'b1;
            end
        end
    end
    
    always_comb begin
        if (RE)
            READ_OUT = MEM[ADDR];
        else
            READ_OUT = '0;
    end

endmodule