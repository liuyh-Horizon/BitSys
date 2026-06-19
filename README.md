# BitSys: Bitwise Systolic Array Architecture for Runtime-Reconfigurable Multi-Precision Multiplier

This repository provides the Verilog RTL implementation of **BitSys-LUT**, a runtime-reconfigurable multi-precision multiplier based on a bitwise systolic array architecture.

The current release focuses on the **multiplier RTL** of BitSys. The MAC unit, single-layer accelerator, systolic-array accelerator, FIFO control logic, accumulator, and activation/quantization modules are not included in this initial release.

## Repository Organization

This project is organized under the main `BitSys` repository.

```text
BitSys/
└── BitSys_MUL/
    ├── LUT/
    │   ├── src/
    │   │   ├── verilog/
    │   │   │   ├── BitSys_MUL.v
    │   │   │   ├── BitwiseSA_LUT.v
    │   │   │   ├── BitwisePE_LUT.v
    │   │   │   └── BitwiseSA_DataLoader.v
    │   │   └── testbench/
    │   │       └── BitSys_MUL_tb.v
    │   └── Vivado project files
    └── RTL/
        └── Reserved for the pure RTL version or future non-primitive implementations
```

The current uploaded and verified version is located in:

```text
BitSys_MUL/LUT/
```

The `LUT` folder contains a complete **Vivado 2024.1** project. It is configured for the **Ultra96-V2** FPGA platform and can be opened, synthesized, implemented, and simulated directly in Vivado.

No paid Vivado license is required for this project setup.

## Overview

BitSys-LUT is designed for low-precision and mixed-precision quantized neural network hardware accelerators. It uses a fixed 8-bit input container and supports multiple packed multiplication modes at runtime.

The design is based on a bitwise systolic array. Instead of using conventional fixed-width multipliers, BitSys computes bitwise sub-partial products, applies precision-dependent masks, and generates packed multi-channel outputs for different precision modes.

The LUT-optimized version uses the Xilinx `LUT6_2` primitive to implement the bitwise processing elements efficiently on Xilinx FPGA devices.

## Features

* Fixed 8-bit input container
* Runtime-selectable precision modes:

  * 1-bit mode: 8 packed 1-bit multiplications
  * 2-bit mode: 4 packed 2-bit multiplications
  * 4-bit mode: 2 packed 4-bit multiplications
  * 8-bit mode: 1 8-bit multiplication
* Signed and unsigned multiplication support
* XNOR-style 1-bit multiplication for BNN-style computation
* Fully pipelined bitwise systolic-array-based multiplier structure
* Xilinx `LUT6_2` primitive optimization
* Complete Vivado 2024.1 project included
* Verilog testbench included
* Verified with random functional simulation for all supported modes

## Directory Description

### `BitSys_MUL/LUT`

This folder contains the LUT-primitive-optimized BitSys multiplier implementation.

It includes:

* Vivado 2024.1 project files
* Verilog source files
* Verilog testbench
* Project configuration for Ultra96-V2

This is the recommended version for users who want to directly synthesize and test the multiplier in Vivado.

### `BitSys_MUL/LUT/src/verilog`

This folder contains the Verilog design files of the BitSys-LUT multiplier.

Main files:

```text
BitSys_MP_MUL_LUT.v
BitwiseSA_LUT.v
BitwisePE_LUT.v
BitwiseSA_DataLoader.v
```

### `BitSys_MUL/LUT/src/testbench`

This folder contains the Verilog testbench for functional verification.

Main file:

```text
BitSys_MP_MUL_LUT_tb.v
```

### `BitSys_MUL/RTL`

This folder is reserved for the pure RTL version or future non-primitive implementations.

The current released and tested implementation is the LUT-optimized version under `BitSys_MUL/LUT`.

## Module Description

### `BitSys_MP_MUL_LUT`

Top-level multiplier module.

Main ports:

```verilog
input  wire                  sys_clk,
input  wire                  sys_rst_n,

input  wire [IN_PRECI-1:0]   precision,

input  wire [IN_WIDTH-1:0]   in_0,
input  wire [IN_WIDTH-1:0]   in_1,
input  wire                  in_valid,

input  wire                  rst,
input  wire                  is_signed,

output wire [OUT_WIDTH-1:0]  result,
output wire                  result_valid
```

### `BitwiseSA_DataLoader`

Input loader used to prepare the two 8-bit operands for the bitwise systolic array.

### `BitwiseSA_LUT`

Bitwise systolic array and output generation pipeline.

### `BitwisePE_LUT`

LUT-optimized bitwise processing element implemented with the Xilinx `LUT6_2` primitive.

## Precision Encoding

The `precision` signal selects the active multiplication mode.

