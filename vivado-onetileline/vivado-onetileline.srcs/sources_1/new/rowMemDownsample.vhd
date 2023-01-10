----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/25/2022 05:37:18 PM
-- Design Name: 
-- Module Name: rowMemDownsample - Behavioral
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

entity rowMemDownsample is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           valid_i : in STD_LOGIC;
           ready_i : in STD_LOGIC;
           
           -- PRs
           PRH_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           PRV_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           valid_pr_i : in STD_LOGIC;
           num_block_pr_i : in STD_LOGIC_VECTOR(7 downto 0);
           
           -- Data from cam
           num_pixel_i: in STD_LOGIC_VECTOR(7 downto 0);
           num_line_i: in STD_LOGIC_VECTOR(7 downto 0);
           num_block_i: in STD_LOGIC_VECTOR(7 downto 0);
           Y_i : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           
           -- Downsampled data out
           switch_ds_hle_o : out STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
           addr_r_hle_i : in vector_array_ds_address(SIZE_H_BK-1 downto 0);
           DS_o : out vector_array_ds_data(SIZE_H_BK-1 downto 0)
           );
end rowMemDownsample;

architecture Behavioral of rowMemDownsample is
    component blockMemDownsample is
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
    end component;
    
    signal valid_vector : std_logic_vector(SIZE_H_BK-1 downto 0);
    signal valid_pr_vector : std_logic_vector(SIZE_H_BK-1 downto 0);
    signal switch_ds_hle_vector : std_logic_vector(SIZE_H_BK-1 downto 0);
        
begin

    -- Valid signals per block
    valid_gen: for I in 0 to SIZE_H_BK-1 generate
        valid_vector(I) <= valid_i when (std_logic_vector(to_unsigned(I, 8)) = num_block_i) else '0';
        valid_pr_vector(I) <= valid_pr_i when (std_logic_vector(to_unsigned(I, 8)) = num_block_pr_i) else '0';
    end generate;
    
    -- Blocks (whole row)
    block_gen: for I in 0 to SIZE_H_BK-1 generate
    begin
        block_inst: blockMemDownsample
        port map (
            clk_i => clk_i,
            reset_i => reset_i,
            valid_i => valid_vector(I),
            ready_i => ready_i,
            
            -- PRs
            PRH_i => PRH_i,
            PRV_i => PRV_i,
            valid_pr_i => valid_pr_vector(I),
            
            -- Data from cam
            num_pixel_i => num_pixel_i,
            num_line_i => num_line_i,
            Y_i => Y_i,
            
            -- Data to HLE
            switch_ds_hle_o => switch_ds_hle_vector(I),
            addr_r_hle_i => addr_r_hle_i(I),
            DS_o => DS_o(I)
        );
    end generate;
    
    switch_ds_hle_o <= switch_ds_hle_vector;


end Behavioral;
