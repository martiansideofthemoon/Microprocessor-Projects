library std;
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity Datapath is
  port (
    clk, reset: in std_logic;

    -- Data coming from outside
    external_r0: out std_logic_vector(15 downto 0);
    external_r1: out std_logic_vector(15 downto 0);
    external_r2: out std_logic_vector(15 downto 0);
    external_r3: out std_logic_vector(15 downto 0);
    external_r4: out std_logic_vector(15 downto 0);
    external_r5: out std_logic_vector(15 downto 0);
    external_r6: out std_logic_vector(15 downto 0)
  );
end entity;

architecture Mixed of Datapath is
  -- Constants
  signal CONST_0: std_logic_vector(15 downto 0) := (others => '0');
  signal CONST_1: std_logic_vector(15 downto 0) := (0 => '1', others => '0');
  signal CONST_32: std_logic_vector(15 downto 0) := (5 => '1', others => '0');

---------------------------------------------------
---------STAGE 1 - INSTRUCTION FETCH---------------
  signal PC_IN: std_logic_vector(15 downto 0);
  signal LSHIFT_PC_OUT: std_logic_vector(15 downto 0);
  signal PC_OUT: std_logic_vector(15 downto 0);
  signal PC_INCREMENT: std_logic_vector(15 downto 0);
  signal INST_MEMORY: std_logic_vector(15 downto 0);
  signal CACHE_NEXT_PC: std_logic_vector(15 downto 0);
  signal pc_enable: std_logic;
  signal pc_hit: std_logic;
  signal pc_history: std_logic;
  signal kill_stage1: std_logic;
  signal pc_branch_forward: std_logic;
  signal PC_BRANCH_ADDRESS: std_logic_vector(15 downto 0);
---------------------------------------------------
  signal p1_enable: std_logic;
  signal P1_IN: std_logic_vector(49 downto 0);
  signal P1_OUT: std_logic_vector(49 downto 0);

---------------------------------------------------
---------STAGE 2 - INSTRUCTION DECODE--------------
  signal INST_DECODE: std_logic_vector(DecodeSize-1 downto 0) := (others => '0');
  signal INST_JUMP_DECODE: std_logic_vector(3 downto 0) := (others => '0');
  signal pl_input_zero: std_logic;
  signal LM_SM:std_logic;
  signal priority_select_in: std_logic;
  signal PL_WRITE:std_logic_vector(2 downto 0);
  signal LM_INST_DECODE:std_logic_vector(DecodeSize-1 downto 0);
  signal SM_INST_DECODE:std_logic_vector(DecodeSize-1 downto 0);
  signal PL_OFFSET: std_logic_vector(15 downto 0);
  signal kill_stage2: std_logic;
---------------------------------------------------
  signal p2_enable: std_logic;
  signal P2_IN_DUMMY:std_logic_vector(DecodeSize-1 downto 0);
  signal P2_kill:std_logic_vector(DecodeSize-1 downto 0);
  signal P2_STALL_KILL: std_logic_vector(DecodeSize-1 downto 0);
  signal P2_IN: std_logic_vector(DecodeSize-1 downto 0);
  signal P2_OUT: std_logic_vector(DecodeSize-1 downto 0);
  signal P2_DATA_IN: std_logic_vector(31 downto 0);
  signal P2_DATA_OUT: std_logic_vector(31 downto 0);
  signal P2_JUMP_DATA_IN: std_logic_vector(21 downto 0);
  signal P2_JUMP_DATA: std_logic_vector(21 downto 0);
  signal P2_CACHE_DATA_IN: std_logic_vector(17 downto 0);
  signal P2_CACHE_DATA: std_logic_vector(17 downto 0);


---------------------------------------------------
---------STAGE 3 - REGISTER READ-------------------
  signal DATA1: std_logic_vector(15 downto 0);
  signal DATA2: std_logic_vector(15 downto 0);
  signal FINAL_DATA1: std_logic_vector(15 downto 0);
  signal FINAL_DATA2: std_logic_vector(15 downto 0);
  signal SE6_OUT: std_logic_vector(15 downto 0);
  signal SE9_OUT: std_logic_vector(15 downto 0);
  signal ZERO_PAD9: std_logic_vector(15 downto 0);
  signal kill_stage3: std_logic;
  signal jump_stage3: std_logic;
  signal JUMP_STAGE3_ADDR: std_logic_vector(15 downto 0);
