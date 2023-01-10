----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2022 02:14:34 PM
-- Design Name: 
-- Module Name: hopGpioWrapper - Behavioral
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

entity hopGpioWrapper is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           ready_i : in STD_LOGIC;
           user_i : in STD_LOGIC;
           
           -- Data from cam
           num_pixel_i: in STD_LOGIC_VECTOR(7 downto 0);
           num_line_i: in STD_LOGIC_VECTOR(7 downto 0);
           num_block_i: in STD_LOGIC_VECTOR(7 downto 0);
           num_block_v_i: in STD_LOGIC_VECTOR(7 downto 0);
           Y_i : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           valid_ds_i : in STD_LOGIC;
           
           -- Hops
           PRH_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           PRV_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           valid_pr_i : in STD_LOGIC;
           num_block_pr_i: in STD_LOGIC_VECTOR(7 downto 0);
           num_block_v_pr_i: in STD_LOGIC_VECTOR(7 downto 0);
           
           -- ARM I/O
           gpio_i : in STD_LOGIC_VECTOR(31 downto 0);
           gpio_o : out STD_LOGIC_VECTOR(31 downto 0));
end hopGpioWrapper;

architecture Behavioral of hopGpioWrapper is
    component multiMemDownsample is
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
    end component;
    
    component rowMultimemDownsample is
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
    end component;
    
    component rowMemDownsample is
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
    end component;
    
    signal valid_ds : STD_LOGIC;
    signal switch_y_ds : STD_LOGIC;
    signal switch_ds_hle : STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
    signal addr_r_ds : STD_LOGIC_VECTOR(14 downto 0) := "000000000000000";
    
    signal valid_pr_ds : std_logic;
    
    signal valid_pr_filtered : std_logic;
    signal valid_ds_filtered : std_logic;
    
    --signal switch_ds_hle_ds, switch_ds_hle_ds_1 : STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
    signal switch_ds_hle_ds : vector_array_blocks(1 downto 0);
    signal addr_r_hle_ds : vector_array_ds_address(SIZE_H_BK-1 downto 0);
    signal addr_r_hle_ds_u : unsigned(10 downto 0);
    signal DS_ds : vector_array_ds_data(SIZE_H_BK-1 downto 0);
    signal mem_block_ds : std_logic_vector(SIZE_H_BK-1 downto 0);
    
--    --
    component hopCache is
        Generic (SIZE_CACHE_VECTOR : integer := SIZE_H_BK/2);
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               
               address_block_a_i : in vector_array_hop_address(SIZE_CACHE_VECTOR-1 downto 0);
               address_block_b_i : in vector_array_hop_address(SIZE_CACHE_VECTOR-1 downto 0);
               
               req_block_a_i : in std_logic_vector(SIZE_CACHE_VECTOR-1 downto 0);
               req_block_b_i : in std_logic_vector(SIZE_CACHE_VECTOR-1 downto 0);
               
               valid_block_a_o : out std_logic_vector(SIZE_CACHE_VECTOR-1 downto 0);
               valid_block_b_o : out std_logic_vector(SIZE_CACHE_VECTOR-1 downto 0);
               
               data_block_a_o : out std_logic_vector(11 downto 0);
               data_block_b_o : out std_logic_vector(11 downto 0)
               );
    end component;
    
    signal address_block_a_hop1, address_block_a_hop2 : vector_array_hop_address(SIZE_H_BK/2-1 downto 0);
    signal address_block_a_hop, address_block_b_hop : vector_array_hop_address(SIZE_H_BK-1 downto 0);
    
    signal req_block_a_hop1, req_block_a_hop2 : std_logic_vector(SIZE_H_BK/2-1 downto 0);
    signal req_block_a_hop, req_block_b_hop : std_logic_vector(SIZE_H_BK-1 downto 0);
    
    signal valid_block_a_hop1, valid_block_a_hop2 : std_logic_vector(SIZE_H_BK/2-1 downto 0);
    signal valid_block_a_hop : std_logic_vector(SIZE_H_BK-1 downto 0);
    
    signal data_block_a_hop : std_logic_vector(11 downto 0);
    signal data_block_b_hop : std_logic_vector(11 downto 0);
