library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;
library work;
use work.ProcessorComponents.all;

entity TestbenchPriorityLoop is
end entity;
architecture Behave of TestbenchPriorityLoop is
  signal input: std_logic_vector(7 downto 0);
  signal output: std_logic_vector(2 downto 0);
  signal priority_select: std_logic;
  signal input_zero: std_logic;
  signal clk: std_logic := '0';
  signal reset: std_logic := '1';

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

begin
  clk <= not clk after 5 ns; -- assume 10ns clock.

  -- reset process
  process
  begin
     wait until clk = '1';
     reset <= '0';
     wait;
  end process;

  process
    variable err_flag : boolean := false;
    File INFILE: text open read_mode is "Tracefiles/tracefile_priority.txt";
    FILE OUTFILE: text  open write_mode is "Outputs/output_priority.txt";

    ---------------------------------------------------
    -- edit the next few lines to customize
    variable input_var: bit_vector (7 downto 0);
    variable output_var: bit_vector (2 downto 0);
    variable Result_var: bit_vector (2 downto 0);
    variable number_outputs: integer := 0;
    variable current_output: integer := 0;
    ----------------------------------------------------
    variable INPUT_LINE: Line;
    variable OUTPUT_LINE: Line;
    variable LINE_COUNT: integer := 0;

  begin
    wait until clk = '0';
    priority_select <= '1';

    while not endfile(INFILE) loop
      readLine(INFILE, INPUT_LINE);
      read(INPUT_LINE, input_var);
      read(INPUT_LINE, number_outputs);
      current_output := 0;
      LINE_COUNT := LINE_COUNT + 1;
      input <= to_std_logic_vector(input_var);

      wait until clk = '1';

      while current_output < number_outputs loop
        readLine(INFILE, INPUT_LINE);
        read(INPUT_LINE, output_var);
        current_output := current_output + 1;
        LINE_COUNT := LINE_COUNT + 1;

        wait until clk = '0';

        if (output /= to_std_logic_vector(output_var)) then
          write(OUTPUT_LINE,to_string("ERROR: in RESULT, line "));
          write(OUTPUT_LINE, LINE_COUNT);
          writeline(OUTFILE, OUTPUT_LINE);
          err_flag := true;
        end if;

        priority_select <= '0';
        wait until clk = '1';

      end loop;

      priority_select <= '1';
    	wait until clk = '0';

    end loop;

    assert (err_flag) report "SUCCESS, all tests passed." severity note;
    assert (not err_flag) report "FAILURE, some tests failed." severity error;

    wait;
  end process;

  dut: PriorityLoop
  port map (
    input => input,
    priority_select => priority_select,
    clock => clk,
    output => output,
    input_zero => input_zero
  );

end Behave;

