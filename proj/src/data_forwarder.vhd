-------------------------------------------------------------------------
-- David Rice
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- data_forwarder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a hazard detection unit which outputs the PC update, register update, and flushing
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity data_forwarder is

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

end data_forwarder;
architecture dataflow of data_forwarder is
    signal s_rs1_EX_to_ID_hazard, s_rs2_EX_to_ID_hazard, s_rs1_MEM_to_ID_hazard, s_rs2_MEM_to_ID_hazard, s_rs1_MEM_to_EX_hazard, s_rs2_MEM_to_EX_hazard, s_rs1_WB_to_EX_hazard, s_rs2_WB_to_EX_hazard, s_WB_to_MEM_hazard : std_logic;
begin
    s_rs1_EX_to_ID_hazard <= '1' when(i_rd_EX /= "00000" and i_rs1_addr_ID = i_rd_EX and i_reg_write_EX = '1') else
        '0';
    s_rs2_EX_to_ID_hazard <= '1' when(i_rd_EX /= "00000" and i_rs2_addr_ID = i_rd_EX and i_reg_write_EX = '1') else
        '0';
    s_rs1_MEM_to_ID_hazard <= '1' when(i_rd_MEM /= "00000" and i_rs1_addr_ID = i_rd_MEM and i_reg_write_MEM = '1') else
        '0';
    s_rs2_MEM_to_ID_hazard <= '1' when(i_rd_MEM /= "00000" and i_rs2_addr_ID = i_rd_MEM and i_reg_write_MEM = '1') else
        '0';
    s_rs1_MEM_to_EX_hazard <= '1' when(i_rd_MEM /= "00000" and i_rs1_addr_EX = i_rd_MEM and i_reg_write_MEM = '1') else
        '0';
    s_rs2_MEM_to_EX_hazard <= '1' when(i_rd_MEM /= "00000" and i_rs2_addr_EX = i_rd_MEM and i_reg_write_MEM = '1') else
        '0';

    s_rs1_WB_to_EX_hazard <= '1' when(i_rd_WB /= "00000" and i_rs1_addr_EX = i_rd_WB and i_reg_write_WB = '1') else
        '0';
    s_rs2_WB_to_EX_hazard <= '1' when(i_rd_WB /= "00000" and i_rs2_addr_EX = i_rd_WB and i_reg_write_WB = '1') else
        '0';
    s_WB_to_MEM_hazard <= '1' when(i_rd_WB /= "00000" and i_rs2_addr_MEM = i_rd_WB and i_reg_write_WB = '1') else
        '0';
    --inst type
    --00 : arithemetic/lui
    --11: auipc
    --10: jal/jalr
    --01: load

    --NOTE: sooner pipeline stages are higher up to be prioritized
    o_rs1_ID <= i_ALU_res_EX when(
        (s_rs1_EX_to_ID_hazard = '1' and i_inst_type_EX = "00")
        )
        else
        i_PC_imm_EX when(
        ((s_rs1_EX_to_ID_hazard = '1' and i_inst_type_EX = "11"))
        )
        else
        i_PC_4_EX when(
        ((s_rs1_EX_to_ID_hazard = '1' and i_inst_type_EX = "10"))
        )
        else
        i_ALU_res_MEM when(
        (s_rs1_MEM_to_ID_hazard = '1' and i_inst_type_MEM = "00")
        )
        else
        i_PC_imm_MEM when(
        (s_rs1_MEM_to_ID_hazard = '1' and i_inst_type_MEM = "11")
        )
        else
        i_PC_4_MEM when(
        (s_rs1_MEM_to_ID_hazard = '1' and i_inst_type_MEM = "10")
        )
        else
        i_mem_res_MEM when(
        (s_rs1_MEM_to_ID_hazard = '1' and i_inst_type_MEM = "01")
        )
        else
        X"00000000";

    --indicates that the forwarder can do this type of forwarding to ID stage
    o_forward_rs1_ID <= '1' when(
        (s_rs1_EX_to_ID_hazard = '1' and i_inst_type_EX = "00") or
        (s_rs1_EX_to_ID_hazard = '1' and i_inst_type_EX = "11") or
        (s_rs1_EX_to_ID_hazard = '1' and i_inst_type_EX = "10") or
        (s_rs1_MEM_to_ID_hazard = '1')
        )
        else
        '0';
    --NOTE: sooner pipeline stages are higher up to be prioritized
    o_rs2_ID <= i_ALU_res_EX when(
        (s_rs2_EX_to_ID_hazard = '1' and i_inst_type_EX = "00")
        )
        else
        i_PC_imm_EX when(
        ((s_rs2_EX_to_ID_hazard = '1' and i_inst_type_EX = "11"))
        )
        else
        i_PC_4_EX when(
        ((s_rs2_EX_to_ID_hazard = '1' and i_inst_type_EX = "10"))
        )
        else
        i_ALU_res_MEM when(
        (s_rs2_MEM_to_ID_hazard = '1' and i_inst_type_MEM = "00")
        )
        else
        i_PC_imm_MEM when(
        (s_rs2_MEM_to_ID_hazard = '1' and i_inst_type_MEM = "11")
        )
        else
        i_PC_4_MEM when(
        (s_rs2_MEM_to_ID_hazard = '1' and i_inst_type_MEM = "10")
        )
        else
        i_mem_res_MEM when(
        (s_rs2_MEM_to_ID_hazard = '1' and i_inst_type_MEM = "01")
        )
        else
        X"00000000";

    --indicates that the forwarder can do this type of forwarding to ID stage
    o_forward_rs2_ID <= '1' when(
        (s_rs2_EX_to_ID_hazard = '1' and i_inst_type_EX = "00") or
        (s_rs2_EX_to_ID_hazard = '1' and i_inst_type_EX = "11") or
        (s_rs2_EX_to_ID_hazard = '1' and i_inst_type_EX = "10") or
        (s_rs2_MEM_to_ID_hazard = '1')
        )
        else
        '0';

    --NOTE: do not forward mem result from memory stage to EX otherwise fclk may suffer
    o_rs1_EX <= i_ALU_res_MEM when(
        (s_rs1_MEM_to_EX_hazard = '1' and i_inst_type_MEM = "00")
        )
        else
        i_PC_imm_MEM when(
        (s_rs1_MEM_to_EX_hazard = '1' and i_inst_type_MEM = "11")
        )
        else
        i_PC_4_MEM when(
        (s_rs1_MEM_to_EX_hazard = '1' and i_inst_type_MEM = "10")
        )
        else
        i_ALU_res_WB when(
        (s_rs1_WB_to_EX_hazard = '1' and i_inst_type_WB = "00")
        )
        else
        i_PC_imm_WB when(
        (s_rs1_WB_to_EX_hazard = '1' and i_inst_type_WB = "11")
        )
        else
        i_PC_4_WB when(
        (s_rs1_WB_to_EX_hazard = '1' and i_inst_type_WB = "10")
        )
        else
        i_mem_res_WB when(
        (s_rs1_WB_to_EX_hazard = '1' and i_inst_type_WB = "01")
        )
        else
        X"00000000";

    o_forward_rs1_EX <= '1' when(
        (s_rs1_MEM_to_EX_hazard = '1' and i_inst_type_MEM = "00") or
        (s_rs1_MEM_to_EX_hazard = '1' and i_inst_type_MEM = "11") or
        (s_rs1_MEM_to_EX_hazard = '1' and i_inst_type_MEM = "10") or
        --All WB -> EX can be resolved
        (s_rs1_WB_to_EX_hazard = '1')
        )
        else
        '0';

    --NOTE: do not forward mem result from memory stage to EX otherwise fclk may suffer
    o_rs2_EX <= i_ALU_res_MEM when(
        (s_rs2_MEM_to_EX_hazard = '1' and i_inst_type_MEM = "00")
        )
        else
        i_PC_imm_MEM when(
        (s_rs2_MEM_to_EX_hazard = '1' and i_inst_type_MEM = "11")
        )
        else
        i_PC_4_MEM when(
        (s_rs2_MEM_to_EX_hazard = '1' and i_inst_type_MEM = "10")
        )
        else
        i_ALU_res_WB when(
        (s_rs2_WB_to_EX_hazard = '1' and i_inst_type_WB = "00")
        )
        else
        i_PC_imm_WB when(
        (s_rs2_WB_to_EX_hazard = '1' and i_inst_type_WB = "11")
        )
        else
        i_PC_4_WB when(
        (s_rs2_WB_to_EX_hazard = '1' and i_inst_type_WB = "10")
        )
        else
        i_mem_res_WB when(
        (s_rs2_WB_to_EX_hazard = '1' and i_inst_type_WB = "01")
        )
        else
        X"00000000";

    o_forward_rs2_EX <= '1' when(
        (s_rs2_MEM_to_EX_hazard = '1' and i_inst_type_MEM = "00") or
        (s_rs2_MEM_to_EX_hazard = '1' and i_inst_type_MEM = "11") or
        (s_rs2_MEM_to_EX_hazard = '1' and i_inst_type_MEM = "10") or
        --All WB -> EX can be resolved
        (s_rs2_WB_to_EX_hazard = '1')
        )
        else
        '0';

    o_rs2_MEM <= i_ALU_res_WB when(
        (s_WB_to_MEM_hazard = '1' and i_inst_type_WB = "00")
        )
        else
        i_PC_imm_WB when(
        (s_WB_to_MEM_hazard = '1' and i_inst_type_WB = "11")
        )
        else
        i_PC_4_WB when(
        (s_WB_to_MEM_hazard = '1' and i_inst_type_WB = "10")
        )
        else
        i_mem_res_WB when(
        (s_WB_to_MEM_hazard = '1' and i_inst_type_WB = "01")
        )
        else
        X"00000000";

    --all WB -> MEM is resolvable
    o_forward_rs2_MEM <= '1' when(
        (s_WB_to_MEM_hazard = '1')
        )
        else
        '0';

end dataflow;