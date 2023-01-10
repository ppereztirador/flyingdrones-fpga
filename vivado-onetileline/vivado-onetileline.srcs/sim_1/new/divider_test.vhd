----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2022 11:02:16 AM
-- Design Name: 
-- Module Name: divider_test - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library WORK;
use WORK.lhe_lib.ALL;

entity divider_test is
--  Port ( );
end divider_test;

architecture Behavioral of divider_test is

    component division_H is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               valid_i : in STD_LOGIC;
               ready_i : in STD_LOGIC;           
               diff_accum_i : in STD_LOGIC_VECTOR(NUM_BITS_ACCUM_DIFF-1 downto 0);
               counter_accum_i : in STD_LOGIC_VECTOR(NUM_BITS_COUNTER_DIFF-1 downto 0);
               valid_o : out STD_LOGIC;
               pr_o : out STD_LOGIC_VECTOR (2 downto 0));
    end component;
    
    signal clk_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal valid_i, valid_gen : STD_LOGIC := '0';
    signal ready_i : STD_LOGIC;           
    signal diff_accum_i : STD_LOGIC_VECTOR(NUM_BITS_ACCUM_DIFF-1 downto 0);
    signal diff_accum_u : unsigned(NUM_BITS_ACCUM_DIFF-1 downto 0) := "0001101000000";
    signal counter_accum_i : STD_LOGIC_VECTOR(NUM_BITS_COUNTER_DIFF-1 downto 0);
    signal counter_accum_u : unsigned(NUM_BITS_COUNTER_DIFF-1 downto 0) := "00000000000";
    signal valid_o : STD_LOGIC;
    signal pr_o : STD_LOGIC_VECTOR (2 downto 0);
    
    constant clk_period : time := 6 ns;
    signal cycles_update : unsigned(3 downto 0) := x"0"; 

begin

    division_inst: division_H
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        valid_i => valid_i,
        ready_i => ready_i,
        diff_accum_i => diff_accum_i,
        counter_accum_i => counter_accum_i,
        valid_o => valid_o,
        pr_o => pr_o
    );
    
    -- Clk and reset
    clk_proc: process
    begin
        clk_i <= '1';
        wait for clk_period/2;
        clk_i <= '0';
        wait for clk_period/2;
    end process;
    
    reset_i <= '1';
    
    -- Valid
    valid_proc: process
    begin
        valid_gen <='0';
        wait for 4*clk_period;
        valid_gen <= '1';
        wait for clk_period;
    end process;
    
    valid_i <= '1';--transport valid_gen after 1 ps;
    
    ready_i <= '1';
    
    -- Data
    cycles_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            if (cycles_update=x"4") then
                cycles_update <= x"0";
            else
                cycles_update <= cycles_update + 1;
            end if;
        end if;
    end process;
    
    data_proc: process(clk_i, cycles_update)
    begin
        if (rising_edge(clk_i)) then
            if (cycles_update=x"4") then
                counter_accum_u <= counter_accum_u + 1;
                
                if (counter_accum_u="11111111111") then
                    diff_accum_u <= diff_accum_u + 1;
                end if;
            end if;
        end if;
    end process;
    
    counter_accum_i <= std_logic_vector(counter_accum_u);
    diff_accum_i <= std_logic_vector(diff_accum_u);


end Behavioral;
