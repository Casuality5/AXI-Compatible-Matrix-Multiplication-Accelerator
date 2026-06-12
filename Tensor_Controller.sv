module Tensor_Controller(
          input logic CLK,
          input logic RST,
          input logic [31:0] CONTROL_REG,
          input logic [31:0] SRCA_ADDR_REG,
          input logic [31:0] SRCB_ADDR_REG,
          input logic [31:0] DEST_ADDR_REG,
          
          input logic DMA_FETCH_READY,            // DMA SIGNAL
          input logic DMA_FETCH_COMPLETE,         // DMA SIGNAL
          input logic DMA_DISPATCH_READY,         // DMA SIGNAL
          input logic DMA_DISPATCH_COMPLETE,      // DMA SIGNAL
          
          input logic IPU_READY,            // IPU SIGNAL
          input logic IPU_LOADING_COMPLETE, // IPU SIGNAL
          input logic READY,                // READY
          
          input logic OPU_READY,                  // OPU SIGNAL
          input logic OPU_UNLOADING_COMPLETE,     // OPU SIGNAL
          
          output logic SKEW,            // SKEWER SIGNAL
          input logic SKEW_DONE,        // SKEWER SIGNAL 
          
          
          output logic VALID_BUFFER_IN, //BUFFER SIGNAL
          input logic VALID_BUFFER_OUT, //BUFFER SIGNAL
          
          output logic VALID_REGISTER_IN, // REGISTER SIGNAL
          output logic CLR_IN,            // REGISTER SIGNAL
          input logic VALID_REGISTER_OUT, // REGISTER SIGNAL
          
          output logic VALID_IN_ARRAY,  // SYSTOLIC ARRAY SIGNAL
          output logic CLR,             // SYSTOLIC ARRAY SIGNAL
          input logic VALID,            // SYSTOLIC ARRAY SIGNAL
          
          
          output logic START, // OUTPUT UNPACKING UNIT SIGNALS
          input logic DONE,   // OUTPUT UNPACKING UNIT SIGNALS
          
          
          output logic [31:0] STATUS_REG,
          output logic [31:0] PERFORMANCE_REG,
          output logic [31:0] SRCA_ADDR_to_DMA,
          output logic [31:0] SRCB_ADDR_to_DMA,
          output logic [31:0] DEST_ADDR_to_DMA,
          
          output logic LOAD_to_Tensor_DataPath,
          output logic UNLOAD_from_Tensor_DataPath
    );

typedef enum logic [1:0] {
          
          IPU_IDLE,
          IPU_LOADING,
          IPU_LOADING_DONE
          } IPU_STAGE;
          
          IPU_STAGE CURRENT_IPU_STAGE, NEXT_IPU_STAGE;

typedef enum logic [1:0] {
          
          OPU_IDLE,
          OPU_UNLOADING,
          OPU_UNLOADING_DONE
          } OPU_STAGE;
          
          OPU_STAGE CURRENT_OPU_STAGE, NEXT_OPU_STAGE;



typedef enum logic [1:0] {
          
          DMA_FETCH_IDLE,
          DMA_FETCH_RUNNING,
          DMA_FETCH_DONE
          
          } DMA_FETCHING_STAGE;
          
          DMA_FETCHING_STAGE CURRENT_DMA_FETCHING_STAGE, NEXT_DMA_FETCHING_STAGE;

typedef enum logic [1:0] {
          
          DMA_DISPATCH_IDLE,
          DMA_DISPATCH_RUNNING,
          DMA_DISPATCH_DONE
          
          } DMA_DISPATCHING_STAGE;
          
          DMA_DISPATCHING_STAGE CURRENT_DMA_DISPATCHING_STAGE, NEXT_DMA_DISPATCHING_STAGE;

