-------------------------------------------------------------------------
-- David Rice
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ID_EX_stage.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a ID_EX_stage and the write back to register file in the WB stage
-- implementation.

-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity ID_EX_stage is
    generic (N : integer := DATA_WIDTH);
    port (
        i_CLK : in std_logic;
        i_RST : in std_logic;
        --control signals
        i_ALU_src :  in std_logic;
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

        --control signals for later (or to be sent directly to fetch logic)
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

        --this will eventually circle around to the register
        i_rs1_addr : in std_logic_vector(4 downto 0);
        i_rs2_addr : in std_logic_vector(4 downto 0);
        i_rd : in std_logic_vector(4 downto 0);

        --operands for ex stage
        i_rs1 : in std_logic_vector(31 downto 0);
        i_rs2 : in std_logic_vector(31 downto 0);
        i_imm32 : in std_logic_vector(31 downto 0);

        --this will eventually circle around to the register
        o_rd : out std_logic_vector(4 downto 0);

        --operands for ex stage
        o_rs1 : out std_logic_vector(31 downto 0);
        o_rs2 : out std_logic_vector(31 downto 0);
        o_imm32 : out std_logic_vector(31 downto 0);

        o_rs1_addr : out std_logic_vector(4 downto 0);
        o_rs2_addr : out std_logic_vector(4 downto 0);

        i_PC_4 : in std_logic_vector(31 downto 0);
        o_PC_4 : out std_logic_vector(31 downto 0);
        i_PC : in std_logic_vector(31 downto 0);
        o_PC : out std_logic_vector(31 downto 0)
    );
end ID_EX_stage;
architecture structure of ID_EX_stage is

    component reg_n is

        generic (
            N : integer := 32;
            RST_VALUE : std_logic_vector(31 downto 0) := X"00000000";
            CLOCK_CONFIG : std_logic := '1');
        port (
            i_CLK : in std_logic; -- Clock input
            i_RST : in std_logic; -- Reset input
            i_WE : in std_logic; -- Write enable input
            i_D : in std_logic_vector(N - 1 downto 0); -- Data vector input
            o_Q : out std_logic_vector(N - 1 downto 0)); -- Data vector output

    end component;

    component dffg is

        port (
            i_CLK : in std_logic; -- Clock input
            i_RST : in std_logic; -- Reset input
            i_WE : in std_logic; -- Write enable input
            i_D : in std_logic; -- Data value input
            o_Q : out std_logic); -- Data value output

    end component;

    signal s_ALU_src : std_logic;
    signal s_ALU_control : std_logic_vector(3 downto 0);
    signal s_result_src : std_logic_vector(1 downto 0);
    signal s_mem_write : std_logic;
    signal s_reg_write : std_logic;
    signal s_reg_read : std_logic;
    signal s_PC_source : std_logic_vector(1 downto 0);
    signal s_mem_slice : std_logic_vector(2 downto 0);
    signal s_comparison : std_logic_vector(2 downto 0);
    signal s_halt : std_logic;

begin

    s_ALU_src <= i_ALU_src when i_flush_n = '1' else '0';
    s_ALU_control <= i_ALU_control when i_flush_n = '1' else (others => '0');
    s_result_src <= i_result_src when i_flush_n = '1' else (others => '0');
    s_mem_write <= i_mem_write when i_flush_n = '1' else '0';
    s_reg_write <= i_reg_write when i_flush_n = '1' else '0';
    s_reg_read <= i_reg_read when i_flush_n = '1' else '0';
    s_PC_source <= i_PC_source when i_flush_n = '1' else (others => '0');
    s_mem_slice <= i_mem_slice when i_flush_n = '1' else (others => '0');
    s_comparison <= i_comparison when i_flush_n = '1' else (others => '0');
    s_halt <= i_halt when i_flush_n = '1' else '0';

    
    ALU_src_reg : dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => s_ALU_src,
        i_WE => i_update,
        o_Q => o_ALU_src
    );

    ALU_control_reg : reg_n
    generic map(
        N => 4
    )
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => s_ALU_control,
        i_WE => i_update,
        o_Q => o_ALU_control
    );

    result_src_reg : reg_n
    generic map(
        N => 2
    )
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => s_result_src,
        i_WE => i_update,
        o_Q => o_result_src
    );

    mem_write_reg : dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => s_mem_write,
        i_WE => i_update,
        o_Q => o_mem_write
    );

    reg_write_reg : dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => s_reg_write,
        i_WE => i_update,
        o_Q => o_reg_write
    );

    reg_read_reg : dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => s_reg_read,
        i_WE => i_update,
        o_Q => o_reg_read
    );
    PC_src_reg : reg_n
    generic map(
        N => 2
    )
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => s_PC_source,
        i_WE => i_update,
        o_Q => o_PC_source
    );

    mem_slice_reg : reg_n
    generic map(
        N => 3
    )
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => s_mem_slice,
        i_WE => i_update,
        o_Q => o_mem_slice
    );

    comaprison_reg : reg_n
    generic map(
        N => 3
    )
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => s_comparison,
        i_WE => i_update,
        o_Q => o_comparison
    );

    halt_reg : dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => s_halt,
        i_WE => i_update,
        o_Q => o_halt
    );
    rd_reg : reg_n
    generic map(
        N => 5
    )
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_rd,
        i_WE => i_update,
        o_Q => o_rd
    );

    rs1_addr_reg : reg_n
    generic map(
        N => 5
    )
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_rs1_addr,
        i_WE => i_update,
        o_Q => o_rs1_addr
    );


    rs2_addr_reg : reg_n
    generic map(
        N => 5
    )
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_rs2_addr,
        i_WE => i_update,
        o_Q => o_rs2_addr
    );


    rs1_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_rs1,
        i_WE => i_update,
        o_Q => o_rs1
    );

    rs2_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_rs2,
        i_WE => i_update,
        o_Q => o_rs2
    );

    imm32_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_imm32,
        i_WE => i_update,
        o_Q => o_imm32
    );

    PC_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_PC,
        i_WE => i_update,
        o_Q => o_PC
    );

    PC_4_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_PC_4,
        i_WE => i_update,
        o_Q => o_PC_4
    );
end structure;