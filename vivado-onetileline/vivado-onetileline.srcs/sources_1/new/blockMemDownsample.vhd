----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2022 05:04:06 PM
-- Design Name: 
-- Module Name: blockMemDownsample - Behavioral
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

entity blockMemDownsample is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           valid_i : in STD_LOGIC;
           ready_i : in STD_LOGIC;
           
           -- PRs
           PRH_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           PRV_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           valid_pr_i : in STD_LOGIC;
           
           -- Data from cam
           num_pixel_i: in STD_LOGIC_VECTOR(7 downto 0);
           num_line_i: in STD_LOGIC_VECTOR(7 downto 0);
           Y_i : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           
           -- Data to HLE
           switch_ds_hle_o : out STD_LOGIC;
           addr_r_hle_i : in  STD_LOGIC_VECTOR(10 downto 0);
           DS_o : out STD_LOGIC_VECTOR(7 downto 0));
end blockMemDownsample;

architecture Behavioral of blockMemDownsample is
    -- Memory
    component blockBlockMemory is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               valid_i : in STD_LOGIC;
               ready_i : in STD_LOGIC;
               valid_ds_i : in STD_LOGIC;
               switch_y_ds_i : in STD_LOGIC;
               switch_ds_hle_i : in STD_LOGIC;
               -- Write - Y (cam)
               num_pixel_i: in STD_LOGIC_VECTOR(7 downto 0);
               num_line_i: in STD_LOGIC_VECTOR(7 downto 0);
               Y_i : in STD_LOGIC_VECTOR(7 downto 0);
               
               -- Read - DS
               addr_r_ds_i : in STD_LOGIC_VECTOR(10 downto 0);
               Y_o : out STD_LOGIC_VECTOR(7 downto 0);
               
               -- Write - DS
               addr_w_ds_i : in  STD_LOGIC_VECTOR(10 downto 0);
               DS_i : in STD_LOGIC_VECTOR(7 downto 0);
               
               -- Read - HLE
               addr_r_hle_i : in  STD_LOGIC_VECTOR(10 downto 0);
               DS_o : out STD_LOGIC_VECTOR(7 downto 0)
           );
    end component;
    
    -- Downsampling
    component blockDownsample is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               ready_i : in STD_LOGIC;
               
               -- PRs
               PRH_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
               PRV_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
               valid_pr_i : in STD_LOGIC;
               
               -- Data from memory
               Y_i : in STD_LOGIC_VECTOR(7 DOWNTO 0);
               addr_r_ds_o : out STD_LOGIC_VECTOR(10 DOWNTO 0);
               switch_y_ds_o : out STD_LOGIC;
               
               -- Data to memory
               DS_o : out STD_LOGIC_VECTOR(7 downto 0);
               addr_w_ds_o : out STD_LOGIC_VECTOR(10 DOWNTO 0);
               switch_ds_hle_o : out STD_LOGIC);
    end component;
    
    signal valid_ds : std_logic;
    signal switch_y_ds, switch_ds_hle : std_logic;
    signal addr_r_ds, addr_w_ds : std_logic_vector(10 downto 0);
    signal Y_mem, DS_result : std_logic_vector(7 downto 0);


begin

    bk_mem_inst: blockBlockMemory
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        valid_i => valid_i,
        ready_i => ready_i,
        valid_ds_i => valid_ds,
        switch_y_ds_i => switch_y_ds,
        switch_ds_hle_i => switch_ds_hle,
        -- Write - Y (cam)
        num_pixel_i => num_pixel_i,
        num_line_i => num_line_i,
        Y_i => Y_i,
        
        -- Read - DS
        addr_r_ds_i => addr_r_ds,
        Y_o => Y_mem,
        
        -- Write - DS
        addr_w_ds_i => addr_w_ds,
        DS_i => DS_result,
        
        -- Read - HLE
        addr_r_hle_i => addr_r_hle_i, 
        DS_o => DS_o
    );
    
    bk_ds_inst: blockDownsample
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        ready_i => ready_i,
        
        -- PRs
        PRH_i => PRH_i,
        PRV_i => PRV_i,
        valid_pr_i => valid_pr_i,
        
        -- Data from memory
        Y_i => Y_mem,
        addr_r_ds_o => addr_r_ds,
        switch_y_ds_o => switch_y_ds,
        
        -- Data to memory
        DS_o => DS_result,
        addr_w_ds_o => addr_w_ds,
        switch_ds_hle_o => switch_ds_hle
    );
    
    valid_ds <= '1';
    switch_ds_hle_o <= switch_ds_hle;

end Behavioral;
