----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/25/2022 12:41:08 PM
-- Design Name: 
-- Module Name: pr_big_test - Behavioral
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

entity pr_big_test is
--  Port ( );
end pr_big_test;

architecture Behavioral of pr_big_test is

signal clk_i, reset_i, demo_i : std_logic;

--
component fixed_image is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           demo_i : in STD_LOGIC;
           
           s_axis_video_tdata : in STD_LOGIC_VECTOR (23 downto 0);
           s_axis_video_tvalid : in STD_LOGIC;
           s_axis_video_tready : out STD_LOGIC;
           s_axis_video_tuser : in STD_LOGIC;
           s_axis_video_tlast : in STD_LOGIC;
           
           m_axis_video_tdata : out STD_LOGIC_VECTOR (23 downto 0);
           m_axis_video_tvalid : out STD_LOGIC;
           m_axis_video_tready : in STD_LOGIC;
           m_axis_video_tuser : out STD_LOGIC;
           m_axis_video_tlast : out STD_LOGIC);
end component;

signal data_start : STD_LOGIC_VECTOR (23 downto 0);
signal valid_start, ready_start, user_start, last_start : STD_LOGIC;

signal data_image : STD_LOGIC_VECTOR (23 downto 0);
signal valid_image, ready_image, user_image, last_image: STD_LOGIC;

--

component stream2hleblock is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           demo_i : in STD_LOGIC;
           s_axis_video_tdata : in STD_LOGIC_VECTOR (23 downto 0);
           s_axis_video_tvalid : in STD_LOGIC;
           s_axis_video_tready : out STD_LOGIC;
           s_axis_video_tuser : in STD_LOGIC;
           s_axis_video_tlast : in STD_LOGIC;
           m_axis_video_tdata : out STD_LOGIC_VECTOR (23 downto 0);
           m_axis_video_tvalid : out STD_LOGIC;
           m_axis_video_tready : in STD_LOGIC;
           m_axis_video_tuser : out STD_LOGIC;
           m_axis_video_tlast : out STD_LOGIC;
           Y_o : out STD_LOGIC_VECTOR(7 downto 0);
           num_pixel_o : out STD_LOGIC_VECTOR(7 downto 0);
           num_pixel_full_o : out STD_LOGIC_VECTOR(9 downto 0);
           num_line_o : out STD_LOGIC_VECTOR(7 downto 0);
           num_block_o : out STD_LOGIC_VECTOR(7 downto 0);
           num_block_v_o : out STD_LOGIC_VECTOR(7 downto 0);
           num_pixel_adv_o : out STD_LOGIC_VECTOR(7 downto 0);
           num_block_adv_o : out STD_LOGIC_VECTOR(7 downto 0)
           );
end component;

signal data_block : STD_LOGIC_VECTOR (23 downto 0);
signal valid_block, ready_block, user_block, last_block : STD_LOGIC := '0';
signal Y_block : STD_LOGIC_VECTOR (7 downto 0);
signal num_block, num_block_v, num_pixel, num_line : STD_LOGIC_VECTOR(7 downto 0);
signal num_pixel_full : STD_LOGIC_VECTOR(9 downto 0);
signal num_block_adv, num_pixel_adv : STD_LOGIC_VECTOR(7 downto 0);  

--

component prStreamHV is
  Port ( clk_i : in STD_LOGIC;
         reset_i : in STD_LOGIC;
         demo_i : in STD_LOGIC;
         hv_i : in STD_LOGIC;
         s_axis_video_tdata : in STD_LOGIC_VECTOR (23 downto 0);
         s_axis_video_tvalid : in STD_LOGIC;
         s_axis_video_tready : out STD_LOGIC;
         s_axis_video_tuser : in STD_LOGIC;
         s_axis_video_tlast : in STD_LOGIC;
         m_axis_video_tdata : out STD_LOGIC_VECTOR (23 downto 0);
         Y_i                : in STD_LOGIC_VECTOR(7 downto 0);
         num_pixel_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_pixel_adv_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_line_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_block_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_block_adv_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_block_v_i : in STD_LOGIC_VECTOR(7 downto 0);
         
         PRh_o : out STD_LOGIC_VECTOR(2 downto 0);
         PRv_o : out STD_LOGIC_VECTOR(2 downto 0);
         valid_prh_o : out STD_LOGIC;
         valid_prv_o : out STD_LOGIC;
         num_block_pr_o : out STD_LOGIC_VECTOR(7 downto 0);
         num_block_v_pr_o : out STD_LOGIC_VECTOR(7 downto 0);
         
         m_axis_video_tvalid : out STD_LOGIC;
         m_axis_video_tready : in STD_LOGIC;
         m_axis_video_tuser : out STD_LOGIC;
         m_axis_video_tlast : out STD_LOGIC );
