----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/30/2022 01:44:54 PM
-- Design Name: 
-- Module Name: blockMultimemDownsample - Behavioral
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

entity blockMultimemDownsample is
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
end blockMultimemDownsample;

architecture Behavioral of blockMultimemDownsample is
    constant NUMBER_MEMORIES : integer := 2;
    
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
    
    signal valid_pr_internal : std_logic_vector(NUMBER_MEMORIES-1 downto 0);
    signal valid_Y_internal : std_logic_vector(NUMBER_MEMORIES-1 downto 0);
    
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
    signal switch_y_ds_intermediate, switch_ds_hle_intermediate : std_logic_vector(NUMBER_MEMORIES-1 downto 0);
    signal addr_r_ds, addr_w_ds : std_logic_vector(10 downto 0);
    signal Y_mem, DS_result : std_logic_vector(7 downto 0);
    signal Y_mem_row, DS_row : vector_array_ds_data(NUMBER_MEMORIES-1 downto 0);

    type memory_state_type is (IDLE, WAIT_UP, WAIT_DOWN, CHANGE_MEM);
    constant NUMBER_MEMORIES_BITS : integer := integer(ceil(log2(real(NUMBER_MEMORIES))));
    signal memory_state_current, memory_state_next : memory_state_type;
    signal ds_state_current, ds_state_next : memory_state_type;
    signal memory_current_u, ds_current_u : unsigned(NUMBER_MEMORIES_BITS-1 downto 0);
    
begin

    bk_mem_gen: for I in 0 to NUMBER_MEMORIES-1 generate
        bk_mem_inst: blockBlockMemory
        port map (
            clk_i => clk_i,
            reset_i => reset_i,
            valid_i => valid_Y_internal(I),
            ready_i => ready_i,
            valid_ds_i => valid_ds,
            switch_y_ds_i => switch_y_ds_intermediate(I),
            switch_ds_hle_i => switch_ds_hle_intermediate(I),
            -- Write - Y (cam)
            num_pixel_i => num_pixel_i,
            num_line_i => num_line_i,
            Y_i => Y_i,
            
            -- Read - DS
            addr_r_ds_i => addr_r_ds,
            Y_o => Y_mem_row(I),
            
            -- Write - DS
            addr_w_ds_i => addr_w_ds,
            DS_i => DS_result,
            
            -- Read - HLE
            addr_r_hle_i => addr_r_hle_i, 
            DS_o => DS_row(I)
        );
    end generate;
    
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
    begin
        case memory_state_current is
            when IDLE =>
                if (ready_hop_i='1') then
                    memory_state_next <= IDLE;
                else
                    memory_state_next <= WAIT_UP;
                end if;
            when WAIT_UP =>
                if (ready_hop_i='1') then
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
        if (reset_i='0') then -- or user_i='1'
            memory_current_u <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (memory_state_current=CHANGE_MEM) then
--                if (memory_current_u=to_unsigned(NUMBER_MEMORIES-1, NUMBER_MEMORIES_BITS)) then
--                    memory_current_u <= (others=>'0');
--                else
--                    memory_current_u <= memory_current_u + 1;
--                end if;
                
                if (memory_current_u(0)='1') then
                    memory_current_u(0) <= '0';
                else
                    memory_current_u(0) <= '1';
                end if;
            end if;
        end if;
    end process;
    
    --
    ds_next_proc: process (clk_i, reset_i)
    begin
        if (reset_i='0') then
            ds_state_current <= IDLE;
        elsif (rising_edge(clk_i)) then
            ds_state_current <= ds_state_next;
        end if;
    end process;
        
    ds_state_proc: process(ds_state_current, switch_y_ds)
    begin
        case ds_state_current is
            when IDLE =>
                if (switch_y_ds='0') then
                    ds_state_next <= IDLE;
                else
                    ds_state_next <= WAIT_DOWN;
                end if;
            when WAIT_DOWN =>
                if (switch_y_ds='0') then
                    ds_state_next <= CHANGE_MEM;
                else
                    ds_state_next <= WAIT_DOWN;
                end if;
            when CHANGE_MEM =>
                ds_state_next <= IDLE;
            when OTHERS =>
                ds_state_next <= IDLE;
        end case;
    end process;
    
    -- Memory counter (reset also with first frame, to sync)
    ds_ct_proc: process(clk_i, reset_i, user_i, ds_state_current)
    begin
        if (reset_i='0' or user_i='1') then
            ds_current_u <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (ds_state_current=CHANGE_MEM) then
--                if (ds_current_u=to_unsigned(NUMBER_MEMORIES-1, NUMBER_MEMORIES_BITS)) then
--                    ds_current_u <= (others=>'0');
--                else
--                    ds_current_u <= ds_current_u + 1;
--                end if;
                
                if (ds_current_u(0)='1') then
                    ds_current_u(0) <= '0';
                else
                    ds_current_u(0) <= '1';
                end if;
            end if;
        end if;
    end process;
    
    
    cam_if_gen: for I in 0 to NUMBER_MEMORIES-1 generate
        even_if: if (I MOD 2) = 0 generate
            valid_Y_internal(I) <= valid_i when ( num_block_v_i(0) = '0' ) else '0';
            switch_y_ds_intermediate(I) <= switch_y_ds when ( ds_current_u(0) = '0' ) else '0';
            switch_ds_hle_intermediate(I) <= switch_ds_hle when ( memory_current_u(0) = '0' ) else '0';
        end generate;
        
        odd_if: if (I MOD 2) = 1 generate
            valid_Y_internal(I) <= valid_i when ( num_block_v_i(0) = '1' ) else '0';
            switch_y_ds_intermediate(I) <= switch_y_ds when ( ds_current_u(0) = '1' ) else '0';
            switch_ds_hle_intermediate(I) <= switch_ds_hle when ( memory_current_u(0) = '1' ) else '0';
        end generate;
    end generate;
    
    Y_mem <= Y_mem_row(1) when ds_current_u(0)='1' else Y_mem_row(0);
    DS_o <= DS_row(1) when memory_current_u(0)='1' else DS_row(0);
    
    mem_block_o <= '0' when (memory_current_u(0)='0') else '1';

end Behavioral;