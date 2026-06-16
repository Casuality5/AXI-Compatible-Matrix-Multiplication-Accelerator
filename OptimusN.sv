module OptimiusN(
          input logic CLK,
          input logic RST,
          
          input logic [31:0] MMIO_DATA,
          input logic [2:0] MMIO_ADDRESS,
          input logic MMIO_WE,
          input logic MMIO_RE,
          output logic [31:0] MMIO_READ_DATA,
          
          output logic DDR_RE,
          output logic DDR_WE,
          output logic [31:0] ACTUAL_DDR_ADDRESS_A,
          output logic [31:0] ACTUAL_DDR_ADDRESS_B,
          output logic [31:0] ACTUAL_DDR_ADDRESS_C,
          input logic [15:0] DDR_IN_A,
          input logic [15:0] DDR_IN_B,
          output logic [33:0] DDR_OUT_C,
          output logic DONE,
          output logic STATUS_REG
    );
    
    
    
    Top hw(
        .CLK(CLK),
        .RST(RST),
        .MMIO_DATA(MMIO_DATA),
        .MMIO_ADDRESS(MMIO_ADDRESS),
        .MMIO_WE(MMIO_WE),
        .MMIO_RE(MMIO_RE),
        .MMIO_READ_DATA(MMIO_READ_DATA),
        .DDR_RE(DDR_RE),
        .DDR_WE(DDR_WE),
        .ACTUAL_DDR_ADDRESS_A(ACTUAL_DDR_ADDRESS_A),
        .ACTUAL_DDR_ADDRESS_B(ACTUAL_DDR_ADDRESS_B),
        .ACTUAL_DDR_ADDRESS_C(ACTUAL_DDR_ADDRESS_C),
        .DDR_IN_A(DDR_IN_A),
        .DDR_IN_B(DDR_IN_B),
        .DDR_OUT_C(DDR_OUT_C),
        .DONE(DONE),
        .STATUS_REG(STATUS_REG)
        );

endmodule
