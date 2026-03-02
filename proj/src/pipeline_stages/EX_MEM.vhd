-------------------------------------------------------------------------
-- David Rice
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- EX_MEM_stage.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a EX_MEM_stage and the write back to register file in the WB stage
-- implementation.

-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity EX_MEM_stage is
    generic (N : integer := DATA_WIDTH);
    port (
        i_CLK : in std_logic;
        i_RST : in std_logic;
        --control signals
        i_result_src : in std_logic_vector(1 downto 0);
        i_mem_write : in std_logic;
        i_reg_write : in std_logic;
        i_mem_slice : in std_logic_vector(2 downto 0);
        i_halt : in std_logic;

        i_flush_n : in std_logic;
        o_result_src : out std_logic_vector(1 downto 0);
        o_reg_write : out std_logic;
        o_mem_write : out std_logic;
        o_mem_slice : out std_logic_vector(2 downto 0);
        o_halt : out std_logic;
        --this will eventually circle around to the register
        i_rd : in std_logic_vector(4 downto 0);

        --operands for ex stage
        i_adder_res : in std_logic_vector(31 downto 0);
        i_ALU_res : in std_logic_vector(31 downto 0);
        i_rs2 : in std_logic_vector(31 downto 0);
        --this will eventually circle around to the register

        --this will eventually circle around to the register
        o_rd : out std_logic_vector(4 downto 0);

        --operands for ex stage
        o_adder_res : out std_logic_vector(31 downto 0);
        o_ALU_res : out std_logic_vector(31 downto 0);
        o_rs2 : out std_logic_vector(31 downto 0);
        --this will eventually circle around to the register

        i_PC_imm : in std_logic_vector(31 downto 0);
        o_PC_imm : out std_logic_vector(31 downto 0);

        i_PC_4 : in std_logic_vector(31 downto 0);
        o_PC_4 : out std_logic_vector(31 downto 0)

    );
end EX_MEM_stage;
architecture structure of EX_MEM_stage is

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
begin
    result_src_reg : reg_n
    generic map(
        N => 2
    )
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_result_src,
        i_WE => i_flush_n,
        o_Q => o_result_src
    );

    mem_write_reg : dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_mem_write,
        i_WE => i_flush_n,
        o_Q => o_mem_write
    );

    reg_write_reg : dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_reg_write,
        i_WE => i_flush_n,
        o_Q => o_reg_write
    );
    mem_slice_reg : reg_n
    generic map(
        N => 3
    )
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_mem_slice,
        i_WE => i_flush_n,
        o_Q => o_mem_slice
    );
    halt_reg : dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
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
        i_RST => i_RST,
        i_D => i_rd,
        i_WE => i_flush_n,
        o_Q => o_rd
    );
    rs2_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_rs2,
        i_WE => i_flush_n,
        o_Q => o_rs2
    );

    ALU_res_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_ALU_res,
        i_WE => i_flush_n,
        o_Q => o_ALU_res
    );

    adder_res_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_adder_res,
        i_WE => i_flush_n,
        o_Q => o_adder_res
    );

    PC_4_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_PC_4,
        i_WE => i_flush_n,
        o_Q => o_PC_4
    );

    PC_imm_reg : reg_n
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_D => i_PC_imm,
        i_WE => i_flush_n,
        o_Q => o_PC_imm
    );

end structure;