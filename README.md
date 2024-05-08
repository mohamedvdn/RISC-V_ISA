# RISC-V CPU Design RV32I Core

This repository contains all the information needed to build your RISC-V pipelined core, which has support of base interger RV32I instruction format using TL-Verilog on Makerchip IDE platform.

# Table of Contents
- [Introduction to RISC-V ISA](#introduction-to-risc-v-isa)
- [Overview of GNU compiler toolchain](#overview-of-gnu-compiler-toolchain)
- [Introduction to ABI](#introduction-to-abi)
- [Digital Logic with TL-Verilog and Makerchip](#digital-logic-with-tl-verilog-and-makerchip)
  - [Combinational Logic](#combinational-logic)
  - [Sequential Logic](#sequential-logic)
  - [Counter and Calculator in Pipeline](#counter-and-calculator-in-pipeline)
  - [2-Cycle Calculator with Validity](#2-cycle-calculator-with-validity)
- [Basic RISC-V CPU micro-architecture](#basic-risc-v-cpu-micro-architecture)
  - [Fetch](#fetch)
  - [Instruction Decode](#instruction-decode)
  - [Register File Read and Write](#register-file-read-and-write)
  - [ALU](#alu)
  - [Control Logic](#control-logic)
- [Pipelined RISC-V CPU](#pipelined-risc-v-cpu)
  - [Completing the RISC-V CPU](#completing-the-risc-v-cpu)
- [Conclusion](#conclusion)
- [Acknowledgements](#acknowledgements)


# Introduction to RISC-V ISA

A RISC-V ISA is defined as a base integer ISA, which must be present in any implementation, plus optional extensions to the base ISA. Each base integer instruction set is characterized by
  1. Width of the integer registers (XLEN) 
  2. Corresponding size of the address space
  3. Number of integer registers (32 in RISC-V)

More details on RISC-V ISA can be obtained [here](https://github.com/riscv/riscv-isa-manual/releases/download/draft-20200727-8088ba4/riscv-spec.pdf).

# Overview of GNU compiler toolchain

The GNU Toolchain is a set of programming tools in Linux systems that programmers can use to make and compile their code to produce a program or library. So, how the machine code which is understandable by processer is explained below.

  * Preprocessor - Process source code before compilation. Macro definition, file inclusion or any other directive if present then are preprocessed. 
  * Compiler - Takes the input provided by preprocessor and converts to assembly code.
  * Assembler - Takes the input provided by compiler and converts to relocatable machine code.
  * Linker - Takes the input provided by Assembler and converts to Absolute machine code.

Under the risc-v toolchain, 
  * To use the risc-v gcc compiler use the below command:

    `riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o <object filename> <C filename>`

    More generic command with different options:

    `riscv64-unknown-elf-gcc <compiler option -O1 ; Ofast> <ABI specifier -lp64; -lp32; -ilp32> <architecture specifier -RV64 ; RV32> -o <object filename> <C      filename>`

    More details on compiler options can be obtained [here](https://www.sifive.com/blog/all-aboard-part-1-compiler-args)

  * To view assembly code use the below command,
    
    `riscv64-unknown-elf-objdump -d <object filename>`
    
  * To use SPIKE simualtor to run risc-v obj file use the below command,
  
    `spike pk <object filename>`
    
    To use SPIKE as debugger
    
    `spike -d pk <object Filename>` with degub command as `until pc 0 <pc of your choice>`

    To install complete risc-v toolchain locally on linux machine,
      1. [RISC-V GNU Toolchain](http://hdlexpress.com/RisKy1/How2/toolchain/toolchain.html)
      2. [RISC-V ISA SImulator - Spike](https://github.com/kunalg123/riscv_workshop_collaterals)
    
    Once done with installation add the PATH to .bashrc file for future use.
    
 Test Case for the above commands [(unsignedhighest)](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%201/unsignedhighest.c)

  * Below image shows the disassembled file `unsignedhighest.o` with `main` function highlighted.

    ![disassemble](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/c4ebbf1e95c319f836092005095c8ac99d2c7e03/day%201/lab_tutorial_2.png)
    
# Introduction to ABI

An Application Binary Interface is a set of rules enforced by the operating system on a specific architecture. So, Linker converts relocatable machine code to absolute machine code via ABI interface specific to the architecture of machine.

So, it is system call interface used by the application program to access the registers specific to architecture. Overhere the architecture is RISC-V, so to access 32 registers of RISC-V below is the table which shows the calling convention (ABI name) given to registers for the application programmer to use.
[(Image source)](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf)

![calling_convention](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%201/ABI.png)

# RISC-V Block Diagram

![RISC-V](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%201/Block%20Diagram.png)

![RISC-V](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%201/Block%20Diagram%20v2.png)

# Digital Logic with TL-Verilog and Makerchip

[Makerchip](https://makerchip.com/) is a free online environment for developing high-quality integrated circuits. You can code, compile, simulate, and debug Verilog designs, all from your browser. Your code, block diagrams, and waveforms are tightly integrated.

All the examples shown below are done on Makerchip IDE using TL-verilog. Also there are other tutorials present on IDE which can be found [here](https://makerchip.com/sandbox/) under Tutorials section.

## [Combinational Logic](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%203/combinational_calculator.tlv)

Starting with basic example in combinational logic is an inverter. To write the logic of inverter using TL-verilog is `$out = ! $in;`. There is no need to declare `$out` and `$in` unlike Verilog. There is also no need to assign `$in`. Random stimulus is provided, and a warning is produced. Below is snapshot of Combinational Calculator.

![Combinational-Calculator](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%203/combinational_calculator.png)

## [Sequential Logic](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%203/sequential_calculator.tlv)

Starting with basic example in sequential logic is Fibonacci Series with reset. To write the logic of Series using TL-Verilog is `$num[31:0] = $reset ? 1 : (>>1$num + >>2$num)`. This operator `>>?` is ahead of operator which will provide the value of that signal 1 cycle before and 2 cycle before respectively. Below is snapshot of Sequential Calculator which remembers the last result, and uses it for the next calculation.

![Sequential-Calculator](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%203/sequential_calculator.png)

## [Counter and Calculator in Pipeline](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%203/error_condition_with_pipeline.tlv)

Timing abstract powerful feature of TL-Verilog which converts a code into pipeline stages easily. Whole code under `|pipe` scope with stages defined as `@?`
Below is snapshot of Counter and Calculator in Pipeline & 2-Cycle Calculator which clears the output alternatively and output of given inputs are observed at the next cycle.

![Counter-and-Calculator-in-Pipeline](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%203/error_condition_with_pipeline.png)

![2-Cycle-Calculator](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%203/two_pipeline_calc.tlv)

## [2-Cycle Calculator with Validity](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%203/two_pipeline_calc_with_valid_and_mem.tlv)

Validity is TL-verilog means signal indicates validity of transaction and described as "when" scope else it will work as don't care. Denoted as `?$valid`. Validity provides easier debug, cleaner design, better error checking, automated clock gating. Below is snapshot of 2-Cycle Calculator with Validity and Calculator with Single-Value Memory.

![2-Cycle-Calculator-with-Validity](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%203/two_pipeline_calc_with_valid_and_mem.png)

![Calculator with Single-Value Memory](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%203/calculate_with_single_value_mem.png)

# Basic RISC-V CPU micro-architecture

Designing the basic processor of 3 stages fetch, decode and execute based on RISC-V ISA.

## [Fetch](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%204/lab_fetch.tlv)

* Program Counter (PC): Holds the address of next Instruction
* Instruction Memory (IM): Holds the set of instructions to be executed

During fetch stage, processor fetches the instruction from the IM pointed by address given by PC. Below is snapshot from Makerchip IDE after performing the fetch stage.

![Fetch](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%204/lab_fetch.png)

## [Instruction Decode](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%204/instruction_decode.tlv)

6 types of Instructions:
  * R-type - Register 
  * I-type - Immediate
  * S-type - Store
  * B-type - Branch (Conditional Jump)
  * U-type - Upper Immediate
  * J-type - Jump (Unconditional Jump)

Instruction Format includes opcode, immediate value, source address and destination address. During decode stage, processor decodes the instruction based on instruction format and type of instruction. Below is snapshot from Makerchip IDE after performing the decode stage.

![Decode]https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%204/instruction_decode.png)

## [Register File Read and Write](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%204/write_reg.tlv)

Here the Register file is 2 read, 1 write which means 2 read and 1 write operation can happen simultanously.

Inputs:
  * Read_Enable   - Enable signal to perform read operation
  * Read_Address1 - Address1 from where data has to be read 
  * Read_Address2 - Address2 from where data has to be read 
  * Write_Enable  - Enable signal to perform write operation
  * Write_Address - Address where data has to be written
  * Write_Data    - Data to be written at Write_Address

Outputs:
  * Read_Data1    - Data from Read_Address1
  * Read_Data2    - Data from Read_Address2

Below is snapshot from Makerchip IDE after performing the Register File Read followed by Register File Write.

![Register-File-Read](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%204/read_reg.png)

![Register-File-Write](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%204/write_reg.png)

## [ALU](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%204/alu.tlv)

During the execute stage at ALU, both the operands perform the operation based on opcode. Below is snapshot from Makerchip IDE after performing the execute stage.

![ALU](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%204/alu.png)

## [Control Logic](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%204/testbench.tlv)

During decode stage, branch target address is calculated and fed into PC mux. Before execute stage, once the operands are ready branch condition is checked. Below is snapshot from Makerchip IDE after including the control logic for branch instructions and testbench.

![Branch](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%204/branch_instruction.png)

![Testbench](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%204/testbench.png)

# Pipelined RISC-V CPU

Converting non-piepleined CPU to pipelined CPU using timing abstract feature of TL-Verilog. This allows easy retiming wihtout any risk of funcational bugs. More details reagrding Timing Abstract in TL-Verilog can be found in IEEE Paper ["Timing-Abstract Circuit Design in Transaction-Level Verilog" by Steven Hoover.](https://ieeexplore.ieee.org/document/8119264)

Pipelining the CPU with branches still having 3 cycle delay rest all instructions are pipelined. Pipelining the CPU in TL-Verilog can be done in following manner:
```
|<pipe-name>
    @<pipe stage>
       Instructions present in this stage
       
    @<pipe_stage>
       Instructions present in this stage       
```
Test case:
```
*passed = |cpu/xreg[10]>>5$value == (1+2+3+4+5+6+7+8+9);

```
Similar to branch, load will also have 3 cycle delay. So, added a Data Memory 1 write/read memory.

Inputs:
  * Read_Enable - Enable signal to perform read operation
  * Write_Enable - Enable signal to perform write operation
  * Address - Address specified whether to read/write from
  * Write_Data - Data to be written on Address (Store Instruction)

Output: 
  * Read_Data - Data to be read from Address (Load Instruction)

Added test case to check fucntionality of load/store. Stored the summation of 1 to 9 on address 4 of Data Memory and loaded that value from Data Memory to r17.
```
*passed = |cpu/xreg[17]>>5$value == (1+2+3+4+5+6+7+8+9);
```
## [Completing the RISC-V CPU](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%205/complete%20RISC-V%20core.tlv)

Added Jumps and completed Instruction Decode and ALU for all instruction present in RV32I base integer instruction set.

Below is final snapshots of Complete Pipelined RISC-V CPU core.

![Final](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%205/pipeline%20risc%20v.png)

![Final](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%205/complete_ALU_instruction.png)

![Final](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%205/load_store.png)

![Final](https://github.com/RISCV-MYTH-WORKSHOP/riscv-myth-workshop-sep23-mohamedvdn/blob/master/day%205/complete%20RISC-V%20core.png)


# Conclusion
This project was done as a part of the RISC-V based MYTH (Microprocessor for You in Thirty Hours) workshop conducted by Kunal Ghosh and Steve Hoover. The current project implements almost the entire RV32I base instruction set. We capable of executing all RISC-V instructions in four cycles with easy pipelining using Transaction-Level Verilog. TL-Verilog not only reduces your code size significantly but allows us to freely declare signals without explicitly declaring them (just like Python does compare to C). In addition, we can generate Verilog/SystemVerilog code from TL-Verilog in Makerchip IDE which using Sandpiper complier. Future work involves modifying the current design to implement support for the remaining operations and also implementation of other standard extensions like M, F and D.

# Acknowledgements
- [Kunal Ghosh](https://github.com/kunalg123), Co-founder, VSD Corp. Pvt. Ltd.
- [Steve Hoover](https://github.com/stevehoover), Founder, Redwood EDA
- [Shivam Potdar](https://github.com/shivampotdar), GSoC 2020 @fossi-foundation
