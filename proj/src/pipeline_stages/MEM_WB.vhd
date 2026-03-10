-------------------------------------------------------------------------
-- David Rice
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- MEM_WB_stage.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MEM_WB_stage and the write back to register file in the WB stage
-- implementation.

-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity MEM_WB_stage is
    generic (N : integer := DATA_WIDTH);
    port (
        i_CLK : in std_logic;
        i_RST : in std_logic;
        --control signals
        i_result_src : in std_logic_vector(1 downto 0);
        i_reg_write : in std_logic;
        i_halt : in std_logic;

        i_flush_n : in std_logic;

        i_PC_imm : in std_logic_vector(31 downto 0);
        o_PC_imm : out std_logic_vector(31 downto 0);

    
        o_result_src : out std_logic_vector(1 downto 0);
        o_reg_write : out std_logic;
        o_halt : out std_logic;
        --this will eventually circle around to the register
        i_rd : in std_logic_vector(4 downto 0);

        --operands for wb stage
        i_mem_res : in std_logic_vector(31 downto 0);
        i_ALU_res : in std_logic_vector(31 downto 0);
        i_PC_4 : in std_logic_vector(31 downto 0);
        --this will eventually circle around to the register

        --this will eventually circle around to the register
        o_rd : out std_logic_vector(4 downto 0);

        --operands for wb stage
        o_mem_res : out std_logic_vector(31 downto 0);
        o_ALU_res : out std_logic_vector(31 downto 0);
        o_PC_4 : out std_logic_vector(31 downto 0)
        --this will eventually circle around to the register


    );
end MEM_WB_stage;
architecture structure of MEM_WB_stage is



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

    signal s_RST : std_logic;
begin

    s_RST  <= '1' when(
        i_RST = '1' or
        i_flush_n = '0'
        )
        else
        '0';
    

    result_src_reg : reg_n
    generic map(
        N => 2
    )
    port map(
        i_CLK => i_CLK,
        i_RST => s_RST,
        i_D => i_result_src,
        i_WE => i_flush_n,
        o_Q => o_result_src
    );

    reg_write_reg : dffg
    port map(
        i_CLK => i_CLK,
        i_RST => s_RST,
        i_D => i_reg_write,
        i_WE => i_flush_n,
        o_Q => o_reg_write
    );

    halt_reg : dffg
    port map(
        i_CLK => i_CLK,
        i_RST => s_RST,
        i_D => i_halt,
        i_WE => i_flush_n,
        o_Q => o_halt
    );

    rd_reg : reg_n
    generic map(
        N => 5
    )
    port map(
        i_CLK => i_CLK,
        i_RST => s_RST,
        i_D => i_rd,
        i_WE => i_flush_n,
        o_Q => o_rd
    );


    ALU_res_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => s_RST,
        i_D => i_ALU_res,
        i_WE => i_flush_n,
        o_Q => o_ALU_res
    );

    MEM_WB_res_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => s_RST,
        i_D => i_mem_res,
        i_WE => i_flush_n,
        o_Q => o_mem_res
    );

    PC_4_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => s_RST,
        i_D => i_PC_4,
        i_WE => i_flush_n,
        o_Q => o_PC_4
    );

    PC_imm_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => s_RST,
        i_D => i_PC_imm,
        i_WE => i_flush_n,
        o_Q => o_PC_imm
    );

    
end structure;