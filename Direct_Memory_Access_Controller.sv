module DMAC(
    input logic CLK,
    input logic RST,
    
    input logic READY,                  // SIGNAL FROM DATAPATH TELLING PACKING IS DONE
    input logic VALID_OUT_CONTROLLER,   // SIGNAL FROM DATAPATH TELLING COMPUTATION IS COMPLETE
    
    input logic [31:0] CONTROL_REG,     // READ THE MMIO CONTROL REGISTER
    
    input logic [15:0] DDR_IN_A,       // READ THE MATRIX_A ELEMENT FROM DDR
    input logic [15:0] DDR_IN_B,       // READ THE MATRIX_B ELEMENT FROM DDR
    
    input logic [31:0] SRC_A_ADDRESS,    // READ THE MMIO SRC_A_REGISTER
    input logic [31:0] SRC_B_ADDRESS,    // READ THE MMIO SRC_B_REGISTER
    
    input logic [33:0] OUTPUT_BUFFER_IN,          // RESULT FROM DATAPATH TO SRAM C
    input logic [31:0] DEST_ADDRESS,              // WRITING ADDRESS ON DDR
    
    input logic DONE,         // FROM DATAPATH TELLING RESULT IS READY
    
    output logic PACKING_ENABLE,        // SIGNAL TO DATAPATH TO START PACKING
    output logic DDR_RE,       // FOR READING DATA FROM DDR MEMORY IN FETCH STAGE
    output logic DDR_WE,       // FOR WRITING DAT FROM SRAM TO DDR MEMORY
    
    output logic SRAM_WE,      // FOR WRITING DATA TO SRAM IN FETCH STAGE
    output logic SRAM_RE,      // FOR READING DATA FROM SRAM TO DATAPATH
    
    output logic OUTPUT_BUFFER_RE,      // FOR READING THE OUTPUT_BUFFER IN DATAPATH
    output logic [8:0] OUTPUT_BUFFER_ADDR, // FOR ADDRESSING OUTPUT BUFFER
    
    
    output logic [3:0] SRAM_ADDRESS [0:1], // FOR SRAM ADDRESS
    
    output logic [15:0] SRAM_WRITE_A,   // WRITING INTO SRAM
    output logic [15:0] SRAM_WRITE_B,   // WRITING INTO SRAM
    

    
    output logic SKEW,                   // SIGNAL TO DATAPATH TO SKEW THE PACKED DATA
    output logic START,                  // SIGNAL TO DATAPATH TO STORE THE ACCUMULATE IN OUTPUT BUFFER
    output logic CLR_IN,                 // SIGNAL TO DATAPATH TO CLR REGISTER
    output logic CLR_ACCUMULATE,         // SIGNAL TO DATAPATH TO CLR ACCUMUULATE        
    
    output logic [31:0] ACTUAL_DDR_ADDRESS_A,     
    output logic [31:0] ACTUAL_DDR_ADDRESS_B,
    output logic [31:0] ACTUAL_DDR_ADDRESS_C,
    output logic [33:0] DDR_OUT_C
    );

logic [3:0] SRAM_ADDRESS_COUNTER [0:1];               // for 2x4x4 TENSOR
logic [3:0] DISPATCH_COUNTER;



typedef enum logic [3:0] {
          
          IDLE,
          FETCH,
          LOAD,
          WAIT_READY,
          SKEW_START,
          WAIT_VALID,
          STORE_RESULT,
          WAIT_DONE,
          CLEARING_STATE,
          CLEARING_LOW,
          DISPATCH,
          COMPLETE
          } STATE;
          
          STATE CURRENT_STATE, NEXT_STATE;
          
          
always_ff @(posedge CLK) begin
if (RST) begin
CURRENT_STATE <= IDLE;
end
else begin
CURRENT_STATE <= NEXT_STATE;
end
end

always_ff @ (posedge CLK) begin
if (RST || CURRENT_STATE == IDLE || CURRENT_STATE == WAIT_READY) begin
SRAM_ADDRESS_COUNTER <= '{4'h0, 4'h0};
DISPATCH_COUNTER <= 0;
end
else if (CURRENT_STATE == FETCH || CURRENT_STATE == LOAD) begin
SRAM_ADDRESS_COUNTER[0] <= SRAM_ADDRESS_COUNTER[0] + 1;
SRAM_ADDRESS_COUNTER[1] <= SRAM_ADDRESS_COUNTER[1] + 1;
end
else if (CURRENT_STATE == DISPATCH) begin
DISPATCH_COUNTER <= DISPATCH_COUNTER + 1;
end
end                
                                                            
                                                            
                                                            
                                        
                                        
