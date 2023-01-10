----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/20/2021 05:14:09 PM
-- Design Name: 
-- Module Name: stream2hleblock - Behavioral
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

entity stream2hleblock is
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
           user_o : out STD_LOGIC;
           ready_o : out STD_LOGIC;
           
           num_pixel_o : out STD_LOGIC_VECTOR(7 downto 0);
           num_pixel_full_o : out STD_LOGIC_VECTOR(9 downto 0);
           num_line_o : out STD_LOGIC_VECTOR(7 downto 0);
           num_block_o : out STD_LOGIC_VECTOR(7 downto 0);
           num_block_v_o : out STD_LOGIC_VECTOR(7 downto 0);
           num_pixel_adv_o : out STD_LOGIC_VECTOR(7 downto 0);
           num_block_adv_o : out STD_LOGIC_VECTOR(7 downto 0)
           );
end stream2hleblock;

architecture Behavioral of stream2hleblock is
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
    
    -- Memory
    -- ******
    
    -- Valid
    signal global_ce : std_logic;
    signal valid_internal, valid_internal_1cycle : std_logic;
    signal ready_internal : std_logic;
    
    signal tuser_reg : std_logic_vector(1 downto 0);
    signal tlast_reg : std_logic_vector(1 downto 0);
    
    signal dataAvailableAndRequested : std_logic;
    signal initialLatencyCovered : std_logic;
    signal user_internal : std_logic;
    signal remainingPixels : unsigned(3 downto 0) := "0000";
    
    -- Data
    signal Yi, Y_reg : std_logic_vector(7 downto 0);
    signal Ro, Go, Bo : std_logic_vector(7 downto 0);
    signal data_internal, data_internal_reg : std_logic_vector(23 downto 0);
    
    -- Signals for counters
    signal mem_idx, mem_idx_1cycle : unsigned(0 downto 0) := "0";
    signal num_line, num_pixel : unsigned(11 downto 0) := x"000";
    signal num_pixel_1cycle : unsigned(11 downto 0) := x"000";
    signal num_pixel_bk, num_line_bk, num_line_bk_tlast : unsigned(7 downto 0) := x"00";
    signal num_pixel_bk_1cycle, num_line_bk_1cycle : unsigned(7 downto 0) := x"00";
    signal num_block, num_block_v : unsigned(7 downto 0) := x"00";
    signal num_block_1cycle, num_block_v_1cycle : unsigned(7 downto 0) := x"00";
    signal num_pixel_bk_adv, num_block_adv : unsigned(7 downto 0) := x"00";
    signal num_pixel_bk_adv_1cycle, num_block_adv_1cycle : unsigned(7 downto 0) := x"00";
    
    -- 40 x 40
    constant block_pixels : unsigned(7 downto 0) := to_unsigned(SIZE_BLOCK_H-1, 8);
    constant block_lines : unsigned(7 downto 0) := to_unsigned(SIZE_BLOCK_V-1, 8);
    constant max_blocks_h : unsigned(7 downto 0) := to_unsigned(SIZE_H_BK-1, 8);    
    constant max_blocks_vv : unsigned(7 downto 0) := to_unsigned(SIZE_V_BK-1, 8);
    constant max_blocks_v : unsigned(0 downto 0) := "1";
    
    ---
