----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/01/2022 10:56:49 AM
-- Design Name: 
-- Module Name: prStreamHV - Behavioral
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

entity prStreamHV is
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
end prStreamHV;

architecture Behavioral of prStreamHV is
    -- Attributes for clocks and resets (IP integrator)
    ATTRIBUTE X_INTERFACE_INFO : STRING; 
    ATTRIBUTE X_INTERFACE_INFO of clk_i: SIGNAL is "xilinx.com:signal:clock:1.0 clk_i CLK";
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER of clk_i : SIGNAL is "ASSOCIATED_RESET reset_i, FREQ_HZ 150000000";
    
     -- s_video
    ATTRIBUTE X_INTERFACE_INFO of s_axis_video_tdata: SIGNAL is "xilinx.com:signal:clock:1.0 clk_i CLK";
    ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_video_tdata : SIGNAL is "ASSOCIATED_RESET reset_i, FREQ_HZ 150000000";
    
    ATTRIBUTE X_INTERFACE_INFO of s_axis_video_tvalid: SIGNAL is "xilinx.com:signal:clock:1.0 clk_i CLK";
    ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_video_tvalid : SIGNAL is "ASSOCIATED_RESET reset_i, FREQ_HZ 150000000";
    
    ATTRIBUTE X_INTERFACE_INFO of s_axis_video_tready: SIGNAL is "xilinx.com:signal:clock:1.0 clk_i CLK";
    ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_video_tready : SIGNAL is "ASSOCIATED_RESET reset_i, FREQ_HZ 150000000";
    
    ATTRIBUTE X_INTERFACE_INFO of s_axis_video_tuser: SIGNAL is "xilinx.com:signal:clock:1.0 clk_i CLK";
    ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_video_tuser : SIGNAL is "ASSOCIATED_RESET reset_i, FREQ_HZ 150000000";
    
    ATTRIBUTE X_INTERFACE_INFO of s_axis_video_tlast: SIGNAL is "xilinx.com:signal:clock:1.0 clk_i CLK";
    ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_video_tlast : SIGNAL is "ASSOCIATED_RESET reset_i, FREQ_HZ 150000000";
    
     -- m_video
    ATTRIBUTE X_INTERFACE_INFO of m_axis_video_tdata: SIGNAL is "xilinx.com:signal:clock:1.0 clk_i CLK";
    ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_video_tdata : SIGNAL is "ASSOCIATED_RESET reset_i, FREQ_HZ 150000000";
    
    ATTRIBUTE X_INTERFACE_INFO of m_axis_video_tvalid: SIGNAL is "xilinx.com:signal:clock:1.0 clk_i CLK";
    ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_video_tvalid : SIGNAL is "ASSOCIATED_RESET reset_i, FREQ_HZ 150000000";
    
    ATTRIBUTE X_INTERFACE_INFO of m_axis_video_tready: SIGNAL is "xilinx.com:signal:clock:1.0 clk_i CLK";
    ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_video_tready : SIGNAL is "ASSOCIATED_RESET reset_i, FREQ_HZ 150000000";
        
    ATTRIBUTE X_INTERFACE_INFO of m_axis_video_tuser: SIGNAL is "xilinx.com:signal:clock:1.0 clk_i CLK";
    ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_video_tuser : SIGNAL is "ASSOCIATED_RESET reset_i, FREQ_HZ 150000000";
    
    ATTRIBUTE X_INTERFACE_INFO of m_axis_video_tlast: SIGNAL is "xilinx.com:signal:clock:1.0 clk_i CLK";
    ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_video_tlast : SIGNAL is "ASSOCIATED_RESET reset_i, FREQ_HZ 150000000";
    
    -- Logic - common
    signal valid_stream : STD_LOGIC;
    
    type num_array is array(integer range <>) of unsigned(7 downto 0);
    signal num_block_reg, num_block_v_reg : num_array(65 downto 0);
    signal num_block_last, num_block_last_1cycle : unsigned(7 downto 0);
    signal num_block_v_last, num_block_v_last_1cycle : unsigned(7 downto 0);
    
    -- Video with PR
    signal red_pr, blue_pr, green_pr : std_logic_vector(7 downto 0);
    signal pr_last : std_logic_vector(2 downto 0);
    signal data_internal : std_logic_vector(23 downto 0);
    
    -- Register for valids
    signal vstream_valid_buffer, vstream_user_buffer, vstream_last_buffer : STD_LOGIC_VECTOR(65 downto 0);
    signal ready_internal : std_logic;
    signal remainingPixels : unsigned(3 downto 0) := "0000";
    
    -- Types
    type pr_array is array(integer range <>, integer range <>) of std_logic_vector(2 downto 0);
    
    -- Logic - VERTICAL
    component verticalPR is
    Port ( clk_i : in STD_LOGIC;
         reset_i : in STD_LOGIC;
         valid_i : in STD_LOGIC;
         ready_i : in STD_LOGIC;
         Y_i : in STD_LOGIC_VECTOR (7 downto 0);
         num_pixel_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_pixel_adv_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_line_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_block_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_block_adv_i : in STD_LOGIC_VECTOR(7 downto 0);
         valid_o : out STD_LOGIC;
         pr_o : out STD_LOGIC_VECTOR (2 downto 0);
         
         valid_single_o : out STD_LOGIC;
         diff_accum_single_o : out STD_LOGIC_VECTOR(12 downto 0);
         counter_accum_single_o : out STD_LOGIC_VECTOR(10 downto 0)
          );
    end component;
        
    signal valid_pr_v : STD_LOGIC;
    signal pr_v : STD_LOGIC_VECTOR (2 downto 0);
    
    -- Register for PRs
    signal pr_reg_v : pr_array(SIZE_V_BK-1 downto 0, SIZE_H_BK-1 downto 0);
    signal pr_last_v : std_logic_vector(2 downto 0);
    
    -- Logic - HORIZONTAL
    component horizontalPR is
    Port ( clk_i : in STD_LOGIC;
         reset_i : in STD_LOGIC;
         valid_i : in STD_LOGIC;
         ready_i : in STD_LOGIC;
         Y_i : in STD_LOGIC_VECTOR (7 downto 0);
         num_pixel_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_line_i : in STD_LOGIC_VECTOR(7 downto 0);
         num_block_i : in STD_LOGIC_VECTOR(7 downto 0);
         valid_o : out STD_LOGIC;
         pr_o : out STD_LOGIC_VECTOR (2 downto 0);
         
         valid_single_o : out STD_LOGIC;
         diff_accum_single_o : out STD_LOGIC_VECTOR(12 downto 0);
         counter_accum_single_o : out STD_LOGIC_VECTOR(10 downto 0)
          );
    end component;
        
    signal valid_pr_h : STD_LOGIC;
    signal pr_h : STD_LOGIC_VECTOR (2 downto 0);
    
    -- Register for PRs
    signal pr_reg_h : pr_array(SIZE_V_BK-1 downto 0, SIZE_H_BK-1 downto 0);
    signal pr_last_h : std_logic_vector(2 downto 0);
    
