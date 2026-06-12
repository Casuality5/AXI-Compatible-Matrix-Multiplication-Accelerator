module Direct_Memory_Access_Controller(
          
          input logic CLK,
          input logic RST,
          
          input logic [31:0] SRCA_ADDR_from_CU,
          input logic [31:0] SRCB_ADDR_from_CU,
          input logic [31:0] DEST_ADDR_from_CU,
          input logic DMA_FETCH_START,
          input logic DMA_DISPATCH_START,
          
          input logic signed [15:0] DATA_IN_A,
          input logic signed [15:0] DATA_IN_B,
          input logic signed [33:0] DATA_IN_C,
          
          output logic [15:0] DATA_to_SRAM_A,
          output logic [15:0] DATA_to_SRAM_B,
          output logic [33:0] DATA_from_SRAM,
          
          
          output logic DMA_FETCH_READY,
          output logic DMA_FETCH_COMPLETE,
          output logic DMA_DISPATCH_READY,
          output logic DMA_DISPATCH_COMPLETE
    );
    
logic [31:0] COUNTER_ADDRESS_A;
logic [31:0] COUNTER_ADDRESS_B;
logic [31:0] COUNTER_ADDRESS_C;
logic [3:0] ELEMENT_COUNTER_AB;
logic [3:0] ELEMENT_COUNTER_C;

typedef enum logic [2:0] {
          
          DMA_IDLE,
          
          DMA_FETCHING,
          
          DMA_FETCHING_DONE,
          
          DMA_WAIT,
          
          DMA_DISPATCHING,
          
          DMA_DISPATCHING_DONE,
          
          DMA_OPERATION_DONE
          
          } STAGE;
          
          STAGE CURRENT_STAGE, NEXT_STAGE;
          
          
          always_ff @ (posedge CLK) begin
                    
                    if (RST)  CURRENT_STAGE <= DMA_IDLE;
                    
                    else  CURRENT_STAGE <= NEXT_STAGE;
                    
                    end
          
          
          always_ff @ (posedge CLK) begin
                    
                    if (CURRENT_STAGE == DMA_IDLE) begin
                          COUNTER_ADDRESS_A <= SRCA_ADDR_from_CU;
                          COUNTER_ADDRESS_B <= SRCB_ADDR_from_CU;
                          COUNTER_ADDRESS_C <= DEST_ADDR_from_CU;
                          ELEMENT_COUNTER_AB <= 0;
                          ELEMENT_COUNTER_C <= 0;
                          end
                          
                          else if (CURRENT_STAGE == DMA_FETCHING) begin
                              COUNTER_ADDRESS_A <= COUNTER_ADDRESS_A + 1;
                              COUNTER_ADDRESS_B <= COUNTER_ADDRESS_B + 1;
                              ELEMENT_COUNTER_AB <= ELEMENT_COUNTER_AB + 1;
                              
                              end
                              
                          else if (CURRENT_STAGE == DMA_DISPATCHING) begin
                              COUNTER_ADDRESS_C <= COUNTER_ADDRESS_C + 1;
                              ELEMENT_COUNTER_C <= ELEMENT_COUNTER_C + 1;
                              end
                              end
                          
                              
                                                 
    
          always_comb begin
                    
                   NEXT_STAGE = CURRENT_STAGE;
                    
                   DATA_to_SRAM_A = 0;
                    
                   DATA_to_SRAM_B = 0;
                    
                   DATA_from_SRAM = 0;
                    
                   DMA_FETCH_READY = 0;
                    
                   DMA_FETCH_COMPLETE = 0;
                    
                   DMA_DISPATCH_READY = 0;
                    
                   DMA_DISPATCH_COMPLETE = 0;
                    
                              
                              case (CURRENT_STAGE) 
                                        
                                        DMA_IDLE : begin
                                                   DMA_FETCH_READY = 1;
                                                   if (DMA_FETCH_START) NEXT_STAGE = DMA_FETCHING;
                                                  end
                                                                       
                                                                       
                                                                       
                                        DMA_FETCHING : begin
                                        
                                                  if (ELEMENT_COUNTER_AB == 4'hf) begin
                                                             DATA_to_SRAM_A = DATA_IN_A;
                                                             DATA_to_SRAM_B = DATA_IN_B;
                                                             NEXT_STAGE = DMA_FETCHING_DONE;
                                                             end
                                                             
                                                             else begin
                                                                      DATA_to_SRAM_A = DATA_IN_A; // CPU SIDE
                                                                      DATA_to_SRAM_B = DATA_IN_B; // CPU SIDE
                                                                      NEXT_STAGE = DMA_FETCHING;
                                                                      end
                                                                      end
                                       
                                       
                                        DMA_FETCHING_DONE : begin
                                                  DMA_FETCH_COMPLETE = 1;
                                                  NEXT_STAGE = DMA_WAIT;
                                                  end
                                                                                 
                                                                       
                                        DMA_WAIT : begin
                                                  
                                                  DMA_DISPATCH_READY = 1;                                                 
                                                  
                                                  if (DMA_DISPATCH_START) NEXT_STAGE = DMA_DISPATCHING;
                                                  
                                                  end
                                                             
                                                                       
                                       DMA_DISPATCHING : begin
                                                  
                                                  if (ELEMENT_COUNTER_C == 4'hf) begin
                                                  
                                                           DATA_from_SRAM = DATA_IN_C; // ACCELERATOR SIDE
                                                           NEXT_STAGE = DMA_DISPATCHING_DONE;
                                                           end
                                                           
                                                           else begin
                                                            
                                                            DATA_from_SRAM = DATA_IN_C;
                                                            NEXT_STAGE = DMA_DISPATCHING;
                                                            end
                                                            end
                                                                    
                                                                        
                                                                                 
                                                                       
                                                                       
                                       DMA_DISPATCHING_DONE : begin
                                                  
                                                  DMA_DISPATCH_COMPLETE = 1;
                                                  NEXT_STAGE = DMA_OPERATION_DONE;
                                                  
                                                  end
                                                                                  
                                                                       
                                                                       
                                       DMA_OPERATION_DONE : NEXT_STAGE = DMA_IDLE;
                                       
                                       
                                       
                                       default : ;
                                       
                                       endcase
                                       end                           
    
endmodule
