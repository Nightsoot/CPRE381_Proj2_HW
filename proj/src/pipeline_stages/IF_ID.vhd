-------------------------------------------------------------------------
-- David Rice
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- IF_ID_stage.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a IF_ID_stage and the write back to register file in the WB stage
-- implementation.

-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity IF_ID_stage is
  generic (N : integer := DATA_WIDTH);
  port (
    i_CLK : in std_logic;
    i_RST : in std_logic;
    i_instruction : in std_logic_vector(31 downto 0);

    i_flush_n : in std_logic;
    i_PC : in std_logic_vector(31 downto 0);
    o_PC : out std_logic_vector(31 downto 0);
    i_PC_4 : in std_logic_vector(31 downto 0);

    --control signals
    o_instruction : out std_logic_vector(31 downto 0);
    o_PC_4 : out std_logic_vector(31 downto 0)

  );
end IF_ID_stage;
architecture structure of IF_ID_stage is

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

  --result of IF buffered
  inst_reg : reg_n
  port map(
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_WE => i_flush_n,
    i_D => i_instruction,
    o_Q => o_instruction
  );

  PC_reg : reg_n
  port map(
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_D => i_PC,
    i_WE => i_flush_n,
    o_Q => o_PC
  );

  PC_4_reg : reg_n
  port map(
    i_CLK => i_CLK,
    i_RST => i_RST,
    i_D => i_PC_4,
    i_WE => i_flush_n,
    o_Q => o_PC_4
  );

end structure;