--    --
    component rowHle is
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
    end component;
    
    signal hops_vector_row : vector_array_4(SIZE_H_BK-1 downto 0);
    signal ppp_vector_row : vector_array_4(SIZE_H_BK-1 downto 0);
    signal luma_vector_row : vector_array_8(SIZE_H_BK-1 downto 0);
    signal valid_hop_row, valid_hop_mem : std_logic_vector(SIZE_H_BK-1 downto 0);
    signal ready_hop_row : std_logic_vector(SIZE_H_BK-1 downto 0);
    
    ----
    
    component hopMemBlockmem2 is
        Generic (NUMBER_MEMORIES : integer := SIZE_H_BK);
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               user_i : in STD_LOGIC;
               arm_i : in STD_LOGIC;
--               user_temp_i : in STD_LOGIC;
               
               hop_i : in vector_array_4(NUMBER_MEMORIES-1 downto 0);
               valid_hop_i : in std_logic_vector(NUMBER_MEMORIES-1 downto 0);
               ready_hop_i : in std_logic_vector(NUMBER_MEMORIES-1 downto 0);
               mem_block_i : in STD_LOGIC_VECTOR(NUMBER_MEMORIES-1 downto 0);
               
               read_addr_i : in std_logic_vector(14 downto 0);
               hop_read_o : out std_logic_vector(8 downto 0);
               valid_rw_o : out STD_LOGIC;
               mem_full_o : out STD_LOGIC;
               mem_empty_o : out STD_LOGIC
               );
    end component;
    
    signal hopmem_addr : std_logic_vector(14 downto 0);
    signal hopmem_hop : std_logic_vector(8 downto 0);
    signal hopmem_full, hopmem_empty, hopmem_valid_rw : std_logic;
    signal arm_internal : std_logic;
    
    ----
    component hopStreamInfo is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               user_i : in STD_LOGIC;
               arm_i : in STD_LOGIC;
               
               first_luma_i : in vector_array_8(SIZE_H_BK-1 downto 0);
               ppp_i : in vector_array_4(SIZE_H_BK-1 downto 0);
               valid_i : in std_logic_vector(SIZE_H_BK-1 downto 0);
               sw_i : in std_logic_vector(SIZE_H_BK-1 downto 0);
               ready_hop_i : in std_logic_vector(SIZE_H_BK-1 downto 0);
               
               num_block_i : in std_logic_vector(7 downto 0);
               first_luma_o : out std_logic_vector(7 downto 0);
               ppp_o : out std_logic_vector(3 downto 0)
               );
    end component;
    
    signal num_block_info : std_logic_vector(7 downto 0);
    signal first_luma_info : std_logic_vector(7 downto 0);
    signal ppp_info : std_logic_vector(3 downto 0);
    signal ones_info : std_logic_vector(SIZE_H_BK-1 downto 0);
    
    --
    type memory_state_type is (IDLE, WAIT_UP, WAIT_DOWN, CHANGE_MEM);
    signal memory_state_current, memory_state_next : memory_state_type;
    signal current_memblock_u : unsigned(7 downto 0);
    constant ones : std_logic_vector(SIZE_H_BK-1 downto 0) := (others=>'1');
    constant zeros : std_logic_vector(SIZE_H_BK-1 downto 0) := (others=>'0');
    signal first_hop_block, first_hop_block_1cycle : std_logic;
    
    --
    signal user_hopmem : std_logic;
    signal reset_internal, reset_uc : std_logic;
    
    attribute mark_debug : string;
--    attribute mark_debug of current_memblock_u : signal is "true";
begin
    
    reset_internal <= reset_i and (not reset_uc);

