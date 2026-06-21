module axi_mmio(
    input logic s_axi_aclk,
    input logic s_axi_aresetn,

    // ADDRESS WRITE CHANNEL (AW)
    input logic [63:0] s_axi_awaddr,
    input logic s_axi_awvalid,
    output logic s_axi_awready,

    // WRITE DATA CHANNGEL (W)
    input logic [63:0] s_axi_wdata,
    input logic [3:0] s_axi_wstrb,
    input logic s_axi_wvalid,
    output logic s_axi_wready,

    // WRITE RESPONSE CHANNEL (B)
    output logic [1:0] s_axi_bresp,
    output logic s_axi_bvalid,
    input logic s_axi_bready,

    // ADDRESS READ CHANNEL (AR)
    input logic [63:0] s_axi_araddr,
    input logic s_axi_arvalid,
    output logic s_axi_arready,

    // READ DATA CHANNEL (R)
    output logic [63:0] s_axi_rdata,
    output logic [1:0] s_axi_rresp,
    output logic s_axi_rvalid,
    input logic s_axi_rready,

    output logic [63:0] CONTROL,
    input  logic [63:0] STATUS,
    output logic [63:0] SRC_ADDRESS,
    output logic [63:0] DEST_ADDRESS,
    input  logic [63:0] PERFORMANCE,
    output logic [63:0] NAME
);

logic [63:0] MEM [0:4];
logic [2:0] latch_address;

typedef enum logic [1:0] {

    write_idle,
    write_response,
    write_done

} write_state;

write_state current_write_state, next_write_state;

typedef enum logic {

    read_idle,
    read_data 
} read_state;

read_state current_read_state, next_read_state;




always_ff @(posedge s_axi_aclk) begin
    if (~s_axi_aresetn) begin
        current_write_state <= write_idle;
        current_read_state <= read_idle;
    end else begin
        current_write_state <= next_write_state;
        current_read_state <= next_read_state;
    end
end


always_comb begin
    // Default values
    s_axi_awready = 0;
    s_axi_wready = 0;
    s_axi_bvalid = 0;
    s_axi_bresp = 2'b00; // OKAY
    s_axi_arready = 0;
    s_axi_rdata = 64'b0;
    s_axi_rresp = 2'b00; // OKAY
    s_axi_rvalid = 0;
    

    case (current_write_state)

        write_idle : begin
            s_axi_awready = 1;
            s_axi_wready = 1;

            if(s_axi_awvalid && s_axi_wvalid) begin
                if ((s_axi_awaddr[5:3] != 3'd1) && (s_axi_awaddr[5:3] != 3'd4)) begin
                    MEM[s_axi_awaddr[5:3]] = s_axi_wdata;
                    end
                next_write_state = write_response;
            end else begin
                next_write_state = write_idle;
            end
        end

        write_response : begin
            s_axi_awready = 0;
            s_axi_wready = 0;
            s_axi_bvalid = 1;
            s_axi_bresp = 2'b00; // OKAY

            if (s_axi_bready) begin
                next_write_state = write_done;
            end else begin
                next_write_state = write_response;
            end
        end

        write_done : begin
            s_axi_bvalid = 0;
            next_write_state = write_idle;
        end

        default : begin
            next_write_state = write_idle;
        end

    endcase

    case (current_read_state)

        read_idle : begin
            s_axi_arready = 1;
            if (s_axi_arvalid) begin
                latch_address = s_axi_araddr[5:3];
                next_read_state = read_data;
            end else begin
                next_read_state = read_idle;
            end
    
        end

        read_data : begin
            s_axi_arready = 0;
            s_axi_rresp = 2'b00; // OKAY
            s_axi_rvalid = 1;

            case (latch_address)

                3'd0 : s_axi_rdata = MEM[0];
                
                3'd1 : s_axi_rdata = STATUS;
                
                3'd2 : s_axi_rdata = MEM[2];
                
                3'd3 : s_axi_rdata = MEM[3];
                 
                3'd4 : s_axi_rdata = PERFORMANCE;

                3'd5 : s_axi_rdata = 64'hDEAD_BEEF_DEAD_BEEF;

                default : s_axi_rdata = 64'hDEAD_BEEF_DEAD_BEEF;

            endcase



            if (s_axi_rready) begin
//                s_axi_rvalid = 0;
                next_read_state = read_idle;
            end else next_read_state = read_data;
        end
    endcase
end

assign CONTROL      = MEM[0];
//assign MEM[1]       = STATUS;
assign SRC_ADDRESS  = MEM[2];
assign DEST_ADDRESS = MEM[3];
//assign MEM[4]       = PERFORMANCE;
assign NAME         = {32'h4F707469, 32'h6D75734E};

endmodule