library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity ALU is
   port(alu_in_1, alu_in_2: in std_logic_vector(15 downto 0);
        op_in: in std_logic;
        alu_out: out std_logic_vector(15 downto 0);
        carry: out std_logic;
        zero: out std_logic);
end entity;
architecture Struct of ALU is
begin
    
   zero <= '1' when alu_out = '0' else '0';
   carry <= '1' when alu_in_1 > alu_out else '0';
      
   process(op_in,alu_in_1,alu_in_2)
  
   if(op_in = '0') then
      alu_out <= alu_in_1 + alu_in_2;
   else  
      alu_out <= alu_in_1 nand alu_in_2;
   end if;
   
   end process;
end Struct;
