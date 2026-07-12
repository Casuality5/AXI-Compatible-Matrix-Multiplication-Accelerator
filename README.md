# OptimusN: AXI4-Compatible DMA-Driven Tensor Accelerator

OptimusN is a SystemVerilog RTL implementation of a DMA-driven tensor accelerator for 4 x 4 matrix multiplication. The design combines an AXI4-Lite control plane with an AXI4 master DMA engine to fetch operands, sequence the datapath, execute the matrix operation, and write results back to memory.

![OptimusN block diagram](<Block Diagram.png>)

## Architecture

The accelerator is structured around a DMA-control engine and a modular compute datapath.

### Operation flow

1. Software configures source, destination, and control registers through AXI4-Lite MMIO.
2. The DMA-control engine reads source matrix data from external memory over AXI4.
3. The input packing unit and input skewer arrange operands for systolic execution.
4. Tensor buffers and registers stream operands into the 4 x 4 systolic array.
5. Sixteen processing elements perform parallel multiply-accumulate operations.
6. The output buffer collects results and the DMA-control engine writes them to the destination address.

## RTL modules

| Module | Responsibility |
| --- | --- |
| `axi_tpu.sv` | Top-level accelerator integration, AXI4-Lite slave interface, and AXI4 master interface. |
| `axi_mmio.sv` | Memory-mapped control and status register interface. |
| `axi_dma.sv` | DMA control, AXI transactions, datapath sequencing, and writeback orchestration. |
| `datapath.sv` | Connects the input preparation, storage, systolic array, and output stages. |
| `Input_Packing_Unit.sv` | Packs incoming matrix operands. |
| `Tensor_Input_Skewer.sv` | Time-skews tensor data for systolic-array propagation. |
| `Tensor_Buffer.sv` / `Tensor_Register.sv` | Stores and presents prepared tensor operands. |
| `SYSTOLIC_ARRAY.sv` | 4 x 4 compute array containing 16 processing elements. |
| `Processing_Element.sv` | Processing-element multiply-accumulate datapath. |
| `Output_Unpacking_Unit.sv` | Prepares accumulated results for output/writeback. |

## Verification

Functional RTL simulation exercises the complete data path:

- AXI read transactions fetch source matrices into the accelerator.
- The datapath prepares and propagates values through the systolic array.
- Computed results are collected in the output buffer.
- AXI write transactions return results to the destination memory address.
- The controller returns to idle after writeback.

### End-to-end check

An end-to-end simulation confirmed that the observed output matches the expected 4 x 4 result:

```text
Expected output:  [ 1  2  3  4 ] [ 5  6  7  8 ] [ 9 10 11 12 ] [13 14 15 16]
Observed output:  [ 1  2  3  4 ] [ 5  6  7  8 ] [ 9 10 11 12 ] [13 14 15 16]
```

## Measured latency

Performance was evaluated in RTL simulation for one end-to-end 4 x 4 matrix multiplication at a 50 MHz clock (20 ns period).

| Operation stage | Clock cycles |
| --- | ---: |
| DMA fetch | 18 |
| Input preparation | 5 |
| Matrix computation | 10 |
| Result writeback | 21 |
| **Total latency** | **54** |

The full operation completes in approximately **1.08 us**. This includes memory fetch, datapath preparation, systolic-array computation, and result writeback.

## Current status and next steps

The RTL has been implemented and functionally verified in simulation, including AXI data movement, datapath sequencing, systolic matrix multiplication, and memory writeback.

Planned work includes FPGA deployment and board-level validation, integration with the VEGA RISC-V processor subsystem, software drivers for memory-mapped control and DMA transfers, and performance optimization through workload analysis and improved scheduling.
