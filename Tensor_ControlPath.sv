module Tensor_ControlPath(
          
          input logic CLK,
          input logic RST,
          
          input logic READY,
          output logic SKEW,
          input logic SKEW_DONE,
          output logic VALID_BUFFER_IN,
          input logic VALID_BUFFER_OUT,
          output logic VALID_REGISTER_IN,
          output logic CLR_IN,
          input logic VALID_REGISTER_OUT,
          output logic VALID_IN_ARRAY,
          input logic VALID,
          output logic CKR,
          output logic START,
          input logic DONE,
          output logic LOAD_to_Tensor_DataPath,
          output logic UNLOAD_from_Tensor_DataPath,
          
          input logic [31:0] SRC_ADDR_BUS [0:3],
          output logic [31:0] STATUS_ADDR_BUS
          
          
    );
    
    
   
    


logic [31:0] SRC_ADDR_REG_BUS [0:5];


logic DMA_SIGNAL_BUS [0:5];


logic IPU_SIGNAL_BUS [0:3];


logic OPU_SIGNAL_BUS [0:3];


logic [31:0] DMA_DATA_BUS [0:5];


logic [63:0] NAME_REG;


assign IPU_SIGNAL_BUS[0] = 1'b1;
assign IPU_SIGNAL_BUS[1] = 1'b1;
assign OPU_SIGNAL_BUS[0] = 1'b1;
assign OPU_SIGNAL_BUS[1] = 1'b1;


    
    
    Tensor_Controller TC(
          
          .CLK(CLK),
          .RST(RST),
          
          .CONTROL_REG(SRC_ADDR_REG_BUS[0]),
          .SRCA_ADDR_REG(SRC_ADDR_REG_BUS[1]),
          .SRCB_ADDR_REG(SRC_ADDR_REG_BUS[2]),
          .DEST_ADDR_REG(SRC_ADDR_REG_BUS[3]),
          
          .DMA_FETCH_READY(DMA_SIGNAL_BUS[0]),
          .DMA_FETCH_COMPLETE(DMA_SIGNAL_BUS[1]),
          .DMA_DISPATCH_READY(DMA_SIGNAL_BUS[2]),
          .DMA_DISPATCH_COMPLETE(DMA_SIGNAL_BUS[3]),
          .DMA_FETCH_START(DMA_SIGNAL_BUS[4]),
          .DMA_DISPATCH_START(DMA_SIGNAL_BUS[5]),
          
          .IPU_READY(IPU_SIGNAL_BUS[0]),
          .IPU_LOADING_COMPLETE(IPU_SIGNAL_BUS[1]),
          .READY(READY),
          
          .OPU_READY(OPU_SIGNAL_BUS[0]),
          .OPU_UNLOADING_COMPLETE(OPU_SIGNAL_BUS[1]),
          
          .SKEW(SKEW),
          .SKEW_DONE(SKEW_DONE),
          
          .VALID_BUFFER_IN(VALID_BUFFER_IN),
          .VALID_BUFFER_OUT(VALID_BUFFER_OUT),
          
          .VALID_REGISTER_IN(VALID_REGISTER_IN),
          .CLR_IN(CLR_IN),
          .VALID_REGISTER_OUT(VALID_REGISTER_OUT),
          
          .VALID_IN_ARRAY(VALID_IN_ARRAY),
          .CLR(CKR),
          .VALID(VALID),
          
          .START(START),
          .DONE(DONE),
          
          .STATUS_REG(SRC_ADDR_REG_BUS[4]),
          .PERFORMANCE_REG(SRC_ADDR_REG_BUS[5]),
          .SRCA_ADDR_to_DMA(DMA_DATA_BUS[0]),
          .SRCB_ADDR_to_DMA(DMA_DATA_BUS[1]),
          .DEST_ADDR_to_DMA(DMA_DATA_BUS[2]),
          
          .LOAD_to_Tensor_DataPath(LOAD_to_Tensor_DataPath),
          .UNLOAD_from_Tensor_DataPath(UNLOAD_from_Tensor_DataPath)
          
          );
          
     
     Direct_Memory_Access_Controller DMAC(
          
          .CLK(CLK),
          .RST(RST),
          
          .SRCA_ADDR_from_CU(DMA_DATA_BUS[0]),
          .SRCB_ADDR_from_CU(DMA_DATA_BUS[1]),
          .DEST_ADDR_from_CU(DMA_DATA_BUS[2]),
          .DMA_FETCH_START(DMA_SIGNAL_BUS[4]),
          .DMA_DISPATCH_START(DMA_SIGNAL_BUS[5]),
          
          .DATA_IN_A(),
          .DATA_IN_B(),
          .DATA_IN_C(),
          
          .DATA_to_SRAM_A(),
          .DATA_to_SRAM_B(),
          .DATA_from_SRAM(),
          
          .DMA_FETCH_READY(DMA_SIGNAL_BUS[0]),
          .DMA_FETCH_COMPLETE(DMA_SIGNAL_BUS[1]),
          .DMA_DISPATCH_READY(DMA_SIGNAL_BUS[2]),
          .DMA_DISPATCH_COMPLETE(DMA_SIGNAL_BUS[3])
          
          );
          
          
          
     Memory_Mapped_IO  MMIO(
          
          .CLK(CLK),
          .RST(RST),
          
          .DATA(),
          .ADDRESS(),
          .WE(),
          .RE(),
          
          .CONTROL_REG(),
          .STATUS_REG(),
          
          .SRCA_ADDR_REG(),
          .SRCB_ADDR_REG(),
          .DEST_ADDR_REG(),
          .PERFORMANCE_REG(),
          .NAME_REG(NAME_REG)
          
          );
          
      
     SRAM_A MEMA(
          
          .CLK(CLK),
          .WE(),
          .RE(),
          .ADDR(),
          .WRITE_DATA(),
          .READ_DATA()
          );
          
     SRAM_B MEMB(
          
          .CLK(CLK),
          .WE(),
          .RE(),
          .ADDR(),
          .WRITE_DATA(),
          .READ_DATA()
          );
          
     SRAM_C MEMC(
          
          .CLK(CLK),
          .WE(),
          .RE(),
          .ADDR(),
          .WRITE_DATA(),
          .READ_DATA()
          );          

 assign SRC_ADDR_REG_BUS[0:3] = SRC_ADDR_BUS;
 assign STATUS_ADDR_BUS = SRC_ADDR_REG_BUS[4];     
          
    
endmodule
