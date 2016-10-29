import sys

MEM_SIZE = 128

commands = []
memory = ["00000000"] * MEM_SIZE

output = """
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity ResetMemory is
  port (
    memory: out MemArray
  );
end entity ResetMemory;

architecture Struct of ResetMemory is
begin
"""
sample_end = "end Struct;"

file_name = sys.argv[1]
with open(file_name, 'r') as f:
  for line in f:
    commands.append(line[:-1])

pointer = 0
index = 0

while (index < len(commands)):
  command = commands[index]
  if command == "1111111111111111":
    index += 1
    new_pointer = int(commands[index], 2)
    pointer = new_pointer
  else:
    memory[pointer] = command[8:]
    pointer += 1
    memory[pointer] = command[:8]
    pointer += 1
  index += 1

for index, data in enumerate(memory):
  output += "  memory(" + str(index) + ") <= \"" + data + "\";\n"

output += sample_end

# Write the hex output to a file
f = open(sys.argv[2], 'w')
f.write(output)
f.close()