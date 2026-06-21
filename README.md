# BitSys: Bitwise Systolic Array Architecture for Runtime-Reconfigurable Multi-Precision Multiplication

This repository provides the open-source Verilog implementations and Vivado projects of **BitSys**, a bitwise systolic-array-based architecture for runtime-reconfigurable multi-precision multiplication on FPGA-based quantized neural network accelerators.

BitSys is designed to support low-precision and mixed-precision quantized computation by using a fixed input container and runtime-selectable precision modes. The currently released design focuses on the **BitSys multi-precision multiplier**, including both the LUT6_2-optimized version and the pure RTL version.

## Current Release

The current release includes:

* BitSys multi-precision multiplier

  * LUT6_2-optimized implementation
  * Pure RTL implementation
  * Complete Vivado projects
  * Verilog source code
  * Testbenches
* Vivado packaged IP for the LUT6_2-optimized BitSys multi-precision multiplier

The following components are planned for future releases:

* INT8 BitSys multiplier
* BitSys MAC
* Output-stationary BitSys systolic array
* Weight-stationary BitSys systolic array

## Repository Organization

```text
BitSys/
├── BitSys_MUL/
│   ├── INT8/
│   │   └── Reserved for the future INT8 BitSys multiplier
│   │
│   └── Multi_Precision/
│       ├── LUT/
│       │   ├── src/
│       │   │   ├── verilog/
│       │   │   └── testbench/
│       │   └── Vivado project files
│       │
│       └── RTL/
│           ├── src/
│           │   ├── verilog/
│           │   └── testbench/
│           └── Vivado project files
│
├── Vivado_IP/
│   └── Vivado packaged IPs based on LUT6_2-optimized BitSys implementations
│
├── README.md
├── LICENSE
└── .gitignore
```

## Directory Description

### `BitSys_MUL/INT8`

This folder is reserved for the future INT8 BitSys multiplier.

The INT8 multiplier is planned as a standard 8-bit multiplier variant derived from the BitSys design.

### `BitSys_MUL/Multi_Precision/LUT`

This folder contains the LUT6_2-optimized implementation of the BitSys multi-precision multiplier.

It includes:

* Complete Vivado project
* Verilog design files
* Verilog testbench
* Xilinx LUT6_2 primitive-based bitwise processing elements

This is the recommended version for Xilinx FPGA synthesis and implementation.

### `BitSys_MUL/Multi_Precision/RTL`

This folder contains the pure RTL implementation of the BitSys multi-precision multiplier.

It includes:

* Complete Vivado project
* Verilog design files
* Verilog testbench
* Primitive-free RTL implementation

This version is mainly provided as a reference implementation and for easier understanding of the design principle.

### `Vivado_IP`

This folder contains Vivado packaged IPs generated from the LUT6_2-optimized BitSys implementations.

Currently included:

```text
BitSys_MPMUL
```

All Vivado packaged IPs in this repository are based on LUT6_2-optimized implementations. The pure RTL versions are provided as source-level reference implementations and are not packaged as Vivado IPs.

## Overview of the Multi-Precision Multiplier

The BitSys multi-precision multiplier uses a fixed 8-bit input container and supports multiple packed multiplication modes at runtime.

Instead of using conventional fixed-width multipliers, BitSys computes bitwise sub-partial products, applies precision-dependent masks, and generates packed multi-channel outputs for different precision modes.

The LUT6_2-optimized implementation maps the bitwise processing elements to Xilinx LUT6_2 primitives.

## Features

* Fixed 8-bit input container
* Runtime-selectable precision modes:

  * 1-bit mode: 8 packed 1-bit multiplications
  * 2-bit mode: 4 packed 2-bit multiplications
  * 4-bit mode: 2 packed 4-bit multiplications
  * 8-bit mode: 1 8-bit multiplication
* Signed and unsigned multiplication support
* XNOR-style 1-bit multiplication for BNN-style computation
* Bitwise systolic-array-based multiplier structure
* LUT6_2-optimized implementation for Xilinx FPGA devices
* Pure RTL implementation for reference
* Complete Vivado projects included
* Vivado packaged IP included for the LUT6_2-optimized version
* Verilog testbenches included
* Verified with random functional simulation for all supported modes

## Precision Encoding

The `precision` signal selects the active multiplication mode.

| `precision` | Mode  | Packed Channels | Output Layout     |
| ----------- | ----- | --------------: | ----------------- |
| `2'b00`     | 1-bit |      8 channels | 8 × 2-bit outputs |
| `2'b01`     | 2-bit |      4 channels | 4 × 4-bit outputs |
| `2'b10`     | 4-bit |      2 channels | 2 × 8-bit outputs |
| `2'b11`     | 8-bit |       1 channel | 1 × 16-bit output |

The total output width is always 16 bits.

## 1-bit Mode

The 1-bit mode is designed for BNN-style computation.

Input bit encoding:

| Bit    | Value |
| ------ | ----- |
| `1'b1` | `+1`  |
| `1'b0` | `-1`  |

The packed 2-bit output uses two's-complement-style encoding:

| Value | Encoding |
| ----- | -------- |
| `+1`  | `2'b01`  |
| `-1`  | `2'b11`  |

## Top-Level Interface

The top-level module of the multi-precision multiplier is:

