----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/11/2022 11:27:18 AM
-- Design Name: 
-- Module Name: hotizontalPR - Behavioral
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

entity horizontalPR is
  Port ( clk_i : in STD_LOGIC;
         reset_i : in STD_LOGIC;
         valid_i : in STD_LOGIC;
         ready_i : in STD_LOGIC;
         Y_i : in STD_LOGIC_VECTOR (7 downto 0);
         num_pixel_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_line_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_block_i : in STD_LOGIC_VECTOR(7 downto 0);
         valid_o : out STD_LOGIC;
         pr_o : out STD_LOGIC_VECTOR (2 downto 0);
         
         valid_single_o : out STD_LOGIC;
         diff_accum_single_o : out STD_LOGIC_VECTOR(12 downto 0);
         counter_accum_single_o : out STD_LOGIC_VECTOR(10 downto 0)
         );
end horizontalPR;

architecture Behavioral of horizontalPR is
    signal Y_div : std_logic_vector (7 downto 0);
    
    component diff_H_oneline is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               valid_i : in STD_LOGIC;
               ready_i : in STD_LOGIC;
               Y_i : in STD_LOGIC_VECTOR (7 downto 0);
               num_pixel_i : in STD_LOGIC_VECTOR(7 downto 0);
               num_line_i : in STD_LOGIC_VECTOR(7 downto 0);
               num_block_i : in STD_LOGIC_VECTOR(7 downto 0);
               --valid_o : out STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
               valid_single_o : out STD_LOGIC;
               diff_accum_single_o : out STD_LOGIC_VECTOR(NUM_BITS_ACCUM_DIFF-1 downto 0);
               counter_accum_single_o : out STD_LOGIC_VECTOR(NUM_BITS_COUNTER_DIFF-1 downto 0)--;
               --diff_accum_o : out vector_array_accum(SIZE_H_BK-1 downto 0);
               --counter_accum_o : out vector_array_counter(SIZE_H_BK-1 downto 0)
               );
    end component;
    
    signal valid_single_diff : STD_LOGIC;
    signal diff_accum_single : STD_LOGIC_VECTOR(NUM_BITS_ACCUM_DIFF-1 downto 0);
    signal counter_accum_single : STD_LOGIC_VECTOR(NUM_BITS_COUNTER_DIFF-1 downto 0);
    
    component division_HV is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               valid_i : in STD_LOGIC;
               ready_i : in STD_LOGIC;
               diff_accum_i : in STD_LOGIC_VECTOR(NUM_BITS_ACCUM_DIFF-1 downto 0);
               counter_accum_i : in STD_LOGIC_VECTOR(NUM_BITS_COUNTER_DIFF-1 downto 0);
               valid_o : out STD_LOGIC;
               pr_o : out STD_LOGIC_VECTOR (2 downto 0));
    end component;
    
    signal valid_division : STD_LOGIC;
    signal pr_division : STD_LOGIC_VECTOR (2 downto 0);

begin
    Y_div <= Y_i;--"00" & Y_i(9 downto 2);


    diff_inst: diff_H_oneline
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        valid_i => valid_i,
        ready_i => ready_i,
        Y_i => Y_div,
        num_pixel_i => num_pixel_i,
        num_line_i => num_line_i,
        num_block_i => num_block_i,
        --valid_o => open,
        valid_single_o => valid_single_diff,
        diff_accum_single_o => diff_accum_single,
        counter_accum_single_o => counter_accum_single--,
        --diff_accum_o => open,
        --counter_accum_o => open
    );
    
    division_inst: division_HV
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        valid_i => valid_single_diff,
        ready_i => ready_i,
        diff_accum_i => diff_accum_single,
        counter_accum_i => counter_accum_single,
        valid_o => valid_division,
        pr_o => pr_division
    );
    
    --
    
    valid_o <= valid_division;
    pr_o <= pr_division;
    
    --
    valid_single_o <= valid_single_diff;
    diff_accum_single_o <= diff_accum_single;
    counter_accum_single_o <= counter_accum_single;

end Behavioral;
