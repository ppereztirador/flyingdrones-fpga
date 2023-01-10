----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/28/2022 02:49:59 PM
-- Design Name: 
-- Module Name: rowHle - Behavioral
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

entity rowHle is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           ready_i : in STD_LOGIC;
           
           -- PRs
           PRH_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           PRV_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           valid_pr_i : in STD_LOGIC;
           num_block_pr_i : in STD_LOGIC_VECTOR(7 downto 0);
           
           -- Data from memory
           DS_i : in vector_array_ds_data(SIZE_H_BK-1 downto 0);
           switch_ds_hle_i : in STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
           addr_r_hle_o : out vector_array_ds_address(SIZE_H_BK-1 downto 0);
           
           -- Access to hop cache
           address_block_a_o : out vector_array_hop_address(SIZE_H_BK/2-1 downto 0);
           address_block_b_o : out vector_array_hop_address(SIZE_H_BK/2-1 downto 0);
           
           req_block_a_o : out std_logic_vector(SIZE_H_BK/2-1 downto 0);
           req_block_b_o : out std_logic_vector(SIZE_H_BK/2-1 downto 0);
           
           valid_block_a_i : in std_logic_vector(SIZE_H_BK/2-1 downto 0);
           valid_block_b_i : in std_logic_vector(SIZE_H_BK/2-1 downto 0);
           
           data_block_a_i : in std_logic_vector(11 downto 0);
           data_block_b_i : in std_logic_vector(11 downto 0);
           
           -- Results out
           hops_vector_o : out vector_array_4(SIZE_H_BK-1 downto 0);
           ppp_vector_o : out vector_array_4(SIZE_H_BK-1 downto 0);
           luma_vector_o : out vector_array_8(SIZE_H_BK-1 downto 0);
           valid_hop_o : out std_logic_vector(SIZE_H_BK-1 downto 0);
           ready_hop_o : out std_logic_vector(SIZE_H_BK-1 downto 0)
           );
end rowHle;

architecture Behavioral of rowHle is
    component blockHle is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               ready_i : in STD_LOGIC;
               
               -- PRs
               PRH_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
               PRV_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
               valid_pr_i : in STD_LOGIC;
               
               -- Data from memory
               DS_i : in STD_LOGIC_VECTOR(7 DOWNTO 0);
               switch_ds_hle_i : in STD_LOGIC;
               addr_r_hle_o : out STD_LOGIC_VECTOR(10 DOWNTO 0);
               
               -- Access to hop cache
               addr_hop_o : out STD_LOGIC_VECTOR(17 downto 0);
               req_hop_o : out STD_LOGIC;
               valid_hop_i : in STD_LOGIC;
               value_hop_i : in STD_LOGIC_VECTOR(11 downto 0);
               
               -- Results out
               hop_o : out STD_LOGIC_VECTOR(3 DOWNTO 0);
               first_luma_o : out STD_LOGIC_VECTOR(7 DOWNTO 0);
               pppx_o : out STD_LOGIC_VECTOR(1 DOWNTO 0);
               pppy_o : out STD_LOGIC_VECTOR(1 DOWNTO 0);
               valid_o : out STD_LOGIC;
               ready_o : out STD_LOGIC);
    end component;
    
    signal valid_pr_vector : std_logic_vector(SIZE_H_BK-1 downto 0);
    signal valid_hop_vector : std_logic_vector(SIZE_H_BK-1 downto 0);
    signal ready_hop_vector : std_logic_vector(SIZE_H_BK-1 downto 0);
    signal hops_vector : vector_array_4(SIZE_H_BK-1 downto 0);
    signal ppp_vector : vector_array_4(SIZE_H_BK-1 downto 0);
    signal luma_vector : vector_array_8(SIZE_H_BK-1 downto 0);
begin
    -- Valid
    valid_gen: for I in 0 to SIZE_H_BK-1 generate
        valid_pr_vector(I) <= valid_pr_i when (std_logic_vector(to_unsigned(I, 8)) = num_block_pr_i) else '0';
    end generate;
    
    -- HLE
    hle_gen: for I in 0 to SIZE_H_BK-1 generate
        even_gen: if (I < SIZE_H_BK/2) generate --if (I rem 2=0) generate
            hle_inst: blockHle
            port map (
                clk_i => clk_i,
                reset_i => reset_i,
                ready_i => ready_i,
                
                -- PRs
                PRH_i => PRH_i,
                PRV_i => PRV_i,
                valid_pr_i => valid_pr_vector(I),
                
                -- Data from memory
                DS_i => DS_i(I),
                switch_ds_hle_i => switch_ds_hle_i(I),
                addr_r_hle_o => addr_r_hle_o(I),
                
                -- Access to hop cache
--                addr_hop_o => address_block_a_o(I/2),
--                req_hop_o => req_block_a_o(I/2),
--                valid_hop_i => valid_block_a_i(I/2),
                addr_hop_o => address_block_a_o(I),
                req_hop_o => req_block_a_o(I),
                valid_hop_i => valid_block_a_i(I),
                value_hop_i => data_block_a_i,
                
                -- Results out
                hop_o => hops_vector(I),
                first_luma_o => luma_vector(I),
                pppx_o => ppp_vector(I)(3 downto 2),
                pppy_o => ppp_vector(I)(1 downto 0),
                valid_o => valid_hop_vector(I),
                ready_o => ready_hop_vector(I)
            );
        end generate;
        
        odd_gen: if (I >= SIZE_H_BK/2) generate --if (I rem 2=1) generate
            hle_inst: blockHle
            port map (
                clk_i => clk_i,
                reset_i => reset_i,
                ready_i => ready_i,
                
                -- PRs
                PRH_i => PRH_i,
                PRV_i => PRV_i,
                valid_pr_i => valid_pr_vector(I),
                
                -- Data from memory
                DS_i => DS_i(I),
                switch_ds_hle_i => switch_ds_hle_i(I),
                addr_r_hle_o => addr_r_hle_o(I),
                
                -- Access to hop cache
--                addr_hop_o => address_block_b_o(I/2),
--                req_hop_o => req_block_b_o(I/2),
--                valid_hop_i => valid_block_b_i(I/2),
                addr_hop_o => address_block_b_o(I rem (SIZE_H_BK/2)),
                req_hop_o => req_block_b_o(I rem (SIZE_H_BK/2)),
                valid_hop_i => valid_block_b_i(I rem (SIZE_H_BK/2)),
                value_hop_i => data_block_b_i,
                
                -- Results out
                hop_o => hops_vector(I),
                first_luma_o => luma_vector(I),
                pppx_o => ppp_vector(I)(3 downto 2),
                pppy_o => ppp_vector(I)(1 downto 0),
                valid_o => valid_hop_vector(I),
                ready_o => ready_hop_vector(I)
            );
        end generate;
    end generate;

    -- Out
    hops_vector_o <= hops_vector;
    ppp_vector_o <= ppp_vector;
    luma_vector_o <= luma_vector;
    valid_hop_o <= valid_hop_vector;
    ready_hop_o <= ready_hop_vector;
end Behavioral;
