library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity DataForwarding is
  port (
    -- STAGE 3
    -- stage3 opcode --> 9 downto 6
    -- stage3 regA1 --> 5 downto 3
    -- stage3 regA2 --> 2 downto 0
    stage3_signals: in std_logic_vector(9 downto 0);

    -- STAGE 4
    -- stage4 opcode --> 9 downto 6
    -- stage4 regA1 --> 5 downto 3
    -- stage4 regA2 --> 2 downto 0
    stage4_signals: in std_logic_vector(9 downto 0);

    -- STAGE 5
    -- stage5 reg_write --> 8
    -- stage5 r7_write --> 7
    -- stage5 opcode --> 6 downto 3
    -- stage5 writeA3 --> 2 downto 0
    stage5_signals: in std_logic_vector(8 downto 0);
    -- stage5 r7_data --> 31 downto 16
    -- stage5 regdata_in --> 15 downto 0
    stage5_data: in std_logic_vector(31 downto 0);

    -- STAGE 6
    -- stage6 reg_write --> 4
    -- stage6 r7_write --> 3
    -- stage6 writeA3 --> 2 downto 0
    stage6_signals: in std_logic_vector(4 downto 0);
    -- stage6 r7_data --> 31 downto 16
    -- stage6 regdata_in --> 15 downto 0
    stage6_data: in std_logic_vector(31 downto 0);

    -- Load-Read Distress Signal
    -- Pipeline should be stalled for one cycle
    -- Forwarding will happen when load reaches stage 6
    load5_read4: out std_logic;

    -- Forward to Stage 3
    forward3_regA1: out std_logic;
    forward3_regA2: out std_logic;
    forward3_dataA1: out std_logic_vector(15 downto 0);
    forward3_dataA2: out std_logic_vector(15 downto 0);
    -- Forward to Stage 4
    forward4_regA1: out std_logic;
    forward4_regA2: out std_logic;
    forward4_dataA1: out std_logic_vector(15 downto 0);
    forward4_dataA2: out std_logic_vector(15 downto 0);
    -- Reset Signal
    reset: in std_logic
  );
end entity DataForwarding;

architecture Struct of DataForwarding is
begin

-- Process to generate Load Distress Signals
process(stage4_signals, stage5_signals, reset)
  variable stage4_opcode: std_logic_vector(3 downto 0);
  variable stage4_regA1: std_logic_vector(2 downto 0);
  variable stage4_regA2: std_logic_vector(2 downto 0);

  variable stage5_opcode: std_logic_vector(3 downto 0);
  variable stage5_writeA3: std_logic_vector(2 downto 0);
  variable stage5_regwrite: std_logic;

  variable nload5_read4_regA1: std_logic;
  variable nload5_read4_regA2: std_logic;
begin
  stage4_opcode := stage4_signals(9 downto 6);
  stage4_regA1 := stage4_signals(5 downto 3);
  stage4_regA2 := stage4_signals(2 downto 0);

  stage5_opcode := stage5_signals(6 downto 3);
  stage5_writeA3 := stage5_signals(2 downto 0);
  stage5_regwrite := stage5_signals(8);

  nload5_read4_regA1 := '0';
  nload5_read4_regA2 := '0';

  -- TODO :- BRANCH op_codes
  -- Current opcodes include all ADDs, NDUs, LM, SM, LW, SW
  if (stage4_opcode = "0000" or stage4_opcode = "0001" or
      stage4_opcode = "0010" or stage4_opcode = "0100" or
      stage4_opcode = "0101" or stage4_opcode = "0110" or
      stage4_opcode = "0111" or stage4_opcode = "1100") then
    if ((stage5_opcode = "0100" or stage5_opcode = "0110") and
        stage5_regwrite = '1' and stage4_regA1 = stage5_writeA3) then
      nload5_read4_regA1 := '1';
    else
      nload5_read4_regA1 := '0';
    end if;
  else
    nload5_read4_regA1 := '0';
  end if;

  -- TODO :- BRANCH op_codes
  -- Current opcodes include all ADDs, NDUs, SW, SM
  if (stage4_opcode = "0000" or stage4_opcode = "0010" or
      stage4_opcode = "0101" or stage4_opcode = "0111" or stage4_opcode = "1100") then
    if ((stage5_opcode = "0100" or stage5_opcode = "0110") and
        stage5_regwrite = '1' and stage4_regA2 = stage5_writeA3) then
      nload5_read4_regA2 := '1';
    else
      nload5_read4_regA2 := '0';
    end if;
  else
    nload5_read4_regA2 := '0';
  end if;

  if (reset = '1') then
    load5_read4 <= '0';
  else
    load5_read4 <= nload5_read4_regA1 or nload5_read4_regA2;
  end if;

