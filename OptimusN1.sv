module Top(
          input logic CLK,
          input logic RST,
          
          input logic [31:0] CONTROL_AXI_REG,
          input logic [31:0] SRCA_AXI_REG,
          input logic [31:0] SRCB_AXI_REG,
          input logic [31:0] DEST_AXI_REG,
          
//          input logic [31:0] MMIO_DATA,
//          input logic [2:0] MMIO_ADDRESS,
//          input logic MMIO_WE,
//          input logic MMIO_RE,
//          output logic [31:0] MMIO_READ_DATA,
          
          output logic DDR_RE,
          output logic DDR_WE,
          output logic [31:0] ACTUAL_DDR_ADDRESS_A,
          output logic [31:0] ACTUAL_DDR_ADDRESS_B,
          output logic [31:0] ACTUAL_DDR_ADDRESS_C,
          input logic [15:0] DDR_IN_A,
          input logic [15:0] DDR_IN_B,
          output logic [33:0] DDR_OUT_C,
          output logic DONE
    );
    
    logic SKEW_WIRE;
    logic CLR_IN_WIRE;
    logic CLR_ACCUMULATE_WIRE;
    logic START_WIRE;
    logic DONE_WIRE;
    logic READY_WIRE;
    logic VALID_OUT_CONTROLLER_WIRE;
    logic [3:0] SRAM_ADDRESS_WIRE [0:1];
    logic SRAM_WRITE_WIRE;
    logic SRAM_READ_WIRE;
    logic [15:0] SRAM_READ_DATA_A;
    logic [15:0] SRAM_READ_DATA_B;
    logic [33:0] OUTPUT_BUFFER_IN_WIRE;
    logic OUTPUT_BUFFER_RE_WIRE;
    logic PACKING_ENABLE_WIRE;
    logic [15:0] SRAM_WRITE_WIRE_A;
    logic [15:0] SRAM_WRITE_WIRE_B;
    
            logic [8:0] OUTPUT_BUFFER_ADDR; 
            logic [31:0] CONTROL_REG_WIRE;
            logic [31:0] SRC_A_ADDRESS_WIRE;
            logic [31:0] SRC_B_ADDRESS_WIRE;
            logic [31:0] DEST_ADDRESS_WIRE;
            
            assign CONTROL_REG_WIRE   = CONTROL_AXI_REG;
            assign SRC_A_ADDRESS_WIRE = SRCA_AXI_REG;
            assign SRC_B_ADDRESS_WIRE = SRCB_AXI_REG;
            assign DEST_ADDRESS_WIRE  = DEST_AXI_REG;
            
          logic [31:0] DUMMY_STATUS_REG;
          logic [31:0] DUMMY_PERFORMANCE_REG;
          logic [63:0] DUMMY_NAME_REG;
    
    assign DONE = DONE_WIRE;
    
//    Memory_Mapped_IO MMIO_INST (
//          .CLK(CLK),
//          .RST(RST),
          
//          .DATA(MMIO_DATA),
//          .ADDRESS(MMIO_ADDRESS),
//          .WE(MMIO_WE),
//          .RE(MMIO_RE),
          
//          .READ_DATA(MMIO_READ_DATA),
//          .CONTROL_REG(CONTROL_REG_WIRE),
//          .STATUS_REG(DUMMY_STATUS_REG),
//          .SRCA_ADDR_REG(SRC_A_ADDRESS_WIRE),
//          .SRCB_ADDR_REG(SRC_B_ADDRESS_WIRE),
//          .DEST_ADDR_REG(DEST_ADDRESS_WIRE),
//          .PERFORMANCE_REG(DUMMY_PERFORMANCE_REG),
//          .NAME_REG(DUMMY_NAME_REG)
//    );
    
    Data_Path DP(
          
          .CLK(CLK),
          .RST(RST),
          .PACKING_ENABLE(PACKING_ENABLE_WIRE),
          .SKEW(SKEW_WIRE),
          .CLR_IN(CLR_IN_WIRE),
          .CLR_ACCUMULATE(CLR_ACCUMULATE_WIRE),
          .START(START_WIRE),
          .ADDR(OUTPUT_BUFFER_ADDR),
          .RE(OUTPUT_BUFFER_RE_WIRE),
          
          .UNPACKED_INPUT_A(SRAM_READ_DATA_A),
          .UNPACKED_INPUT_B(SRAM_READ_DATA_B),
          
          .READY(READY_WIRE),
          .VALID_OUT_CONTROLLER(VALID_OUT_CONTROLLER_WIRE),
          .DONE(DONE_WIRE),
          .READ_OUT(OUTPUT_BUFFER_IN_WIRE)
          );
          
    
    DMAC DMA(
          
          .CLK(CLK),
          .RST(RST),
          
          .READY(READY_WIRE),
          .VALID_OUT_CONTROLLER(VALID_OUT_CONTROLLER_WIRE),
          
          .CONTROL_REG(CONTROL_REG_WIRE), //
          
          .DDR_IN_A(DDR_IN_A),     //
          .DDR_IN_B(DDR_IN_B),     //
          
          .SRC_A_ADDRESS(SRC_A_ADDRESS_WIRE),     //
          .SRC_B_ADDRESS(SRC_B_ADDRESS_WIRE),     //
          
          .OUTPUT_BUFFER_IN(OUTPUT_BUFFER_IN_WIRE),         //
          .DEST_ADDRESS(DEST_ADDRESS_WIRE),       //
          
          .DONE(DONE_WIRE),
          
          .DDR_RE(DDR_RE),
          .DDR_WE(DDR_WE),
          
          .SRAM_WE(SRAM_WRITE_WIRE),
          .SRAM_RE(SRAM_READ_WIRE),
          
          .OUTPUT_BUFFER_RE(OUTPUT_BUFFER_RE_WIRE),
          .OUTPUT_BUFFER_ADDR(OUTPUT_BUFFER_ADDR),
          
          .SRAM_ADDRESS(SRAM_ADDRESS_WIRE),
          .SRAM_WRITE_A(SRAM_WRITE_WIRE_A),
          .SRAM_WRITE_B(SRAM_WRITE_WIRE_B),
          
          .SKEW(SKEW_WIRE),
          .START(START_WIRE),
          .CLR_IN(CLR_IN_WIRE),
          .CLR_ACCUMULATE(CLR_ACCUMULATE_WIRE),
          
          .ACTUAL_DDR_ADDRESS_A(ACTUAL_DDR_ADDRESS_A),
          .ACTUAL_DDR_ADDRESS_B(ACTUAL_DDR_ADDRESS_B),
          .ACTUAL_DDR_ADDRESS_C(ACTUAL_DDR_ADDRESS_C),
          .DDR_OUT_C(DDR_OUT_C),
          
          .PACKING_ENABLE(PACKING_ENABLE_WIRE)
          );
    
    SRAM_A RAMA(
          
          .CLK(CLK),
          .WE(SRAM_WRITE_WIRE),
          .RE(SRAM_READ_WIRE),
          .ADDR(SRAM_ADDRESS_WIRE[0]),
          .WRITE_DATA(SRAM_WRITE_WIRE_A),
          .READ_DATA(SRAM_READ_DATA_A)
          );
               
    
    SRAM_B RAMB(
          
          .CLK(CLK),
          .WE(SRAM_WRITE_WIRE),
          .RE(SRAM_READ_WIRE),
          .ADDR(SRAM_ADDRESS_WIRE[1]),
          .WRITE_DATA(SRAM_WRITE_WIRE_B),
          .READ_DATA(SRAM_READ_DATA_B)
          );
    
   
    
endmodule