--    ds_inst: rowMultimemDownsample
--    port map (
--        clk_i => clk_i,
--        reset_i => reset_i,
--        valid_i => valid_ds_i,
--        ready_i => ready_i,
--        user_i => user_i,
        
--        ready_hop_i => ready_hop_row,
--        mem_block_o => mem_block_ds,
        
--        -- PRs
--        PRH_i => PRH_i,
--        PRV_i => PRV_i,
--        valid_pr_i => valid_pr_i,
--        num_block_pr_i => num_block_pr_i,
--        num_block_v_pr_i => num_block_v_pr_i,
        
--        -- Data from cam
--        num_pixel_i => num_pixel_i,
--        num_line_i => num_line_i,
--        num_block_i => num_block_i,
--        num_block_v_i => num_block_v_i,
--        Y_i => Y_i,
        
--        -- Downsampled data out
--        switch_ds_hle_o => switch_ds_hle,
--        addr_r_hle_i => addr_r_hle_ds,
--        DS_o => ds_ds
--    );

    ds_inst: rowMemDownsample
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        valid_i => valid_ds_filtered,
        ready_i => ready_i,
        --user_i => user_i,
        
        --ready_hop_i => ready_hop_row,
        --mem_block_o => mem_block_ds,
        
        -- PRs
        PRH_i => PRH_i,
        PRV_i => PRV_i,
        valid_pr_i => valid_pr_filtered,
        num_block_pr_i => num_block_pr_i,
        --num_block_v_pr_i => num_block_v_pr_i,
        
        -- Data from cam
        num_pixel_i => num_pixel_i,
        num_line_i => num_line_i,
        num_block_i => num_block_i,
        --num_block_v_i => num_block_v_i,
        Y_i => Y_i,
        
        -- Downsampled data out
        switch_ds_hle_o => switch_ds_hle,
        addr_r_hle_i => addr_r_hle_ds,
        DS_o => ds_ds
    );
    
    valid_pr_filtered <= valid_pr_i when(num_block_v_pr_i=x"00") else '0';
    valid_ds_filtered <= valid_ds_i when(num_block_v_i=x"00") else '0';
--    valid_pr_filtered <= valid_pr_i when(num_block_v_pr_i(0)='0') else '0';
--    valid_ds_filtered <= valid_ds_i when(num_block_v_i(0)='0') else '0';
    mem_block_ds <= (others=>'0');
    ---
    
    hle_inst_row: rowHle
    port map(
        clk_i => clk_i,
        reset_i => reset_i,
        ready_i => ready_i,
        
        -- PRs
        PRH_i => PRH_i,
        PRV_i => PRV_i,
        valid_pr_i => valid_pr_i,
        num_block_pr_i => num_block_pr_i,
        
        -- Data from memory
        DS_i => ds_ds,
        switch_ds_hle_i => switch_ds_hle,
        addr_r_hle_o => addr_r_hle_ds,
        
        -- Access to hop cache
        address_block_a_o => address_block_a_hop1,
        address_block_b_o => address_block_a_hop2,
        
        req_block_a_o => req_block_a_hop1,
        req_block_b_o => req_block_a_hop2,
        
        valid_block_a_i => valid_block_a_hop1,
        valid_block_b_i => valid_block_a_hop2,
        
        data_block_a_i => data_block_a_hop,
        data_block_b_i => data_block_b_hop,
        
        -- Results out
        hops_vector_o => hops_vector_row,
        ppp_vector_o => ppp_vector_row,
        luma_vector_o => luma_vector_row,
        valid_hop_o => valid_hop_row,
        ready_hop_o => ready_hop_row
    );
    
    address_block_a_hop <= address_block_a_hop2 & address_block_a_hop1;
    req_block_a_hop <= req_block_a_hop2 & req_block_a_hop1;
    
    address_block_b_hop <= (others=>(others=>'0'));
    req_block_b_hop <= (others=>'0');
    
    valid_block_a_hop1 <= valid_block_a_hop(SIZE_H_BK/2-1 downto 0);
    valid_block_a_hop2 <= valid_block_a_hop(SIZE_H_BK-1 downto SIZE_H_BK/2);
    
