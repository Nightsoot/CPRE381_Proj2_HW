-------------------------------------------------------------------------
-- David Rice
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mem_slice.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an immediate generator to take the instruciton and output it to its proper 32-bit value
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity store_slice is

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

end store_slice;

architecture dataflow of store_slice is

begin
    o_data <= (i_memory_val(31 downto 8) & i_store_half(7 downto 0)) when(
        i_2LSB_addr = "00" and i_slice_type = "01"
        )
        else
        (i_memory_val(31 downto 16) & i_store_half(15 downto 8) & i_memory_val(7 downto 0))
        when(
        i_2LSB_addr = "01" and i_slice_type = "01"
        )
        else
        (i_memory_val(31 downto 24) & i_store_half(23 downto 16) & i_memory_val(15 downto 0))
        when(
        i_2LSB_addr = "10" and i_slice_type = "01"
        )
        else
        (i_store_half(31 downto 24) & i_memory_val(23 downto 0))
        when(
        i_2LSB_addr = "11" and i_slice_type = "01"
        )
        else
        (i_store_half(31 downto 16) & i_memory_val(15 downto 0))
        when(
        i_2LSB_addr = "10" and i_slice_type = "10"
        )
        else
        (i_memory_val(31 downto 16) & i_store_half(15 downto 0))
        when(
        i_2LSB_addr = "00" and i_slice_type = "10"
        )
        else
        i_memory_val;

end dataflow;