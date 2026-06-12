module SRAM_C (
    input  logic              CLK,
    input  logic              WE,
    input  logic              RE,

    input  logic [8:0]        ADDR,
    input  logic signed [33:0] WRITE_DATA,

    output logic signed [33:0] READ_DATA
);

    logic signed [33:0] MEM [0:511];

    always_ff @(posedge CLK) begin

        if (WE)
            MEM[ADDR] <= WRITE_DATA;

        if (RE)
            READ_DATA <= MEM[ADDR];

    end

endmodule