```verilog
module BitSys_MUL
#(
    parameter IN_WIDTH  = 8,
    parameter IN_PRECI  = 2,
    parameter OUT_WIDTH = 2*IN_WIDTH
)
(
    input  wire                  sys_clk,
    input  wire                  sys_rst_n,

    input  wire                  mul_rst,

    input  wire [IN_PRECI-1:0]   precision,
    input  wire                  is_signed,

    input  wire [IN_WIDTH-1:0]   in_0,
    input  wire [IN_WIDTH-1:0]   in_1,
    input  wire                  in_valid,

    output wire [OUT_WIDTH-1:0]  result,
    output wire                  result_valid
);
```

## Important Notes

The current multi-precision multiplier is an 8-bit fixed-container version.

Although some parameters are kept in the RTL for readability and possible future extensions, the current implementation only supports:

```verilog
IN_WIDTH   = 8
IN_PRECI   = 2
OUT_WIDTH  = 16
```

Changing these parameters is not supported in the current release.

The `precision` and `is_signed` signals must remain stable from the `in_valid` cycle until `result_valid` is asserted.

The current testbench verifies one multiplication transaction at a time. Fully back-to-back streaming usage should be verified separately before integration into larger accelerator designs.

## Using the Vivado Projects

Each implementation folder contains a complete Vivado project.

For the LUT6_2-optimized multi-precision multiplier:

```text
BitSys_MUL/Multi_Precision/LUT/
```

For the pure RTL multi-precision multiplier:

```text
BitSys_MUL/Multi_Precision/RTL/
```

To use a Vivado project:

1. Open Vivado.
2. Open the corresponding `.xpr` project file.
3. Run behavioral simulation with the provided testbench.
4. Run synthesis or implementation.

The current projects were prepared and tested with Vivado 2024.1.

## Using the Vivado Packaged IP

The `Vivado_IP` folder contains packaged Vivado IPs generated from LUT6_2-optimized BitSys implementations.

To use the packaged IP in a new Vivado project:

1. Open or create a Vivado project.
2. Go to `Settings -> IP -> Repository`.
3. Add the repository path:

```text
Vivado_IP/
```

4. Refresh the IP catalog.
5. Search for:

```text
BitSys_MPMUL
```

6. Instantiate the IP in your design.

The current packaged IP exposes the native BitSys multiplier interface. It does not include AXI4-Lite, AXI4-Stream, FIFO control, MAC logic, or accelerator-level control logic.

## Simulation

The testbench for the multi-precision multiplier verifies:

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

The LUT6_2-optimized implementation is mainly intended for Xilinx FPGA devices because it uses the Xilinx `LUT6_2` primitive.

Current project setup:

* Tool: Vivado 2024.1
* Target platform: Ultra96-V2
* FPGA family: Zynq UltraScale+
* License requirement: no paid Vivado license required for the provided setup

For non-Xilinx FPGA devices or generic simulation/synthesis flows, please use the pure RTL version or provide a behavioral replacement for Xilinx-specific primitives.

## Current Limitations

* The current released multiplier uses a fixed 8-bit input container.
* The current Vivado packaged IP is provided only for the LUT6_2-optimized implementation.
* The pure RTL version is not packaged as a Vivado IP.
* MAC and accelerator-level modules are not included in the current release.
* Back-to-back streaming input is not exposed as a guaranteed public interface in the current release.
* The LUT6_2 version is Xilinx-specific.

## Planned Extensions

Future releases are expected to include:

* Standard INT8 BitSys multiplier
* BitSys MAC
* Output-stationary BitSys systolic array
* Weight-stationary BitSys systolic array
* Additional Vivado packaged IPs for LUT6_2-optimized implementations

## Citation

If you use this repository in your research, please cite the full paper:

```bibtex
@INPROCEEDINGS{liu2026bitsys,
  author={Liu, Yuhao and Ullah, Salim and Kumar, Akash},
  booktitle={2025 26th International Symposium on Quality Electronic Design (ISQED)}, 
  title={Bitwise Systolic Array Architecture for Runtime-Reconfigurable Multi-Precision Quantized Multiplication on Hardware Accelerators}, 
  year={2025},
  volume={},
  number={},
  pages={1-9},
  keywords={Runtime;Quantization (signal);Accuracy;Neural networks;Memory architecture;Systolic arrays;Delays;Racetrack memory;Object tracking;Clocks},
  doi={10.1109/ISQED65160.2025.11014376}
}
```

An earlier one-page poster version of this work appeared at FCCM 2024:

```bibtex
@INPROCEEDINGS{liu2024bitsys_fccm_poster,
  author={Liu, Yuhao and Ullah, Salim and Kumar, Akash},
  booktitle={2024 IEEE 32nd Annual International Symposium on Field-Programmable Custom Computing Machines (FCCM)}, 
  title={BitSys: Bitwise Systolic Array Architecture for Multi-precision Quantized Hardware Accelerators}, 
  year={2024},
  volume={},
  number={},
  pages={220-220},
  keywords={Accuracy;Runtime;Quantization (signal);Pipelines;Neural networks;Computer architecture;Systolic arrays;Multi-Precision;Multiplier;Runtime-Reconfiguration;FPGA;Quantized Neural Network;Systolic Array},
  doi={10.1109/FCCM60383.2024.00042}
}
```

## License

This project is released under the Apache License 2.0.

Please see the `LICENSE` file for details.

## Acknowledgement

This work was developed as part of the BitSys project for runtime-reconfigurable multi-precision quantized hardware accelerators.