---------------------------------------------------
  signal p3_enable: std_logic;
  signal P3_IN: std_logic_vector(DecodeSize-1 downto 0);
  signal P3_OUT: std_logic_vector(DecodeSize-1 downto 0);
  signal P3_DATA_IN: std_logic_vector(63 downto 0);
  signal P3_DATA_OUT: std_logic_vector(63 downto 0);
  signal P3_JUMP_DATA_IN: std_logic_vector(21 downto 0);
  signal P3_JUMP_DATA: std_logic_vector(21 downto 0);
  signal P3_CACHE_DATA_IN: std_logic_vector(17 downto 0);
  signal P3_CACHE_DATA: std_logic_vector(17 downto 0);
  signal P3_STALL_KILL: std_logic_vector(DecodeSize-1 downto 0);

---------------------------------------------------
---------STAGE 4 - EXECUTE STAGE-------------------
  signal ALU1_IN: std_logic_vector(15 downto 0);
  signal ALU2_IN: std_logic_vector(15 downto 0);
  signal ALU_OUT: std_logic_vector(15 downto 0);
  signal FINAL_CARRY: std_logic_vector(0 downto 0);
  signal FINAL_ZERO: std_logic_vector(0 downto 0);
  signal FINAL_FLAG_CONDITION: std_logic_vector(1 downto 0);
  signal ALU_carry: std_logic;
  signal ALU_zero: std_logic;
  signal kill_stage4: std_logic;
  signal jump_stage4: std_logic;
  signal JUMP_STAGE4_ADDR: std_logic_vector(15 downto 0);
---------------FLAG FORWARDING SIGNALS-------------
  signal carry_forward: std_logic;
  signal carry_forward_val: std_logic;
  signal zero_forward: std_logic;
  signal zero_forward_val: std_logic;
---------------DATA FORWARDING SIGNALS-------------
  -- DataForwarding inputs
  signal STAGE3_DF_SIGNALS: std_logic_vector(9 downto 0);
  signal STAGE4_DF_SIGNALS: std_logic_vector(9 downto 0);
  signal STAGE5_DF_SIGNALS: std_logic_vector(8 downto 0);
  signal STAGE6_DF_SIGNALS: std_logic_vector(4 downto 0);
  signal STAGE5_DF_DATA: std_logic_vector(31 downto 0);
  signal STAGE6_DF_DATA: std_logic_vector(31 downto 0);
  -- DataForwarding outputs
  signal FORWARD3_DATA1: std_logic_vector(15 downto 0);
  signal FORWARD3_DATA2: std_logic_vector(15 downto 0);
  signal FORWARD4_DATA1: std_logic_vector(15 downto 0);
  signal FORWARD4_DATA2: std_logic_vector(15 downto 0);
  signal load5_read4: std_logic;
  signal forward3_regA1: std_logic;
  signal forward3_regA2: std_logic;
  signal forward4_regA1: std_logic;
  signal forward4_regA2: std_logic;
---------------------------------------------------
  signal p4_enable: std_logic;
  signal P4_IN: std_logic_vector(DecodeSize-1 downto 0);
  signal P4_OUT: std_logic_vector(DecodeSize-1 downto 0);
  signal P4_DATA_IN: std_logic_vector(47 downto 0);
  signal P4_DATA_OUT: std_logic_vector(47 downto 0);
  signal P4_FLAG_IN: std_logic_vector(1 downto 0);
  signal P4_FLAG_OUT: std_logic_vector(1 downto 0);
  signal P4_KILL: std_logic_vector(DecodeSize-1 downto 0);
  signal P4_KILL_STALL: std_logic_vector(DecodeSize-1 downto 0);
  signal P4_CACHE_DATA_IN: std_logic_vector(17 downto 0);
  signal P4_CACHE_DATA: std_logic_vector(17 downto 0);
  signal P4_CACHE_VALUES: std_logic_vector(17 downto 0);
  signal P4_JUMP_DATA_IN: std_logic_vector(21 downto 0);
  signal P4_JUMP_DATA: std_logic_vector(21 downto 0);