typedef enum logic [3:0] {
          
          IDLE,
          
          DMA_FETCH_STAGE,
          
          LOAD_STAGE,
          
          PACKING_STAGE,
          
          SKEWING_STAGE,
          
          BUFFER_STAGE,
          
          REGISTER_STAGE,
          
          COMPUTE_STAGE,
          
          UNPACKING_STAGE,
          
          UNLOAD_STAGE,
          
          DMA_DISPATCH_STAGE,
          
          COMPLETE
          } STAGE;
          
          STAGE CURRENT_STAGE, NEXT_STAGE;
          
          
          
          always_ff @ (posedge CLK) begin
                    
                    if (RST) begin 
                              CURRENT_STAGE <= IDLE;
                              CURRENT_DMA_FETCHING_STAGE <= DMA_FETCH_IDLE;
                              CURRENT_DMA_DISPATCHING_STAGE <= DMA_DISPATCH_IDLE;
                              CURRENT_IPU_STAGE <= IPU_IDLE;
                              CURRENT_OPU_STAGE <= OPU_IDLE;
                              PERFORMANCE_REG <= 0;
                              end
                    
                    else begin
                              CURRENT_STAGE <= NEXT_STAGE;
                              CURRENT_DMA_FETCHING_STAGE <= NEXT_DMA_FETCHING_STAGE;
                              CURRENT_DMA_DISPATCHING_STAGE <= NEXT_DMA_DISPATCHING_STAGE;
                              CURRENT_IPU_STAGE <= NEXT_IPU_STAGE;
                              CURRENT_OPU_STAGE <= NEXT_OPU_STAGE;
                              if (CURRENT_STAGE != IDLE && CURRENT_STAGE != COMPLETE)
                                        PERFORMANCE_REG <= PERFORMANCE_REG + 1;
                    
                    end
                    end     
          
          
          always_comb begin
                    NEXT_STAGE = CURRENT_STAGE;

                    NEXT_DMA_FETCHING_STAGE = CURRENT_DMA_FETCHING_STAGE;
                    NEXT_DMA_DISPATCHING_STAGE = CURRENT_DMA_DISPATCHING_STAGE;
                    NEXT_IPU_STAGE = CURRENT_IPU_STAGE;
                    NEXT_OPU_STAGE = CURRENT_OPU_STAGE;

                    SRCA_ADDR_to_DMA = 32'b0;
                    SRCB_ADDR_to_DMA = 32'b0;
                    DEST_ADDR_to_DMA = 32'b0;

                    LOAD_to_Tensor_DataPath = 1'b0;
                    UNLOAD_from_Tensor_DataPath = 1'b0;

                    SKEW = 1'b0;
                    VALID_BUFFER_IN = 1'b0;
                    VALID_REGISTER_IN = 1'b0;
                    VALID_IN_ARRAY = 1'b0;

                    START = 1'b0;
                    CLR = 1'b0;
                    CLR_IN = 1'b0;

                    STATUS_REG = 32'b1;
                    
                    case (CURRENT_STAGE)
                              
                              IDLE : begin
                                        STATUS_REG = 32'b0;
                                        if (CONTROL_REG[0] == 1'b1) begin
                                                  
                                                  NEXT_STAGE = DMA_FETCH_STAGE;
                                                  end 
                                                  
                                                  else NEXT_STAGE = IDLE;
                                                  end
                                                    
                              
                              DMA_FETCH_STAGE : begin                                                                             // THIS STAGE REQUIRES DMA HANDSHAKE
                                        
                                        case (CURRENT_DMA_FETCHING_STAGE)
                                                  
                                                  DMA_FETCH_IDLE: begin
                                                            if (DMA_FETCH_READY) begin
                                                                      SRCA_ADDR_to_DMA = SRCA_ADDR_REG;
                                                                      SRCB_ADDR_to_DMA = SRCB_ADDR_REG;
                                                                      NEXT_DMA_FETCHING_STAGE = DMA_FETCH_RUNNING;
                                                                      end
                                                                      
                                                                      else begin
                                                                                SRCA_ADDR_to_DMA = 32'b0;
                                                                                SRCB_ADDR_to_DMA = 32'b0;
                                                                                NEXT_DMA_FETCHING_STAGE = DMA_FETCH_IDLE;
                                                                                end
                                                                                end
                                                  
                                                  
                                                  DMA_FETCH_RUNNING : begin
                                                            
                                                            if (DMA_FETCH_COMPLETE) NEXT_DMA_FETCHING_STAGE = DMA_FETCH_DONE; 
                                                            
                                                            else NEXT_DMA_FETCHING_STAGE = DMA_FETCH_RUNNING;
                                                            end
                                                            
                                                                     
                                                  
                                                  DMA_FETCH_DONE : begin
                                                            NEXT_DMA_FETCHING_STAGE = DMA_FETCH_IDLE;
                                                            
                                                            NEXT_STAGE = LOAD_STAGE;
                                                            
                                                            end
                                                            
                                                            
                                                  
                                                  default : ;
                                                  
                                                  endcase
                                                  end                    
                                                            
          
          
          
                              LOAD_STAGE : begin                                                                             // THIS STAGE REQUIRES IPU HANDSHAKE
                                        
                                        case (CURRENT_IPU_STAGE)
                                                  
                                                  IPU_IDLE : begin
                                                            
                                                            if (IPU_READY) begin
                                                                      LOAD_to_Tensor_DataPath = 1'b1;
                                                                      NEXT_IPU_STAGE = IPU_LOADING;
                                                                      end
                                                                      
                                                                      else begin
                                                                                LOAD_to_Tensor_DataPath = 1'b0;
                                                                                NEXT_IPU_STAGE = IPU_IDLE;
                                                                                end
                                                                                end
                                                   
                                                  
                                                  IPU_LOADING: begin
                                                            
                                                            if (IPU_LOADING_COMPLETE) NEXT_IPU_STAGE = IPU_LOADING_DONE;     
                                                            
                                                            else NEXT_IPU_STAGE = IPU_LOADING;
                                                            
                                                            end
                                                            
  
  
                                                 IPU_LOADING_DONE : begin
                                                            NEXT_IPU_STAGE = IPU_IDLE;
                                                            NEXT_STAGE = PACKING_STAGE;
                                                            end
                                                            
                                                            
                                                 default : ;
                                                 
                                                 endcase
                                                 end
                                                            
                              PACKING_STAGE : begin
                                        
                                        if (READY) NEXT_STAGE = SKEWING_STAGE;
                                        
                                        else NEXT_STAGE = PACKING_STAGE;
                                        
                                        end
                                                                      
                              
                              SKEWING_STAGE : begin
                                        
                                        SKEW = 1'b1;
                                        
                                        if (SKEW_DONE) NEXT_STAGE = BUFFER_STAGE;
                                        
                                        else NEXT_STAGE = SKEWING_STAGE;
                                        
                                        end
                                        
                                                                   
                              BUFFER_STAGE : begin
                                        
                                        VALID_BUFFER_IN = 1'b1;
                                        CLR_IN = 1'b1;
                                        
                                        if (VALID_BUFFER_OUT) NEXT_STAGE = REGISTER_STAGE;
                                        
                                        else NEXT_STAGE = BUFFER_STAGE;
                                        
                                        end
                                        
                                        
                              REGISTER_STAGE : begin                                                          // CHECK FOR CLR_IN LOGIC
                                        
                                        VALID_REGISTER_IN = 1'b1;
                                        
                                        if (VALID_REGISTER_OUT) NEXT_STAGE = COMPUTE_STAGE;
                                        
                                        else NEXT_STAGE = REGISTER_STAGE;
                                        
                                        end
                                        
                              
                              COMPUTE_STAGE : begin                                                           // CHECK FOR CLR LOGIC (CURRENTLY SYSTOLIC)
                              
                                        VALID_IN_ARRAY = 1'b1;
                                        CLR = 1'b1;
                                        
                                        if (VALID) NEXT_STAGE = UNPACKING_STAGE;
                                        
                                        else NEXT_STAGE = COMPUTE_STAGE;
                                        
                                        end
                                        
                              
                              UNPACKING_STAGE : begin
                                        
                                        START = 1'b1;
                                        
                                        if (DONE) NEXT_STAGE = UNLOAD_STAGE;
                                        
                                        else NEXT_STAGE = UNPACKING_STAGE;
                                        
                                        end
                                        
                                                                                                    
                             
                              UNLOAD_STAGE : begin
                                        
                                        case (CURRENT_OPU_STAGE)
                                                  
                                                  OPU_IDLE : begin
                                                            
                                                            if (OPU_READY) begin
                                                                      UNLOAD_from_Tensor_DataPath = 1'b1;
                                                                      NEXT_OPU_STAGE = OPU_UNLOADING;
                                                                      end
                                                            
                                                            else begin
                                                                      UNLOAD_from_Tensor_DataPath = 1'b0;
                                                                      NEXT_OPU_STAGE = OPU_IDLE;
                                                                      end
                                                                      end        
                                                  
                                                  OPU_UNLOADING : begin
                                                            
                                                            if (OPU_UNLOADING_COMPLETE) NEXT_OPU_STAGE = OPU_UNLOADING_DONE;
                                                            
                                                            else NEXT_OPU_STAGE = OPU_UNLOADING;
                                                            
                                                            end
                                                                      
                                        
                                                  
                                                  
                                                  OPU_UNLOADING_DONE : begin
                                                            
                                                            NEXT_OPU_STAGE = OPU_IDLE;
                                                            
                                                            NEXT_STAGE = DMA_DISPATCH_STAGE;
                                                            
                                                            end
                                                                       
                                                            
                                                  default : ;
                                                  
                                                  endcase
                                                  end
                                                  
                                                  
                                                  
                                                  
                                                  
                               DMA_DISPATCH_STAGE : begin
                                        
                                        case (CURRENT_DMA_DISPATCHING_STAGE)
                                        
                                                  DMA_DISPATCH_IDLE : begin
                                                            
                                                            if (DMA_DISPATCH_READY) begin
                                                                     DEST_ADDR_to_DMA = DEST_ADDR_REG;
                                                                     NEXT_DMA_DISPATCHING_STAGE = DMA_DISPATCH_RUNNING;
                                                                     end
                                                                     
                                                                     else begin
                                                                      
                                                                      DEST_ADDR_to_DMA = 32'b0;
                                                                      NEXT_DMA_DISPATCHING_STAGE = DMA_DISPATCH_IDLE;
                                                                      end
                                                                      end
                                                                                         
                                                                      
                                                  
                                                  DMA_DISPATCH_RUNNING : begin
                                                            
                                                            if (DMA_DISPATCH_COMPLETE) NEXT_DMA_DISPATCHING_STAGE = DMA_DISPATCH_DONE;
                                                            
                                                            else NEXT_DMA_DISPATCHING_STAGE = DMA_DISPATCH_RUNNING;
                                                            end
                                                            
                                                                      
                                                  
                                                  DMA_DISPATCH_DONE : begin
                                                            
                                                            NEXT_DMA_DISPATCHING_STAGE = DMA_DISPATCH_IDLE;
                                                            
                                                            NEXT_STAGE = COMPLETE;
                                                            
                                                            end
                                                            
                                                                      
                                                            
                                                  default : ;
                                                  
                                                  endcase
                                                  end
                                                  
                                                  
                              COMPLETE : begin
                                        
                                        STATUS_REG = 32'b10;
                                        
                                        NEXT_STAGE = IDLE;
                                        
                                        end
                                                            

                              default : ;                               
                    endcase                                                           
          end                                                           
                                                           
endmodule
