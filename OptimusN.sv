module OptimusN(
    input  logic        CLK,
    input  logic        RST,

    input  logic        READY,
    input  logic [31:0] SRC_ADDR_BUS [0:3],
    output logic [31:0] STATUS_ADDR_BUS,
    output logic        LOAD_to_Tensor_DataPath,
    output logic        UNLOAD_from_Tensor_DataPath,

    input  logic signed [15:0] UNPACKED_INPUT_A,
    input  logic signed [15:0] UNPACKED_INPUT_B,
    output logic        READY_A,
    output logic        READY_B,
    input  logic [8:0]  ADDRESS,
    input  logic        WD,
    input  logic        RE,
    input  logic [8:0]  ADDR,
    input  logic        OUURE,
    output logic signed [33:0] ACCUMULATE_OUT
);

    logic skew;
    logic skew_done;
    logic valid_buffer_in;
    logic valid_buffer_out;
    logic valid_register_in;
    logic clr_in;
    logic valid_register_out;
    logic valid_in_array;
    logic valid;
    logic ckr;
    logic start;
    logic done;

    Tensor_ControlPath TCP (
        .CLK                        (CLK),
        .RST                        (RST),
        .READY                      (READY),
        .SKEW                       (skew),
        .SKEW_DONE                  (skew_done),
        .VALID_BUFFER_IN            (valid_buffer_in),
        .VALID_BUFFER_OUT           (valid_buffer_out),
        .VALID_REGISTER_IN          (valid_register_in),
        .CLR_IN                     (clr_in),
        .VALID_REGISTER_OUT         (valid_register_out),
        .VALID_IN_ARRAY             (valid_in_array),
        .VALID                      (valid),
        .CKR                        (ckr),
        .START                      (start),
        .DONE                       (done),
        .LOAD_to_Tensor_DataPath    (LOAD_to_Tensor_DataPath),
        .UNLOAD_from_Tensor_DataPath(UNLOAD_from_Tensor_DataPath),
        .SRC_ADDR_BUS               (SRC_ADDR_BUS),
        .STATUS_ADDR_BUS            (STATUS_ADDR_BUS)
    );

    Tensor_DataPath TDP (
        .CLK              (CLK),
        .RST              (RST),
        .UNPACKED_INPUT_A  (UNPACKED_INPUT_A),
        .UNPACKED_INPUT_B  (UNPACKED_INPUT_B),
        .READY_A           (READY_A),
        .READY_B           (READY_B),
        .SKEW              (skew),
        .SKEW_DONE         (skew_done),
        .ADDRESS           (ADDRESS),
        .WD                (WD),
        .RE                (RE),
        .VALID_BUFFER_IN   (valid_buffer_in),
        .VALID_BUFFER_OUT  (valid_buffer_out),
        .CLR               (clr_in),
        .VALID_TR          (valid_register_in),
        .VALID_OUT_TR      (valid_register_out),
        .VALID_IN_ARRAY    (valid_in_array),
        .SACLR             (ckr),
        .VALID             (valid),
        .START             (start),
        .ADDR              (ADDR),
        .OUURE             (OUURE),
        .DONE              (done),
        .ACCUMULATE_OUT    (ACCUMULATE_OUT)
    );

endmodule
