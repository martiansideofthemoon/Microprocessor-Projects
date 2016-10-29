library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
--library work;
--use work.ProcessorComponents.all;

entity Testbench is
end entity;
architecture Behave of Testbench is
component TopLevel is
  port (
    clk, reset: in std_logic;
    -- Data coming from outside
    external_pc_out: out std_logic_vector(15 downto 0);
    external_ir: out std_logic_vector(15 downto 0);
    external_r0: out std_logic_vector(15 downto 0);
    --external_r1: out std_logic_vector(15 downto 0);
    --external_r2: out std_logic_vector(15 downto 0);
    external_r3: out std_logic_vector(15 downto 0);
    external_r4: out std_logic_vector(15 downto 0);
    external_r5: out std_logic_vector(15 downto 0);
    external_r6: out std_logic_vector(15 downto 0)
  );
end component TopLevel;
  --signal data: std_logic_vector(15 downto 0) := "0000000000000000";
  --signal addr : std_logic_vector(15 downto 0) := "0000000000000000";
  --signal mem_write: std_logic := '0';
  signal clk: std_logic := '0';
  signal reset: std_logic := '1';
  signal external_pc_out: std_logic_vector(15 downto 0);
  signal external_ir: std_logic_vector(15 downto 0);
  signal external_r0: std_logic_vector(15 downto 0);
  --signal external_r1: std_logic_vector(15 downto 0);
  --signal external_r2: std_logic_vector(15 downto 0);
  signal external_r3: std_logic_vector(15 downto 0);
  signal external_r4: std_logic_vector(15 downto 0);
  signal external_r5: std_logic_vector(15 downto 0);
  signal external_r6: std_logic_vector(15 downto 0);

  function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin
      ret_val := lx;
      return(ret_val);
  end to_string;

  function to_std_logic_vector(x: bit_vector) return std_logic_vector is
    alias lx: bit_vector(1 to x'length) is x;
    variable ret_var : std_logic_vector(1 to x'length);
  begin
     for I in 1 to x'length loop
        if(lx(I) = '1') then
           ret_var(I) :=  '1';
        else
           ret_var(I) :=  '0';
  end if;
     end loop;
     return(ret_var);
  end to_std_logic_vector;

  function to_std_logic(x: bit) return std_logic is
      variable ret_val: std_logic;
  begin
      if (x = '1') then
        ret_val := '1';
      else
        ret_val := '0';
      end if;
      return(ret_val);
  end to_std_logic;

begin
  clk <= not clk after 5 ns; -- assume 10ns clock.

  process
    variable err_flag : boolean := false;
    File INFILE: text open read_mode is "abc.hex";
    FILE OUTFILE: text  open write_mode is "Outputs/output_memory.txt";

    ---------------------------------------------------
    -- edit the next few lines to customize
    variable m_write: bit;
    variable address: bit_vector (15 downto 0) := "0000000000000000";
    variable din: bit_vector (15 downto 0);
    variable dout: bit_vector (15 downto 0);
    ----------------------------------------------------
    variable INPUT_LINE: Line;
    variable OUTPUT_LINE: Line;
    variable LINE_COUNT: integer := 0;
    variable address_int: integer := 0;

  begin
    --addr <= "0000000000000000";
    wait until clk = '1';

    --while not endfile(INFILE) loop
    --  readLine(INFILE, INPUT_LINE);
    --  read(INPUT_LINE, din);
    --  LINE_COUNT := LINE_COUNT + 1;
    --  if (din = "1111111111111111") then
    --    readLine(INFILE, INPUT_LINE);
    --    read(INPUT_LINE, address);
    --    address_int := to_integer(unsigned(to_std_logic_vector(address)));
    --    mem_write <= '0';
    --    addr <= std_logic_vector(to_unsigned(address_int, addr'length));
    --    data <= to_std_logic_vector(din);
    --  else
    --    mem_write <= '0';
    --    addr <= std_logic_vector(to_unsigned(address_int, addr'length));
    --    data <= to_std_logic_vector(din);
    --    address_int := address_int + 1;
    --  end if;
    --	wait until clk = '1';
    --end loop;

    reset <= '0';

    wait;
  end process;

  dut: TopLevel
  port map (
    clk => clk,
    reset => reset,
    --external_addr => addr,
    --external_data => data,
    --external_mem_write => mem_write,
    external_ir => external_ir,
    external_pc_out => external_pc_out,
    external_r0 => external_r0,
    --external_r1 => external_r1,
    --external_r2 => external_r2,
    external_r3 => external_r3,
    external_r4 => external_r4,
    external_r5 => external_r5,
    external_r6 => external_r6
  );
end Behave;

