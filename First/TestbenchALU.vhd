library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;

entity TestbenchALU is
end entity;
architecture Behave of TestbenchALU is
  component ALU is
   port(alu_in_1, alu_in_2: in std_logic_vector(15 downto 0);
        op_in: in std_logic;
        alu_out: out std_logic_vector(15 downto 0);
        carry: out std_logic;
        zero: out std_logic);
  end component;

  signal i1,i2 : std_logic_vector(15 downto 0);
  signal i3 : std_logic;
  signal o1 : std_logic_vector(15 downto 0);
  signal o2,o3 : std_logic;
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

  function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin  
      ret_val := lx;
      return(ret_val);
  end to_string;

begin
  process 
    variable err_flag : boolean := false;
    File INFILE: text open read_mode is "Generators/TRACEFILE_ALU.txt";
    FILE OUTFILE: text  open write_mode is "Outputs/OUTPUTS_ALU.txt";

    ---------------------------------------------------
    -- edit the next two lines to customize
    variable input_vector1: bit_vector ( 15 downto 0) := "0000000000000000";
    variable input_vector2: bit_vector ( 15 downto 0) := "0000000000000000";
    variable input3: bit := '0';
    variable output2: bit := '0';
    variable output3: bit := '0';
    variable output_vector1: bit_vector ( 15 downto 0) := "0000000000000000";
    ----------------------------------------------------
    variable INPUT_LINE: Line;
    variable OUTPUT_LINE: Line;
    variable LINE_COUNT: integer := 0;
    
  begin
   
    while not endfile(INFILE) loop
          LINE_COUNT := LINE_COUNT + 1;
      
      readLine (INFILE, INPUT_LINE);
          read (INPUT_LINE, input_vector1);
          read (INPUT_LINE, input_vector2);
          read (INPUT_LINE, input3);
          read (INPUT_LINE, output_vector1);
          read (INPUT_LINE, output2);
          read (INPUT_LINE, output3);
   
          --------------------------------------
          -- from input-vector to DUT inputs
          --------------------------------------
    i1 <= to_stdlogicvector(input_vector1);
    i2 <= to_stdlogicvector(input_vector2);
    i3 <= to_std_logic(input3);
      -- let circuit respond.
          wait for 5 ns;

          --------------------------------------
      -- check outputs.
      if (o1 /= to_stdlogicvector(output_vector1) or
          o2 /= to_std_logic(output2) or 
          (input3 = '0' and o3 /= to_std_logic(output3))) then
             write(OUTPUT_LINE,to_string("ERROR: in c1, line "));
             write(OUTPUT_LINE, LINE_COUNT);
             writeline(OUTFILE, OUTPUT_LINE);
             err_flag := true;
          end if;
          --------------------------------------


    end loop;

    assert (err_flag) report "SUCCESS, all tests passed." severity note;
    assert (not err_flag) report "FAILURE, some tests failed." severity error;

    wait;
  end process;

  dut: ALU
     port map(alu_in_1 => i1, alu_in_2 => i2, op_in => i3, alu_out => o1, zero => o2, carry => o3);

end Behave;