end component;

signal data_pr: STD_LOGIC_VECTOR (23 downto 0);
signal valid_pr, ready_pr, user_pr, last_pr : STD_LOGIC;
signal prh_pr, prv_pr : std_logic_vector(2 downto 0);
signal validh_pr, validv_pr : STD_LOGIC;
signal hv_i : STD_LOGIC := '0';
signal num_block_pr, num_block_v_pr : STD_LOGIC_VECTOR(7 downto 0);

--
--component downsampleStream is
--    Port (clk_i : in STD_LOGIC;
--          reset_i : in STD_LOGIC;
--          demo_i : in STD_LOGIC;

--          s_axis_video_tdata : in STD_LOGIC_VECTOR (23 downto 0);
--          s_axis_video_tvalid : in STD_LOGIC;
--          s_axis_video_tready : out STD_LOGIC;
--          s_axis_video_tuser : in STD_LOGIC;
--          s_axis_video_tlast : in STD_LOGIC;
          
--          Y_i                : in STD_LOGIC_VECTOR(7 downto 0);
--          num_pixel_i : in STD_LOGIC_VECTOR(7 downto 0);
--          num_line_i : in STD_LOGIC_VECTOR(7 downto 0);
--          num_block_i : in STD_LOGIC_VECTOR(7 downto 0);
--          num_block_v_i : in STD_LOGIC_VECTOR(7 downto 0);
         
--          PRh_i : in STD_LOGIC_VECTOR(2 downto 0);
--          PRv_i : in STD_LOGIC_VECTOR(2 downto 0);
--          valid_prh_i : in STD_LOGIC;
--          valid_prv_i : in STD_LOGIC;
--          num_block_pr_i : in STD_LOGIC_VECTOR(7 downto 0);
--          num_block_v_pr_i : in STD_LOGIC_VECTOR(7 downto 0);
         
--          m_axis_video_tdata : out STD_LOGIC_VECTOR (23 downto 0);
--          m_axis_video_tvalid : out STD_LOGIC;
--          m_axis_video_tready : in STD_LOGIC;
--          m_axis_video_tuser : out STD_LOGIC;
--          m_axis_video_tlast : out STD_LOGIC);
--end component;

--signal data_ds: STD_LOGIC_VECTOR (23 downto 0);
--signal valid_ds, ready_ds, user_ds, last_ds : STD_LOGIC;

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
           num_block_v_pr_i: in STD_LOGIC_VECTOR(7 downto 0);
           
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

signal valid_ds_0i, valid_ds_single : STD_LOGIC;
signal switch_y_ds_0i : STD_LOGIC;
signal switch_ds_hle_0i : STD_LOGIC;
signal addr_r_ds_0i : STD_LOGIC_VECTOR(14 downto 0) := "000000000000000";
signal addr_r_ds_0gen : UNSIGNED(15 downto 0) := x"0000";
signal Y_0o : STD_LOGIC_VECTOR(7 downto 0);
signal zero_addr : STD_LOGIC_VECTOR(14 downto 0) := "000000000000000";
signal zero_data : STD_LOGIC_VECTOR(7 downto 0) := "00000000";

signal valid_pr_ds, ready_ds : std_logic;

signal switch_ds_hle_ds : STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
signal addr_r_hle_ds : vector_array_ds_address(SIZE_H_BK-1 downto 0);
signal addr_r_hle_ds_u : unsigned(10 downto 0);
signal DS_ds : vector_array_ds_data(SIZE_H_BK-1 downto 0);
--

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
           ready_o : out STD_LOGIC);
end component;

signal valid_pr_hle_single : std_logic;
signal hop_hle : std_logic_vector(3 downto 0);
signal first_luma_hle : std_logic_vector(7 downto 0);
signal pppx_hle, pppy_hle : std_logic_vector(1 downto 0);
signal ready_hle : std_logic;

