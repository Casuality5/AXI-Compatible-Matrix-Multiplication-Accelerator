module axi_dma(
    input logic m_axi_aclk,
    input logic m_axi_aresetn,
    
    input logic dma_start,
    input logic [63:0] dma_src_addr,
    input logic [63:0] dma_dest_addr,
    output logic [63:0] performance,
    output logic dma_read_done,
    output logic dma_write_done,
    
    // STREAMING INTERFACE TO/FROM DATAPATH

    output logic dma_busy,
    input logic [33:0] read_out,
    input logic from_accel_valid,
    output logic [63:0] to_accel_data,
    output logic to_accel_valid,
    output logic from_accel_ready,

    // HARDWARE CONTROL WIRES TO DATAPATH EXPOSED AS PORTS

    output logic packing_enable,
    output logic skew,
    output logic start,
    output logic clear,
    output logic re,
    output logic [8:0] addr,
    input  logic ready,
    input  logic valid_out_controller,
    input  logic done,    

    // ADDRESS READ (AR) CHANNEL

    output logic  [63:0] m_axi_araddr,
    output logic m_axi_arvalid,
    input logic m_axi_arready,
    output logic [7:0] m_axi_arlen,      // WILL BE HARDCODED FOR 16 BITS
    output logic [2:0] m_axi_arsize,     // WILL BE HARDCODED TO 3'b011 
    output logic [1:0] m_axi_arburst,    // WILL BE HARDCODED TO 2'b01 (INCREMENTING)

    // READ DATA (R) CHANNEL

    input logic [63:0] m_axi_rdata,
    input logic m_axi_rvalid,
    output logic m_axi_rready,
    input logic m_axi_rlast,
    input logic [1:0] m_axi_rresp,

    // ADDRESS WRITE (AW) CHANNEL

    output logic [63:0] m_axi_awaddr,
    output logic m_axi_awvalid,
    input logic m_axi_awready,
    output logic [7:0] m_axi_awlen,     // WILL BE HARDCODED FOR 16 BITS
    output logic [2:0] m_axi_awsize,    // WILL BE HARDCODED TO 3'b011
    output logic [1:0] m_axi_awburst,   // WILL BE HARCODED TO 2'b01 (INCREMENTING)

    // WRITE DATA (W) CHANNEL

    output logic [63:0] m_axi_wdata,
    output logic [7:0] m_axi_wstrb,     // 8'b1111_1111
    output logic m_axi_wvalid,
    input logic m_axi_wready,
    output logic m_axi_wlast,

    // WRITE RESPONSE (B) CHANNEL

    input logic m_axi_bvalid,
    output logic m_axi_bready,
    input logic [1:0] m_axi_bresp
);

logic [63:0] src_addr_reg;
logic [63:0] dest_addr_reg;
logic [3:0] burst_counter;
logic [8:0] next_out_buf_addr;
logic [8:0] out_buf_addr_reg;

typedef enum logic [3:0] {

    dma_idle,
    dma_send_addr,
    dma_read_burst,
    dma_compute_start,
    dma_skew_start,
    dma_compute_done,
    dma_write_addr,
    dma_write_data,
    dma_wait_resp
} dma_states;

dma_states current_dma_state, next_dma_state;

always_ff @(posedge m_axi_aclk) begin
    if (!m_axi_aresetn) begin
        current_dma_state <= dma_idle;
    end else begin
        current_dma_state <= next_dma_state;

        if (current_dma_state == dma_write_data) begin
            out_buf_addr_reg <= next_out_buf_addr;

            if (m_axi_wvalid && m_axi_wready) begin
                burst_counter <= burst_counter + 1;
            end
        end else begin
            burst_counter <= 4'd0;
            out_buf_addr_reg <= 9'd0;
        end
    end
end

always_ff @(posedge m_axi_aclk) begin
    if (!m_axi_aresetn) begin
        performance <= 0;
        end else begin
            
            case (current_dma_state) 
                
                dma_idle : performance <= 0;
                
                default : performance <= performance + 1;
                
            endcase       
        end
