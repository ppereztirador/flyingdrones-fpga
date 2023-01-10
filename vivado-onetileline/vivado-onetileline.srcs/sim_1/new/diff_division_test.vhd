----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/03/2022 07:44:20 PM
-- Design Name: 
-- Module Name: diff_division_test - Behavioral
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

entity diff_division_test is
--  Port ( );
end diff_division_test;

architecture Behavioral of diff_division_test is
    component diff_H_oneline is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               valid_i : in STD_LOGIC;
               Y_i : in STD_LOGIC_VECTOR (9 downto 0);
               num_pixel_i : in STD_LOGIC_VECTOR(11 downto 0);
               num_line_i : in STD_LOGIC_VECTOR(11 downto 0);
               num_block_i : in STD_LOGIC_VECTOR(11 downto 0);
               valid_o : out STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
               valid_single_o : out STD_LOGIC;
               diff_accum_single_o : out STD_LOGIC_VECTOR(NUM_BITS_ACCUM_DIFF-1 downto 0);
               counter_accum_single_o : out STD_LOGIC_VECTOR(NUM_BITS_COUNTER_DIFF-1 downto 0);
               diff_accum_o : out vector_array_accum(SIZE_H_BK-1 downto 0);
               counter_accum_o : out vector_array_counter(SIZE_H_BK-1 downto 0)
               );
    end component;
    
    component division_H is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               valid_i : in STD_LOGIC;
               diff_accum_i : in STD_LOGIC_VECTOR(NUM_BITS_ACCUM_DIFF-1 downto 0);
               counter_accum_i : in STD_LOGIC_VECTOR(NUM_BITS_COUNTER_DIFF-1 downto 0);
               valid_o : out STD_LOGIC;
               pr_o : out STD_LOGIC_VECTOR (2 downto 0));
    end component;
    
    signal clk_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal valid_i : STD_LOGIC;
    signal Y_i : STD_LOGIC_VECTOR (9 downto 0);
    signal num_pixel_i : STD_LOGIC_VECTOR(11 downto 0);
    signal num_line_i : STD_LOGIC_VECTOR(11 downto 0);
    signal num_block_i : STD_LOGIC_VECTOR(11 downto 0);
    signal valid_o : STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
    signal valid_single_o : STD_LOGIC;
    signal diff_accum_single_o : STD_LOGIC_VECTOR(NUM_BITS_ACCUM_DIFF-1 downto 0);
    signal counter_accum_single_o : STD_LOGIC_VECTOR(NUM_BITS_COUNTER_DIFF-1 downto 0);
    signal diff_accum_o : vector_array_accum(SIZE_H_BK-1 downto 0);
    signal counter_accum_o : vector_array_counter(SIZE_H_BK-1 downto 0);
    
    signal valid_div_o : STD_LOGIC;
    signal pr_o : STD_LOGIC_VECTOR (2 downto 0);
    
    signal Y_i_u : unsigned(9 downto 0) := "0000000000";
    signal num_pixel_u, num_line_u : unsigned(11 downto 0) := "000000100111";--"000000111100";
    signal num_block_u : unsigned(11 downto 0) := "000000001111";

    constant clk_period : time := 6ns;
begin

    test_diff_inst: diff_H_oneline
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        valid_i => valid_i,
        Y_i => Y_i,
        num_pixel_i => num_pixel_i,
        num_line_i => num_line_i,
        num_block_i => num_block_i,
        valid_o => valid_o,
        diff_accum_single_o => diff_accum_single_o,
        counter_accum_single_o => counter_accum_single_o,
        valid_single_o => valid_single_o,
        diff_accum_o => diff_accum_o,
        counter_accum_o => counter_accum_o
    );
    
    test_div_inst: division_H
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        valid_i => valid_single_o,
        diff_accum_i => diff_accum_single_o,
        counter_accum_i => counter_accum_single_o,
        valid_o => valid_div_o,
        pr_o => pr_o
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
        reset_i <= '1';
        wait for 2*clk_period;
        reset_i <= '0';
        wait;
    end process;
    
    -- signal processes
    valid_proc: process
    begin
        valid_i <= '0';
        wait for 4.5*clk_period;
        valid_i <= '1';
        wait for 10*clk_period;
        valid_i <= '0';
        wait for clk_period;
        valid_i <= '1';
        wait;
    end process;
    
    y_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            Y_i_u <= Y_i_u + "0000001000";
            
            if (num_pixel_u=to_unsigned(SIZE_BLOCK_H-1,12)) then
                num_pixel_u <= "000000000000";
                if (num_block_u=to_unsigned(SIZE_H_BK-1,12)) then
                    num_block_u <= "000000000000";
                else
                    num_block_u <= num_block_u + 1;
                end if;
            else
                num_pixel_u <= num_pixel_u + 1;
            end if;
            
--            if (num_block_u=to_unsigned(SIZE_H_BK,12) and num_pixel_u=to_unsigned(SIZE_BLOCK_H,12)) then
--                num_block_u <= "000000000000";
--            elsif (num_pixel_u=to_unsigned(SIZE_BLOCK_H,12)) then
--                num_block_u <= num_block_u + 1;
--            end if;
            
            
            if (num_block_u=to_unsigned(SIZE_H_BK-1,12) and num_pixel_u=to_unsigned(SIZE_BLOCK_H-1,12)) then
                if (num_line_u=to_unsigned(SIZE_BLOCK_V-1,12)) then
                    num_line_u <= "000000000000";
                else
                    num_line_u <= num_line_u + 1;
                end if;
            end if;
        end if;
    end process;
    
    Y_i <= std_logic_vector(Y_i_u);
    num_pixel_i <= std_logic_vector(num_pixel_u);
    num_line_i <= std_logic_vector(num_line_u);
    num_block_i <= std_logic_vector(num_block_u);


end Behavioral;
