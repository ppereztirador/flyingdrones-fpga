----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/06/2022 12:08:36 PM
-- Design Name: 
-- Module Name: rowMultimemDownsample - Behavioral
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
use IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library WORK;
use WORK.lhe_lib.ALL;

entity rowMultimemDownsample is
    Generic (NUMBER_MEMORIES : integer := 2);
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           
           valid_i : in STD_LOGIC;
           ready_i : in STD_LOGIC;
           user_i : in STD_LOGIC;
           
           ready_hop_i : in STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
           mem_block_o : out STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
           
           -- PRs
           PRH_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           PRV_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           valid_pr_i : in STD_LOGIC;
           num_block_pr_i: in STD_LOGIC_VECTOR(7 downto 0);
           num_block_v_pr_i : in STD_LOGIC_VECTOR(7 downto 0);
           
           -- Data from cam
           num_pixel_i: in STD_LOGIC_VECTOR(7 downto 0);
           num_line_i: in STD_LOGIC_VECTOR(7 downto 0);
           num_block_i: in STD_LOGIC_VECTOR(7 downto 0);
           num_block_v_i: in STD_LOGIC_VECTOR(7 downto 0);
           Y_i : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           
           -- Downsampled data out
           switch_ds_hle_o : out STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
           addr_r_hle_i : in vector_array_ds_address(SIZE_H_BK-1 downto 0);
           DS_o : out vector_array_ds_data(SIZE_H_BK-1 downto 0)
           );
end rowMultimemDownsample;

architecture Behavioral of rowMultimemDownsample is
    component blockMultimemDownsample is
        --Generic (NUMBER_MEMORIES : integer := 2);
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               valid_i : in STD_LOGIC;
               ready_i : in STD_LOGIC;
               user_i : in STD_LOGIC;
               
               mem_block_o : out STD_LOGIC;
               
               -- PRs
               PRH_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
               PRV_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
               valid_pr_i : in STD_LOGIC;
               
               -- Data from cam
               num_pixel_i: in STD_LOGIC_VECTOR(7 downto 0);
               num_line_i: in STD_LOGIC_VECTOR(7 downto 0);
               num_block_v_i : in STD_LOGIC_VECTOR(7 downto 0);
               Y_i : in STD_LOGIC_VECTOR(7 DOWNTO 0);
               
               -- Data to HLE
               ready_hop_i : in STD_LOGIC;
               switch_ds_hle_o : out STD_LOGIC;
               addr_r_hle_i : in  STD_LOGIC_VECTOR(10 downto 0);
               DS_o : out STD_LOGIC_VECTOR(7 downto 0));
    end component;
    
    signal valid_vector : std_logic_vector(SIZE_H_BK-1 downto 0);
    signal valid_pr_vector : std_logic_vector(SIZE_H_BK-1 downto 0);
begin

    block_gen: for I in 0 to SIZE_H_BK-1 generate
        block_inst: blockMultimemDownsample
        port map (
            clk_i => clk_i,
            reset_i => reset_i,
            valid_i => valid_vector(I),
            ready_i => ready_i,
            user_i => user_i,
            mem_block_o => mem_block_o(I),
            
            -- PRs
            PRH_i => PRH_i,
            PRV_i => PRV_i,
            valid_pr_i => valid_pr_vector(I),
            
            -- Data from cam
            num_pixel_i => num_pixel_i,
            num_line_i => num_line_i,
            num_block_v_i => num_block_v_i,
            Y_i => Y_i,
            
            -- Data to HLE
            ready_hop_i => ready_hop_i(I),
            switch_ds_hle_o => switch_ds_hle_o(I),
            addr_r_hle_i => addr_r_hle_i(I),
            DS_o => DS_o(I)
        );
    end generate;
    
    -- Valid signals per block
    valid_gen: for I in 0 to SIZE_H_BK-1 generate
        valid_vector(I) <= valid_i when (std_logic_vector(to_unsigned(I, 8)) = num_block_i) else '0';
        valid_pr_vector(I) <= valid_pr_i when (std_logic_vector(to_unsigned(I, 8)) = num_block_pr_i) else '0';
    end generate;
    

end Behavioral;