end process;

-- Process to resolve stage3 - stage6 conflicts
process(stage3_signals, stage6_signals, stage6_data, reset)
  variable stage3_opcode: std_logic_vector(3 downto 0);
  variable stage3_regA1: std_logic_vector(2 downto 0);
  variable stage3_regA2: std_logic_vector(2 downto 0);

  variable stage6_writeA3: std_logic_vector(2 downto 0);
  variable stage6_regwrite: std_logic;
  variable stage6_r7write: std_logic;

  variable nforward3_regA1: std_logic;
  variable nforward3_regA2: std_logic;
  variable nforward3_dataA1: std_logic_vector(15 downto 0);
  variable nforward3_dataA2: std_logic_vector(15 downto 0);

begin
  stage3_opcode := stage3_signals(9 downto 6);
  stage3_regA1 := stage3_signals(5 downto 3);
  stage3_regA2 := stage3_signals(2 downto 0);
  stage6_writeA3 := stage6_signals(2 downto 0);
  stage6_regwrite := stage6_signals(4);
  stage6_r7write := stage6_signals(3);

  nforward3_regA1 := '0';
  nforward3_dataA1 := (others => '0');
  nforward3_regA2 := '0';
  nforward3_dataA2 := (others => '0');

  -- TODO :- BRANCH op_codes
  -- Current opcodes include all ADDs, NDUs, LM, SM, LW, SW
  if (stage3_opcode = "0000" or stage3_opcode = "0001" or
      stage3_opcode = "0010" or stage3_opcode = "0100" or
      stage3_opcode = "0101" or stage3_opcode = "0110" or
      stage3_opcode = "0111" or stage3_opcode = "1100") then

    if (stage6_regwrite = '1' and stage3_regA1 = stage6_writeA3) then
      nforward3_regA1 := '1';
      nforward3_dataA1 := stage6_data(15 downto 0);
    elsif (stage6_r7write = '1' and stage3_regA1 = "111") then
      nforward3_regA1 := '1';
      nforward3_dataA1 := stage6_data(31 downto 16);
    else
      nforward3_regA1 := '0';
      nforward3_dataA1 := (others => '0');
    end if;
  else
    nforward3_regA1 := '0';
    nforward3_dataA1 := (others => '0');
  end if;

  -- TODO :- BRANCH op_codes
  -- Current opcodes include all ADDs, NDUs, SW, SM
  if (stage3_opcode = "0000" or stage3_opcode = "0010" or
      stage3_opcode = "0101" or stage3_opcode = "0111" or stage3_opcode = "1100") then

    if (stage6_regwrite = '1' and stage3_regA2 = stage6_writeA3) then
      nforward3_regA2 := '1';
      nforward3_dataA2 := stage6_data(15 downto 0);
    elsif (stage6_r7write = '1' and stage3_regA2 = "111") then
      nforward3_regA2 := '1';
      nforward3_dataA2 := stage6_data(31 downto 16);
    else
      nforward3_regA2 := '0';
      nforward3_dataA2 := (others => '0');
    end if;
  else
    nforward3_regA2 := '0';
    nforward3_dataA2 := (others => '0');
  end if;

  if (reset = '1') then
    forward3_regA1 <= '0';
    forward3_dataA1 <= (others => '0');
    forward3_regA2 <= '0';
    forward3_dataA2 <= (others => '0');
  else
    forward3_regA1 <= nforward3_regA1;
    forward3_dataA1 <= nforward3_dataA1;
    forward3_regA2 <= nforward3_regA2;
    forward3_dataA2 <= nforward3_dataA2;
  end if;

end process;

