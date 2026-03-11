-------------------------------------------------------------------------
-- David Rice
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- hazard_detector.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a hazard detection unit which outputs the PC update, register update, and flushing
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity hazard_detector is

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

end hazard_detector;
architecture dataflow of hazard_detector is

    signal s_data_hazard_r1, s_data_hazard_r2, s_data_hazard : std_logic;
begin
    --waiting would require MEM->EX, but in the case of sw we can wait even longer til WB -> MEM
    s_data_hazard_r2 <= '1' when(
        (i_rd_EX /= "00000" and i_reg_write_EX = '1' and i_rd_EX = i_rs2_ID and i_inst_forward_type = "01" and i_ID_mem_write = '0')
        ) else
        '0';
    --an instruction in ID that is dependent on an instruction in EX which is load, will not do
    --if we wait a cycle we could pipe MEM -> EX but this would be bad for fmax
    s_data_hazard_r1 <= '1' when(
        i_rd_EX /= "00000" and i_reg_write_EX = '1' and i_rd_EX = i_rs1_ID and i_inst_forward_type = "01"
        ) else
        '0';

    s_data_hazard <= s_data_hazard_r1 or s_data_hazard_r2;

    o_PC_update <= '1' when (s_data_hazard = '0') else
        '0';

    o_update_ID_EX <= '0' when (s_data_hazard = '1') else
        '1';

    --needed when doing control flow hazards
    o_flush_IF_ID_n <= '1';

    o_update_IF_ID <= '0' when (s_data_hazard = '1') else
        '1';

end dataflow;