always_comb begin
          NEXT_STATE = CURRENT_STATE;
          DDR_RE = 0;
          DDR_WE = 0;
          SRAM_WE = 0;
          SRAM_RE = 0;
          SRAM_ADDRESS = '{4'h0,4'h0};
          SRAM_WRITE_A = 0;
          SRAM_WRITE_B = 0;
          SKEW = 0;
          ACTUAL_DDR_ADDRESS_A = 0;
          ACTUAL_DDR_ADDRESS_B = 0;
          ACTUAL_DDR_ADDRESS_C = 0; 
          DDR_OUT_C = 0;
          OUTPUT_BUFFER_RE = 0;
          OUTPUT_BUFFER_ADDR = 0;
          START = 0;
          CLR_IN = 0;
          CLR_ACCUMULATE = 0;
          PACKING_ENABLE = 0;
          


          case (CURRENT_STATE)
          


          IDLE : begin
                    if (CONTROL_REG == 32'b1) begin
                              NEXT_STATE = FETCH;
                    end
                    end
          


          FETCH : begin
                    DDR_RE = 1;
                    SRAM_WE = 1;
                    ACTUAL_DDR_ADDRESS_A = SRC_A_ADDRESS + SRAM_ADDRESS_COUNTER[0];
                    ACTUAL_DDR_ADDRESS_B = SRC_B_ADDRESS + SRAM_ADDRESS_COUNTER[1];
                    SRAM_ADDRESS = SRAM_ADDRESS_COUNTER;
                    SRAM_WRITE_A = DDR_IN_A;
                    SRAM_WRITE_B = DDR_IN_B;
                    if (SRAM_ADDRESS_COUNTER[0] == 4'hf && SRAM_ADDRESS_COUNTER[1] == 4'hf) begin
                              NEXT_STATE = LOAD;
                    end
                    else begin
                              NEXT_STATE = FETCH;
                    end
                    end



          LOAD : begin
                    SRAM_ADDRESS = SRAM_ADDRESS_COUNTER;
                    PACKING_ENABLE = 1;
                    SRAM_RE = 1;
                    if (SRAM_ADDRESS_COUNTER[0] == 4'hf && SRAM_ADDRESS_COUNTER[1] == 4'hf) begin
                              NEXT_STATE = WAIT_READY;
                    end
                    else begin
                              NEXT_STATE = LOAD;
                    end
                    end



          WAIT_READY : begin
                    if (READY) NEXT_STATE = SKEW_START;
                    end
          
          SKEW_START : begin
                    SKEW = 1;
                    NEXT_STATE = WAIT_VALID;
                    end
          
          WAIT_VALID : begin
                    if (VALID_OUT_CONTROLLER) begin
                              NEXT_STATE = WAIT_DONE;
                              START = 1;
                    end
          end


          WAIT_DONE : begin
                    if (DONE) NEXT_STATE = CLEARING_STATE;
                    end
          
          CLEARING_STATE : begin
                    CLR_ACCUMULATE = 1;
                    CLR_IN = 1;
                    NEXT_STATE = CLEARING_LOW;
                    end
                    
          CLEARING_LOW : begin
                    CLR_ACCUMULATE = 0;
                    CLR_IN = 0;
                    NEXT_STATE = DISPATCH;
                    end
                    

          DISPATCH : begin
                    OUTPUT_BUFFER_RE = 1;
                    OUTPUT_BUFFER_ADDR = {5'b0, DISPATCH_COUNTER};
                    DDR_WE = 1;
                    ACTUAL_DDR_ADDRESS_C = DEST_ADDRESS + DISPATCH_COUNTER;
                    DDR_OUT_C = OUTPUT_BUFFER_IN;
                    if (DISPATCH_COUNTER == 4'hf) begin
                              NEXT_STATE = COMPLETE;
                    end else begin
                              NEXT_STATE = DISPATCH;
                    end
                    end



          COMPLETE : begin
                    NEXT_STATE = IDLE;
                    end
                    
          default : ;
          
          endcase
end          
endmodule         