-- Process to resolve stage4 - stage5/stage6 conflicts for regA1
process(stage4_signals, stage5_signals, stage6_signals, stage5_data, stage6_data, reset)
  variable stage4_opcode: std_logic_vector(3 downto 0);
  variable stage4_regA1: std_logic_vector(2 downto 0);
  variable stage4_regA2: std_logic_vector(2 downto 0);

  variable stage5_opcode: std_logic_vector(3 downto 0);
  variable stage5_writeA3: std_logic_vector(2 downto 0);
  variable stage5_regwrite: std_logic;
  variable stage5_r7write: std_logic;

  variable stage6_writeA3: std_logic_vector(2 downto 0);
  variable stage6_regwrite: std_logic;
  variable stage6_r7write: std_logic;

  variable nforward4_regA1: std_logic;
  variable nforward4_dataA1: std_logic_vector(15 downto 0);
  variable nforward4_regA2: std_logic;
  variable nforward4_dataA2: std_logic_vector(15 downto 0);
begin
  stage4_opcode := stage4_signals(9 downto 6);
  stage4_regA1 := stage4_signals(5 downto 3);
  stage4_regA2 := stage4_signals(2 downto 0);

  stage5_regwrite := stage5_signals(8);
  stage5_r7write := stage5_signals(7);
  stage5_opcode := stage5_signals(6 downto 3);
  stage5_writeA3 := stage5_signals(2 downto 0);

  stage6_regwrite := stage6_signals(4);
  stage6_r7write := stage6_signals(3);
  stage6_writeA3 := stage6_signals(2 downto 0);

  nforward4_regA1 := '0';
  nforward4_dataA1 := (others => '0');
  nforward4_regA2 := '0';
  nforward4_dataA2 := (others => '0');

  -- TODO :- BRANCH op_codes
  -- Current opcodes include all ADDs, NDUs, LM, SM, LW, SW
  if (stage4_opcode = "0000" or stage4_opcode = "0001" or
      stage4_opcode = "0010" or stage4_opcode = "0100" or
      stage4_opcode = "0101" or stage4_opcode = "0110" or
      stage4_opcode = "0111" or stage4_opcode = "1100") then

    if (stage5_regwrite = '1' and stage4_regA1 = stage5_writeA3) then
      nforward4_regA1 := '1';
      nforward4_dataA1 := stage5_data(15 downto 0);
    elsif (stage5_r7write = '1' and stage4_regA1 = "111") then
      nforward4_regA1 := '1';
      nforward4_dataA1 := stage5_data(31 downto 16);
    elsif (stage6_regwrite = '1' and stage4_regA1 = stage6_writeA3) then
      nforward4_regA1 := '1';
      nforward4_dataA1 := stage6_data(15 downto 0);
    elsif (stage6_r7write = '1' and stage4_regA1 = "111") then
      nforward4_regA1 := '1';
      nforward4_dataA1 := stage6_data(31 downto 16);
    else
      nforward4_regA1 := '0';
      nforward4_dataA1 := (others => '0');
    end if;
  else
    nforward4_regA1 := '0';
    nforward4_dataA1 := (others => '0');
  end if;

  -- TODO :- BRANCH op_codes
  -- Current opcodes include all ADDs, NDUs, SW, SM
  if (stage4_opcode = "0000" or stage4_opcode = "0010" or
      stage4_opcode = "0101" or stage4_opcode = "0111" stage4_opcode = "1100") then
    if (stage5_regwrite = '1' and stage4_regA2 = stage5_writeA3) then
      nforward4_regA2 := '1';
      nforward4_dataA2 := stage5_data(15 downto 0);
    elsif (stage5_r7write = '1' and stage4_regA2 = "111") then
      nforward4_regA2 := '1';
      nforward4_dataA2 := stage5_data(31 downto 16);
    elsif (stage6_regwrite = '1' and stage4_regA2 = stage6_writeA3) then
      nforward4_regA2 := '1';
      nforward4_dataA2 := stage6_data(15 downto 0);
    elsif (stage6_r7write = '1' and stage4_regA2 = "111") then
      nforward4_regA2 := '1';
      nforward4_dataA2 := stage6_data(31 downto 16);
    else
      nforward4_regA2 := '0';
      nforward4_dataA2 := (others => '0');
    end if;
  else
    nforward4_regA2 := '0';
    nforward4_dataA2 := (others => '0');
  end if;

  if (reset = '1') then
    forward4_regA1 <= '0';
    forward4_dataA1 <= (others => '0');
    forward4_regA2 <= '0';
    forward4_dataA2 <= (others => '0');
  else
    forward4_regA1 <= nforward4_regA1;
    forward4_dataA1 <= nforward4_dataA1;
    forward4_regA2 <= nforward4_regA2;
    forward4_dataA2 <= nforward4_dataA2;
  end if;
end process;

end Struct;