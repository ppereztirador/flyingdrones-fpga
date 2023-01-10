----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/10/2022 12:34:51 PM
-- Design Name: 
-- Module Name: fixed_image_test - Behavioral
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

entity fixed_image_test is
--  Port ( );
end fixed_image_test;

architecture Behavioral of fixed_image_test is
    component fixed_image is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               
               s_axis_video_tdata : in STD_LOGIC_VECTOR (31 downto 0);
               s_axis_video_tvalid : in STD_LOGIC;
               s_axis_video_tready : out STD_LOGIC;
               s_axis_video_tuser : in STD_LOGIC;
               s_axis_video_tlast : in STD_LOGIC;
               m_axis_video_tdata : out STD_LOGIC_VECTOR (31 downto 0);
             
               m_axis_video_tvalid : out STD_LOGIC;
               m_axis_video_tready : in STD_LOGIC;
               m_axis_video_tuser : out STD_LOGIC;
               m_axis_video_tlast : out STD_LOGIC);
    end component;
    
    signal clk_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
               
    signal s_axis_video_tdata : STD_LOGIC_VECTOR (31 downto 0);
    signal s_axis_video_tvalid : STD_LOGIC;
    signal s_axis_video_tready : STD_LOGIC;
    signal s_axis_video_tuser, s_axis_video_tuser_gen : STD_LOGIC := '0';
    signal s_axis_video_tlast, s_axis_video_tlast_gen : STD_LOGIC := '0';
    signal m_axis_video_tdata : STD_LOGIC_VECTOR (31 downto 0);
    
    signal m_axis_video_tvalid : STD_LOGIC;
    signal m_axis_video_tready : STD_LOGIC;
    signal m_axis_video_tuser : STD_LOGIC;
    signal m_axis_video_tlast : STD_LOGIC;
    
    constant clk_period : time := 6 ns; 
begin

    test_inst: fixed_image
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
        m_axis_video_tlast => m_axis_video_tlast
    );
    
    --
    -- clk process
    clk_proc: process
    begin
        clk_i <= '1';
        wait for clk_period/2;
        clk_i <= '0';
        wait for clk_period/2;
    end process;
    
    -- reset process
    rst_proc: process
    begin
        reset_i <= '0';
        wait for 2*clk_period;
        reset_i <= '1';
        wait;
    end process;
    
    -- signals
    s_axis_video_tdata <= (others => '1');
    s_axis_video_tvalid <= '1';
    
    user_proc: process
    begin
        s_axis_video_tuser_gen <= '1';
        wait for clk_period;
        s_axis_video_tuser_gen <= '0';
        wait for clk_period*307200;
    end process;
    
    s_axis_video_tuser <= transport s_axis_video_tuser_gen after 5*clk_period;
    
    last_proc: process
    begin
        s_axis_video_tlast_gen <= '0';
        wait for clk_period*640;
        s_axis_video_tlast_gen <= '1';
        wait for clk_period;
    end process;
    
    s_axis_video_tlast <= transport s_axis_video_tlast_gen after 5*clk_period;
    
    m_axis_video_tready <= '1';



end Behavioral;