--    --
--    hop_inst: hopCache
--    generic map (SIZE_CACHE_VECTOR => SIZE_H_BK/2)
--    port map (
--        clk_i => clk_i,
--        reset_i => reset_i,
    
--        address_block_a_i => address_block_a_hop1,
--        address_block_b_i => address_block_a_hop2,
    
--        req_block_a_i => req_block_a_hop1, 
--        req_block_b_i => req_block_a_hop2,
    
--        valid_block_a_o => valid_block_a_hop1,
--        valid_block_b_o => valid_block_a_hop2,
    
--        data_block_a_o => data_block_a_hop,
--        data_block_b_o => data_block_b_hop
--    );
    
    hop_inst: hopCache
    generic map (SIZE_CACHE_VECTOR => SIZE_H_BK)
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
    
        address_block_a_i => address_block_a_hop,
        address_block_b_i => address_block_b_hop,
    
        req_block_a_i => req_block_a_hop, 
        req_block_b_i => req_block_b_hop,
    
        valid_block_a_o => valid_block_a_hop,
        valid_block_b_o => open,
    
        data_block_a_o => data_block_a_hop,
        data_block_b_o => data_block_b_hop
    );
    ----
    mem_inst: hopMemBlockmem2
    generic map (NUMBER_MEMORIES => SIZE_H_BK)
    port map (
        clk_i => clk_i,
        reset_i => reset_internal,
        user_i => user_hopmem,
        arm_i => arm_internal,
--        user_temp_i => user_i,
        
        hop_i => hops_vector_row,
        valid_hop_i => valid_hop_mem,
        ready_hop_i => ready_hop_row,
        mem_block_i => mem_block_ds,
        
        read_addr_i => hopmem_addr,
        hop_read_o => hopmem_hop,
        
        valid_rw_o => hopmem_valid_rw,
        mem_full_o => hopmem_full,
        mem_empty_o => hopmem_empty
    );
    
    --user_hopmem <= '1' when (num_block_i=x"00" and num_pixel_i=x"00" and num_line_i=x"00") else '0';
    user_hopmem <=user_i; -- first_hop_block and not first_hop_block_1cycle;
    valid_hop_mem <= valid_hop_row;-- when (current_memblock_u=x"00") else zeros;
               
    ----
    ones_info <= (others=>'1');
    
    info_inst: hopStreamInfo
    port map (
        clk_i => clk_i,
        reset_i => reset_internal,
        user_i => user_hopmem,
        arm_i => arm_internal,
        
        first_luma_i => luma_vector_row,
        ppp_i => ppp_vector_row,
        valid_i => valid_hop_mem,
        sw_i => ones_info, -- CHECK THIS !!! ---
        ready_hop_i => ready_hop_row,
        
        num_block_i => num_block_info,
        first_luma_o => first_luma_info,
        ppp_o => ppp_info
    );
    
    -- Count current block
    -- Logic to decide when to change memory
    mem_next_proc: process (clk_i, reset_i)
    begin
        if (reset_i='0') then
            memory_state_current <= IDLE;
        elsif (rising_edge(clk_i)) then
            memory_state_current <= memory_state_next;
        end if;
    end process;
        
    mem_state_proc: process(memory_state_current, ready_hop_row)
    begin
        case memory_state_current is
            when IDLE =>
                if (ready_hop_row=ones) then
                    memory_state_next <= IDLE;
                else
                    memory_state_next <= WAIT_UP;
                end if;
            when WAIT_UP =>
                if (ready_hop_row=ones) then
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
            current_memblock_u <= x"00";
        elsif (rising_edge(clk_i)) then
            if (memory_state_current=CHANGE_MEM) then
                if (current_memblock_u=to_unsigned(SIZE_V_BK-1, 8)) then
                    current_memblock_u <= x"00";
                else
                    current_memblock_u <= current_memblock_u + 1;
                end if;
                
            end if;
        end if;
    end process;
    
    first_hop_block <= '1' when (current_memblock_u=x"00") else '0';
    
    firstbk_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            first_hop_block_1cycle <= first_hop_block;
        end if;
    end process;
    
    ----
    -- Interface to the Microcontroller
    -- In
    hopmem_addr <= gpio_i(14 downto 0);
    num_block_info <= gpio_i(7 downto 0);--gpio_i(23 downto 16);
    arm_internal <= gpio_i(23);
    reset_uc <= gpio_i(24);
    
    -- Out
    gpio_o(7 downto 0) <= hopmem_hop(7 downto 0);
    gpio_o(15 downto 8) <= first_luma_info;
    gpio_o(19 downto 16) <= ppp_info;
    gpio_o(20) <= hopmem_hop(8);
    gpio_o(29) <= hopmem_valid_rw;
    gpio_o(30) <= hopmem_empty;
    gpio_o(31) <= hopmem_full;

end Behavioral;
