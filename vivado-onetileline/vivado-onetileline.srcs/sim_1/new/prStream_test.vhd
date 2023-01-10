----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/16/2022 04:29:51 PM
-- Design Name: 
-- Module Name: prStream_test - Behavioral
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


entity prStream_test is
--  Port ( );
end prStream_test;

architecture Behavioral of prStream_test is
    component prStream is
      Port ( clk_i : in STD_LOGIC;
             reset_i : in STD_LOGIC;
             demo_i : in STD_LOGIC;
             s_axis_video_tdata : in STD_LOGIC_VECTOR (23 downto 0);
             s_axis_video_tvalid : in STD_LOGIC;
             s_axis_video_tready : out STD_LOGIC;
             s_axis_video_tuser : in STD_LOGIC;
             s_axis_video_tlast : in STD_LOGIC;
             m_axis_video_tdata : out STD_LOGIC_VECTOR (23 downto 0);
             Y_i                : in STD_LOGIC_VECTOR(7 downto 0);
             num_pixel_i : in STD_LOGIC_VECTOR(11 downto 0);
             num_line_i : in STD_LOGIC_VECTOR(11 downto 0);
             num_block_i : in STD_LOGIC_VECTOR(11 downto 0);
             num_block_v_i : in STD_LOGIC_VECTOR(11 downto 0);
             m_axis_video_tvalid : out STD_LOGIC;
             m_axis_video_tready : in STD_LOGIC;
             m_axis_video_tuser : out STD_LOGIC;
             m_axis_video_tlast : out STD_LOGIC );
    end component;
    
    signal clk_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal demo_i : STD_LOGIC;
    signal s_axis_video_tdata : STD_LOGIC_VECTOR (23 downto 0);
    signal s_axis_video_tvalid : STD_LOGIC;
    signal s_axis_video_tready : STD_LOGIC;
    signal s_axis_video_tuser : STD_LOGIC;
    signal s_axis_video_tlast : STD_LOGIC;
    signal m_axis_video_tdata : STD_LOGIC_VECTOR (23 downto 0);
    signal Y_i                : STD_LOGIC_VECTOR(7 downto 0);
    signal num_pixel_i : STD_LOGIC_VECTOR(11 downto 0);
    signal num_line_i : STD_LOGIC_VECTOR(11 downto 0);
    signal num_block_i : STD_LOGIC_VECTOR(11 downto 0);
    signal num_block_v_i : STD_LOGIC_VECTOR(11 downto 0);
    signal m_axis_video_tvalid : STD_LOGIC;
    signal m_axis_video_tready : STD_LOGIC;
    signal m_axis_video_tuser : STD_LOGIC;
    signal m_axis_video_tlast : STD_LOGIC;
    
    signal Y_i_u : unsigned(7 downto 0) := "00000000";
    signal num_pixel_u, num_line_u : unsigned(11 downto 0) := "000000100111";--"000000111100";
    signal num_block_u, num_block_v_u : unsigned(11 downto 0) := "000000000000";

    constant clk_period : time := 6ns;
    
begin

    test_inst: prStream
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        demo_i => '0',
        s_axis_video_tdata => s_axis_video_tdata,
        s_axis_video_tvalid => s_axis_video_tvalid,
        s_axis_video_tready => s_axis_video_tready,
        s_axis_video_tuser => s_axis_video_tuser,
        s_axis_video_tlast => s_axis_video_tlast,
        m_axis_video_tdata => m_axis_video_tdata,
        Y_i => Y_i,
        num_pixel_i => num_pixel_i,
        num_line_i => num_line_i,
        num_block_i => num_block_i,
        num_block_v_i => num_block_v_i,
        m_axis_video_tvalid => m_axis_video_tvalid,
        m_axis_video_tready => m_axis_video_tready,
        m_axis_video_tuser => m_axis_video_tuser,
        m_axis_video_tlast => m_axis_video_tlast
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
    
    y_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            Y_i_u <= Y_i_u + "00001000";
            
            if (num_pixel_u=to_unsigned(SIZE_BLOCK_H-1,12)) then
                num_pixel_u <= "000000000000";
                if (num_block_u=to_unsigned(SIZE_H_BK-1,12)) then
                    num_block_u <= "000000000000";
                else
                    num_block_u <= num_block_u + 1;
                end if;
            else
                num_pixel_u <= num_pixel_u + 1;
            end if;
            
--            if (num_block_u=to_unsigned(SIZE_H_BK,12) and num_pixel_u=to_unsigned(SIZE_BLOCK_H,12)) then
--                num_block_u <= "000000000000";
--            elsif (num_pixel_u=to_unsigned(SIZE_BLOCK_H,12)) then
--                num_block_u <= num_block_u + 1;
--            end if;
            
            
            if (num_block_u=to_unsigned(SIZE_H_BK-1,12) and num_pixel_u=to_unsigned(SIZE_BLOCK_H-1,12)) then
                if (num_line_u=to_unsigned(SIZE_BLOCK_V-1,12)) then
                    num_line_u <= "000000000000";
                    if (num_block_v_u="000000001011") then
                        num_block_v_u <= "000000000000";
                    else
                        num_block_v_u <= num_block_v_u + 1;  
                    end if;
                else
                    num_line_u <= num_line_u + 1;
                end if;
            end if;
        end if;
    end process;
    
    Y_i <= std_logic_vector(Y_i_u);
    num_pixel_i <= std_logic_vector(num_pixel_u);
    num_line_i <= std_logic_vector(num_line_u);
    num_block_i <= std_logic_vector(num_block_u);
    num_block_v_i <= std_logic_vector(num_block_v_u);
    
    -- Video stream
    s_axis_video_tdata <= Y_i & Y_i & Y_i;
    
    s_axis_video_tvalid <= '1';
    
    m_axis_video_tready <= '1';
    
    valid_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            if (num_pixel_u="000000000000" and num_block_u="000000000000") then
                    s_axis_video_tuser <= '1';
            else
                    s_axis_video_tuser <= '0';
            end if;
            
            if (num_block_u=to_unsigned(SIZE_H_BK-1,12) and
                num_pixel_u=to_unsigned(SIZE_BLOCK_H-1,12) and
                num_line_u=to_unsigned(SIZE_BLOCK_V-1,12)) then
                    s_axis_video_tlast <= '1';
            else
                    s_axis_video_tlast <= '0';
            end if;
        end if;
    end process;


end Behavioral;
