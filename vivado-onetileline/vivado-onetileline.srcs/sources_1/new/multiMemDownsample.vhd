----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/19/2022 12:56:26 PM
-- Design Name: 
-- Module Name: multiMemDownsample - Behavioral
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

entity multiMemDownsample is
    Generic (NUMBER_MEMORIES : integer := 2);
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           
           valid_i : in STD_LOGIC;
           ready_i : in STD_LOGIC;
           user_i : in STD_LOGIC;
           
           ready_hop_i : in STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
           
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
end multiMemDownsample;

architecture Behavioral of multiMemDownsample is
    component rowMemDownsample is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               valid_i : in STD_LOGIC;
               ready_i : in STD_LOGIC;
               
               -- PRs
               PRH_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
               PRV_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
               valid_pr_i : in STD_LOGIC;
               num_block_pr_i: in STD_LOGIC_VECTOR(7 downto 0);
               
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
    end component;
    
    signal switch_ds_hle_internal : vector_array_blocks(NUMBER_MEMORIES-1 downto 0);
    signal addr_r_hle_internal : vector_array_ds_address(SIZE_H_BK-1 downto 0);
    signal DS_internal : vector_array_ds_data_array(NUMBER_MEMORIES-1 downto 0);
    signal valid_pr_internal : std_logic_vector(NUMBER_MEMORIES-1 downto 0);
    signal valid_Y_internal : std_logic_vector(NUMBER_MEMORIES-1 downto 0);
    
    constant NUMBER_MEMORIES_BITS : integer := integer(ceil(log2(real(NUMBER_MEMORIES))));
    
    type memory_state_type is (IDLE, WAIT_UP, CHANGE_MEM);
    signal memory_state_current, memory_state_next : memory_state_type;
    signal memory_current_u : unsigned(NUMBER_MEMORIES_BITS-1 downto 0);
    
begin
    -- Multiple memories (one per tile row)
    mem_gen: for I in 0 to NUMBER_MEMORIES-1 generate
        mem_inst: rowMemDownsample
            port map (
                clk_i => clk_i,
                reset_i => reset_i,
                valid_i => valid_Y_internal(I),
                ready_i => ready_i,
                
                -- PRs
                PRH_i => PRH_i,
                PRV_i => PRV_i,
                valid_pr_i => valid_pr_internal(I),
                num_block_pr_i => num_block_pr_i,
                
                -- Data from cam
                num_pixel_i => num_pixel_i,
                num_line_i => num_line_i,
                num_block_i => num_block_i,
                Y_i => Y_i,
                
                -- Downsampled data out
                switch_ds_hle_o => switch_ds_hle_internal(I),
                addr_r_hle_i => addr_r_hle_i,--addr_r_hle_internal,
                DS_o => DS_internal(I)
            );
            
        valid_Y_internal(I) <= valid_i when ( num_block_v_i(NUMBER_MEMORIES_BITS-1 downto 0) = std_logic_vector(to_unsigned(I, NUMBER_MEMORIES_BITS)) ) else '0';
        valid_pr_internal(I) <= valid_pr_i when ( num_block_v_pr_i(NUMBER_MEMORIES_BITS-1 downto 0) = std_logic_vector(to_unsigned(I, NUMBER_MEMORIES_BITS)) ) else '0';
    end generate;
    
    -- Logic to decide when to change memory
    mem_next_proc: process (clk_i, reset_i)
    begin
        if (reset_i='0') then
            memory_state_current <= IDLE;
        elsif (rising_edge(clk_i)) then
            memory_state_current <= memory_state_next;
        end if;
    end process;
        
    mem_state_proc: process(memory_state_current, ready_hop_i)
        variable ones : std_logic_vector(SIZE_H_BK-1 downto 0);
    begin
        ones := (others=>'1');
        
        case memory_state_current is
            when IDLE =>
                if (ready_hop_i=ones) then
                    memory_state_next <= IDLE;
                else
                    memory_state_next <= WAIT_UP;
                end if;
            when WAIT_UP =>
                if (ready_hop_i=ones) then
                    memory_state_next <= CHANGE_MEM;
                else
                    memory_state_next <= WAIT_UP;
                end if;
            when CHANGE_MEM =>
                memory_state_next <= IDLE;
            when OTHERS =>
                memory_state_next <= IDLE;
        end case;
    end process;
    
    -- Memory counter (reset also with first frame, to sync)
    mem_ct_proc: process(clk_i, reset_i, user_i, memory_state_current)
    begin
        if (reset_i='0' or user_i='1') then
            memory_current_u <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (memory_state_current=CHANGE_MEM) then
                if (memory_current_u=to_unsigned(NUMBER_MEMORIES-1, NUMBER_MEMORIES_BITS)) then
                    memory_current_u <= (others=>'0');
                else
                    memory_current_u <= memory_current_u + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Outputs - select memory
    switch_ds_hle_o <= switch_ds_hle_internal(to_integer(memory_current_u));
    DS_o <= DS_internal(to_integer(memory_current_u));


end Behavioral;
