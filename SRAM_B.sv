module SRAM_B (
    input  logic              CLK,
    input  logic              WE,
    input  logic              RE,

    input  logic [3:0]        ADDR,
    input  logic signed [15:0] WRITE_DATA,

    output logic signed [15:0] READ_DATA
);

    logic signed [15:0] MEM [0:511];

    always_ff @(posedge CLK) begin
        if (WE)
            MEM[ADDR] <= WRITE_DATA;
    end

    always_comb begin
        if (RE)
            READ_DATA = MEM[ADDR];
        else
            READ_DATA = 0;
    end

endmodule