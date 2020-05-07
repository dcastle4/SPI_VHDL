# SPI_VHDL
This is an implementation of an SPI MASTER module in VHDL as a Xilinx Vivado project. 
It is by no means complete, as I still need to tweak and implement certain things, such as creating the logic to sample the MISO line on MASTER.
Right now, SS, SCK and MOSI seem to work perfectly under simulation, as pictured below:
![waveform](doc/waveform.png?raw=true)


This was originally being developed as part of CpE4400: Directed Study with Professor Tippens. After the scope shifted away from FPGAs to STM32 microcontrollers, this project went mostly untouched for the rest of the semester, although I plan on finishing it and tweaking it over the summer.

