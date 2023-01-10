----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/21/2022 04:46:58 PM
-- Design Name: 
-- Module Name: rgb2yuv_test - Behavioral
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

entity rgb2yuv_test is
--  Port ( );
end rgb2yuv_test;

architecture Behavioral of rgb2yuv_test is

    component rgb2yuv is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               s_axis_video_tdata : in STD_LOGIC_VECTOR (23 downto 0);
               s_axis_video_tvalid : in STD_LOGIC;
               s_axis_video_tready : out STD_LOGIC;
               s_axis_video_tuser : in STD_LOGIC;
               s_axis_video_tlast : in STD_LOGIC;
               m_axis_video_tdata : out STD_LOGIC_VECTOR (23 downto 0);
               Y_o                : out STD_LOGIC_VECTOR(7 downto 0);
               m_axis_video_tvalid : out STD_LOGIC;
               m_axis_video_tready : in STD_LOGIC;
               m_axis_video_tuser : out STD_LOGIC;
               m_axis_video_tlast : out STD_LOGIC);
    end component;
    
    signal clk_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal s_axis_video_tdata, data_gen : STD_LOGIC_VECTOR (23 downto 0);
    signal valid_gen, s_axis_video_tvalid : STD_LOGIC;
    signal s_axis_video_tready : STD_LOGIC;
    signal user_gen, s_axis_video_tuser : STD_LOGIC;
    signal last_gen, s_axis_video_tlast : STD_LOGIC;
    signal m_axis_video_tdata : STD_LOGIC_VECTOR (23 downto 0);
    signal m_axis_video_tvalid : STD_LOGIC;
    signal ready_gen, m_axis_video_tready : STD_LOGIC;
    signal m_axis_video_tuser : STD_LOGIC;
    signal m_axis_video_tlast : STD_LOGIC;
    signal Y_o, Y_v : std_logic_vector(7 downto 0);
    signal Y_u : unsigned(7 downto 0) := "00000000";
    
    constant clk_period : time := 6ns;

begin

    test_inst: rgb2yuv
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        s_axis_video_tdata => s_axis_video_tdata,
        s_axis_video_tvalid => s_axis_video_tvalid,
        s_axis_video_tready => s_axis_video_tready,
        s_axis_video_tuser => s_axis_video_tuser,
        s_axis_video_tlast => s_axis_video_tlast,
        m_axis_video_tdata => m_axis_video_tdata,
        Y_o => Y_o,
        m_axis_video_tvalid => m_axis_video_tvalid,
        m_axis_video_tready => m_axis_video_tready,
        m_axis_video_tuser => m_axis_video_tuser,
        m_axis_video_tlast => m_axis_video_tlast
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
    
--    y_proc: process(clk_i)
--    begin
--        if (rising_edge(clk_i)) then
--            Y_u <= Y_u + "00000100";
--        end if;
--    end process;
--    Y_v <= transport std_logic_vector(Y_u) after 1 ps;
    
--    s_axis_video_tdata <= Y_v & Y_v & not Y_v;

    data_proc: process
    begin
        data_gen <= x"000000";
        wait for 5*clk_period;
        data_gen <= x"aeaeae"; -- p2
        wait for clk_period;
        data_gen <= x"aeaeae"; -- p1
        wait for clk_period;
        data_gen <= x"aeaeae"; -- last
        wait for clk_period;
        data_gen <= x"aeaeae"; -- 0
        wait for 5*clk_period;
        data_gen <= x"3e5847"; -- 1
        wait for clk_period;
        data_gen <= x"3e4c48"; -- 2
        wait for clk_period;
        data_gen <= x"474c47"; -- 3
        wait for clk_period;
        data_gen <= x"474745"; -- 4
        wait for 5*clk_period;
        data_gen <= x"4b4744"; -- 5
        wait for clk_period;
        data_gen <= x"4b4a44"; -- 6
        wait;
    end process;
    
    s_axis_video_tdata <= transport data_gen after 1 ps;

    
--    valid_proc: process
--    begin
--        valid_gen <= '0';
--        wait for 5*clk_period;
--        valid_gen <= '1';
--        wait for 4*clk_period;
--        valid_gen <= '0';
--        wait for 4*clk_period;
--        valid_gen <= '1';
--        wait for 14*clk_period;
--        valid_gen <= '0';
--        wait for clk_period;
--        valid_gen <= '1';
--        wait for 8*clk_period;
--        valid_gen <= '0';
--        wait;
--    end process;

    valid_proc: process
    begin
        valid_gen <= '0';
        wait for 5*clk_period;
        valid_gen <= '1';
        wait for 4*clk_period;
        valid_gen <= '0';
        wait for 4*clk_period;
        valid_gen <= '1';
        wait for 4*clk_period;
        valid_gen <= '0';
        wait for 4*clk_period;
        valid_gen <= '1';
        wait for 8*clk_period;
        valid_gen <= '0';
        wait;
    end process;
    
    s_axis_video_tvalid <= transport valid_gen after 1 ps;
    
--    ready_proc: process
--    begin
--        ready_gen <= '1';
--        wait for 5*clk_period;
--        ready_gen <= '1';
--        wait for 11*clk_period;
--        ready_gen <= '0';
--        wait for 9*clk_period;
--        ready_gen <= '1';
--        wait;
--    end process;

    ready_gen <= '1';
    
    m_axis_video_tready <= transport ready_gen after 1 ps;

--    user_proc: process
--    begin
--        user_gen <= '0';
--        wait for 3*clk_period;
--        user_gen <= '1';
--        wait for clk_period;
--        user_gen <= '0';
--        wait for 4*clk_period;
--        user_gen <= '1';
--        wait for 5*clk_period;
--        user_gen <= '0';
--        wait;
--    end process;

    user_gen <= '0';
    
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
