----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/21/2022 05:33:12 PM
-- Design Name: 
-- Module Name: pr_big_test_gpio - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.lhe_lib.ALL;

entity pr_big_test_gpio is
--  Port ( );
end pr_big_test_gpio;

architecture Behavioral of pr_big_test_gpio is
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

signal data_start2 : STD_LOGIC_VECTOR (23 downto 0);
signal valid_start2, ready_start2, user_start2, last_start2 : STD_LOGIC;

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
           valid_o : out STD_LOGIC;
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
signal valid_block, ready_block, user_block, last_block, valid_o_block : STD_LOGIC := '0';
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
component hopGpioWrapper is
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
end component;

signal gpio_i, gpio_o : std_logic_vector(31 downto 0);

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
        
        m_axis_video_tdata => data_start2,
        m_axis_video_tvalid => valid_start2,
        m_axis_video_tready => ready_start2,
        m_axis_video_tuser => user_start2,
        m_axis_video_tlast => last_start2
    );
    
    im_inst2: fixed_image
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        demo_i => '0',
        
        s_axis_video_tdata => data_start2,
        s_axis_video_tvalid => valid_start2,
        s_axis_video_tready => ready_start2,
        s_axis_video_tuser => user_start2,
        s_axis_video_tlast => last_start2,
        
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
        valid_o => valid_o_block,
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
    
    hop_inst: hopGpioWrapper
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        ready_i => ready_start,
        user_i => user_block,

        -- Data from cam
        num_pixel_i => num_pixel,
        num_line_i => num_line,
        num_block_i => num_block,
        num_block_v_i => num_block_v,
        Y_i => Y_block,
        valid_ds_i => valid_o_block,
        
        -- Hops
        PRH_i => prh_pr,
        PRV_i => prv_pr,
        valid_pr_i => validh_pr,
        num_block_pr_i => num_block_pr,
        num_block_v_pr_i => num_block_v_pr,

        -- ARM I/O
        gpio_i => gpio_i,
        gpio_o => gpio_o
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

    -- Control signals
    gpio_proc: process
    begin
        gpio_i <= x"00000000";
        wait for 3 ms;
        gpio_i <= x"00800000";--x"FFFFFFFF";
        wait for 3*clk_period;
        gpio_i <= x"00000000";
        wait for 33.2 ms;--3*clk_period;
        gpio_i <= x"00000001";
        wait for 3*clk_period;
        gpio_i <= x"00000002";
        wait for 3*clk_period;
        gpio_i <= x"00000003";
        wait for 3*clk_period;
        wait;
    end process;
    
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
        wait for 33336237.06 ns-2*clk_period;
        user_gen <= '1';
        wait for clk_period;
        user_gen <= '0';
        wait for 33336237.06 ns;
        user_gen <= '1';
        wait for clk_period;
        user_gen <= '0';
        wait for 33336237.06 ns;
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
        wait for 10427*clk_period;--wait for 6945*clk_period;
        
    end process;
    
    --valid_gen <= '1';
    
    valid_proc: process
    begin
        valid_gen <= '1';
        wait for 640*clk_period;-- For 720p: wait for 1280*clk_period;
        valid_gen <= '0';
        wait for 9788*clk_period;-- For 720p: wait for 5664*clk_period;
    end process;

end Behavioral;
