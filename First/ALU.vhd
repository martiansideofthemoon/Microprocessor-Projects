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
  signal two_complement1: std_logic_vector(15 downto 0);
  signal two_complement2: std_logic_vector(15 downto 0);
  signal two_complement_add: std_logic_vector(15 downto 0);
  signal carry1, carry2: std_logic;
begin
   two: TwosComplement
        port map (
          input => alu_in_1,
          output => two_complement1
        );
   two1: TwosComplement
        port map (
          input => alu_in_2,
          output => two_complement2
        );
   alu_out <= alu_out_read;
   zero <= '1' when alu_out_read = "0000000000000000" else '0';
   carry1 <= '1' when alu_in_1(15) = '1' and alu_in_2(15) = '1' and
                      two_complement1(14 downto 0) > two_complement_add(14 downto 0) else '0';
   carry2 <= '1' when alu_in_1(15) = '0' and alu_in_2(15) = '0' and
                      alu_in_1(14 downto 0) > alu_out_read(14 downto 0) else '0';
   carry <= '1' when carry1 = '1' or carry2 = '1' else '0';

   process(op_in, alu_in_1, alu_in_2)
   begin

   if(op_in = '0') then
      alu_out_read <= std_logic_vector(unsigned(alu_in_1) + unsigned(alu_in_2));
      two_complement_add <= std_logic_vector(unsigned(two_complement1) + unsigned(two_complement2));
   else
      alu_out_read <= alu_in_1 nand alu_in_2;
      two_complement_add <= alu_in_1 nand alu_in_2;
   end if;

   end process;

end Struct;
