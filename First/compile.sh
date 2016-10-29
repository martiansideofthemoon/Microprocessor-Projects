python assembler.py abc.asm abc.hex
python memory_init.py abc.hex MemoryComponent.vhd
ghdl -a Components.vhd
ghdl -a *.vhd
ghdl -m Testbench
