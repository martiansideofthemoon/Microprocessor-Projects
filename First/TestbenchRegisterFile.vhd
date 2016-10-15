library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;
library work;
use work.ProcessorComponents.all;

entity TestbenchRegisterFile is
end entity;
architecture Behave of TestbenchRegisterFile is
  signal dout1: std_logic_vector(15 downto 0);
  signal dout2: std_logic_vector(15 downto 0);
  signal din : std_logic_vector(15 downto 0);
  signal register_write: std_logic;
  signal readA1: std_logic_vector(2 downto 0);
  signal readA2: std_logic_vector(2 downto 0);
  signal writeA3: std_logic_vector(2 downto 0);
  signal PC_write: std_logic;
  signal PC_in: std_logic_vector(15 downto 0);
  signal PC_out: std_logic_vector(15 downto 0);
  signal clk: std_logic := '0';
  signal reset: std_logic := '1';

  function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin
      ret_val := lx;
      return(ret_val);
  end to_string;

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
    File INFILE: text open read_mode is "Tracefiles/tracefile_register_file.txt";
    FILE OUTFILE: text  open write_mode is "Outputs/output_register_file.txt";

    ---------------------------------------------------
    -- edit the next few lines to customize
    variable reg_write: bit;
    variable pc_w: bit;
    variable ra1: bit_vector (2 downto 0);
    variable ra2: bit_vector (2 downto 0);
    variable wa3: bit_vector (2 downto 0);
    variable di : bit_vector (15 downto 0);
    variable p_in: bit_vector (15 downto 0);
    variable p_o: bit_vector (15 downto 0);
    variable d1: bit_vector (15 downto 0);
    variable d2: bit_vector (15 downto 0);
    ----------------------------------------------------
    variable INPUT_LINE: Line;
    variable OUTPUT_LINE: Line;
    variable LINE_COUNT: integer := 0;

  begin
    wait until clk = '1';

    while not endfile(INFILE) loop
      readLine(INFILE, INPUT_LINE);
      read(INPUT_LINE, reg_write);
      read(INPUT_LINE, pc_w);
      read(INPUT_LINE, ra1);
      read(INPUT_LINE, ra2);
      read(INPUT_LINE, wa3);
      read(INPUT_LINE, di);
      read(INPUT_LINE, p_in);
      LINE_COUNT := LINE_COUNT + 1;
      register_write <= to_std_logic(reg_write);
      PC_write <= to_std_logic(pc_w);
      readA1 <= to_std_logic_vector(ra1);
      readA1 <= to_std_logic_vector(ra2);
      writeA3 <= to_std_logic_vector(wa3);
      din <= to_std_logic_vector(di);
      PC_in <= to_std_logic_vector(p_in);

      wait until clk = '0';

        readLine(INFILE, INPUT_LINE);
        read(INPUT_LINE, d1);
        read(INPUT_LINE, d2);
        read(INPUT_LINE, p_o);
        LINE_COUNT := LINE_COUNT + 1;

        if (dout1 /= to_std_logic_vector(d1)) then
          write(OUTPUT_LINE,to_string("ERROR: in RESULT of DOUT1, line "));
          write(OUTPUT_LINE, LINE_COUNT);
          writeline(OUTFILE, OUTPUT_LINE);
          err_flag := true;
        end if;

        if (dout2 /= to_std_logic_vector(d2)) then
          write(OUTPUT_LINE,to_string("ERROR: in RESULT of DOUT2, line "));
          write(OUTPUT_LINE, LINE_COUNT);
          writeline(OUTFILE, OUTPUT_LINE);
          err_flag := true;
        end if;

        if (PC_out /= to_std_logic_vector(p_o)) then
          write(OUTPUT_LINE,to_string("ERROR: in RESULT of PC_OUT, line "));
          write(OUTPUT_LINE, LINE_COUNT);
          writeline(OUTFILE, OUTPUT_LINE);
          err_flag := true;
        end if;

    	wait until clk = '1';

    end loop;

    assert (err_flag) report "SUCCESS, all tests passed." severity note;
    assert (not err_flag) report "FAILURE, some tests failed." severity error;

    wait;
  end process;

  dut: RegisterFile
  port map (
    dout1 => dout1,
    dout2 => dout2,
    din => din,
    register_write => register_write,
    readA1 => readA1,
    readA2 => readA2,
    writeA3 => writeA3,
    PC_write => PC_write,
    PC_in => PC_in,
    PC_out => PC_out,
    clk => clk
  );
end Behave;