signal addr_hop : std_logic_vector(17 downto 0);
signal req_hop : std_logic;
signal valid_hop : std_logic;
signal value_hop : std_logic_vector(11 downto 0);
--
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
signal address_block_b_hop1, address_block_b_hop2 : vector_array_hop_address(SIZE_H_BK/2-1 downto 0);
signal address_block_a_hop, address_block_b_hop : vector_array_hop_address(SIZE_H_BK-1 downto 0);

signal req_block_a_hop1, req_block_a_hop2 : std_logic_vector(SIZE_H_BK/2-1 downto 0);
signal req_block_b_hop1, req_block_b_hop2 : std_logic_vector(SIZE_H_BK/2-1 downto 0);
signal req_block_a_hop, req_block_b_hop : std_logic_vector(SIZE_H_BK-1 downto 0);

signal valid_block_a_hop1, valid_block_a_hop2 : std_logic_vector(SIZE_H_BK/2-1 downto 0);
signal valid_block_b_hop1, valid_block_b_hop2 : std_logic_vector(SIZE_H_BK/2-1 downto 0);
signal valid_block_a_hop, valid_block_b_hop : std_logic_vector(SIZE_H_BK-1 downto 0);

signal data_block_a_hop : std_logic_vector(11 downto 0);
signal data_block_b_hop : std_logic_vector(11 downto 0);
--
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
signal hops_vector_row, hops_vector_row2 : vector_array_4(SIZE_H_BK-1 downto 0);
signal ppp_vector_row, ppp_vector_row2 : vector_array_4(SIZE_H_BK-1 downto 0);
signal luma_vector_row, luma_vector_row2 : vector_array_8(SIZE_H_BK-1 downto 0);
signal valid_hop_row, valid_hop_row2 : std_logic_vector(SIZE_H_BK-1 downto 0);
signal ready_hop_row, ready_hop_row2 : std_logic_vector(SIZE_H_BK-1 downto 0);

--
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

signal mem_block_mmds : std_logic;
--

constant clk_period : time := 6.66 ns; --6ns;
signal user_gen, last_gen, valid_gen : std_logic := '0';


begin

im_inst: fixed_image
port map (
    clk_i => clk_i,
    reset_i => reset_i,
    demo_i => demo_i,
    
    s_axis_video_tdata => data_start,
    s_axis_video_tvalid => valid_start,
    s_axis_video_tready => ready_start,
    s_axis_video_tuser => user_start,
    s_axis_video_tlast => last_start,
    
    m_axis_video_tdata => data_image,
    m_axis_video_tvalid => valid_image,
    m_axis_video_tready => ready_image,
    m_axis_video_tuser => user_image,
    m_axis_video_tlast => last_image
);

block_inst: stream2hleblock
port map (
    clk_i => clk_i,
    reset_i => reset_i,
    demo_i => demo_i,
    s_axis_video_tdata => data_image,
    s_axis_video_tvalid => valid_image,
    s_axis_video_tready => ready_image,
    s_axis_video_tuser => user_image,
    s_axis_video_tlast => last_image,
    m_axis_video_tdata => data_block,
    m_axis_video_tvalid => valid_block,
    m_axis_video_tready => ready_block,
    m_axis_video_tuser => user_block,
    m_axis_video_tlast => last_block,
    Y_o => y_block,
    num_pixel_o => num_pixel,
    num_pixel_full_o => num_pixel_full,
    num_line_o => num_line,
    num_block_o => num_block,
    num_block_v_o => num_block_v,
    num_pixel_adv_o => num_pixel_adv,
    num_block_adv_o => num_block_adv
);

pr_inst: prStreamHV
port map(
    clk_i => clk_i,
    reset_i => reset_i,
    demo_i => demo_i,
    hv_i => hv_i,
    s_axis_video_tdata => data_block,
    s_axis_video_tvalid => valid_block,
    s_axis_video_tready => ready_block,
    s_axis_video_tuser => user_block,
    s_axis_video_tlast => last_block,
    m_axis_video_tdata => data_pr,
    Y_i => y_block,
    num_pixel_i => num_pixel,
    num_pixel_adv_i => num_pixel_adv,
    num_line_i => num_line,
    num_block_i => num_block,
    num_block_adv_i => num_block_adv,
    num_block_v_i => num_block_v,
    
    PRh_o => prh_pr,
    PRv_o => prv_pr,
    valid_prh_o => validh_pr,
    valid_prv_o => validv_pr,
    num_block_pr_o => num_block_pr,
    num_block_v_pr_o => num_block_v_pr,
    
    m_axis_video_tvalid => valid_pr,
    m_axis_video_tready => ready_pr,
    m_axis_video_tuser => user_pr,
    m_axis_video_tlast => last_pr
);