begin

    valid_stream <= s_axis_video_tvalid and m_axis_video_tready;
    
    -- Registers for PRs
    num_block_proc: process(clk_i, num_block_i)
    begin
        if (rising_edge(clk_i)) then
            num_block_reg(0) <= unsigned(num_block_i);
            num_block_reg(65 downto 1) <= num_block_reg(64 downto 0);
            
            num_block_v_reg(0) <= unsigned(num_block_v_i);
            num_block_v_reg(65 downto 1) <= num_block_v_reg(64 downto 0);
        end if;
    end process;
    
    num_block_last <= num_block_reg(64); -- Another name for convenience
    --num_block_last_1cycle <= num_block_reg(65); -- Another name for convenience
    num_block_v_last <= num_block_v_reg(64); -- Another name for convenience
    --num_block_v_last_1cycle <= num_block_v_reg(65); -- Another name for convenience
    
    num_block_pr_o <= std_logic_vector(num_block_last);
    num_block_v_pr_o <= std_logic_vector(num_block_v_last);
    
    -- Vertical PR
    verticalPR_inst: verticalPR
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        valid_i => valid_stream,
        ready_i => m_axis_video_tready,
        Y_i => Y_i,
        num_pixel_i => num_pixel_i,
        num_pixel_adv_i => num_pixel_adv_i,
        num_line_i => num_line_i,
        num_block_i => num_block_i,
        num_block_adv_i => num_block_adv_i,
        valid_o => valid_pr_v,
        pr_o => pr_v,
        
        valid_single_o => open, 
        diff_accum_single_o => open,
        counter_accum_single_o => open
    );
    
    pr_reg_v_proc: process(clk_i, valid_pr_v, num_block_reg)
    begin
        if (rising_edge(clk_i)) then
            if (valid_pr_v='1') then
                pr_reg_v(to_integer(num_block_v_last), to_integer(num_block_last)) <= pr_v;
            end if;
        end if;
    end process;
    
    pr_last_v <= pr_reg_v(to_integer(unsigned(num_block_v_i)), to_integer(unsigned(num_block_i)));
    PRv_o <= pr_v;
    valid_prv_o <= valid_pr_v;
    
    -- Horizontal PR
    horizontalPR_inst: horizontalPR
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        valid_i => valid_stream,
        ready_i => m_axis_video_tready,
        Y_i => Y_i,
        num_pixel_i => num_pixel_i,
        num_line_i => num_line_i,
        num_block_i => num_block_i,
        valid_o => valid_pr_h,
        pr_o => pr_h,
        
        valid_single_o => open, 
        diff_accum_single_o => open,
        counter_accum_single_o => open
    );
    
    pr_reg_h_proc: process(clk_i, valid_pr_h, num_block_reg)
    begin
        if (rising_edge(clk_i)) then
            if (valid_pr_h='1') then
                pr_reg_h(to_integer(num_block_v_last), to_integer(num_block_last)) <= pr_h;
            end if;
        end if;
    end process;
    
    pr_last_h <= pr_reg_h(to_integer(unsigned(num_block_v_i)), to_integer(unsigned(num_block_i)));
    PRh_o <= pr_h;
    valid_prh_o <= valid_pr_v;
    
    -- Out colors
    pr_last <= pr_last_h when(hv_i='0') else pr_last_v;
    red_pr <= Y_i when(pr_last(0)='1') else "00000000";
    blue_pr <= Y_i when(pr_last(1)='1') else "00000000";
    green_pr <= Y_i when(pr_last(2)='1') else "00000000";
    
     -- Valid buffer
    valid_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            vstream_valid_buffer(0) <= s_axis_video_tvalid;
            --vstream_valid_buffer(65 downto 1) <= vstream_valid_buffer(64 downto 0);
        end if;
    end process;
    
    m_axis_video_tvalid <= vstream_valid_buffer(0) when (demo_i='0') else s_axis_video_tvalid;    
    
    -- User and Last buffers
    buff_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            vstream_user_buffer(0) <= s_axis_video_tuser;
            --vstream_user_buffer(65 downto 1) <= vstream_user_buffer(64 downto 0);
            
            vstream_last_buffer(0) <= s_axis_video_tlast;
            --vstream_last_buffer(65 downto 1) <= vstream_last_buffer(64 downto 0);
        end if;
    end process;
    
    m_axis_video_tuser <= vstream_user_buffer(0) when (demo_i='0') else s_axis_video_tuser; 
    m_axis_video_tlast <= vstream_last_buffer(0) when (demo_i='0') else s_axis_video_tlast;
    
    
    -- Sample data with delay
    data_proc: process(clk_i, vstream_valid_buffer)
    begin
        if (rising_edge(clk_i)) then
            if (vstream_valid_buffer(0)='1') then
                data_internal <= red_pr & blue_pr & green_pr;
            end if;
        end if;
    end process;
--    data_internal <= (others=>'0');
    
    m_axis_video_tdata <= data_internal when (demo_i='0') else s_axis_video_tdata;
    
    -- Ready
    remaining_proc: process(clk_i, reset_i)
    begin
        if (reset_i = '0') then
            remainingPixels <= "0000";
        elsif (rising_edge(clk_i)) then
            if (m_axis_video_tready='1') then
                remainingPixels <= "0000";
            else
                remainingPixels <= "0001";
            end if;
        end if;
    end process;
    
    ready_internal <= '1' when(m_axis_video_tready='1' and remainingPixels="0000") else '0';
    s_axis_video_tready <= ready_internal when (demo_i='0') else m_axis_video_tready;

end Behavioral;
