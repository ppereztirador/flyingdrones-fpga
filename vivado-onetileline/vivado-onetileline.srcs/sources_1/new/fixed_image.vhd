----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/10/2022 10:57:28 AM
-- Design Name: 
-- Module Name: fixed_image - Behavioral
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

entity fixed_image is
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
end fixed_image;

architecture Behavioral of fixed_image is

    COMPONENT blk_mem_image_0
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END COMPONENT;
    
    signal image_addr : std_logic_vector(18 DOWNTO 0);
    signal image_dout : std_logic_vector(7 DOWNTO 0);
    signal image_addr_un : unsigned(18 downto 0);
    signal x, y : unsigned(10 downto 0);
    constant max_address: unsigned(18 downto 0) := "1001010111111111111"; --640*480-1
    
    ---
    signal global_ce : std_logic;
    signal tuser_reg : std_logic_vector(2 downto 0);
    signal tlast_reg : std_logic_vector(2 downto 0);
    signal globalce_reg : std_logic_vector(2 downto 0);
    signal ready_internal : std_logic;
    
    signal remainingPixels : unsigned(3 downto 0);
    signal data_internal : std_logic_vector(23 downto 0);
    
    ---
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

    attribute mark_debug : string;
    --attribute mark_debug of image_addr : signal is "true";
    --attribute mark_debug of image_dout : signal is "true";
--    attribute mark_debug of s_axis_video_tvalid : signal is "true";
--    attribute mark_debug of s_axis_video_tdata : signal is "true";
--    attribute mark_debug of s_axis_video_tuser : signal is "true";
--    attribute mark_debug of s_axis_video_tlast : signal is "true";
--    attribute mark_debug of m_axis_video_tready : signal is "true";
--    attribute mark_debug of m_axis_video_tuser : signal is "true";
begin
    
--    image_inst: blk_mem_image_0
--    port map (
--        clka => clk_i,
--        ena => '1',
--        addra => image_addr,
--        douta => image_dout
--    );
    --- EXPERIMENTAL: GENERATE IMAGE BASED ON PIXEL POSITION
    --- BEHAVIOURALLY SUBSTITUTING THE BLK MEM
    image_proc: process(clk_i, image_addr_un)
--        variable num_high : unsigned(8 downto 0);
--        variable num_low : unsigned(9 downto 0);
--        variable im_val : unsigned(13 downto 0);
    begin
--        num_high := image_addr_un(18 downto 10);
--        num_low := image_addr_un(9 downto 0);
--        im_val := ('0'&num_high) + num_low;
--        im_val := ("0"&image_addr_un(18 downto 6)) + ("00"&image_addr_un(18 downto 7));

        if (rising_edge(clk_i)) then
--            image_dout <= std_logic_vector(im_val(9 downto 2));
--            if (x>to_unsigned(100,10) and x<to_unsigned(150,10) and y>to_unsigned(80,10) and y<to_unsigned(197,10)) then
--                if (x(1 downto 0)="00") then
--                    image_dout <= x"FF";
--                else
--                    image_dout <= x"00";
--                end if;
--            else
--                image_dout <= std_logic_vector(im_val(7 downto 0));
--            end if;

--            -- CHECKERED
--            if (x(0)='0' and y(1)='0') then
--                image_dout <= x"FF";
--            elsif (x(0)='1' and y(1)='1') then
--                image_dout <= x"FF";
--            else
--                image_dout <= x"00";
--            end if;

              -- BLANK
              image_dout <= x"00";
        end if;
    end process;
    ---
    -- Generate rolling address
    global_ce <= s_axis_video_tvalid and m_axis_video_tready;
      
    addr_proc: process(clk_i, reset_i, global_ce, s_axis_video_tuser)
    begin
        if (reset_i='0') then
            image_addr_un <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (global_ce = '1') then
                if (s_axis_video_tuser = '1') then
                    image_addr_un <= (others=>'0');
                elsif (image_addr_un = max_address) then
                    image_addr_un <= (others=>'0');
                else
                    image_addr_un <= image_addr_un + 1;
                end if;
            end if;
        end if;
    end process;
    image_addr <= std_logic_vector(image_addr_un);
    
    xy_proc: process(clk_i, reset_i, global_ce, s_axis_video_tuser)
    begin
        if (reset_i='0') then
            x <= (others=>'0');
            y <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (global_ce = '1') then
                if (s_axis_video_tuser = '1') then
                    x <= (others=>'0');
                    y <= (others=>'0');
                elsif (x = to_unsigned(639,10)) then
                    x <= (others=>'0');
                    if (y = to_unsigned(479,10)) then
                        y <= (others=>'0');
                    else
                        y <= y + 1;
                    end if;
                else
                    x <= x + 1;
                end if;
            end if;
        end if;
    end process;
      
    -- User out
    reguser_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            tuser_reg(0) <= s_axis_video_tuser;
            tuser_reg(2 downto 1) <= tuser_reg(1 downto 0);
        end if;
    end process;
    
    m_axis_video_tuser <= tuser_reg(2) when (demo_i='0') else s_axis_video_tuser;
    
    -- Last out
    reglast_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            tlast_reg(0) <= s_axis_video_tlast;
            tlast_reg(2 downto 1) <= tlast_reg(1 downto 0);
        end if;
    end process;
    
    m_axis_video_tlast <= tlast_reg(2) when (demo_i='0') else s_axis_video_tlast;
    
    -- Valid
    regce_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            globalce_reg(0) <= s_axis_video_tvalid;
            globalce_reg(2 downto 1) <= globalce_reg(1 downto 0);
        end if;
    end process;
    
    m_axis_video_tvalid <= globalce_reg(2) when (demo_i='0') else s_axis_video_tvalid;
    
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
    s_axis_video_tready <= ready_internal when (demo_i='0') else m_axis_video_tready; -- Leave room for extra conditions
    
    -- Data
    data_internal <=  image_dout & image_dout & image_dout;
    m_axis_video_tdata <= data_internal when (demo_i='0') else s_axis_video_tdata; 

---
--m_axis_video_tdata <= s_axis_video_tdata;
--m_axis_video_tvalid <= s_axis_video_tvalid;
--s_axis_video_tready <= m_axis_video_tready;
--m_axis_video_tuser <= s_axis_video_tuser;
--m_axis_video_tlast <= s_axis_video_tlast;
---

end Behavioral;