-- Addresses for mem0
--mem0_addr_proc: process(clk_i)
--begin
--    if (rising_edge(clk_i)) then
--        if (addr_r_ds_0gen=x"63ff") then
--            addr_r_ds_0gen <= (others=>'0');
--        else
--            addr_r_ds_0gen <= addr_r_ds_0gen + 1;
--        end if;
--    end if;
--end process;

--addr_r_ds_0i <= transport std_logic_vector(addr_r_ds_0gen(14 downto 0)) after 25650.5*clk_period;


--ds_inst: downsampleStream
--port map (
--    clk_i => clk_i,
--    reset_i => reset_i,
--    demo_i => demo_i,
    
--    s_axis_video_tdata => data_pr,
--    s_axis_video_tvalid => valid_pr,
--    s_axis_video_tready => open,--ready_pr,
--    s_axis_video_tuser => user_pr,
--    s_axis_video_tlast => last_pr,
    
--    Y_i => y_block,
--    num_pixel_i => num_pixel,
--    num_line_i => num_line,
--    num_block_i => num_block,
--    num_block_v_i => num_block_v,
    
--    PRh_i => prh_pr,
--    PRv_i => prv_pr,
--    valid_prh_i => validh_pr,
--    valid_prv_i => validv_pr,
--    num_block_pr_i => num_block_pr,
--    num_block_v_pr_i => num_block_v_pr,
    
--    m_axis_video_tdata => data_ds,
--    m_axis_video_tvalid => valid_ds,
--    m_axis_video_tready => ready_ds,
--    m_axis_video_tuser => user_ds,
--    m_axis_video_tlast => last_ds
--);

--ds_inst: rowMemDownsample
--port map (
--    clk_i => clk_i,
--    reset_i => reset_i,
--    valid_i => valid_ds_0i,
--    ready_i => ready_start,
    
--    -- PRs
--    PRH_i => prh_pr,
--    PRV_i => prv_pr,
--    valid_pr_i => valid_pr_ds,
--    num_block_pr_i => num_block_pr,
    
--    -- Data from cam
--    num_pixel_i => num_pixel,
--    num_line_i => num_line,
--    num_block_i => num_block,
--    Y_i => Y_block,
    
--    -- Downsampled data out
--    switch_ds_hle_o => switch_ds_hle_ds,
--    addr_r_hle_i => addr_r_hle_ds,
--    DS_o => ds_ds
--);

ds_inst: multiMemDownsample
port map (
    clk_i => clk_i,
    reset_i => reset_i,
    valid_i => valid_ds_0i,
    ready_i => ready_start,
    user_i => user_image,
    
    ready_hop_i => ready_hop_row,
    
    -- PRs
    PRH_i => prh_pr,
    PRV_i => prv_pr,
    valid_pr_i => valid_pr_ds,
    num_block_pr_i => num_block_pr,
    num_block_v_pr_i => num_block_v_pr,
    
    -- Data from cam
    num_pixel_i => num_pixel,
    num_line_i => num_line,
    num_block_i => num_block,
    num_block_v_i => num_block_v,
    Y_i => Y_block,
    
    -- Downsampled data out
    switch_ds_hle_o => switch_ds_hle_ds,
    addr_r_hle_i => addr_r_hle_ds,
    DS_o => ds_ds
);

mmbk_test_inst: blockMultimemDownsample
port map (
    clk_i => clk_i,
    reset_i => reset_i,
    valid_i => valid_ds_single,
    ready_i => ready_start,
    user_i => user_image,
    mem_block_o => mem_block_mmds,
    
    -- PRs
    PRH_i => prh_pr,
    PRV_i => prv_pr,
    valid_pr_i => valid_pr_hle_single,
    
    -- Data from cam
    num_pixel_i => num_pixel,
    num_line_i => num_line,
    num_block_v_i => num_block_v,
    Y_i => Y_block,
    
    -- Data to HLE
    ready_hop_i => ready_hop_row(0),
    switch_ds_hle_o => open,
    addr_r_hle_i => addr_r_hle_ds(0),
    DS_o => open
);

