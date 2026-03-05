-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic (N : integer := DATA_WIDTH);
  port (
    iCLK : in std_logic;
    iRST : in std_logic;
    iInstLd : in std_logic;
    iInstAddr : in std_logic_vector(N - 1 downto 0);
    iInstExt : in std_logic_vector(N - 1 downto 0);
    oALUOut : out std_logic_vector(N - 1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end RISCV_Processor;
architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr : std_logic_vector(N - 1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData : std_logic_vector(N - 1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut : std_logic_vector(N - 1 downto 0); -- TODO: use this signal as the data memory output

  -- Required register file signals 
  signal s_RegWr : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData : std_logic_vector(N - 1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr : std_logic_vector(N - 1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_PC : std_logic_vector(N - 1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst : std_logic_vector(N - 1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt : std_logic; -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011)
  signal s_Inst_IF : std_logic_vector(31 downto 0);
  signal s_PC_4_IF : std_logic_vector(31 downto 0);
  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl : std_logic; -- TODO: this signal indicates an overflow exception would have been initiated
  signal s_PC_4_ID : std_logic_vector(31 downto 0);
  -- Define the signals between stages
  -- IF_ID Stage signals

  -- ID_Stage signals
  signal s_ALU_src_ID : std_logic;
  signal s_ALU_control_ID : std_logic_vector(3 downto 0);
  signal s_imm_type_ID : std_logic_vector(2 downto 0);
  signal s_result_src_ID : std_logic_vector(1 downto 0);
  signal s_reg_read_ID : std_logic;
  signal s_PC_source_ID : std_logic_vector(1 downto 0);
  signal s_mem_slice_ID : std_logic_vector(2 downto 0);
  signal s_comparison_ID : std_logic_vector(2 downto 0);
  signal s_halt_ID : std_logic;
  signal s_imm32_ID : std_logic_vector(31 downto 0);
  signal s_rs1_ID : std_logic_vector(31 downto 0);
  signal s_rs2_ID : std_logic_vector(31 downto 0);
  signal s_rd_ID : std_logic_vector(4 downto 0);

  signal s_PC_ID : std_logic_vector(31 downto 0);
  signal s_PC_EX : std_logic_vector(31 downto 0);

  signal s_mem_write_ID : std_logic;
  signal s_reg_write_ID : std_logic;

  -- Control signals
  signal s_ALU_src_EX : std_logic;
  signal s_ALU_control_EX : std_logic_vector(3 downto 0);
  signal s_result_src_EX : std_logic_vector(1 downto 0);
  signal s_mem_write_EX : std_logic;
  signal s_reg_write_EX : std_logic;
  signal s_reg_read_EX : std_logic;
  signal s_PC_source_EX : std_logic_vector(1 downto 0);
  signal s_mem_slice_EX : std_logic_vector(2 downto 0);
  signal s_comparison_EX : std_logic_vector(2 downto 0);
  signal s_halt_EX : std_logic;

  -- Data signals
  signal s_rd_EX : std_logic_vector(4 downto 0);
  signal s_rs1_EX : std_logic_vector(31 downto 0);
  signal s_rs2_EX : std_logic_vector(31 downto 0);
  signal s_imm32_EX : std_logic_vector(31 downto 0);
  signal s_PC_4_EX : std_logic_vector(31 downto 0);
  signal s_PC_imm_EX : std_logic_vector(31 downto 0);

  signal s_adder_res_EX : std_logic_vector(31 downto 0);
  signal s_ALU_res_EX : std_logic_vector(31 downto 0);

  -- Control signals
  signal s_result_src_MEM : std_logic_vector(1 downto 0);
  signal s_reg_write_MEM : std_logic;
  signal s_mem_write_MEM : std_logic;
  signal s_mem_slice_MEM : std_logic_vector(2 downto 0);
  signal s_halt_MEM : std_logic;

  -- Data signals
  signal s_rd_MEM : std_logic_vector(4 downto 0);
  signal s_adder_res_MEM : std_logic_vector(31 downto 0);
  signal s_ALU_res_MEM : std_logic_vector(31 downto 0);
  signal s_rs2_MEM : std_logic_vector(31 downto 0);
  signal s_PC_4_MEM : std_logic_vector(31 downto 0);
  signal s_mem_res_MEM : std_logic_vector(31 downto 0);
  signal s_PC_imm_MEM : std_logic_vector(31 downto 0);

  -- Control signals
  signal s_result_src_WB : std_logic_vector(1 downto 0);
  signal s_reg_write_WB : std_logic;
  signal s_halt_WB : std_logic;

  -- Data signals
  signal s_rd_WB : std_logic_vector(4 downto 0);
  signal s_mem_res_WB : std_logic_vector(31 downto 0);
  signal s_ALU_res_WB : std_logic_vector(31 downto 0);
  signal s_PC_4_WB : std_logic_vector(31 downto 0);
  signal s_PC_imm_WB : std_logic_vector(31 downto 0);
  signal s_update_ID_EX, s_flush_IF_ID_n : std_logic;
  signal s_PC_update : std_logic;
  signal s_update_IF_ID : std_logic;

  signal s_flush_n : std_logic;

  signal s_mem_write_ID_haz, s_reg_write_ID_haz : std_logic;
  signal s_rs1_addr_EX, s_rs2_addr_EX, s_rs2_addr_MEM : std_logic_vector(4 downto 0);

  signal s_rs1_ID_true, s_rs2_ID_true, s_rs1_EX_true, s_rs2_EX_true, s_rs2_MEM_true : std_logic_vector(31 downto 0);
  signal s_rs1_forwarded_ID, s_rs2_forwarded_ID, s_rs1_forwarded_EX, s_rs2_forwarded_EX, s_rs2_forwarded_MEM : std_logic_vector(31 downto 0);
  signal s_forward_rs1_ID, s_forward_rs1_EX, s_forward_rs2_MEM, s_forward_rs2_EX, s_forward_rs2_ID : std_logic;
  component mem is
    generic (
      ADDR_WIDTH : integer;
      DATA_WIDTH : integer);
    port (
      clk : in std_logic;
      addr : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
      data : in std_logic_vector((DATA_WIDTH - 1) downto 0);
      we : in std_logic := '1';
      q : out std_logic_vector((DATA_WIDTH - 1) downto 0));
  end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment
  component alu is
    port (
      i_opperand1 : in std_logic_vector(31 downto 0);
      i_opperand2 : in std_logic_vector(31 downto 0);
      i_ALU_op : in std_logic_vector(3 downto 0);
      o_F : out std_logic_vector(31 downto 0);
      o_C : out std_logic;
      o_N : out std_logic;
      o_V : out std_logic;
      o_Z : out std_logic;
      o_adder_res : out std_logic_vector(31 downto 0)
    );
  end component;

  component control_decoder is

    port (
      i_instruction : in std_logic_vector(31 downto 0);
      o_ALU_src : out std_logic;
      o_ALU_control : out std_logic_vector(3 downto 0);
      o_imm_type : out std_logic_vector(2 downto 0);
      o_result_src : out std_logic_vector(1 downto 0);
      o_mem_write : out std_logic;
      o_reg_write : out std_logic;
      o_reg_read : out std_logic;
      o_PC_source : out std_logic_vector(1 downto 0);
      o_mem_slice : out std_logic_vector(2 downto 0);
      o_comparison : out std_logic_vector(2 downto 0);
      o_halt : out std_logic
    );
  end component;

  component imm_gen is

    port (
      i_instruction : in std_logic_vector(31 downto 0);
      --0 12 bit unsigned (I)
      --1 12 bit signed (I)
      --2 20 bit upper immediate (U)
      --3 12 bit padded (SB)
      --4 20 bit padded (UJ)
      --5 12 bit signed memory (I)
      --6 12 bit signed store  (S)
      i_imm_type : in std_logic_vector(2 downto 0);
      o_imm32 : out std_logic_vector(31 downto 0)
    );

  end component;

  component fetch_logic is

    port (
      i_CLK : in std_logic;
      i_RST : in std_logic;
      --"old" PC value
      i_PC : in std_logic_vector(31 downto 0);
      i_PC_EX : in std_logic_vector(31 downto 0);
      i_imm : in std_logic_vector(31 downto 0);
      --used for register relative addressing
      i_ALU_result : in std_logic_vector(31 downto 0);
      --control signals
      i_PC_source : in std_logic_vector(1 downto 0);
      i_comparison : in std_logic_vector(2 downto 0);
      --comaprison flags
      i_zero : in std_logic;
      i_negative : in std_logic;
      i_carry : in std_logic;
      i_overflow : in std_logic;

      i_PC_enable : in std_logic;
      --new PC used by the program memory
      o_new_PC : out std_logic_vector(31 downto 0);
      o_PC_4 : out std_logic_vector(31 downto 0);
      o_PC_imm : out std_logic_vector(31 downto 0)
    );
  end component;

  component reg_file is

    port (
      i_CLK : in std_logic; -- Clock input
      i_RST : in std_logic; -- Reset input
      i_read_reg1 : in std_logic_vector(4 downto 0);
      i_read_reg2 : in std_logic_vector(4 downto 0);
      i_write_reg : in std_logic_vector(4 downto 0);
      i_write_value : in std_logic_vector(31 downto 0);
      i_read_write : in std_logic;
      o_read_value1 : out std_logic_vector(31 downto 0);
      o_read_value2 : out std_logic_vector(31 downto 0));

  end component;

  component mem_slice is

    port (
      i_data : in std_logic_vector(31 downto 0);
      i_add_2LSB : in std_logic_vector(1 downto 0);
      --0: FULL WORD
      --1: BYTE SIGNED
      --2: HALFWORD SIGNED
      --3: BYTE UNSIGNED
      --4: HALFWORD UNSIGNED
      i_slice_type : in std_logic_vector(2 downto 0);
      o_data : out std_logic_vector(31 downto 0)
    );

  end component;
  component hazard_detector is

    port (
      i_rs1_ID : in std_logic_vector(4 downto 0);
      i_rs2_ID : in std_logic_vector(4 downto 0);
      i_rd_EX : in std_logic_vector(4 downto 0);
      i_reg_write_EX : in std_logic;
      i_rd_MEM : in std_logic_vector(4 downto 0);
      i_reg_write_MEM : in std_logic;
      o_PC_update : out std_logic;
      o_update_ID_EX : out std_logic;
      o_flush_IF_ID_n : out std_logic;
      o_update_IF_ID : out std_logic;
      --this is at the EX stage
      i_inst_forward_type : in std_logic_vector(1 downto 0);
      i_ID_mem_write : in std_logic
    );

  end component;

  component data_forwarder is

    port (
      i_rs1_addr_ID : in std_logic_vector(4 downto 0);
      i_rs2_addr_ID : in std_logic_vector(4 downto 0);
      i_rs1_addr_EX : in std_logic_vector(4 downto 0);
      i_rs2_addr_EX : in std_logic_vector(4 downto 0);
      i_rs2_addr_MEM : in std_logic_vector(4 downto 0);
      i_rd_EX : in std_logic_vector(4 downto 0);
      i_rd_MEM : in std_logic_vector(4 downto 0);
      i_rd_WB : in std_logic_vector(4 downto 0);
      i_reg_write_EX : in std_logic;
      i_reg_write_MEM : in std_logic;
      i_reg_write_WB : in std_logic;
      i_inst_type_EX : in std_logic_vector(1 downto 0);
      i_inst_type_MEM : in std_logic_vector(1 downto 0);
      i_inst_type_WB : in std_logic_vector(1 downto 0);
      --data that could be forwarded
      i_ALU_res_EX : in std_logic_vector(31 downto 0);
      i_ALU_res_MEM : in std_logic_vector(31 downto 0);
      i_ALU_res_WB : in std_logic_vector(31 downto 0);

      i_PC_4_EX : in std_logic_vector(31 downto 0);
      i_PC_4_MEM : in std_logic_vector(31 downto 0);
      i_PC_4_WB : in std_logic_vector(31 downto 0);

      i_PC_imm_EX : in std_logic_vector(31 downto 0);
      i_PC_imm_MEM : in std_logic_vector(31 downto 0);
      i_PC_imm_WB : in std_logic_vector(31 downto 0);

      i_mem_res_MEM : in std_logic_vector(31 downto 0);
      i_mem_res_WB : in std_logic_vector(31 downto 0);

      --fowarded data (rs2 for MEM will not be forwarded)
      o_rs1_ID : out std_logic_vector(31 downto 0);
      o_forward_rs1_ID : out std_logic;
      o_rs2_ID : out std_logic_vector(31 downto 0);
      o_forward_rs2_ID : out std_logic;
      o_rs1_EX : out std_logic_vector(31 downto 0);
      o_forward_rs1_EX : out std_logic;
      o_rs2_EX : out std_logic_vector(31 downto 0);
      o_forward_rs2_EX : out std_logic;
      o_rs2_MEM : out std_logic_vector(31 downto 0);
      o_forward_rs2_MEM : out std_logic

    );
  end component;

  component IF_ID_stage is
    generic (N : integer := DATA_WIDTH);
    port (
      i_CLK : in std_logic;
      i_RST : in std_logic;
      i_instruction : in std_logic_vector(31 downto 0);
      i_flush_n : in std_logic;
      i_update : in std_logic;
      i_PC_4 : in std_logic_vector(31 downto 0);

      i_PC : in std_logic_vector(31 downto 0);
      o_PC : out std_logic_vector(31 downto 0);

      o_instruction : out std_logic_vector(31 downto 0);
      o_PC_4 : out std_logic_vector(31 downto 0)
    );
  end component;

  component ID_EX_stage is
    generic (N : integer := DATA_WIDTH);
    port (
      i_CLK : in std_logic;
      i_RST : in std_logic;

      -- Control signals
      i_ALU_src : in std_logic;
      i_ALU_control : in std_logic_vector(3 downto 0);
      i_result_src : in std_logic_vector(1 downto 0);
      i_mem_write : in std_logic;
      i_reg_write : in std_logic;
      i_reg_read : in std_logic;
      i_PC_source : in std_logic_vector(1 downto 0);
      i_mem_slice : in std_logic_vector(2 downto 0);
      i_comparison : in std_logic_vector(2 downto 0);
      i_halt : in std_logic;
      i_flush_n : in std_logic;
      i_update : in std_logic;

      -- Data signals
      i_rd : in std_logic_vector(4 downto 0);
      i_rs1 : in std_logic_vector(31 downto 0);
      i_rs2 : in std_logic_vector(31 downto 0);
      i_imm32 : in std_logic_vector(31 downto 0);

      i_rs1_addr : in std_logic_vector(4 downto 0);
      i_rs2_addr : in std_logic_vector(4 downto 0);

      i_PC : in std_logic_vector(31 downto 0);
      o_PC : out std_logic_vector(31 downto 0);
      i_PC_4 : in std_logic_vector(31 downto 0);
      o_PC_4 : out std_logic_vector(31 downto 0);

      -- Outputs
      o_ALU_src : out std_logic;
      o_ALU_control : out std_logic_vector(3 downto 0);
      o_result_src : out std_logic_vector(1 downto 0);
      o_mem_write : out std_logic;
      o_reg_write : out std_logic;
      o_reg_read : out std_logic;
      o_PC_source : out std_logic_vector(1 downto 0);
      o_mem_slice : out std_logic_vector(2 downto 0);
      o_comparison : out std_logic_vector(2 downto 0);
      o_halt : out std_logic;

      o_rs1_addr : out std_logic_vector(4 downto 0);
      o_rs2_addr : out std_logic_vector(4 downto 0);

      o_rd : out std_logic_vector(4 downto 0);
      o_rs1 : out std_logic_vector(31 downto 0);
      o_rs2 : out std_logic_vector(31 downto 0);
      o_imm32 : out std_logic_vector(31 downto 0)
    );
  end component;

  component EX_MEM_stage is
    generic (N : integer := DATA_WIDTH);
    port (
      i_CLK : in std_logic;
      i_RST : in std_logic;

      -- Control signals
      i_result_src : in std_logic_vector(1 downto 0);
      i_mem_write : in std_logic;
      i_reg_write : in std_logic;
      i_mem_slice : in std_logic_vector(2 downto 0);
      i_halt : in std_logic;
      i_flush_n : in std_logic;

      -- Data signals
      i_rd : in std_logic_vector(4 downto 0);
      i_adder_res : in std_logic_vector(31 downto 0);
      i_ALU_res : in std_logic_vector(31 downto 0);
      i_rs2 : in std_logic_vector(31 downto 0);
      i_PC_4 : in std_logic_vector(31 downto 0);

      i_rs2_addr : in std_logic_vector(4 downto 0);

      -- Outputs
      o_result_src : out std_logic_vector(1 downto 0);
      o_reg_write : out std_logic;
      o_mem_write : out std_logic;
      o_mem_slice : out std_logic_vector(2 downto 0);
      o_halt : out std_logic;
      o_rd : out std_logic_vector(4 downto 0);
      o_adder_res : out std_logic_vector(31 downto 0);
      o_ALU_res : out std_logic_vector(31 downto 0);
      o_rs2 : out std_logic_vector(31 downto 0);
      o_PC_4 : out std_logic_vector(31 downto 0);
      i_PC_imm : in std_logic_vector(31 downto 0);
      o_rs2_addr : out std_logic_vector(4 downto 0);
      o_PC_imm : out std_logic_vector(31 downto 0)
    );
  end component;

  component MEM_WB_stage is
    generic (N : integer := DATA_WIDTH);
    port (
      i_CLK : in std_logic;
      i_RST : in std_logic;

      -- Control signals
      i_result_src : in std_logic_vector(1 downto 0);
      i_reg_write : in std_logic;
      i_halt : in std_logic;
      i_flush_n : in std_logic;

      -- Data signals
      i_rd : in std_logic_vector(4 downto 0);
      i_mem_res : in std_logic_vector(31 downto 0);
      i_ALU_res : in std_logic_vector(31 downto 0);
      i_PC_4 : in std_logic_vector(31 downto 0);
      -- Outputs
      o_result_src : out std_logic_vector(1 downto 0);
      o_reg_write : out std_logic;
      o_halt : out std_logic;
      o_rd : out std_logic_vector(4 downto 0);
      o_mem_res : out std_logic_vector(31 downto 0);
      o_ALU_res : out std_logic_vector(31 downto 0);
      o_PC_4 : out std_logic_vector(31 downto 0);
      i_PC_imm : in std_logic_vector(31 downto 0);
      o_PC_imm : out std_logic_vector(31 downto 0)
    );
  end component;

  signal s_read_value1_adjusted : std_logic_vector(31 downto 0);
  signal s_ALU_operand2 : std_logic_vector(31 downto 0);

  signal s_C : std_logic;
  signal s_N : std_logic;
  signal s_V : std_logic;
  signal s_Z : std_logic;

  signal cycle : integer;
begin
  s_Ovfl <= '0';
  s_RegWrAddr <= s_rd_WB;
  s_flush_n <= '1';

  cycle_count: process (iRST, iCLK) begin
    if(iRst = '1') then
      cycle <= 0;
    elsif(iCLK'event and iClk = '1') then
      cycle <= cycle + 1;
    end if;
  end process cycle_count;

  oALUout <= s_ALU_res_WB;

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_PC when '0',
    iInstAddr when others;
  IMem : mem
  generic map(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => N)
  port map(
    clk => iCLK,
    addr => s_PC(11 downto 2),
    data => iInstExt,
    we => iInstLd,
    q => s_Inst_IF);

  DMem : mem
  generic map(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => N)
  port map(
    clk => iCLK,
    addr => s_DMemAddr(11 downto 2),
    data => s_DMemData,
    we => s_DMemWr,
    q => s_DMemOut);
  s_DMemWr <= s_mem_write_MEM;
  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 
  g_control_decoder : control_decoder
  port map(
    i_instruction => s_Inst,
    o_ALU_src => s_ALU_src_ID,
    o_ALU_control => s_ALU_control_ID,
    o_imm_type => s_imm_type_ID,
    o_result_src => s_result_src_ID,
    o_mem_write => s_mem_write_ID,
    o_reg_write => s_reg_write_ID,
    o_reg_read => s_reg_read_ID,
    o_PC_source => s_PC_source_ID,
    o_mem_slice => s_mem_slice_ID,
    o_comparison => s_comparison_ID,
    o_halt => s_Halt_ID
  );
  g_imm_gen : imm_gen
  port map(
    i_instruction => s_Inst,
    i_imm_type => s_imm_type_ID,
    o_imm32 => s_imm32_ID
  );
  g_reg_file : reg_file
  port map(
    i_CLK => iCLK,
    i_RST => iRST,
    i_read_reg1 => s_Inst(19 downto 15),
    i_read_reg2 => s_Inst(24 downto 20),
    i_write_reg => s_RegWrAddr,
    i_write_value => s_RegWrData,
    i_read_write => s_RegWr,
    o_read_value1 => s_rs1_ID_true,
    o_read_value2 => s_rs2_ID_true
  );
  s_RegWr <= s_reg_write_WB;

  --zeros out rs1 if not reading for lui
  s_read_value1_adjusted <= s_rs1_EX when (s_reg_read_EX = '1') else
    X"00000000";

  --switch between immediate and read value
  s_ALU_operand2 <= s_imm32_EX when (s_ALU_src_EX = '1') else
    s_rs2_EX;

  g_ALU : alu
  port map(
    i_opperand1 => s_read_value1_adjusted,
    i_opperand2 => s_ALU_operand2,
    i_ALU_op => s_ALU_control_EX,
    o_F => s_ALU_res_EX,
    o_C => s_C,
    o_N => s_N,
    o_V => s_V,
    o_Z => s_Z,
    o_adder_res => s_adder_res_EX
  );

  s_DMemAddr <= s_adder_res_MEM;
  s_DMemData <= s_rs2_MEM;

  g_fetch_logic : fetch_logic
  port map(
    i_CLK => iCLK,
    i_RST => iRST,
    i_PC => s_IMemAddr,
    i_PC_EX => s_PC_EX,
    i_imm => s_imm32_EX,
    i_ALU_result => s_adder_res_EX,
    i_PC_source => s_PC_source_EX,
    i_comparison => s_comparison_EX,
    i_zero => s_Z,
    i_negative => s_N,
    i_carry => s_C,
    i_overflow => s_V,
    i_PC_enable => s_PC_update,
    o_new_PC => s_PC,
    o_PC_4 => s_PC_4_IF,
    o_PC_imm => s_PC_imm_EX
  );

  g_mem_slice : mem_slice
  port map(
    i_data => s_DMemOut,
    i_add_2LSB => s_DMemAddr(1 downto 0),
    i_slice_type => s_mem_slice_MEM,
    o_data => s_mem_res_MEM
  );

  --the various different result sources
  s_RegWrData <= s_ALU_res_WB when(s_result_src_WB = "00")
    else
    s_mem_res_WB when(s_result_src_WB = "01")
    else
    s_PC_4_WB when(s_result_src_WB = "10")
    else
    s_PC_imm_WB;
  IF_ID : IF_ID_stage
  port map(
    i_CLK => iCLK,
    i_RST => iRST,
    i_instruction => s_Inst_IF,
    i_flush_n => s_flush_IF_ID_n,
    i_update => s_update_IF_ID,
    i_PC_4 => s_PC_4_IF,

    i_PC => s_PC,
    o_PC => s_PC_ID,

    o_instruction => s_Inst,
    o_PC_4 => s_PC_4_ID
  );

  s_rd_ID <= s_Inst(11 downto 7);
  g_hazard_detection : hazard_detector
  port map(
    i_rs1_ID => s_Inst(19 downto 15),
    i_rs2_ID => s_Inst(24 downto 20),
    i_rd_EX => s_rd_EX,
    i_reg_write_EX => s_reg_write_EX,
    i_rd_MEM => s_rd_MEM,
    i_reg_write_MEM => s_reg_write_MEM,
    o_PC_update => s_PC_update,
    o_update_ID_EX => s_update_ID_EX,
    o_flush_IF_ID_n => s_flush_IF_ID_n,
    o_update_IF_ID => s_update_IF_ID,
    i_inst_forward_type => s_result_src_EX,
    i_ID_mem_write => s_mem_write_ID
  );

  g_data_forward : data_forwarder
  port map(
    i_rs1_addr_ID => s_Inst(19 downto 15),
    i_rs2_addr_ID => s_Inst(24 downto 20),
    i_rs1_addr_EX => s_rs1_addr_EX,
    i_rs2_addr_EX => s_rs2_addr_EX,
    i_rs2_addr_MEM => s_rs2_addr_MEM,
    i_rd_EX => s_rd_EX,
    i_rd_MEM => s_rd_MEM,
    i_rd_WB => s_rd_WB,
    i_reg_write_EX => s_reg_write_EX,
    i_reg_write_MEM => s_reg_write_MEM,
    i_reg_write_WB => s_reg_write_WB,
    i_inst_type_EX => s_result_src_EX,
    i_inst_type_MEM => s_result_src_MEM,
    i_inst_type_WB => s_result_src_WB,

    --data that could be forwarded
    i_ALU_res_EX => s_ALU_res_EX,
    i_ALU_res_MEM => s_ALU_res_MEM,
    i_ALU_res_WB => s_ALU_res_WB,

    i_PC_4_EX => s_PC_4_EX,
    i_PC_4_MEM => s_PC_4_MEM,
    i_PC_4_WB => s_PC_4_WB,

    i_PC_imm_EX => s_PC_imm_EX,
    i_PC_imm_MEM => s_PC_imm_MEM,
    i_PC_imm_WB => s_PC_imm_WB,

    i_mem_res_MEM => s_mem_res_MEM,
    i_mem_res_WB => s_mem_res_WB,

    --fowarded data (rs2 for MEM will not be forwarded)
    o_rs1_ID => s_rs1_forwarded_ID,
    o_forward_rs1_ID => s_forward_rs1_ID,
    o_rs2_ID => s_rs2_forwarded_ID,
    o_forward_rs2_ID => s_forward_rs2_ID,
    o_rs1_EX => s_rs1_forwarded_EX,
    o_forward_rs1_EX => s_forward_rs1_EX,
    o_rs2_EX => s_rs2_forwarded_EX,
    o_forward_rs2_EX => s_forward_rs2_EX,
    o_rs2_MEM => s_rs2_forwarded_MEM,
    o_forward_rs2_MEM => s_forward_rs2_MEM
  );

  s_rs1_ID <= s_rs1_ID_true when (s_forward_rs1_ID = '0') else
    s_rs1_forwarded_ID;
  s_rs1_EX <= s_rs1_EX_true when (s_forward_rs1_EX = '0') else
    s_rs1_forwarded_EX;
  s_rs2_ID <= s_rs2_ID_true when (s_forward_rs2_ID = '0') else
    s_rs2_forwarded_ID;
  s_rs2_EX <= s_rs2_EX_true when (s_forward_rs2_EX = '0') else
    s_rs2_forwarded_EX;
  s_rs2_MEM <= s_rs2_MEM_true when (s_forward_rs2_MEM = '0') else
    s_rs2_forwarded_MEM;

  --allow the "bad" instruction to pass through so hazards clear but
  --prevent it from actually doing anything (nop)
  s_mem_write_ID_haz <= s_mem_write_ID when (s_update_ID_EX = '1') else
    '0';
  s_reg_write_ID_haz <= s_reg_write_ID when (s_update_ID_EX = '1') else
    '0';
  ID_EX : ID_EX_stage
  port map(
    i_CLK => iCLK,
    i_RST => iRST,

    -- Control signals
    i_ALU_src => s_ALU_src_ID, -- Signal from previous stage
    i_ALU_control => s_ALU_control_ID, -- Signal from previous stage
    i_result_src => s_result_src_ID, -- Signal from previous stage
    i_mem_write => s_mem_write_ID_haz, -- Signal from previous stage
    i_reg_write => s_reg_write_ID_haz, -- Signal from previous stage
    i_reg_read => s_reg_read_ID, -- Signal from previous stage
    i_PC_source => s_PC_source_ID, -- Signal from previous stage
    i_mem_slice => s_mem_slice_ID, -- Signal from previous stage
    i_comparison => s_comparison_ID, -- Signal from previous stage
    i_halt => s_halt_ID, -- Signal from previous stage
    i_flush_n => s_flush_n, -- Global flush signal
    i_update => '1',

    -- Data signals
    i_rd => s_rd_ID, -- Signal from previous stage
    i_rs1 => s_rs1_ID, -- Signal from previous stage
    i_rs2 => s_rs2_ID, -- Signal from previous stage
    i_imm32 => s_imm32_ID, -- Signal from previous stage
    i_PC_4 => s_PC_4_ID,
    o_PC_4 => s_PC_4_EX,

    i_PC => s_PC_ID,
    o_PC => s_PC_EX,

    i_rs1_addr => s_Inst(19 downto 15),
    i_rs2_addr => s_Inst(24 downto 20),

    o_rs1_addr => s_rs1_addr_EX,
    o_rs2_addr => s_rs2_addr_EX,

    -- Outputs
    o_ALU_src => s_ALU_src_EX, -- Signal for EX stage
    o_ALU_control => s_ALU_control_EX, -- Signal for EX stage
    o_result_src => s_result_src_EX, -- Signal for EX stage
    o_mem_write => s_mem_write_EX, -- Signal for EX stage
    o_reg_write => s_reg_write_EX, -- Signal for EX stage
    o_reg_read => s_reg_read_EX, -- Signal for EX stage
    o_PC_source => s_PC_source_EX, -- Signal for EX stage
    o_mem_slice => s_mem_slice_EX, -- Signal for EX stage
    o_comparison => s_comparison_EX, -- Signal for EX stage
    o_halt => s_halt_EX, -- Signal for EX stage
    o_rd => s_rd_EX, -- Signal for EX stage
    o_rs1 => s_rs1_EX_true, -- Signal for EX stage
    o_rs2 => s_rs2_EX_true, -- Signal for EX stage
    o_imm32 => s_imm32_EX -- Signal for EX stage
  );

  EX_MEM : EX_MEM_stage
  port map(
    i_CLK => iCLK,
    i_RST => iRST,

    -- Control signals
    i_result_src => s_result_src_EX, -- Signal from EX stage
    i_mem_write => s_mem_write_EX, -- Signal from EX stage
    i_reg_write => s_reg_write_EX, -- Signal from EX stage
    i_mem_slice => s_mem_slice_EX, -- Signal from EX stage
    i_halt => s_halt_EX, -- Signal from EX stage
    i_flush_n => s_flush_n, -- Global flush signal

    -- Data signals
    i_rd => s_rd_EX, -- Signal from EX stage
    i_adder_res => s_adder_res_EX, -- Signal from EX stage
    i_ALU_res => s_ALU_res_EX, -- Signal from EX stage
    i_rs2 => s_rs2_EX_true, -- Signal from EX stage
    i_PC_4 => s_PC_4_EX, -- Signal from EX stage
    i_PC_imm => s_PC_imm_EX,

    i_rs2_addr => s_rs2_addr_EX,
    o_rs2_addr => s_rs2_addr_MEM,

    -- Outputs
    o_result_src => s_result_src_MEM, -- Signal for MEM stage
    o_reg_write => s_reg_write_MEM, -- Signal for MEM stage
    o_mem_write => s_mem_write_MEM, -- Signal for MEM stage
    o_mem_slice => s_mem_slice_MEM, -- Signal for MEM stage
    o_halt => s_halt_MEM, -- Signal for MEM stage
    o_rd => s_rd_MEM, -- Signal for MEM stage
    o_adder_res => s_adder_res_MEM, -- Signal for MEM stage
    o_ALU_res => s_ALU_res_MEM, -- Signal for MEM stage
    o_rs2 => s_rs2_MEM_true, -- Signal for MEM stage
    o_PC_4 => s_PC_4_MEM, -- Signal for MEM stage
    o_PC_imm => s_PC_imm_MEM
  );

  MEM_WB : MEM_WB_stage
  port map(
    i_CLK => iCLK,
    i_RST => iRST,

    -- Control signals
    i_result_src => s_result_src_MEM, -- Signal from MEM stage
    i_reg_write => s_reg_write_MEM, -- Signal from MEM stage
    i_halt => s_halt_MEM, -- Signal from MEM stage
    i_flush_n => s_flush_n, -- Global flush signal

    -- Data signals
    i_rd => s_rd_MEM, -- Signal from MEM stage
    i_mem_res => s_mem_res_MEM, -- Signal from MEM stage
    i_ALU_res => s_ALU_res_MEM, -- Signal from MEM stage
    i_PC_4 => s_PC_4_MEM, -- Signal from MEM stage
    i_PC_imm => s_PC_imm_MEM,

    -- Outputs
    o_result_src => s_result_src_WB, -- Signal for WB stage
    o_reg_write => s_reg_write_WB, -- Signal for WB stage
    o_halt => s_halt_WB, -- Signal for WB stage
    o_rd => s_rd_WB, -- Signal for WB stage
    o_mem_res => s_mem_res_WB, -- Signal for WB stage
    o_ALU_res => s_ALU_res_WB, -- Signal for WB stage
    o_PC_4 => s_PC_4_WB, -- Signal for WB stage
    o_PC_imm => s_PC_imm_WB

  );

  s_Halt <= s_halt_WB;

end structure;