---------------------------------------------------
---------STAGE 5 - MEMORY STAGE--------------------
  signal ADDRESS_IN: std_logic_vector(15 downto 0);
  signal LSHIFT_ADDRESS_IN: std_logic_vector(15 downto 0);
  signal MEMDATA_IN: std_logic_vector(15 downto 0);
  signal MEM_OUT: std_logic_vector(15 downto 0);
  signal mem_load_zero: std_logic;
  signal jump_stage5: std_logic;
  signal JUMP_STAGE5_ADDR: std_logic_vector(15 downto 0);
---------------------------------------------------
  signal p5_enable: std_logic;
  signal P5_IN: std_logic_vector(DecodeSize-1 downto 0);
  signal P5_OUT: std_logic_vector(DecodeSize-1 downto 0);
  signal P5_DATA_IN: std_logic_vector(47 downto 0);
  signal P5_DATA_OUT: std_logic_vector(47 downto 0);
  signal P5_FLAG_IN: std_logic_vector(1 downto 0);
  signal P5_FLAG_OUT: std_logic_vector(1 downto 0);
  signal P5_CACHE_DATA_IN: std_logic_vector(17 downto 0);
  signal P5_CACHE_DATA: std_logic_vector(17 downto 0);
  signal P5_JUMP_DATA_IN: std_logic_vector(21 downto 0);
  signal P5_JUMP_DATA: std_logic_vector(21 downto 0);

---------------------------------------------------
---------STAGE 6 - WRITE STAGE---------------------
  signal R7_IN: std_logic_vector(15 downto 0);
  signal R7_OUT: std_logic_vector(15 downto 0);
  signal R7_WRITE: std_logic;
  signal WRITE3: std_logic_vector(2 downto 0);
  signal REGDATA_IN: std_logic_vector(15 downto 0);
  signal REGLOAD_zero: std_logic;
  signal reg_write: std_logic;

  signal CARRY_IN: std_logic_vector(0 downto 0);
  signal ZERO_IN: std_logic_vector(0 downto 0);
  signal CARRY: std_logic_vector(0 downto 0);
  signal ZERO: std_logic_vector(0 downto 0);

  signal CACHE_WRITE_PC: std_logic_vector(15 downto 0);
  signal CACHE_WRITE_ADDR: std_logic_vector(15 downto 0);
  signal cache_write_history: std_logic;
  signal cache_write: std_logic;

begin
---------------------------------------------------
---------STAGE 1 - INSTRUCTION FETCH---------------
  PC: DataRegister
      generic map (data_width => 16)
      port map (
        Din => PC_IN,
        Dout => PC_OUT,
        Enable => pc_enable,
        clk => clk,
        reset => reset
      );
  INC: Increment
       port map (
         input => PC_OUT,
         output => PC_INCREMENT
       );
  IM: Memory
      port map (
        clk => clk,
        mem_write => '0',
        addr => LSHIFT_PC_OUT,
        data => CONST_0,
        mem_out => INST_MEMORY
      );
  LS: LeftShift
      port map (
        input => PC_OUT,
        output => LSHIFT_PC_OUT
      );
  CS: Cache
      port map (
      -- Read signals
      target_address => CACHE_NEXT_PC,
      target_history => pc_history,
      target_pc => PC_OUT,
      target_hit => pc_hit,
      clk => clk,
      reset => reset,
      -- Write signals
      write_pc => CACHE_WRITE_PC,
      write_address => CACHE_WRITE_ADDR,
      write_history => cache_write_history,
      cache_write => cache_write
    );
  PCF: PCForwarding
    port map (
    pc_stage3 => JUMP_STAGE3_ADDR,
    pc_stage4 => JUMP_STAGE4_ADDR,
    pc_stage5 => JUMP_STAGE5_ADDR,
    pc_stage3_flag => jump_stage3,
    pc_stage4_flag => jump_stage4,
    pc_stage5_flag => jump_stage5,
    pc_forwarding_out => PC_BRANCH_ADDRESS,
    pc_forwarding => pc_branch_forward,
    kill1 => kill_stage1,
    kill2 => kill_stage2,
    kill3 => kill_stage3,
    kill4 => kill_stage4,
    reset => reset
  );


  PC_IN <= (others => '0') when reset = '1' else
           PC_BRANCH_ADDRESS when pc_branch_forward = '1' else
           PC_INCREMENT when pc_hit = '0' else
           PC_INCREMENT when pc_hit = '1' and pc_history = '0' else
           CACHE_NEXT_PC when pc_hit = '1' and pc_history = '1' else
           (others => '0');

  P1_IN(15 downto 0) <= INST_MEMORY when (reset = '0' and kill_stage1 = '0') else (others => '1');
  P1_IN(31 downto 16) <= PC_IN;
  P1_IN(47 downto 32) <= PC_OUT;
  P1_IN(48) <= pc_history;
  P1_IN(49) <= pc_hit;