--
--hle_inst: blockHle
--port map (
--    clk_i => clk_i,
--    reset_i => reset_i,
--    ready_i => ready_start,
    
--    -- PRs
--    PRH_i => prh_pr,
--    PRV_i => prv_pr,
--    valid_pr_i => valid_pr_hle_single,
    
--    -- Data from memory
--    DS_i => ds_ds(0),
--    switch_ds_hle_i => switch_ds_hle_ds(0),
--    addr_r_hle_o => addr_r_hle_ds(0),
    
--    -- Access to hop cache
--    addr_hop_o => address_block_a_hop(0),
--    req_hop_o => req_block_a_hop(0),
--    valid_hop_i => valid_hop,
--    value_hop_i => value_hop,
    
--    -- Results out
--    hop_o => hop_hle,
--    first_luma_o => first_luma_hle,
--    pppx_o => pppx_hle,
--    pppy_o => pppy_hle,
--    ready_o => ready_hle
--);

--address_block_a_hop(SIZE_H_BK/2-1 downto 1) <= (others => "00000000000000000");
--address_block_b_hop(SIZE_H_BK/2-1 downto 0) <= (others => "00000000000000000");

--req_block_a_hop(SIZE_H_BK/2-1 downto 1) <= (others => '0');
--req_block_b_hop(SIZE_H_BK/2-1 downto 0) <= (others => '0');

--valid_hop <= valid_block_a_hop(0);
--value_hop <= data_block_a_hop;

hle_inst_row: rowHle
port map(
    clk_i => clk_i,
    reset_i => reset_i,
    ready_i => ready_start,
    
    -- PRs
    PRH_i => prh_pr,
    PRV_i => prv_pr,
    valid_pr_i => valid_pr_ds,
    num_block_pr_i => num_block_pr,
    
    -- Data from memory
    DS_i => ds_ds,
    switch_ds_hle_i => switch_ds_hle_ds,
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
valid_block_a_hop1 <= valid_block_a_hop(SIZE_H_BK/2-1 downto 0);
valid_block_a_hop2 <= valid_block_a_hop(SIZE_H_BK-1 downto SIZE_H_BK/2);

address_block_b_hop <= address_block_b_hop2 & address_block_b_hop1;
req_block_b_hop <= req_block_b_hop2 & req_block_b_hop1;
valid_block_b_hop <= valid_block_b_hop2 & valid_block_b_hop1;

address_block_b_hop1 <= (others => (others=>'0'));
address_block_b_hop2 <= (others => (others=>'0'));
req_block_b_hop1 <= (others => '0');
req_block_b_hop2 <= (others => '0');
valid_block_b_hop1 <= (others => '0');
valid_block_b_hop2 <= (others => '0');

--
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
    valid_block_b_o => valid_block_b_hop,

    data_block_a_o => data_block_a_hop,
    data_block_b_o => data_block_b_hop
);
--

--addr_r_ds_0i <= transport std_logic_vector(addr_r_ds_0gen(14 downto 0)) after 25650.5*clk_period;

valid_ds_0i <= valid_image;-- when (num_block=x"00") else '0';
valid_pr_ds <= validh_pr;-- when (num_block_v_pr(0)='0') else '0';
valid_pr_hle_single <= validh_pr  when (num_block_pr=x"00") else '0';
valid_ds_single <= valid_image when (num_block=x"00") else '0';
--switch_y_ds_0i <= '1' when (addr_r_ds_0i/="000000000000000") else '0'; -- process
switch_ds_hle_0i <= '0';

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
    
-- Control signals
data_start <= x"000000";
valid_start <= transport valid_gen after 9.5*clk_period - 1 ps;
ready_pr <= '1';
ready_ds <= '1'; -- !!!! REMEMBER TO PROPAGATE LATER !!!!
user_start <= transport user_gen after clk_period - 1 ps;
last_start <= transport last_gen after 9.5*clk_period - 1 ps;
demo_i <= '0';

user_proc: process
begin
    user_gen <= '0';
    wait for 9.5*clk_period;
    user_gen <= '1';
    wait for clk_period;
    user_gen <= '0';
    wait;
end process;

last_proc: process
begin
    last_gen <= '1';
    wait for clk_period;
    last_gen <= '0';
    --wait for 639*clk_period;
    wait for 10427*clk_period;
end process;

--valid_gen <= '1';

valid_proc: process
begin
    valid_gen <= '1';
    wait for 640*clk_period;
    valid_gen <= '0';
    wait for 9788*clk_period;
end process;

end Behavioral;
