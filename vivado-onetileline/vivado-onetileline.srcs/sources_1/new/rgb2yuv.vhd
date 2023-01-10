----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/14/2021 04:28:56 PM
-- Design Name: 
-- Module Name: rgb2yuv - Behavioral
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

entity rgb2yuv is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           demo_i : in STD_LOGIC;
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
end rgb2yuv;

architecture Behavioral of rgb2yuv is
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

    -- Multipliers
    COMPONENT mult_gen_A00
      PORT (
        CLK : IN STD_LOGIC;
        A : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        CE : IN STD_LOGIC;
        P : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
      );
    END COMPONENT;
    
    COMPONENT mult_gen_A01
      PORT (
        CLK : IN STD_LOGIC;
        A : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        CE : IN STD_LOGIC;
        P : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
      );
    END COMPONENT;
    
    COMPONENT mult_gen_A02
      PORT (
        CLK : IN STD_LOGIC;
        A : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        CE : IN STD_LOGIC;
        P : OUT STD_LOGIC_VECTOR(12 DOWNTO 0)
      );
    END COMPONENT;
    
    -- Input signals
    signal Rin, Gin, Bin : std_logic_vector(7 downto 0);
    
    -- Enables and control
    signal global_ce, global_ce_mult, global_ce_sum, global_ce_shift : std_logic;
    signal tuser_reg : std_logic_vector(5 downto 0);
    signal tlast_reg : std_logic_vector(5 downto 0);
    signal data_valid : std_logic;
    signal data_valid_reg : std_logic_vector(4 downto 0);
    
    signal dataAvailableAndRequested : std_logic;
    signal initialLatencyCovered : std_logic;
    signal ready_internal : std_logic;
    signal remainingPixels : unsigned(3 downto 0) := "0000";
        
    -- Result signals
    signal p_00 : std_logic_vector(14 downto 0);
    signal p_01 : std_logic_vector(15 downto 0);
    signal p_02 : std_logic_vector(12 downto 0);
    signal MxRGB_00, MxRGB_01, MxRGB_02 : unsigned(15 downto 0);
    
    -- Sum signals
    signal YM : unsigned(15 downto 0);
    
    -- Scaled signals
    signal YT : unsigned(15 downto 0);
    
    -- Offset signals
    signal YU : unsigned(7 downto 0);
    signal YU_clipped : std_logic_vector(7 downto 0);
    
    attribute mark_debug : string;
--    attribute mark_debug of reset_i : signal is "true";
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
    -- Inputs
    Rin <= s_axis_video_tdata(23 downto 16);
    Bin <= s_axis_video_tdata(15 downto  8);
    Gin <= s_axis_video_tdata( 7 downto  0);
    
    -- Control signals
    -- Valid data
    global_ce <= s_axis_video_tvalid and m_axis_video_tready;
    
    -- Control signals from input
    latency_proc: process(clk_i, reset_i, tuser_reg)
    begin
        if (rising_edge(clk_i)) then
            if (reset_i = '0') then
                initialLatencyCovered <= '0';
            elsif (tuser_reg(4)='1') then
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
    
    -- CE - adjust for 3-stage multiplier and later stages
    regce_proc: process(clk_i, m_axis_video_tready)
    begin
        if (rising_edge(clk_i)) then
            if (m_axis_video_tready='1') then --- CHECK WELL, I don't want to loose the "valid" status when things stop bc of ready
                data_valid_reg(0) <= s_axis_video_tvalid;
                data_valid_reg(4 downto 1) <= data_valid_reg(3 downto 0);
            end if;
        end if;
    end process;
    
    global_ce_mult <= (s_axis_video_tvalid or data_valid_reg(0) or data_valid_reg(1)) and m_axis_video_tready;
    global_ce_sum <= data_valid_reg(2) and m_axis_video_tready;
    global_ce_shift <= data_valid_reg(3) and m_axis_video_tready;
    
    -- Calculations
    
    -- Row 1 - matrix multiplication
    a00_inst: mult_gen_A00
    PORT MAP (
        CLK => clk_i,
        A => Rin,
        CE => global_ce_mult,
        P => p_00
    );
    MxRGB_00 <= "0" & unsigned(p_00);
    
    a01_inst: mult_gen_A01
    PORT MAP (
        CLK => clk_i,
        A => Gin,
        CE => global_ce_mult,
        P => p_01
    );
    MxRGB_01 <= unsigned(p_01);
    
    a02_inst: mult_gen_A02
    PORT MAP (
        CLK => clk_i,
        A => Bin,
        CE => global_ce_mult,
        P => p_02
    );
    MxRGB_02 <= "000" & unsigned(p_02);
    
    -- Row 1 - Adding
    addR1_proc: process(clk_i, global_ce)
    begin
        if (rising_edge(clk_i)) then
            if (global_ce_sum = '1') then
                YM <= MxRGB_00 + MxRGB_01 + MxRGB_02;
            end if;
        end if;
    end process;
    
    -- Row 1 - offset and shift
    offR1_proc: process(clk_i, global_ce)
    begin
        if (rising_edge(clk_i)) then
            if (global_ce_shift = '1') then
                YT <= YM + "0000000010000000"; --128
            end if;
        end if;
    end process;
    
    YU <= YT(15 downto 8);
    YU_clipped <= std_logic_vector(YU);
    
    -- Out
    m_axis_video_tdata <= YU_clipped & YU_clipped & YU_clipped when (demo_i='0') else s_axis_video_tdata;
    Y_o <= YU_clipped;
    
    -- User out
    reguser_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            tuser_reg(0) <= s_axis_video_tuser;
            tuser_reg(5 downto 1) <= tuser_reg(4 downto 0);
        end if;
    end process;
    
    m_axis_video_tuser <= tuser_reg(4) when (demo_i='0') else s_axis_video_tuser;
    
    -- Last out
    reglast_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            tlast_reg(0) <= s_axis_video_tlast;
            tlast_reg(5 downto 1) <= tlast_reg(4 downto 0);
        end if;
    end process;
    
    m_axis_video_tlast <= tlast_reg(4) when (demo_i='0') else s_axis_video_tlast;
    
    -- Valid and ready
    ready_internal <= '1' when(m_axis_video_tready='1' and remainingPixels="0000") else '0';
    s_axis_video_tready <= ready_internal when (demo_i='0') else m_axis_video_tready;
    
--    dataAvailableAndRequested <= '1' when ((remainingPixels="0001") or (s_axis_video_tvalid='1')) and
--                                           (m_axis_video_tready = '1') else '0';
                                           
    m_axis_video_tvalid <= data_valid_reg(4) when (demo_i='0') else s_axis_video_tvalid;

-----
--m_axis_video_tdata <= s_axis_video_tdata; 
--m_axis_video_tvalid <= s_axis_video_tvalid;
--s_axis_video_tready <= m_axis_video_tready;
--m_axis_video_tuser <= s_axis_video_tuser;
--m_axis_video_tlast <= s_axis_video_tlast;
--m_axis_video_tdata <= s_axis_video_tdata;
--Y_o <= s_axis_video_tdata( 9 downto  0); 
-----
end Behavioral;