end

always_comb begin
    dma_read_done = 0;
    dma_write_done = 0;
    m_axi_araddr = 0;
    m_axi_arvalid = 0;
    m_axi_arlen = 4'hf;
    m_axi_arsize = 3'b011;
    m_axi_arburst = 2'b01;
    m_axi_rready = 0;
    m_axi_awaddr = 0;
    m_axi_awvalid = 0;
    m_axi_awlen = 4'hf;
    m_axi_awsize = 3'b011;
    m_axi_awburst = 2'b01;
    m_axi_wdata = 0;
    m_axi_wstrb = 8'hff;
    m_axi_wvalid = 0;
    m_axi_wlast = 0;
    m_axi_bready = 0;
    packing_enable = 0;//(current_dma_state == dma_compute_start) || (current_dma_state == dma_read_burst);
    skew = 0;
    re = 0;
    start = 0;
    addr = 0;
    next_out_buf_addr = out_buf_addr_reg;
    next_dma_state = current_dma_state;
//    dest_addr_reg = 0;
    from_accel_ready = 0;
//    src_addr_reg = 0;

    case (current_dma_state) 
        dma_idle : begin
            if (dma_start) begin
                src_addr_reg = dma_src_addr;
                dest_addr_reg = dma_dest_addr;
                next_dma_state = dma_send_addr;
            end
        end

        dma_send_addr : begin
            m_axi_arvalid = 1;
            m_axi_araddr = src_addr_reg;

            if (m_axi_arready) begin
                next_dma_state = dma_read_burst;
            end else begin
                next_dma_state = dma_send_addr;
            end
        end

        dma_read_burst : begin
            m_axi_rready = 1;
            to_accel_data = m_axi_rdata;
            to_accel_valid = m_axi_rvalid;
            if (m_axi_rvalid && m_axi_rready) begin
                packing_enable = 1;
                if(m_axi_rlast) begin
                    dma_read_done = 1'b1;
                    next_dma_state = dma_compute_start;
                end else begin
                    next_dma_state = dma_read_burst;
                end
                
            end else begin
                next_dma_state = dma_read_burst;
            end
            end
        
        dma_compute_start : begin
//            packing_enable = 1;
            if (ready) begin
                packing_enable = 0;
                next_dma_state = dma_skew_start;
            end
        end

        dma_skew_start : begin
            skew = 1;
            if (valid_out_controller) begin
                start = 1;
//                clear = 1;
                next_dma_state = dma_compute_done;
            end
        end

        dma_compute_done : begin
//            clear = 1;
            next_dma_state = dma_write_addr;
        end

        dma_write_addr : begin
            m_axi_awvalid = 1'b1;
            m_axi_awaddr = dest_addr_reg;

            if (m_axi_awready) begin
                next_dma_state = dma_write_data;
            end else begin
                next_dma_state = dma_write_addr;
            end
        end

        dma_write_data : begin
            addr = out_buf_addr_reg;
            re = m_axi_wready || (burst_counter == 4'd0);
            m_axi_wdata = {30'd0, read_out};
            m_axi_wvalid = 1;
            from_accel_ready = m_axi_wready;

            if(m_axi_wvalid && m_axi_wready) begin
                next_out_buf_addr = out_buf_addr_reg + 1;
                if (burst_counter == 4'd15) begin
                    m_axi_wlast = 1;
                    next_dma_state = dma_wait_resp;
                end else begin
                    next_dma_state = dma_write_data;
                end
            end else begin
                next_dma_state = dma_write_data;
            end
        end

        dma_wait_resp : begin
            m_axi_bready = 1;

            if (m_axi_bvalid) begin
                dma_write_done = 1;
                next_dma_state = dma_idle;
            end else begin
                next_dma_state = dma_wait_resp;
            end
        end

        default : begin
            
        end

    endcase
end
assign clear = m_axi_awvalid;
assign dma_busy = (current_dma_state != dma_idle);
endmodule