----------------------------------------------------
  P1: DataRegister
      generic map (data_width => 50)
      port map (
        Din => P1_IN,
        Dout => P1_OUT,
        Enable => p1_enable,
        clk => clk,
        reset => reset
      );

---------------------------------------------------
---------STAGE 2 - INSTRUCTION DECODE--------------
  ID: InstructionDecoder
      port map (
        instruction => P1_OUT(15 downto 0),
        output => INST_DECODE,
        jump_output => INST_JUMP_DECODE,
        reset => reset
      );
  RC: RegisterControl
      port map (
        instruction => P1_OUT(15 downto 0),
        pl_input_zero => pl_input_zero,
        load5_read4 => load5_read4,
        pc_enable => pc_enable,
        p1_enable => p1_enable,
        p2_enable => p2_enable,
        p3_enable => p3_enable,
        p4_enable => p4_enable,
        p5_enable => p5_enable,
        reset => reset
      );
  priority_select_in <= '1' when P1_IN(15 downto 12) = "0110" and p1_enable = '1' else
                        '1' when P1_IN(15 downto 12) = "0111" and p1_enable = '1' else
                        '0';
  PL: PriorityLoop
      port map(
        input => P1_IN(7 downto 0),
        priority_select => priority_select_in,
        clock => clk,
        reset => reset,
        input_zero => pl_input_zero,
        output => PL_WRITE,
        offset => PL_OFFSET,
        pl_enable => p2_enable
        );

  LM_INST_DECODE(DecodeSize-1 downto 14) <= INST_DECODE(DecodeSize-1 downto 14);
  LM_INST_DECODE(13 downto 11) <= PL_WRITE when P1_OUT(15 downto 12) = "0110" else
                                     INST_DECODE(13 downto 11);
  LM_INST_DECODE(10 downto 0) <= INST_DECODE(10 downto 0);

  SM_INST_DECODE(DecodeSize-1 downto 3) <= INST_DECODE(DecodeSize-1 downto 3);
  SM_INST_DECODE(2 downto 0) <= PL_WRITE when P1_OUT(15 downto 12) = "0111" else
                                     INST_DECODE(2 downto 0);

  P2_IN_DUMMY <= LM_INST_DECODE when P1_OUT(15 downto 12) = "0110" else
                 SM_INST_DECODE when P1_OUT(15 downto 12) = "0111" else
                 INST_DECODE;

  Kill_LM_SM: KillInstruction
      port map (
        Decode_in => P2_IN_DUMMY,
        Decode_out => P2_kill
        );
  KillStage2: KillStallInstruction
    port map (
        Decode_in => P2_IN_DUMMY,
        Decode_out => P2_STALL_KILL
      );

  LM_SM <= '1' when P1_OUT(15 downto 12) = "0110" else
           '1' when P1_OUT(15 downto 12) = "0111" else
           '0';
  P2_IN <=  P2_STALL_KILL when kill_stage2 = '1' else
            P2_kill when P1_OUT(7 downto 0) = "00000000" and LM_SM = '1' else
            P2_IN_DUMMY;
  P2_DATA_IN(15 downto 0) <= P1_OUT(31 downto 16);
  P2_DATA_IN(31 downto 16) <= PL_OFFSET;
  P2_JUMP_DATA_IN(17 downto 0) <= P1_OUT(49 downto 32);
  P2_JUMP_DATA_IN(21 downto 18) <= INST_JUMP_DECODE(3 downto 0);
  P2_CACHE_DATA_IN(17 downto 0) <= (others => '0');

