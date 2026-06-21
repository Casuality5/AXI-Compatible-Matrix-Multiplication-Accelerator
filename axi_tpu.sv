module axi_tpu(
    input logic m_axi_aclk,
    input logic m_axi_aresetn,

    // CPU MMIO Control Interface (UPDATED to outputs for external system monitoring / Debugging)
//    output logic        dma_start_monitor,
//    output logic [63:0] dma_src_addr_monitor,
//    output logic [63:0] dma_dest_addr_monitor,
//    output logic        dma_read_done,
//    output logic        dma_write_done,
//    output logic        dma_busy,
    
    // AXI4-LITE SLAVE MMIO INTERFACE
    input  logic [63:0] s_axi_awaddr,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,

    // WRITE DATA CHANNEL (W)
    input  logic [63:0] s_axi_wdata,
    input  logic [3:0]  s_axi_wstrb,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,

    // WRITE RESPONSE CHANNEL (B)
    output logic [1:0]  s_axi_bresp,
    output logic        s_axi_bvalid,
    input  logic        s_axi_bready,

    // ADDRESS READ CHANNEL (AR)
    input  logic [63:0] s_axi_araddr,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,

    // READ DATA CHANNEL (R)
    output logic [63:0] s_axi_rdata,
    output logic [1:0]  s_axi_rresp,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready,

    
    // --- FULL EXTERNAL AXI4 MASTER MEMORY INTERFACE ---
    output logic [63:0] m_axi_araddr,
    output logic        m_axi_arvalid,
    input  logic        m_axi_arready,
    output logic [7:0]  m_axi_arlen,
    output logic [2:0]  m_axi_arsize,
    output logic [1:0]  m_axi_arburst,

    input  logic [63:0] m_axi_rdata,
    input  logic        m_axi_rvalid,
    output logic        m_axi_rready,
    input  logic        m_axi_rlast,
    input  logic [1:0]  m_axi_rresp,

    output logic [63:0] m_axi_awaddr,
    output logic        m_axi_awvalid,
    input  logic        m_axi_awready,
    output logic [7:0]  m_axi_awlen,
    output logic [2:0]  m_axi_awsize,
    output logic [1:0]  m_axi_awburst,

    output logic [63:0] m_axi_wdata,
    output logic [7:0]  m_axi_wstrb,
    output logic        m_axi_wvalid,
    input  logic        m_axi_wready,
    output logic        m_axi_wlast,

    input  logic        m_axi_bvalid,
    output logic        m_axi_bready,
    input  logic [1:0]  m_axi_bresp
    );
    
    // Internal Wiring Declarations
    logic skew_wire;
    logic packing_enable_wire;
    logic clr_wire;
    logic re_wire;
    logic start_wire;
    logic [8:0] addr_wire;
    logic valid_controller_wire;
    logic ready_wire;
    logic done_wire;
    logic [63:0] to_accel_data;
    logic [33:0] read_out_wire; 
    
    
    logic [63:0] CONTROL;
    logic [63:0] STATUS;
    logic [63:0] SRC_ADDRESS;
    logic [63:0] DEST_ADDRESS;
    logic [63:0] PERFORMANCE;
    logic [63:0] NAME;

    
    // FIXED: Clean directional status loops to monitoring pins
    assign STATUS                 = {61'b0, dma_write_done, dma_read_done, dma_busy};
    assign dma_start_monitor      = CONTROL[0];
    assign dma_src_addr_monitor   = SRC_ADDRESS;
    assign dma_dest_addr_monitor  = DEST_ADDRESS;

    // -------------------------------------------------------------------------
    // 1. DATAPATH INSTANTIATION
    // -------------------------------------------------------------------------
    datapath dp (
        .CLK(m_axi_aclk),
        .RST(!m_axi_aresetn), 
        .PACKING_ENABLE(packing_enable_wire),
        .SKEW(skew_wire),
        .CLR_IN(clr_wire),
        .CLR_ACCUMULATE(clr_wire),
        .START(start_wire),
        .ADDR(addr_wire),
        .RE(re_wire),
              
        .UNPACKED_INPUT_A(to_accel_data[31:16]),
        .UNPACKED_INPUT_B(to_accel_data[15:0]),
              
        .READY(ready_wire),
        .VALID_OUT_CONTROLLER(valid_controller_wire),
        .DONE(done_wire),
        .READ_OUT(read_out_wire) 
    );
   
    // -------------------------------------------------------------------------
    // 2. AXI MASTER DMA CONTROLLER INSTANTIATION
    // -------------------------------------------------------------------------
    axi_dma adma (
        .m_axi_aclk            (m_axi_aclk),
        .m_axi_aresetn         (m_axi_aresetn),
        
        // System Control Inputs (Fed directly from internal MMIO configurations)
        .dma_start             (CONTROL[0]),
        .dma_src_addr          (SRC_ADDRESS),
        .dma_dest_addr         (DEST_ADDRESS),
        .performance           (PERFORMANCE),
        .dma_read_done         (dma_read_done),
        .dma_write_done        (dma_write_done),
        .dma_busy              (dma_busy),
        
        // Streaming Datapath Connections
        .read_out              (read_out_wire),
        .from_accel_valid      (1'b1), 
        .to_accel_data         (to_accel_data),
        .to_accel_valid        (),     
        .from_accel_ready      (),     
        
        // FSM Configuration & Control Feed
        .packing_enable        (packing_enable_wire),
        .skew                  (skew_wire),
        .start                 (start_wire),
        .re                    (re_wire),
        .addr                  (addr_wire),
        .ready                 (ready_wire),
        .valid_out_controller  (valid_controller_wire),
        .done                  (done_wire),
        .clear                 (clr_wire),
        
        // Full External AXI Master Port Wiring Pass-Through
        .m_axi_araddr          (m_axi_araddr),
        .m_axi_arvalid         (m_axi_arvalid),
        .m_axi_arready         (m_axi_arready),
        .m_axi_arlen           (m_axi_arlen),
        .m_axi_arsize          (m_axi_arsize),
        .m_axi_arburst         (m_axi_arburst),
        
        .m_axi_rdata           (m_axi_rdata),
        .m_axi_rvalid          (m_axi_rvalid),
        .m_axi_rready          (m_axi_rready),
        .m_axi_rlast           (m_axi_rlast),
        .m_axi_rresp           (m_axi_rresp),
        
        .m_axi_awaddr          (m_axi_awaddr),
        .m_axi_awvalid         (m_axi_awvalid),
        .m_axi_awready         (m_axi_awready),
        .m_axi_awlen           (m_axi_awlen),
        .m_axi_awsize          (m_axi_awsize),
        .m_axi_awburst         (m_axi_awburst),
        
        .m_axi_wdata           (m_axi_wdata),
        .m_axi_wstrb           (m_axi_wstrb),
        .m_axi_wvalid          (m_axi_wvalid),
        .m_axi_wready          (m_axi_wready),
        .m_axi_wlast           (m_axi_wlast),
        
        .m_axi_bvalid          (m_axi_bvalid),
        .m_axi_bready          (m_axi_bready),
        .m_axi_bresp           (m_axi_bresp)
    );
   
    // -------------------------------------------------------------------------
    // 3. AXI SLAVE MMIO REGISTER COMPONENT INSTANTIATION
    // -------------------------------------------------------------------------
    axi_mmio ammio (
        .s_axi_aclk         (m_axi_aclk),
        .s_axi_aresetn      (m_axi_aresetn),
        
        .s_axi_awaddr       (s_axi_awaddr),
        .s_axi_awvalid      (s_axi_awvalid),
        .s_axi_awready      (s_axi_awready),
        
        .s_axi_wdata        (s_axi_wdata),
        .s_axi_wstrb        (s_axi_wstrb),
        .s_axi_wvalid       (s_axi_wvalid),
        .s_axi_wready       (s_axi_wready),
        
        .s_axi_bresp        (s_axi_bresp),
        .s_axi_bvalid       (s_axi_bvalid),
        .s_axi_bready       (s_axi_bready),
        
        .s_axi_araddr       (s_axi_araddr),
        .s_axi_arvalid      (s_axi_arvalid),
        .s_axi_arready      (s_axi_arready),
        
        .s_axi_rdata        (s_axi_rdata),
        .s_axi_rresp        (s_axi_rresp),
        .s_axi_rvalid       (s_axi_rvalid),
        .s_axi_rready       (s_axi_rready),
        
        // Parallel Output Interlock Nodes
        .CONTROL            (CONTROL),
        .STATUS             (STATUS), 
        .SRC_ADDRESS        (SRC_ADDRESS),
        .DEST_ADDRESS       (DEST_ADDRESS),
        .PERFORMANCE        (PERFORMANCE),
        .NAME               (NAME)
    );
     
endmodule