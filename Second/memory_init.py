import sys

MEM_SIZE = 128

commands = []
memory = ["00000000"] * MEM_SIZE

output = """library std;
library ieee;
use ieee.std_logic_1164.all;
package MemoryComponent is

type MemArray is array(0 to 127) of std_logic_vector(7 downto 0);

constant INIT_MEMORY : MemArray := (
"""

sample_end = """);

end MemoryComponent;
"""

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
    new_pointer = int(commands[index], 2)*2
    pointer = new_pointer
  else:
    memory[pointer] = command[8:]
    pointer += 1
    memory[pointer] = command[:8]
    pointer += 1
  index += 1


for index, data in enumerate(memory):
  output += "  " + str(index) + " => \"" + data + "\",\n"

output = output[:-2] + "\n"

output += sample_end

# Write the hex output to a file
f = open(sys.argv[2], 'w')
f.write(output)
f.close()