---------------------------------------------------
  P2: DataRegister
      generic map (data_width => DecodeSize)
      port map (
        Din => P2_IN,
        Dout => P2_OUT,
        Enable => p2_enable,
        clk => clk,
        reset => reset
      );
  P2_data: DataRegister
      generic map(data_width => 32)
      port map (
        Din => P2_DATA_IN,
        Dout => P2_DATA_OUT,
        Enable => p2_enable,
        clk => clk,
        reset => reset
      );
  P2_jump: DataRegister
      generic map(data_width => 22)
      port map (
        Din => P2_JUMP_DATA_IN,
        Dout => P2_JUMP_DATA,
        Enable => p2_enable,
        clk => clk,
        reset => reset
      );
  P2_cache: DataRegister
      generic map(data_width => 18)
      port map (
        Din => P2_CACHE_DATA_IN,
        Dout => P2_CACHE_DATA,
        Enable => p2_enable,
        clk => clk,
        reset => reset
      );

---------------------------------------------------
---------STAGE 3 - REGISTER READ-------------------
  RF: RegisterFile
      port map (
        clk => clk,
        PC_in => R7_IN,
        PC_out => R7_OUT,
        PC_write => R7_WRITE,
        dout1 => DATA1,
        dout2 => DATA2,
        readA1 => P2_OUT(5 downto 3),
        readA2 => P2_OUT(2 downto 0),
        writeA3 => WRITE3,
        register_write => reg_write,
        din => REGDATA_IN,
        zero => REGLOAD_zero,
        external_r0 => external_r0,
        external_r1 => external_r1,
        external_r2 => external_r2,
        external_r3 => external_r3,
        external_r4 => external_r4,
        external_r5 => external_r5,
        external_r6 => external_r6
      );
  SE: SignExtender6
      port map (
        input => P2_OUT(20 downto 15),
        output => SE6_OUT
      );
  SE9: SignExtender9
       port map (
         input => P2_OUT(23 downto 15),
         output => SE9_OUT
       );
  PAD: LSBZeroPad
       port map (
         input => P2_OUT(23 downto 15),
         output => ZERO_PAD9
       );
  KillStage3: KillStallInstruction
    port map (
        Decode_in => P2_OUT,
        Decode_out => P3_STALL_KILL
      );


  P3_IN <= P2_OUT when kill_stage3 = '0' else P3_STALL_KILL;
  FINAL_DATA1 <= DATA1 when forward3_regA1 = '0' else FORWARD3_DATA1;
  FINAL_DATA2 <= DATA2 when forward3_regA2 = '0' else FORWARD3_DATA2;

  -- Used for memory data input
  P3_DATA_IN(63 downto 48) <= FINAL_DATA2;
  P3_DATA_IN(47 downto 32) <= P2_DATA_OUT(15 downto 0);
  P3_DATA_IN(31 downto 16) <= FINAL_DATA1 when P2_OUT(27 downto 26) = "00" else
                              CONST_0;
  P3_DATA_IN(15 downto 0) <= SE6_OUT when P2_OUT(25 downto 24) = "01" else
                             FINAL_DATA2 when P2_OUT(25 downto 24) = "00" else
                             ZERO_PAD9 when P2_OUT(25 downto 24) = "10" else
                             P2_DATA_OUT(31 downto 16) when P2_OUT(25 downto 24) = "11";
  P3_JUMP_DATA_IN(21 downto 0) <= P2_JUMP_DATA;
  P3_CACHE_DATA_IN <= P2_CACHE_DATA when kill_stage3 = '0' else (others => '0');
----------------------------------------------------
  P3: DataRegister
      generic map (data_width => DecodeSize)
      port map (
        Din => P3_IN,
        Dout => P3_OUT,
        Enable => p3_enable,
        clk => clk,
        reset => reset
      );
  P3_data: DataRegister
      generic map(data_width => 64)
      port map (
        Din => P3_DATA_IN,
        Dout => P3_DATA_OUT,
        Enable => p3_enable,
        clk => clk,
        reset => reset
      );
  P3_jump: DataRegister
      generic map(data_width => 22)
      port map (
        Din => P3_JUMP_DATA_IN,
        Dout => P3_JUMP_DATA,
        Enable => p3_enable,
        clk => clk,
        reset => reset
      );
  P3_cache: DataRegister
      generic map(data_width => 18)
      port map (
        Din => P3_CACHE_DATA_IN,
        Dout => P3_CACHE_DATA,
        Enable => p3_enable,
        clk => clk,
        reset => reset
      );

