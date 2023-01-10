----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/18/2021 10:46:51 AM
-- Design Name: 
-- Module Name: diffH_block_test - Behavioral
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

entity diffV_block_test is
--  Port ( );
end diffV_block_test;

architecture Behavioral of diffV_block_test is
    component diffV_block is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               valid_i : in STD_LOGIC;
               Y_i : in STD_LOGIC_VECTOR (9 downto 0);
               num_pixel_i : in STD_LOGIC_VECTOR(11 downto 0);
               num_pixel_adv_i : in STD_LOGIC_VECTOR(11 downto 0);
               num_line_i : in STD_LOGIC_VECTOR(11 downto 0);
               num_block_i : in STD_LOGIC_VECTOR(11 downto 0);
               num_block_adv_i : in STD_LOGIC_VECTOR(11 downto 0);
               valid_o : out STD_LOGIC;
               diff_quant_o : out STD_LOGIC_VECTOR(2 downto 0);
               diff_not0_o : out STD_LOGIC_VECTOR(0 downto 0)
           );
    end component;
    
    signal clk_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal valid_i : STD_LOGIC;
    signal Y_i : STD_LOGIC_VECTOR (9 downto 0);
    signal num_pixel_i : STD_LOGIC_VECTOR(11 downto 0);
    signal num_pixel_adv_i : STD_LOGIC_VECTOR(11 downto 0);
    signal num_line_i : STD_LOGIC_VECTOR(11 downto 0);
    signal num_block_i : STD_LOGIC_VECTOR(11 downto 0);
    signal num_block_adv_i : STD_LOGIC_VECTOR(11 downto 0);
    signal valid_o : STD_LOGIC;
    signal diff_quant_o : std_logic_vector(2 downto 0);
    signal diff_not0_o : std_logic_vector(0 downto 0);
    
    signal Y_i_u : unsigned(9 downto 0) := "0000000000";
    signal num_pixel_u, num_line_u : unsigned(11 downto 0) := "000000100011";--"000000111100";
    signal num_block_u : unsigned(11 downto 0) := "000000001111";
    signal num_pixel_adv_u : unsigned(11 downto 0) := "000000100100";--"000000111100";
    signal num_block_adv_u : unsigned(11 downto 0) := "000000001111";
    constant clk_period : time := 6ns;
begin

    test_inst: diffV_block
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        valid_i => valid_i,
        Y_i => Y_i,
        num_pixel_i => num_pixel_i,
        num_pixel_adv_i => num_pixel_adv_i,
        num_line_i => num_line_i,
        num_block_i => num_block_i,
        num_block_adv_i => num_block_adv_i,
        valid_o => valid_o,
        diff_quant_o => diff_quant_o,
        diff_not0_o => diff_not0_o
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
            Y_i_u <= Y_i_u + "0000010001";
            
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
            
            if (num_pixel_adv_u=to_unsigned(SIZE_BLOCK_H-1,12)) then
                num_pixel_adv_u <= "000000000000";
                if (num_block_adv_u=to_unsigned(SIZE_H_BK-1,12)) then
                    num_block_adv_u <= "000000000000";
                else
                    num_block_adv_u <= num_block_adv_u + 1;
                end if;
            else
                num_pixel_adv_u <= num_pixel_adv_u + 1;
            end if;
            
            
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
    num_block_i <= std_logic_vector(num_block_u);
    num_line_i <= std_logic_vector(num_line_u);
    num_pixel_adv_i <= std_logic_vector(num_pixel_adv_u);
    num_block_adv_i <= std_logic_vector(num_block_adv_u);

end Behavioral;

