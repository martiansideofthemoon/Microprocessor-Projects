library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
  signal alu_out_read : std_logic_vector(15 downto 0);
begin
    
   alu_out <= alu_out_read;
   zero <= '1' when alu_out_read = "0000000000000000" else '0';
   carry <= '1' when alu_in_1(15) = alu_in_2(15) and alu_in_1(14 downto 0) > alu_out_read(14 downto 0) else '0';
      
   process(op_in, alu_in_1, alu_in_2)
   begin

   if(op_in = '0') then
      alu_out_read <= std_logic_vector(unsigned(alu_in_1) + unsigned(alu_in_2));
   else  
      alu_out_read <= alu_in_1 nand alu_in_2;
   end if;
   
   end process;

end Struct;