---------------------------------------------------
---------STAGE 4 - EXECUTE STAGE-------------------
  ALU1_IN <= P3_DATA_OUT(31 downto 16) when forward4_regA1 = '0' else FORWARD4_DATA1;
  ALU2_IN <= P3_DATA_OUT(15 downto 0) when forward4_regA2 = '0' else FORWARD4_DATA2;
  AL: ALU
      port map (
        alu_in_1 => ALU1_IN,
        alu_in_2 => ALU2_IN,
        op_in => P3_OUT(6),
        alu_out => ALU_OUT,
        carry => ALU_carry,
        zero => ALU_zero
      );
  FF: FlagForwarding
      port map (
        set_carry5 => P4_OUT(9),
        set_zero5 => P4_OUT(10),
        carry5 => P4_FLAG_OUT(1),
        zero5 => P4_FLAG_OUT(0),
        zero5_load => mem_load_zero,
        op_code => P4_OUT(31 downto 28),
        set_carry6 => P5_OUT(9),
        set_zero6 => P5_OUT(10),
        carry6 => P5_FLAG_OUT(1),
        zero6 => P5_FLAG_OUT(0),
        carry_forward => carry_forward,
        zero_forward => zero_forward,
        carry_val => carry_forward_val,
        zero_val => zero_forward_val,
        reset => reset
      );
  -- stage3 opcode --> 9 downto 6
  STAGE3_DF_SIGNALS(9 downto 6) <= P2_OUT(31 downto 28);
  -- stage3 regA1 --> 5 downto 3
  STAGE3_DF_SIGNALS(5 downto 3) <= P2_OUT(5 downto 3);
  -- stage3 regA2 --> 2 downto 0
  STAGE3_DF_SIGNALS(2 downto 0) <= P2_OUT(2 downto 0);

  -- stage4 opcode --> 9 downto 6
  STAGE4_DF_SIGNALS(9 downto 6) <= P3_OUT(31 downto 28);
  -- stage4 regA1 --> 5 downto 3
  STAGE4_DF_SIGNALS(5 downto 3) <= P3_OUT(5 downto 3);
  -- stage4 regA2 --> 2 downto 0
  STAGE4_DF_SIGNALS(2 downto 0) <= P3_OUT(2 downto 0);

  -- stage5 reg_write --> 8
  STAGE5_DF_SIGNALS(8) <= P4_OUT(8);
  -- stage5 r7_write --> 7
  STAGE5_DF_SIGNALS(7) <= P4_OUT(14);
  -- stage5 opcode --> 6 downto 3
  STAGE5_DF_SIGNALS(6 downto 3) <= P4_OUT(31 downto 28);
  -- stage5 writeA3 --> 2 downto 0
  STAGE5_DF_SIGNALS(2 downto 0) <= P4_OUT(13 downto 11);

  -- stage5 r7_data --> 31 downto 16
  STAGE5_DF_DATA(31 downto 16) <= P4_DATA_OUT(31 downto 16);
  -- stage5 regdata_in --> 15 downto 0
  STAGE5_DF_DATA(15 downto 0) <= P4_DATA_OUT(15 downto 0);

  -- stage6 reg_write --> 4
  STAGE6_DF_SIGNALS(4) <= P5_OUT(8);
  -- stage6 r7_write --> 3
  STAGE6_DF_SIGNALS(3) <= P5_OUT(14);
  -- stage6 writeA3 --> 2 downto 0
  STAGE6_DF_SIGNALS(2 downto 0) <= P5_OUT(13 downto 11);

  -- stage6 r7_data --> 31 downto 16
  STAGE6_DF_DATA(31 downto 16) <= P5_DATA_OUT(47 downto 32);
  -- stage6 regdata_in --> 15 downto 0
  STAGE6_DF_DATA(15 downto 0) <= REGDATA_IN(15 downto 0);

