----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/22/2022 05:35:19 PM
-- Design Name: 
-- Module Name: dummyFifoWrite_test - Behavioral
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

entity dummyFifoWrite_test is
--  Port ( );
end dummyFifoWrite_test;

architecture Behavioral of dummyFifoWrite_test is
    component dummyFifoWrite is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               
               data_o : out vector_array_4(7 downto 0);
               write_o : out STD_LOGIC_VECTOR(7 downto 0));
    end component;
    
    signal clk_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
               
    signal data_o : vector_array_4(7 downto 0);
    signal write_o : STD_LOGIC_VECTOR(7 downto 0);
    
    component hopFifo is
        Generic (NUMBER_MEMORIES : integer := SIZE_H_BK);
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               
               hop_i : in vector_array_4(NUMBER_MEMORIES-1 downto 0);
               valid_hop_i : in std_logic_vector(NUMBER_MEMORIES-1 downto 0);
               
               fifo_read_i : in std_logic;
               hop_read_o : out std_logic_vector(7 downto 0);
               fifo_full_o : out std_logic;
               fifo_empty_o : out std_logic
               );
    end component;
    
    component hopMemBlockmem is
        Generic (NUMBER_MEMORIES : integer := SIZE_H_BK);
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               
               hop_i : in vector_array_4(NUMBER_MEMORIES-1 downto 0);
               valid_hop_i : in std_logic_vector(NUMBER_MEMORIES-1 downto 0);
               
               read_addr_i : in std_logic_vector(14 downto 0);
               hop_read_o : out std_logic_vector(7 downto 0);
               mem_full_o : out std_logic;
               fifo_empty_o : out std_logic);
    end component;
    
    constant clk_period : time := 6ns;

begin

test_inst: dummyFifoWrite
port map (
    clk_i => clk_i,
    reset_i => reset_i,
    
    data_o => data_o,
    write_o => write_o
);

--hop_inst: hopFifo
--generic map (NUMBER_MEMORIES => 8)
--port map (
--clk_i => clk_i,
--reset_i => reset_i,
           
--hop_i => data_o,
--valid_hop_i => write_o,

--fifo_read_i => '1',
--hop_read_o => open,
--fifo_full_o => open,
--fifo_empty_o => open
--);

hop_inst: hopMemBlockmem
generic map (NUMBER_MEMORIES => 8)
port map (
clk_i => clk_i,
reset_i => reset_i,
           
hop_i => data_o,
valid_hop_i => write_o,

read_addr_i => "000000000000010",
hop_read_o => open,
mem_full_o => open,
fifo_empty_o => open
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
end Behavioral;
