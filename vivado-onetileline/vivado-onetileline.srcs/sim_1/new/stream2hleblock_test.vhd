----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/21/2021 12:21:51 PM
-- Design Name: 
-- Module Name: stream2hleblock_test - Behavioral
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

entity stream2hleblock_test is
--  Port ( );
end stream2hleblock_test;

architecture Behavioral of stream2hleblock_test is

    component stream2hleblock is
        Port ( clk_i : in STD_LOGIC;
        reset_i : in STD_LOGIC;
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
        num_pixel_o : out STD_LOGIC_VECTOR(11 downto 0);
        num_line_o : out STD_LOGIC_VECTOR(11 downto 0);
        num_block_o : out STD_LOGIC_VECTOR(11 downto 0);
        num_block_v_o : out STD_LOGIC_VECTOR(11 downto 0);
        num_pixel_adv_o : out STD_LOGIC_VECTOR(11 downto 0);
        num_block_adv_o : out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;

    signal clk_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal s_axis_video_tdata : STD_LOGIC_VECTOR (23 downto 0);
    signal valid_gen, s_axis_video_tvalid : STD_LOGIC;
    signal s_axis_video_tready : STD_LOGIC;
    signal user_gen, s_axis_video_tuser : STD_LOGIC;
    signal last_gen, s_axis_video_tlast : STD_LOGIC;
    signal m_axis_video_tdata : STD_LOGIC_VECTOR (23 downto 0);
    signal m_axis_video_tvalid : STD_LOGIC;
    signal ready_gen, m_axis_video_tready : STD_LOGIC;
    signal m_axis_video_tuser : STD_LOGIC;
    signal m_axis_video_tlast : STD_LOGIC;
    
    signal num_pixel_o : STD_LOGIC_VECTOR(11 downto 0);
    signal num_line_o : STD_LOGIC_VECTOR(11 downto 0);
    signal num_block_o : STD_LOGIC_VECTOR(11 downto 0);
    signal num_block_v_o : STD_LOGIC_VECTOR(11 downto 0);
    signal num_pixel_adv_o : STD_LOGIC_VECTOR(11 downto 0);
    signal num_block_adv_o : STD_LOGIC_VECTOR(11 downto 0);
    
    constant clk_period : time := 6 ns; 
begin

    test_inst: stream2hleblock
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        s_axis_video_tdata => s_axis_video_tdata,
        s_axis_video_tvalid => s_axis_video_tvalid,
        s_axis_video_tready => s_axis_video_tready,
        s_axis_video_tuser => s_axis_video_tuser,
        s_axis_video_tlast => s_axis_video_tlast,
        m_axis_video_tdata => m_axis_video_tdata,
        m_axis_video_tvalid => m_axis_video_tvalid,
        m_axis_video_tready => m_axis_video_tready,
        m_axis_video_tuser => m_axis_video_tuser,
        m_axis_video_tlast => m_axis_video_tlast,
        num_pixel_o => num_pixel_o,
        num_line_o => num_line_o,
        num_block_o => num_block_o,
        num_block_v_o => num_block_v_o,
        num_pixel_adv_o => num_pixel_adv_o,
        num_block_adv_o => num_block_adv_o
    );
    
    -- clk process
    clk_proc: process
    begin
        clk_i <= '1';
        wait for clk_period/2;
        clk_i <= '0';
        wait for clk_period/2;
    end process;
    
    -- signals
    reset_proc: process
    begin
        reset_i <= '0';
        wait for 3*clk_period;
        reset_i <= '1';
        wait;
    end process;
    
    s_axis_video_tdata <= (others => '1');
--    s_axis_video_tvalid <= '1';
    
--    user_proc: process
--    begin
--        s_axis_video_tuser <= '1';
--        wait for clk_period;
--        s_axis_video_tuser <= '0';
--        wait for clk_period*307199;--921599;
--    end process;
    
--    last_proc: process
--    begin
--        s_axis_video_tlast <= '0';
--        wait for clk_period*639;
--        s_axis_video_tlast <= '1';
--        wait for clk_period;
--    end process;
    
--    m_axis_video_tready <= '1';

    valid_proc: process
    begin
        valid_gen <= '0';
        wait for 5*clk_period;
        valid_gen <= '1';
        wait for 4*clk_period;
        valid_gen <= '0';
        wait for 4*clk_period;
        valid_gen <= '1';
        wait for 14*clk_period;
        valid_gen <= '0';
        wait for clk_period;
        valid_gen <= '1';
        wait for 8*clk_period;
        valid_gen <= '0';
        wait;
    end process;
    
    s_axis_video_tvalid <= transport valid_gen after 1 ps;
    
    ready_proc: process
    begin
        ready_gen <= '1';
        wait for 5*clk_period;
        ready_gen <= '1';
        wait for 11*clk_period;
        ready_gen <= '0';
        wait for 9*clk_period;
        ready_gen <= '1';
        wait;
    end process;
    
    m_axis_video_tready <= transport ready_gen after 1 ps;

    user_proc: process
    begin
        user_gen <= '0';
        wait for 3*clk_period;
        user_gen <= '1';
        wait for clk_period;
        user_gen <= '0';
        wait for 4*clk_period;
        user_gen <= '1';
        wait for 5*clk_period;
        user_gen <= '0';
        wait;
    end process;
    
    s_axis_video_tuser <= transport user_gen after 1 ps;
    
    last_proc: process
    begin
        last_gen <= '0';
        wait for 5*clk_period;
        last_gen <= '0';
        wait for 2*clk_period;
        last_gen <= '1';
        wait for clk_period;
        last_gen <= '0';
        wait;
    end process;
    
    s_axis_video_tlast <= transport last_gen after 1 ps;


end Behavioral;