DF: DataForwarding
    port map (
      stage3_signals => STAGE3_DF_SIGNALS,
      stage4_signals => STAGE4_DF_SIGNALS,
      stage5_signals => STAGE5_DF_SIGNALS,
      stage5_data => STAGE5_DF_DATA,
      stage6_signals => STAGE6_DF_SIGNALS,
      stage6_data => STAGE6_DF_DATA,
    -- Load Distress Signal
      load5_read4 => load5_read4,
    -- Forward to Stage 3
      forward3_regA1 => forward3_regA1,
      forward3_regA2 => forward3_regA2,
      forward3_dataA1 => FORWARD3_DATA1,
      forward3_dataA2 => FORWARD3_DATA2,
    -- Forward to Stage 4
      forward4_regA1 => forward4_regA1,
      forward4_regA2 => forward4_regA2,
      forward4_dataA1 => FORWARD4_DATA1,
      forward4_dataA2 => FORWARD4_DATA2,
    -- Reset Signal
      reset => reset
  );

JE: JumpExecuteStage
    port map (
      op_code => P3_OUT(31 downto 28),
      carry_logic => P3_OUT(35 downto 34),
      cache_data => P3_JUMP_DATA(21 downto 0),
      cache_prediction => P3_DATA_OUT(47 downto 32),
      alu_output => ALU_OUT,
      flag_condition => FINAL_FLAG_CONDITION,
      reset => reset,
      jump => jump_stage4,
      jump_address => JUMP_STAGE4_ADDR,
      cache_values => P4_CACHE_VALUES
    );

  Kill: KillInstruction
      port map (
        Decode_in => P3_OUT,
        Decode_out => P4_KILL
        );
  Kill2: KillStallInstruction
      port map (
        Decode_in => P3_OUT,
        Decode_out => P4_KILL_STALL
        );

  FINAL_CARRY(0) <= carry_forward_val when carry_forward = '1' else CARRY(0);
  FINAL_ZERO(0) <= zero_forward_val when zero_forward = '1' else ZERO(0);
  FINAL_FLAG_CONDITION(0) <= FINAL_CARRY(0);
  FINAL_FLAG_CONDITION(1) <= FINAL_ZERO(0);

  P4_IN <= P4_KILL when P3_OUT(34) = '1' and FINAL_CARRY(0) = '0' else
           P4_KILL when P3_OUT(35) = '1' and FINAL_ZERO(0) = '0' else
           P4_KILL_STALL when load5_read4 = '1' or kill_stage4 = '1' else
           P3_OUT;
  P4_DATA_IN(47 downto 32) <= P3_DATA_OUT(63 downto 48) when forward4_regA2 = '0' else FORWARD4_DATA2;
  P4_DATA_IN(31 downto 16) <= P3_DATA_OUT(47 downto 32);
  P4_DATA_IN(15 downto 0) <= ALU_OUT;
  P4_FLAG_IN(1) <= ALU_carry;
  P4_FLAG_IN(0) <= ALU_zero;
  P4_JUMP_DATA_IN <= P3_JUMP_DATA;
  P4_CACHE_DATA_IN <= P4_CACHE_VALUES when P3_JUMP_DATA(21 downto 19) = "100" else
                      (others => '0') when load5_read4 = '1' or kill_stage4 = '1' else
                      P3_CACHE_DATA;
----------------------------------------------------
  P4: DataRegister
      generic map (data_width => DecodeSize)
      port map (
        Din => P4_IN,
        Dout => P4_OUT,
        Enable => p4_enable,
        clk => clk,
        reset => reset
      );
  P4_data: DataRegister
      generic map(data_width => 48)
      port map (
        Din => P4_DATA_IN,
        Dout => P4_DATA_OUT,
        Enable => p4_enable,
        clk => clk,
        reset => reset
      );
  P4_flag: DataRegister
      generic map(data_width => 2)
      port map (
        Din => P4_FLAG_IN,
        Dout => P4_FLAG_OUT,
        Enable => p4_enable,
        clk => clk,
        reset => reset
      );
  P4_jump: DataRegister
      generic map(data_width => 22)
      port map (
        Din => P4_JUMP_DATA_IN,
        Dout => P4_JUMP_DATA,
        Enable => p4_enable,
        clk => clk,
        reset => reset
      );
  P4_cache: DataRegister
      generic map(data_width => 18)
      port map (
        Din => P4_CACHE_DATA_IN,
        Dout => P4_CACHE_DATA,
        Enable => p4_enable,
        clk => clk,
        reset => reset
      );

