module Memory_Mapped_IO(
          input logic CLK,
          input logic RST,
          
          input logic [31:0] DATA,
          input logic [2:0] ADDRESS,
          input logic WE,
          input logic RE,
          
          output logic [31:0]CONTROL_REG,
          output logic [31:0] STATUS_REG,
          output logic [31:0] SRCA_ADDR_REG,
          output logic [31:0] SRCB_ADDR_REG,
          output logic [31:0] DEST_ADDR_REG,
          output logic [31:0] PERFORMANCE_REG,
          output logic [63:0] NAME_REG
          );

localparam CONTROL = 3'b000;
localparam STATUS = 3'b001;
localparam SRCA_ADDR = 3'b010;
localparam SRCB_ADDR = 3'b011;
localparam DEST_ADDR = 3'b100;
localparam PERFORMANCE = 3'b101;
localparam NAME = 3'b110;

 
 
     
logic [31:0] control_reg;
logic [31:0] status_reg;
logic [31:0] srca_addr_reg;
logic [31:0] srcb_addr_reg;
logic [31:0] dest_addr_reg;
logic [31:0] performance_reg;
    

    
    always_ff @(posedge CLK) begin
          if (RST) begin
                    control_reg <= 0;
                    status_reg <= 0;
                    srca_addr_reg <= 0;
                    srcb_addr_reg <= 0;
                    dest_addr_reg <= 0;
                    performance_reg <= 0;
                    end
                    
                    else if (WE) begin
                              
                              case (ADDRESS)
                                        CONTROL : control_reg <= DATA;
                                        
                                        STATUS : status_reg <= DATA;
                                        
                                        SRCA_ADDR : srca_addr_reg <= DATA;
                                        
                                        SRCB_ADDR : srcb_addr_reg <= DATA;
                                        
                                        DEST_ADDR : dest_addr_reg <= DATA;
                                        
                                        PERFORMANCE : performance_reg <= DATA;
                                        
                                        default : ;
                                        
                                        endcase
                                        end
                                        end             
                                        
                                     
                    
    
    always_comb begin
          CONTROL_REG     = 0;
          STATUS_REG      = 0;
          SRCA_ADDR_REG   = 0;
          SRCB_ADDR_REG   = 0;
          DEST_ADDR_REG   = 0;
          PERFORMANCE_REG = 0;
          NAME_REG        = 0;          
          if (RE) begin
                    
                    case (ADDRESS)
                              
                              CONTROL : CONTROL_REG = control_reg;
                              
                              STATUS : STATUS_REG = status_reg;
                              
                              SRCA_ADDR : SRCA_ADDR_REG = srca_addr_reg;
                              
                              SRCB_ADDR : SRCB_ADDR_REG = srcb_addr_reg;
                              
                              DEST_ADDR : DEST_ADDR_REG = dest_addr_reg;
                              
                              PERFORMANCE : PERFORMANCE_REG = performance_reg;
                              
                              NAME : NAME_REG = 64'h4F7074696D75734E;
                                                          
                              default : ;
                              
                              endcase
                              
                              end
                              end
     
endmodule