| `precision` | Mode  | Packed Channels | Output Layout     |
| ----------- | ----- | --------------: | ----------------- |
| `2'b00`     | 1-bit |      8 channels | 8 × 2-bit outputs |
| `2'b01`     | 2-bit |      4 channels | 4 × 4-bit outputs |
| `2'b10`     | 4-bit |      2 channels | 2 × 8-bit outputs |
| `2'b11`     | 8-bit |       1 channel | 1 × 16-bit output |

The total output width is always 16 bits.

## Important Notes

The current release is an **8-bit fixed-container version**.

Although some parameters are kept in the RTL for readability and possible future extensions, the current version only supports:

```verilog
IN_WIDTH   = 8
IN_PRECI   = 2
REGION_NUM = 4
OUT_WIDTH  = 16
```

Changing these parameters is not supported in this release.

The `precision` and `is_signed` signals must remain stable from the input valid cycle until `result_valid` is asserted.

The current testbench verifies one multiplication transaction at a time. Fully back-to-back streaming usage should be verified separately by users before integration into a larger accelerator.

## 1-bit Mode

The 1-bit mode is designed for BNN-style computation. Input bit `1` represents `+1`, and input bit `0` represents `-1`.

The packed 2-bit output uses two's-complement-style encoding:

| Value | Encoding |
| ----- | -------- |
| `+1`  | `2'b01`  |
| `-1`  | `2'b11`  |

## Using the Vivado Project

The `BitSys_MUL/LUT` folder contains a complete Vivado 2024.1 project.

To use it:

1. Open Vivado 2024.1.
2. Open the project located in `BitSys_MUL/LUT`.
3. Run behavioral simulation with the provided testbench.
4. Run synthesis or implementation for the configured Ultra96-V2 target.

The project is configured for the Ultra96-V2 platform and does not require a paid Vivado license for synthesis and testing.

## Simulation

The testbench is located in:

```text
BitSys_MUL/LUT/src/testbench/BitSys_MP_MUL_LUT_tb.v
```

It verifies:

* 1-bit signed/XNOR-style multiplication
* 2-bit unsigned multiplication
* 2-bit signed multiplication
* 4-bit unsigned multiplication
* 4-bit signed multiplication
* 8-bit unsigned multiplication
* 8-bit signed multiplication

The default random test number is:

```verilog
parameter RANDOM_NUM = 100000;
```

## FPGA Target

This RTL is mainly intended for Xilinx FPGA devices because the bitwise processing element uses the Xilinx `LUT6_2` primitive.

Current project setup:

* Tool: Vivado 2024.1
* Target platform: Ultra96-V2
* FPGA family: Zynq UltraScale+
* License requirement: no paid Vivado license required for the provided setup

For non-Xilinx tools or generic RTL simulation, a behavioral replacement of `LUT6_2` may be required.

## Current Limitations

* Only the BitSys-LUT multiplier RTL is included.
* MAC and accelerator-level modules are not included in this release.
* The design is currently fixed to an 8-bit input container.
* The current release uses Xilinx-specific LUT primitives.
* Back-to-back streaming input has not been exposed as a guaranteed public interface in this release.

## Citation

If you use this repository in your research, please cite the full paper:

```bibtex
@inproceedings{liu2026bitsys,
  author    = {Liu, Yuhao and Ullah, Salim and Kumar, Akash},
  title     = {Bitwise Systolic Array Architecture for Runtime-Reconfigurable Multi-precision Quantized Multiplication on Hardware Accelerators},
  booktitle = {Proceedings of the International Symposium on Quality Electronic Design (ISQED)},
  year      = {2026},
  note      = {Please update this entry with the official DOI, page numbers, and publisher information when available}
}
```

An earlier one-page poster version of this work appeared at FCCM 2024:

```bibtex
@inproceedings{liu2024bitsys_fccm_poster,
  author    = {Liu, Yuhao and Ullah, Salim and Kumar, Akash},
  booktitle = {2024 IEEE 32nd Annual International Symposium on Field-Programmable Custom Computing Machines (FCCM)},
  title     = {BitSys: Bitwise Systolic Array Architecture for Multi-precision Quantized Hardware Accelerators},
  year      = {2024},
  pages     = {220--220},
  keywords  = {Accuracy;Runtime;Quantization (signal);Pipelines;Neural networks;Computer architecture;Systolic arrays;Multi-Precision;Multiplier;Runtime-Reconfiguration;FPGA;Quantized Neural Network;Systolic Array},
  doi       = {10.1109/FCCM60383.2024.00042}
}
```

## License

This project is released under the Apache License 2.0.

Please see the `LICENSE` file for details.

## Acknowledgement

This work was developed as part of the BitSys project for runtime-reconfigurable multi-precision quantized hardware accelerators.
