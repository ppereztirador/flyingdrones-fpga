----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2022 05:52:13 PM
-- Design Name: 
-- Module Name: downsample_test - Behavioral
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

entity downsample_test is
--  Port ( );
end downsample_test;

architecture Behavioral of downsample_test is

constant clk_period : time := 6ns;

    component downsample is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               ready_i : in STD_LOGIC;
               
               -- PRs
               PRH_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
               PRV_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
               valid_pr_i : in STD_LOGIC;
               
               -- Data from memory
               Y_i : in STD_LOGIC_VECTOR(7 DOWNTO 0);
               addr_r_ds_o : out STD_LOGIC_VECTOR(14 DOWNTO 0);
               switch_y_ds_o : out STD_LOGIC;
               
               -- Data to memory
               DS_o : out STD_LOGIC_VECTOR(7 downto 0);
               addr_w_ds_o : out STD_LOGIC_VECTOR(14 DOWNTO 0);
               switch_ds_hle_i : out STD_LOGIC
               );
    end component;
    
    signal clk_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal ready_i : STD_LOGIC;
    signal PRH_i : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal PRV_i : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal valid_pr_i : STD_LOGIC;
    signal Y_i : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal addr_r_ds_o : STD_LOGIC_VECTOR(14 DOWNTO 0);
    signal switch_y_ds_o : STD_LOGIC;
    signal DS_o : STD_LOGIC_VECTOR(7 downto 0);
    signal addr_w_ds_o : STD_LOGIC_VECTOR(14 DOWNTO 0);
    signal switch_ds_hle_i : STD_LOGIC;
    
    signal prh_u, prv_u : unsigned(2 downto 0);
begin

    -- Instance
    test_inst: downsample
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        ready_i => ready_i,
        
        -- PRs
        PRH_i => PRH_i, 
        PRV_i => PRV_i,
        valid_pr_i => valid_pr_i, 
        
        -- Data from memory
        Y_i => Y_i,
        addr_r_ds_o => addr_r_ds_o,
        switch_y_ds_o => switch_y_ds_o,
        
        -- Data to memory
        DS_o => DS_o,
        addr_w_ds_o => addr_w_ds_o,
        switch_ds_hle_i => switch_ds_hle_i
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
    
    ready_i <= '1';
    
    -- Data
    pr_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            prh_u <= "000";
            prv_u <= "000";
        elsif (rising_edge(clk_i)) then
            if (prh_u="111") then
                prh_u <= "000";
                prv_u <= "000";
            else
                prh_u <= prh_u + 1;
                prv_u <= prv_u + 1;
            end if;
        end if;
    end process; 
    valid_pr_i <= '1';
    prh_i <= std_logic_vector(prh_u);
    prv_i <= std_logic_vector(prv_u);
    
    -- Temp
    Y_i <= x"00";

end Behavioral;
