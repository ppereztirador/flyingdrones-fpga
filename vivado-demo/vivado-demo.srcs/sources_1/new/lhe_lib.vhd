----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2021 04:05:35 PM
-- Design Name: 
-- Module Name: lhe_lib - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use IEEE.MATH_REAL.ALL;

package lhe_lib is

    constant SIZE_BLOCK_H : integer := 40;
    constant SIZE_BLOCK_V : integer := 40;
    constant SIZE_H_PX : integer := 640;
    constant SIZE_V_PX : integer := 480;
    constant FPS : integer:= 30;
    constant F_CLK : integer := 150000000;
    
    constant SIZE_H_BK : integer := SIZE_H_PX / SIZE_BLOCK_H;
    constant SIZE_V_BK : integer := SIZE_V_PX / SIZE_BLOCK_V;
    
    constant NUM_BITS_COUNTER_DIFF : integer := integer(ceil(log2( real(SIZE_BLOCK_H * SIZE_BLOCK_V) )));
    constant NUM_BITS_ACCUM_DIFF : integer := integer(ceil(log2( real(4 * SIZE_BLOCK_H * SIZE_BLOCK_V) ))); -- if all diffs were 4

    type vector_array_2 is array(integer range<>) of std_logic_vector(2 downto 0);
    type vector_array_0 is array(integer range<>) of std_logic_vector(0 downto 0);
    type vector_array_16 is array(integer range<>) of std_logic_vector(15 downto 0);
    type vector_array_4 is array(integer range<>) of std_logic_vector(3 downto 0);
    type vector_array_8 is array(integer range<>) of std_logic_vector(7 downto 0);
    
    type vector_array_accum is array(integer range<>) of std_logic_vector(NUM_BITS_ACCUM_DIFF-1 downto 0);
    type vector_array_counter is array(integer range<>) of std_logic_vector(NUM_BITS_COUNTER_DIFF-1 downto 0);
    type vector_array_blocks is array(integer range<>) of std_logic_vector(SIZE_H_BK-1 downto 0);
    
    type vector_array_ds_address is array(integer range<>) of std_logic_vector(10 downto 0);
    type vector_array_hop_address is array(integer range<>) of std_logic_vector(17 downto 0);
    type vector_array_ds_data is array(integer range<>) of std_logic_vector(7 downto 0);
    type vector_array_ds_data_array is array(integer range <>) of vector_array_ds_data(SIZE_H_BK-1 downto 0);
    
    constant LINE_CYCLES : integer := F_CLK/(FPS*SIZE_V_PX);
    constant NUM_BITS_LINE_CYCLES : integer := integer(ceil(log2( real(LINE_CYCLES) )));
end lhe_lib;

package body lhe_lib is



end package body lhe_lib;
