# BitSys

**BitSys** is a bitwise arithmetic architecture for runtime-reconfigurable multi-precision multiplication and multiply-accumulation in quantized neural network hardware.

This repository provides the open-source RTL artifacts of the BitSys multi-precision multiplier and multiply-accumulator. The current release includes both Xilinx LUT6_2-optimized implementations and pure RTL reference implementations.

## Current Release

The current repository includes:

* BitSys multi-precision multiplier

  * LUT6_2-optimized implementation
  * Pure RTL implementation
* BitSys multi-precision multiply-accumulator

  * LUT6_2-optimized implementation
  * Pure RTL implementation
* Vivado packaged IPs for the LUT6_2-optimized implementations

  * `BitSys_MPMUL`
  * `BitSys_MPMAC`
* Verilog source code
* Testbenches
* Complete Vivado projects

The main supported configuration is a fixed 8-bit input container with runtime-selectable 1/2/4/8-bit precision modes.

## Repository Structure

```text
BitSys/
├── BitSys_MUL/
│   └── Multi_Precision/
│       ├── LUT/
│       └── RTL/
├── BitSys_MAC/
│   └── Multi_Precision/
│       ├── LUT/
│       └── RTL/
├── Vivado_IP/
│   ├── BitSys_MPMUL/
│   └── BitSys_MPMAC/
├── README.md
├── LICENSE
└── .gitignore
```

## Directory Description

### `BitSys_MUL/Multi_Precision/LUT`

This directory contains the LUT6_2-optimized BitSys multi-precision multiplier implementation.

This version uses Xilinx LUT6_2 primitives to implement the bitwise processing elements efficiently on Xilinx FPGAs.

### `BitSys_MUL/Multi_Precision/RTL`

This directory contains the pure RTL version of the BitSys multi-precision multiplier.

This version is mainly provided as a reference implementation for readability, functional understanding, and easier inspection of the architecture.

### `BitSys_MAC/Multi_Precision/LUT`

This directory contains the LUT6_2-optimized BitSys multi-precision multiply-accumulator implementation.

The MAC builds on the BitSys multi-precision multiplier and adds accumulation support for multi-cycle dot-product-style computation.

### `BitSys_MAC/Multi_Precision/RTL`

This directory contains the pure RTL version of the BitSys multi-precision multiply-accumulator.

This version is provided as a reference implementation.

### `Vivado_IP`

This directory contains Vivado packaged IPs for the LUT6_2-optimized BitSys implementations.

Currently included IPs:

```text
BitSys_MPMUL    BitSys Multi-Precision Multiplier
BitSys_MPMAC    BitSys Multi-Precision Multiply-Accumulator
```

All packaged Vivado IPs in this repository are based on the LUT6_2-optimized implementations. The pure RTL versions are provided as source/reference implementations and are not packaged as Vivado IPs.

## Supported Precision Modes

The current BitSys multiplier and MAC use an 8-bit input container and support runtime-selectable precision modes.

| `precision` |  Mode | Parallel channels |
| ----------- | ----: | ----------------: |
| `2'b00`     | 1-bit |        8 channels |
| `2'b01`     | 2-bit |        4 channels |
| `2'b10`     | 4-bit |        2 channels |
| `2'b11`     | 8-bit |         1 channel |

For 2/4/8-bit modes, both signed and unsigned multiplication are supported through the `is_signed` input.

For 1-bit mode, the design follows a BNN-style bipolar encoding:

```text
1'b1 -> +1
1'b0 -> -1
```

The 1-bit multiplication result is represented as:

```text
2'b01 -> +1
2'b11 -> -1
```

## BitSys Multi-Precision Multiplier

The BitSys multi-precision multiplier performs runtime-reconfigurable multiplication within a fixed 8-bit input container.

Depending on the selected precision, the same hardware can operate as:

```text
8 parallel 1-bit multipliers
4 parallel 2-bit multipliers
2 parallel 4-bit multipliers
1 8-bit multiplier
```

The LUT version uses Xilinx LUT6_2 primitives for FPGA-oriented optimization. The RTL version provides the same architectural behavior in a more generic Verilog form.

## BitSys Multi-Precision MAC

The BitSys multi-precision MAC extends the multiplier with accumulation support.

It is designed for multi-cycle accumulation of multi-precision multiplication results, which is useful for dot-product and quantized neural network computation.

The MAC supports:

```text
1-bit accumulation
2-bit signed and unsigned accumulation
4-bit signed and unsigned accumulation
8-bit signed and unsigned accumulation
```

The accumulation length is configured through the `accu_length` input.

## Vivado IP Usage

The packaged Vivado IPs are located under:

```text
Vivado_IP/
```

To use them in a Vivado project:

1. Open Vivado.
2. Go to `Settings -> IP -> Repository`.
3. Add the `Vivado_IP/` directory as an IP repository.
4. Refresh the IP catalog.
5. Search for:

   * `BitSys_MPMUL`
   * `BitSys_MPMAC`
6. Instantiate the desired IP in your design.

The packaged IPs use native RTL-style interfaces. They do not include AXI4-Lite, AXI-Stream, DMA, FIFO, or system-level control wrappers.

## Important Usage Notes

The current release assumes a fixed 8-bit input container.

The following control signals should remain stable during one transaction:

```text
precision
is_signed
```

For the MAC, the following signal should also remain stable during one accumulation operation:

```text
accu_length
```

The reset signals are used to clear the corresponding internal state. Please refer to the provided testbenches for the expected usage sequence.

## Verification

The released designs include Verilog testbenches.

The BitSys multiplier testbench verifies the runtime-selectable 1/2/4/8-bit multiplication modes.

The BitSys MAC testbench verifies:

```text
1-bit mode
2-bit unsigned mode
2-bit signed mode
4-bit unsigned mode
4-bit signed mode
8-bit unsigned mode
8-bit signed mode
```

The MAC was validated by randomized simulation with 100,000 tests per mode. Each test accumulates 1,024 input pairs. No mismatches were observed in the tested configurations.

## Toolchain

The designs were developed and tested with:

```text
Vivado 2024.1
```

The LUT6_2-optimized versions are Xilinx FPGA specific because they instantiate Xilinx LUT6_2 primitives.

The pure RTL versions are provided for readability and reference, but users should still validate tool compatibility before using them in non-Xilinx flows.

## Current Limitations

The current release focuses on the multiplier-level and MAC-level BitSys arithmetic artifacts.

The current implementation uses a fixed 8-bit input container.

The Vivado packaged IPs are provided only for the LUT6_2-optimized versions.

The repository does not provide AXI wrappers, host software, DMA integration, or complete system-level accelerator integration in the current release.

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
