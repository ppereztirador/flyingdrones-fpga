----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/17/2022 04:52:50 PM
-- Design Name: 
-- Module Name: hopCache_test - Behavioral
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

library WORK;
use WORK.lhe_lib.ALL;

entity hopCache_test is
--  Port ( );
end hopCache_test;

architecture Behavioral of hopCache_test is
    component hopCache is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               
               address_block_a_i : in vector_array_hop_address(SIZE_H_BK/2-1 downto 0);
               address_block_b_i : in vector_array_hop_address(SIZE_H_BK/2-1 downto 0);
               
               req_block_a_i : in std_logic_vector(SIZE_H_BK/2-1 downto 0);
               req_block_b_i : in std_logic_vector(SIZE_H_BK/2-1 downto 0);
               
               valid_block_a_o : out std_logic_vector(SIZE_H_BK/2-1 downto 0);
               valid_block_b_o : out std_logic_vector(SIZE_H_BK/2-1 downto 0);
               
               data_block_a_o : out std_logic_vector(11 downto 0);
               data_block_b_o : out std_logic_vector(11 downto 0)
               );
    end component;
    
    signal clk_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;

    signal address_block_a_i : vector_array_hop_address(SIZE_H_BK/2-1 downto 0);
    signal address_block_b_i : vector_array_hop_address(SIZE_H_BK/2-1 downto 0);
    
    signal req_block_a_i : std_logic_vector(SIZE_H_BK/2-1 downto 0);
    signal req_block_b_i : std_logic_vector(SIZE_H_BK/2-1 downto 0);
    
    signal valid_block_a_o : std_logic_vector(SIZE_H_BK/2-1 downto 0);
    signal valid_block_b_o : std_logic_vector(SIZE_H_BK/2-1 downto 0);
    
    signal data_block_a_o : std_logic_vector(11 downto 0);
    signal data_block_b_o : std_logic_vector(11 downto 0);
    
    --
    constant clk_period : time := 6.66 ns;
begin

hop_inst: hopCache
port map (
    clk_i => clk_i,
    reset_i => reset_i,
    
    address_block_a_i => address_block_a_i ,
    address_block_b_i => address_block_b_i,
    
    req_block_a_i => req_block_a_i,
    req_block_b_i => req_block_b_i,
    
    valid_block_a_o => valid_block_a_o,
    valid_block_b_o => valid_block_b_o,
    
    data_block_a_o => data_block_a_o,
    data_block_b_o => data_block_b_o 
);

-- clock and reset
clk_proc: process
begin
    clk_i <= '0';
    wait for clk_period/2;
    clk_i <= '1';
    wait for clk_period/2;
end process;

reset_proc: process
begin
    reset_i <= '0';
    wait for 2*clk_period;
    reset_i <= '1';
    wait;
end process;

-- Some requests
address_block_a_i(0) <= "000000000111111000";
address_block_a_i(1) <= "000011111100000000";
address_block_a_i(2) <= "000000011111000000";

req0_proc: process
begin
    req_block_a_i(0) <= '0';
    wait for 26.5*clk_period;
    req_block_a_i(0) <= '1';
    wait;
    
end process;

req1_proc: process
begin
    req_block_a_i(1) <= '0';
    wait for 19.5*clk_period;
    req_block_a_i(1) <= '1';
    wait;
    
end process;

req2_proc: process
begin
    req_block_a_i(2) <= '0';
    wait for 24.5*clk_period;
    req_block_a_i(2) <= '1';
    wait;
    
end process;

req_block_a_i(7 downto 3) <= (others=>'0');
req_block_b_i(7 downto 0) <= (others=>'0');
end Behavioral;
