-- -------------------------------------------------------------------------
-- -- David Rice
-- -- Department of Electrical and Computer Engineering
-- -- Iowa State University
-- -------------------------------------------------------------------------
-- -- tb_store_slicer.vhd
-- -------------------------------------------------------------------------
-- -- DESCRIPTION: This file contains a simple VHDL testbench for the
-- -- immediate generator
-- --
-- --
-- -------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
entity tb_store_slicer is
    generic (gCLK_HPER : time := 50 ns);
end tb_store_slicer;

architecture behavior of tb_store_slicer is

    -- Calculate the clock period as twice the half-period
    constant cCLK_PER : time := gCLK_HPER * 2;
    component store_slice is

        port (
            i_memory_val : in std_logic_vector(31 downto 0);
            i_store_half : in std_logic_vector(31 downto 0);
            --0: NOTHING
            --1: BYTE
            --2: HALFWORD
            i_slice_type : in std_logic_vector(1 downto 0);
            i_2LSB_addr : in std_logic_vector(1 downto 0);
            o_data : out std_logic_vector(31 downto 0)
        );

    end component;

    -- Temporary signals to connect to the dff component.
    signal s_CLK, s_RST : std_logic;

    -- Temporary signals to connect to the decoder component.
    signal s_data_i, s_data_o : std_logic_vector(31 downto 0);
    signal s_store_val : std_logic_vector(31 downto 0);
    signal s_slice_type : std_logic_vector(1 downto 0);
    signal s_add_2LSB : std_logic_vector(1 downto 0);

begin

    DUT : store_slice
    port map(
        i_memory_val => s_data_i,
        i_store_half => s_store_val,
        i_slice_type => s_slice_type,
        i_2LSB_addr => s_add_2LSB,
        o_data => s_data_o
    );

    -- This process sets the clock value (low for gCLK_HPER, then high
    -- for gCLK_HPER). Absent a "wait" command, processes restart 
    -- at the beginning once they have reached the final statement.
    P_CLK : process
    begin
        s_CLK <= '0';
        wait for gCLK_HPER;
        s_CLK <= '1';
        wait for gCLK_HPER;
    end process;

    -- Testbench process  
    P_TB : process
    begin
        s_RST <= '1';
        wait for cCLK_PER;
        s_RST <= '0';

        s_store_val <= X"11223344";
        s_data_i <= X"FFEEDDCC";
        s_slice_type <= "00";
        s_add_2LSB <= "00";
        wait for cCLK_PER;

        s_data_i <= X"FFEEDDCC";
        s_slice_type <= "01";
        s_add_2LSB <= "00";
        wait for cCLK_PER;
        s_add_2LSB <= "01";
        wait for cCLK_PER;
        s_add_2LSB <= "10";
        wait for cCLK_PER;
        s_add_2LSB <= "11";
        wait for cCLK_PER;

        s_data_i <= X"FFEEDDCC";
        s_slice_type <= "10";
        s_add_2LSB <= "00";
        wait for cCLK_PER;
        s_add_2LSB <= "10";
        wait for cCLK_PER;

        wait;
    end process;

end behavior;