---------------------------------------------------
---------STAGE 5 - MEMORY STAGE--------------------
  ADDRESS_IN <= P4_DATA_OUT(15 downto 0);
  MEMDATA_IN <= P4_DATA_OUT(47 downto 32);
  ME: Memory
      port map (
        clk => clk,
        mem_write => P4_OUT(7),
        addr => LSHIFT_ADDRESS_IN,
        data => MEMDATA_IN,
        mem_out => MEM_OUT
      );
  LS2: LeftShift
      port map (
        input   => ADDRESS_IN,
        output => LSHIFT_ADDRESS_IN
      );
  mem_load_zero <= '1' when MEM_OUT = "0000000000000000" else '0';

  P5_IN <= P4_OUT;
  P5_DATA_IN(47 downto 32) <= P4_DATA_OUT(31 downto 16);
  P5_DATA_IN(31 downto 16) <= MEM_OUT;
  P5_DATA_IN(15 downto 0) <= P4_DATA_OUT(15 downto 0);
  P5_FLAG_IN(1) <= P4_FLAG_OUT(1);
  P5_FLAG_IN(0) <= mem_load_zero when P4_OUT(31 downto 28) = "0100" else P4_FLAG_OUT(0);
  P5_CACHE_DATA_IN <= P4_CACHE_DATA;
  P5_JUMP_DATA_IN <= P4_JUMP_DATA;
---------------------------------------------------
  P5: DataRegister
      generic map (data_width => DecodeSize)
      port map (
        Din => P5_IN,
        Dout => P5_OUT,
        Enable => p5_enable,
        clk => clk,
        reset => reset
      );
  P5_data: DataRegister
      generic map(data_width => 48)
      port map (
        Din => P5_DATA_IN,
        Dout => P5_DATA_OUT,
        Enable => p5_enable,
        clk => clk,
        reset => reset
      );
  P5_flag: DataRegister
      generic map(data_width => 2)
      port map (
        Din => P5_FLAG_IN,
        Dout => P5_FLAG_OUT,
        Enable => p5_enable,
        clk => clk,
        reset => reset
      );
  P5_jump: DataRegister
      generic map(data_width => 22)
      port map (
        Din => P5_JUMP_DATA_IN,
        Dout => P5_JUMP_DATA,
        Enable => p5_enable,
        clk => clk,
        reset => reset
      );
  P5_cache: DataRegister
      generic map(data_width => 18)
      port map (
        Din => P5_CACHE_DATA_IN,
        Dout => P5_CACHE_DATA,
        Enable => p5_enable,
        clk => clk,
        reset => reset
      );


---------------------------------------------------
---------STAGE 6 - WRITE STAGE---------------------
-- Refer to Register File defined in stage 3
  R7_IN <= P5_DATA_OUT(47 downto 32);
  R7_WRITE <= '1' when P5_OUT(14) = '1' else '0';
  REGDATA_IN <= P5_DATA_OUT(15 downto 0) when P5_OUT(33 downto 32) = "00" else
                P5_DATA_OUT(31 downto 16);
  reg_write <= P5_OUT(8);
  WRITE3 <= P5_OUT(13 downto 11);

  CARRY_IN <= P5_FLAG_OUT(1 downto 1);
  ZERO_IN <= P5_FLAG_OUT(0 downto 0);

  CACHE_WRITE_PC <= P5_JUMP_DATA(15 downto 0);
  CACHE_WRITE_ADDR <= P5_CACHE_DATA(15 downto 0);
  cache_write <= P5_CACHE_DATA(17);
  cache_write_history <= P5_CACHE_DATA(16);

  CR: DataRegister
      generic map (data_width => 1)
      port map (
        Din => CARRY_IN,
        Dout => CARRY,
        Enable => P5_OUT(9),
        clk => clk,
        reset => reset
      );
  ZR: DataRegister
      generic map (data_width => 1)
      port map (
        Din => ZERO_IN,
        Dout => ZERO,
        Enable => P5_OUT(10),
        clk => clk,
        reset => reset
      );


end Mixed;