--    attribute mark_debug : string;
--    attribute mark_debug of num_pixel_o : signal is "true";
--    attribute mark_debug of num_line_o : signal is "true";
--    attribute mark_debug of num_block_o : signal is "true";
--    attribute mark_debug of num_block_v_o : signal is "true";
--    attribute mark_debug of global_ce : signal is "true";
--    attribute mark_debug of s_axis_video_tdata : signal is "true";
--    attribute mark_debug of s_axis_video_tvalid : signal is "true";
--    attribute mark_debug of s_axis_video_tuser : signal is "true";
--    attribute mark_debug of s_axis_video_tlast : signal is "true";
--    attribute mark_debug of s_axis_video_tready : signal is "true";
--    attribute mark_debug of m_axis_video_tdata : signal is "true";
--    attribute mark_debug of m_axis_video_tvalid : signal is "true";
--    attribute mark_debug of m_axis_video_tuser : signal is "true";
--    attribute mark_debug of m_axis_video_tlast : signal is "true";
--    attribute mark_debug of m_axis_video_tready : signal is "true";
    
    
begin
    -- Enable
    global_ce <= s_axis_video_tvalid and m_axis_video_tready;
    
    -- In
    Yi <= s_axis_video_tdata(7 downto 0); -- Extract luminance
    
    -- Control signals from input
    latency_proc: process(clk_i, reset_i, s_axis_video_tuser)
    begin
        if (rising_edge(clk_i)) then
            if (reset_i = '0') then
                initialLatencyCovered <= '0';
            elsif (s_axis_video_tuser='1') then
                initialLatencyCovered <= '1';
            end if;
        end if;
    end process;
    
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
    
    -- Counter for pixels
    pixelct_proc: process(clk_i, reset_i, global_ce)
    begin
        if (rising_edge(clk_i)) then
            if (global_ce = '1') then
                if (s_axis_video_tuser = '1' or s_axis_video_tlast = '1') then
                    num_pixel <= x"000";
                elsif (num_pixel = SIZE_H_PX-1) then
                    num_pixel <= x"000";
                else
                    num_pixel <= num_pixel + 1;
                end if;
            end if;
        end if;
    end process;
    
    pixelbkct_proc: process(clk_i, reset_i, global_ce)
    begin
        if (rising_edge(clk_i)) then
            if (global_ce = '1') then
                if (s_axis_video_tuser = '1' or s_axis_video_tlast = '1') then
                    num_pixel_bk <= x"00";
                elsif (num_pixel_bk = block_pixels) then
                    num_pixel_bk <= x"00";
                else
                    num_pixel_bk <= num_pixel_bk + 1;
                end if;
            end if;
        end if;
    end process;
    
    blockct_proc: process(clk_i, reset_i, global_ce)
    begin
        if (rising_edge(clk_i)) then
            if (global_ce = '1') then
                if (s_axis_video_tuser = '1') then
                    num_block <= x"00";
                elsif (s_axis_video_tlast = '1') then
                    num_block <= x"00";
                elsif (num_block=max_blocks_h and num_pixel_bk=block_pixels) then
                    num_block <= x"00";
                elsif (num_pixel_bk = block_pixels) then
                    num_block <= num_block + 1;
                end if;
            end if;
        end if;
    end process;
    
    ----
    pixelbkadvct_proc: process(clk_i, reset_i, global_ce)
    begin
        if (rising_edge(clk_i)) then
            if (global_ce = '1') then
                if (s_axis_video_tuser = '1' or s_axis_video_tlast = '1') then
                    num_pixel_bk_adv <= x"01";
                elsif (num_pixel_bk_adv = block_pixels) then
                    num_pixel_bk_adv <= x"00";
                else
                    num_pixel_bk_adv <= num_pixel_bk_adv + 1;
                end if;
            end if;
        end if;
    end process;
    
    blockadvct_proc: process(clk_i, reset_i, global_ce)
    begin
        if (rising_edge(clk_i)) then
            if (global_ce = '1') then
                if (s_axis_video_tuser = '1') then
                    num_block_adv <= x"00";
                elsif (s_axis_video_tlast = '1') then
                    num_block_adv <= x"00";
                elsif (num_block_adv=max_blocks_h and num_pixel_bk_adv=block_pixels) then
                    num_block_adv <= x"00";
                elsif (num_pixel_bk_adv = block_pixels) then
                    num_block_adv <= num_block_adv + 1;
                end if;
            end if;
        end if;
    end process;
    
    ----
    linect_proc: process(clk_i, reset_i, global_ce, s_axis_video_tlast)
    begin
        if (rising_edge(clk_i)) then
            if (global_ce = '1' and s_axis_video_tlast='1') then
                if (num_line = x"2D0") then
                    num_line <= x"000";
                else
                    num_line <= num_line + 1;
                end if;
            end if;
        end if;
    end process;
    
    linebkct_proc: process(clk_i, reset_i, global_ce, s_axis_video_tlast, num_block, num_pixel)
    begin
        if (rising_edge(clk_i)) then
--            if (global_ce = '1' and s_axis_video_tlast='1') then
--                if (num_line_bk_tlast = block_lines) then
--                    num_line_bk_tlast <= x"000";
--                else
--                    num_line_bk_tlast <= num_line_bk_tlast + 1;
--                end if;
--            end if;
            
            if (global_ce = '1') then
                if (s_axis_video_tuser='1') then
                    num_line_bk <= x"00";
                --elsif ((num_block=max_blocks_h and num_pixel_bk=block_pixels) or s_axis_video_tlast='1') then
                elsif (s_axis_video_tlast='1') then
                    if (num_line_bk = block_lines) then
                        num_line_bk <= x"00";
                    else
                        num_line_bk <= num_line_bk + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    blockVct_proc: process(clk_i, reset_i, global_ce)
    begin
        if (rising_edge(clk_i)) then
            if (global_ce = '1') then
                if (s_axis_video_tuser = '1') then
                    num_block_v <= x"00";
                --elsif ((num_block=max_blocks_h and num_pixel_bk=block_pixels) or s_axis_video_tlast='1') then
                elsif (s_axis_video_tlast='1') then
                    if (num_block_v=max_blocks_vv and num_line_bk=block_lines) then
                        num_block_v <= x"00";
                    elsif (num_line_bk = block_lines) then
                        num_block_v <= num_block_v + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    memct_proc: process(clk_i, reset_i, global_ce, s_axis_video_tlast)
    begin
        if (rising_edge(clk_i)) then
            if (global_ce = '1') then
                 if (s_axis_video_tuser='1') then
                    mem_idx <= (others=>'0');
                 elsif (s_axis_video_tlast='1') then
                    if (num_line_bk = block_lines) then
                        mem_idx <= mem_idx + 1;
                    end if;
                end if;
            end if;
            
            --mem_idx_1cycle <= mem_idx;
        end if;
    end process;

    -- Out -- !! WRITE CONDS
    Ro <= Yi when (num_block(0)='1') else "00000000";
    Go <= Yi when (num_block_v(0) = '1') else "00000000";
    Bo <= Yi when (num_block(0)='0') else "00000000";

    reg_input_proc: process(clk_i)
    begin
       if(rising_edge(clk_i)) then
            data_internal <= Ro & Bo & Go;--Yi & Yi & Yi;--"00" & Ro & Bo & Go;  
            Y_reg <= Yi;
        end if;
    end process;
    
    reg_output_proc: process(clk_i)
    begin
       if(rising_edge(clk_i)) then
            data_internal_reg <= data_internal;  
            Y_o <= Y_reg;
        end if;
    end process;
    
    m_axis_video_tdata <= data_internal_reg when (demo_i='0') else s_axis_video_tdata;
    
    --s_axis_video_tready <= '1' when(m_axis_video_tready='1') else '0'; -- Leave room for extra conditions
    
    --m_axis_video_tvalid <= global_ce_reg1;
    
    ready_internal <= '1' when(m_axis_video_tready='1' and remainingPixels="0000") else '0';
    s_axis_video_tready <= ready_internal when (demo_i='0') else m_axis_video_tready;
    
    dataAvailableAndRequested <= '1' when ((remainingPixels="0001") or (s_axis_video_tvalid='1')) and
                                           (m_axis_video_tready = '1') else '0';
    
    valid_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            valid_internal <= '0';
            valid_internal_1cycle <= '0';
        elsif (rising_edge(clk_i)) then
            if (dataAvailableAndRequested='1' and initialLatencyCovered='1') then
                valid_internal <= '1';
            elsif (m_axis_video_tready='1') then
                valid_internal <= '0';
            end if;
            
            valid_internal_1cycle <= valid_internal;
        end if;
    end process; 
    
    m_axis_video_tvalid <= valid_internal_1cycle when (demo_i='0') else s_axis_video_tvalid;
    
    -- User out
    genuser_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            user_internal <= '0';
        elsif (rising_edge(clk_i)) then
            if (s_axis_video_tvalid='1' and
                remainingPixels="0000" and
                s_axis_video_tuser='1') then
                
                user_internal <= '1';
            else
                user_internal <= '0';
            end if;
        end if;
    end process;
    
    reguser_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            tuser_reg(0) <=  s_axis_video_tuser;
            tuser_reg(1) <= tuser_reg(0);
        end if;
    end process;
    
    m_axis_video_tuser <= tuser_reg(1)  when (demo_i='0') else s_axis_video_tuser;
    
    -- Last out
    reglast_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            tlast_reg(0) <= s_axis_video_tlast;
            tlast_reg(1) <= tlast_reg(0);
        end if;
    end process;
    
    m_axis_video_tlast <= tlast_reg(1) when (demo_i='0') else s_axis_video_tlast;
    
    -- Number of pixels/lines/blocks
    numdelay_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            num_pixel_1cycle <= num_pixel;
            num_pixel_bk_1cycle <= num_pixel_bk;
            num_pixel_bk_adv_1cycle <= num_pixel_bk_adv;
            num_line_bk_1cycle <= num_line_bk;
            num_block_1cycle <= num_block;
            num_block_adv_1cycle <= num_block_adv;
            num_block_v_1cycle <= num_block_v;
        end if;
    end process;
    
    numout_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            num_pixel_full_o <= std_logic_vector(num_pixel_1cycle(9 downto 0));
            num_pixel_o <= std_logic_vector(num_pixel_bk_1cycle);
            num_pixel_adv_o <= std_logic_vector(num_pixel_bk_adv_1cycle);
            num_line_o <= std_logic_vector(num_line_bk_1cycle);
            num_block_o <= std_logic_vector(num_block_1cycle);
            num_block_adv_o <= std_logic_vector(num_block_adv_1cycle);
            num_block_v_o <= std_logic_vector(num_block_v_1cycle);
        end if;
    end process;
    
    --
    valid_o <= valid_internal_1cycle;
    ready_o <= ready_internal;
    user_o <= tuser_reg(1);
end Behavioral;
