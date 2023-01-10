----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2022 05:04:06 PM
-- Design Name: 
-- Module Name: blockDownsample - Behavioral
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
use IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library WORK;
use WORK.lhe_lib.ALL;

entity blockDownsample is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           ready_i : in STD_LOGIC;
           
           -- PRs
           PRH_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           PRV_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           valid_pr_i : in STD_LOGIC;
           
           -- Data from memory
           Y_i : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           addr_r_ds_o : out STD_LOGIC_VECTOR(10 DOWNTO 0);
           switch_y_ds_o : out STD_LOGIC;
           
           -- Data to memory
           DS_o : out STD_LOGIC_VECTOR(7 downto 0);
           addr_w_ds_o : out STD_LOGIC_VECTOR(10 DOWNTO 0);
           switch_ds_hle_o : out STD_LOGIC);
end blockDownsample;

architecture Behavioral of blockDownsample is
    -- List of PRs for one block row
    signal prh_array, prv_array : std_logic_vector(2 downto 0);
    
    -- Addresses and counters
    signal addr_r_ds_u, addr_r_ds_line, addr_r_ds_pixel : unsigned(10 downto 0);
    signal addr_dsv_line, addr_dsv_pixel : unsigned(10 downto 0);
    signal addr_dso_line, addr_dso_pixel : unsigned(10 downto 0);
    constant max_line : unsigned(10 downto 0) := to_unsigned(SIZE_BLOCK_V-1, 11);
    constant max_pixel : unsigned(10 downto 0) := to_unsigned(SIZE_BLOCK_H-1, 11);
    
    type addr_array is array(integer range <>) of unsigned(10 downto 0); 
    signal addr_r_ds_pixel_delay : addr_array(10 downto 0);
    signal addr_dsv_pixel_delay, addr_dsv_line_delay : addr_array(3 downto 0);
    signal addr_dso_pixel_delay : unsigned(10 downto 0);
    
    -- Processing states
    type ds_state_type is (IDLE, WAIT_LAST_PR, START_PIXEL_READ, COMPUTE_DS);
    signal dsh_state_current, dsh_state_next : ds_state_type := IDLE;
    signal dsv_state_current, dsv_state_next : ds_state_type := IDLE;
    
    type save_state_type is (IDLE, SAVE_DS);
    signal save_state_current, save_state_next : save_state_type := IDLE;
    
    signal pixel_read, pixel_read_delay, pixelv_read, pixelv_save, pixelv_read_delay, pixel_reg : std_logic;
    signal pixelh_calculated, pixelv_calculated : std_logic;
    signal pixelh_last, pixelv_last : std_logic;
    signal pixelsave_last : std_logic;
    
    -- Adders
    signal Y_u : unsigned(7 downto 0);
    
    type adder_h_array is array(integer range <>) of unsigned(11 downto 0);
    type downsample_array  is array(integer range <>) of unsigned(7 downto 0);
    
    signal adder_h_reg, previous_h_reg : adder_h_array(2 downto 0);
    signal downsample_h_reg : downsample_array(2 downto 0);
    signal downsample_h_reg_pr : unsigned(7 downto 0);
    
    --type adder_v_array is array(integer range <>, integer range <>) of unsigned(11 downto 0);
    type adder_v_array is array(integer range <>) of adder_h_array(39 downto 0);
    
    signal previous_v_reg : adder_v_array(2 downto 0);
    signal adder_v_reg : adder_h_array(2 downto 0);
    signal downsample_v_reg : downsample_array(2 downto 0);
    signal downsample_v_pr : unsigned(7 downto 0);
    signal downsample_v_reg_pr : downsample_array(39 downto 0);
    
    signal hle_switch_reg : std_logic;
    signal ds_o_mock : std_logic_vector(7 downto 0);
begin

    -- Register PR for this block
    prsave_proc: process(clk_i, reset_i, valid_pr_i)
    begin
        if (reset_i='0') then
            prh_array <= (others=>'0');
            prv_array <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and valid_pr_i='1') then
                prh_array <= PRH_i;
                prv_array <= PRV_i;
            end if;
        end if;
    end process;
    
----------------------------------------------------------------------------

    -- Downsampling H state machine
    dsh_next_proc: process(clk_i, reset_i, ready_i)
    begin
        if (reset_i='0') then
            dsh_state_current <= IDLE;
        elsif (rising_edge(clk_i)) then
            if (ready_i='1') then
                dsh_state_current <= dsh_state_next;
            end if;
        end if;
    end process;
    
    dsh_state_proc: process(clk_i, reset_i, dsh_state_current,
                            pixelh_calculated, valid_pr_i, pixelh_last)
    begin
        case dsh_state_current is
            when IDLE =>
                if (valid_pr_i='1') then
                    dsh_state_next <= COMPUTE_DS;
                else
                    dsh_state_next <= IDLE;
                end if;
                
            when COMPUTE_DS =>
                if (pixelh_last='1') then
                    dsh_state_next <= IDLE;
                else
                    dsh_state_next <= COMPUTE_DS;
                end if;

            when others =>
                dsh_state_next <= IDLE;
        end case;
    end process;
    
    pixel_read <= '1' when (dsh_state_current=COMPUTE_DS) else '0';
    switch_y_ds_o <= '1' when (dsh_state_current=COMPUTE_DS) else '0';
    
    -- Downsampling H memory addresses
    dsh_pixel_addr_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            addr_r_ds_pixel <= (others => '0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and pixel_read='1') then
                if (addr_r_ds_pixel=max_pixel) then
                    addr_r_ds_pixel <= (others => '0');
                else
                    addr_r_ds_pixel <= addr_r_ds_pixel + 1;
                end if;
            end if;
            
            addr_r_ds_pixel_delay(0) <= addr_r_ds_pixel;
            addr_r_ds_pixel_delay(10 downto 1) <= addr_r_ds_pixel_delay(9 downto 0);
            
        end if;
    end process;
    
    dsh_line_addr_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            addr_r_ds_line <= (others => '0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and pixel_read='1') then
                if (addr_r_ds_pixel=max_pixel) then
                    if (addr_r_ds_line=max_line) then
                        addr_r_ds_line <= (others => '0');
                    else
                        addr_r_ds_line <= addr_r_ds_line + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    pixelh_last <= '1' when (addr_r_ds_pixel=max_pixel and addr_r_ds_line=max_line) else '0';
    
    
    addr_r_ds_u <= (addr_r_ds_line(5 downto 0) & "00000") +
                   (addr_r_ds_line(7 downto 0) & "000") +
                   addr_r_ds_pixel; 
    
    addr_r_ds_o <= std_logic_vector(addr_r_ds_u);
    
    -- Chain of adders for DS h
    Y_u <= unsigned(Y_i);
    
    reg_h_gen: for I in 0 to 2 generate
        first_gen: if (I=0) generate
            reg_h_proc: process (clk_i, ready_i, addr_r_ds_pixel_delay)
            begin
                if (rising_edge(clk_i)) then
                    if (ready_i='1' and addr_r_ds_pixel_delay(1)(0)='0') then
                        previous_h_reg(0) <= "0000"&Y_u;
                    end if;
                end if;
            end process;
        end generate;
        
        other_gen: if (I>0) generate
            reg_h_proc: process (clk_i, ready_i, addr_r_ds_pixel_delay)
            begin
                if (rising_edge(clk_i)) then
                    if (ready_i='1' and addr_r_ds_pixel_delay(2**I+I)(I)='0') then
                        previous_h_reg(I) <= adder_h_reg(I-1);
                    end if;
                end if;
            end process;
        end generate;
    end generate;
    
    adder_h_gen: for I in 0 to 2 generate
        first_gen: if (I=0) generate
            adder_h_proc: process (clk_i, ready_i, addr_r_ds_pixel_delay)
            begin
                if (rising_edge(clk_i)) then
                    if (ready_i='1' and addr_r_ds_pixel_delay(1)(0)='1') then
                        adder_h_reg(0) <= "0000"&Y_u + previous_h_reg(0);
                    end if;
                end if;
            end process;
        end generate;
        
        other_gen: if (I>0) generate
            adder_h_proc: process (clk_i, ready_i, addr_r_ds_pixel_delay)
            begin
                if (rising_edge(clk_i)) then
                    if (ready_i='1' and addr_r_ds_pixel_delay(2**I+I)(I)='1') then
                        adder_h_reg(I) <= adder_h_reg(I-1) + previous_h_reg(I);
                    end if;
                end if;
            end process;
        end generate;
    end generate;

    ds_h_gen: for I in 0 to 2 generate
        downsample_h_reg(I) <= adder_h_reg(I)(7+I+1 downto I+1);
    end generate;
    
    
    -- Choose DSh according to PR -- MAYBE THE MATCHING PR-DS IS THE INVERSE
    px_r_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            pixel_read_delay <= pixel_read;
        end if;
    end process;
    
--    downsample_h_reg_pr <= downsample_h_reg(0) when (prh_array="100") else
--                           downsample_h_reg(1) when (prh_array="011") else
--                           downsample_h_reg(2) when (prh_array="001" or prh_array="010") else
--                           Y_u;
                           
    downsample_h_reg_pr <= Y_u                 when (prh_array="100") else
                           downsample_h_reg(2) when (prh_array="011") else
                           downsample_h_reg(1) when (prh_array="001" or prh_array="010") else
                           downsample_h_reg(0);
    
    -- Choose ready signal for DSh (to mark 1st valid DS pixel)
--    pixelh_calculated <= addr_r_ds_pixel_delay(1)(0) when (prh_array="100") else
--                         addr_r_ds_pixel_delay(3)(1) when (prh_array="011") else -- Check the 3 thoroughly
--                         addr_r_ds_pixel_delay(6)(2) when (prh_array="001" or prh_array="010") else --Check the "5" in the pixel delay!!
--                         pixel_read_delay;
                         
    pixelh_calculated <= pixel_read_delay            when (prh_array="100") else
                         addr_r_ds_pixel_delay(6)(2) when (prh_array="011") else -- Check the 3 thoroughly
                         addr_r_ds_pixel_delay(3)(1) when (prh_array="001" or prh_array="010") else --Check the "5" in the pixel delay!!
                         addr_r_ds_pixel_delay(1)(0);
    
----------------------------------------------------------------------------
    
    -- Downsampling V state machine
    dsv_next_proc: process(clk_i, reset_i, ready_i)
    begin
        if (reset_i='0') then
            dsv_state_current <= IDLE;
        elsif (rising_edge(clk_i)) then
            if (ready_i='1') then
                dsv_state_current <= dsv_state_next;
            end if;
        end if;
    end process;
    
    dsv_state_proc: process(clk_i, reset_i, dsv_state_current, pixelh_calculated, pixelv_last)
    begin
        case dsv_state_current is
            when IDLE =>
                if (pixelh_calculated='1') then
                    dsv_state_next <= COMPUTE_DS;
                else
                    dsv_state_next <= IDLE;
                end if;
                
            when COMPUTE_DS =>
                if (pixelv_last='1') then
                    dsv_state_next <= IDLE;
                else
                    dsv_state_next <= COMPUTE_DS;
                end if;

            when others =>
                dsv_state_next <= IDLE;
        end case;
    end process;
    
    pixelv_read <= '1' when (dsv_state_current=COMPUTE_DS) else '0';
    
    -- Downsampling V memory addresses (better to replicate, because with different PRs sync gets difficult)
    dsv_pixel_addr_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            addr_dsv_pixel <= (others => '0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and pixelv_read='1') then
                if (addr_dsv_pixel=max_pixel) then
                    addr_dsv_pixel <= (others => '0');
                else
                    addr_dsv_pixel <= addr_dsv_pixel + 1;
                end if;
            end if;
            
            addr_dsv_pixel_delay(0) <= addr_dsv_pixel;
            addr_dsv_pixel_delay(3 downto 1) <= addr_dsv_pixel_delay(2 downto 0);
            
        end if;
    end process;
    
    dsv_line_addr_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            addr_dsv_line <= (others => '0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and pixelv_read='1') then
                if (addr_dsv_pixel=max_pixel) then
                    if (addr_dsv_line=max_line) then
                        addr_dsv_line <= (others => '0');
                    else
                        addr_dsv_line <= addr_dsv_line + 1;
                    end if;
                end if;
            end if;
            
            addr_dsv_line_delay(0) <= addr_dsv_line;
            addr_dsv_line_delay(3 downto 1) <= addr_dsv_line_delay(2 downto 0);
        end if;
    end process;
    
    pixelv_last <= '1' when (addr_dsv_pixel=max_pixel and addr_dsv_line=max_line) else '0';
    
    -- Adders and registers for DS v
    reg_v_gen: for I in 0 to 2 generate
        first_gen: if (I=0) generate
            reg_v_proc: process (clk_i, ready_i, addr_dsv_line_delay)
            begin
                if (rising_edge(clk_i)) then
                    if (ready_i='1' and addr_dsv_line(0)='0') then --addr_dsv_line_delay(0)(0)
                        previous_v_reg(0)(to_integer(addr_dsv_pixel)) <= "0000"&downsample_h_reg_pr; --addr_dsv_pixel_delay(0)
                    end if;
                end if;
            end process;
        end generate;
        
        other_gen: if (I>0) generate
                signal ones : unsigned(I-1 downto 0) := (others=>'1');
            begin
                reg_v_proc: process (clk_i, ready_i, addr_dsv_line_delay)
                begin
                    if (rising_edge(clk_i)) then
                        if (ready_i='1' and addr_dsv_line_delay(I-1)(I)='0' and addr_dsv_line_delay(I-1)(I-1 downto 0)=ones) then
                            previous_v_reg(I)(to_integer(addr_dsv_pixel_delay(I-1))) <= adder_v_reg(I-1);
                        end if;
                    end if;
                end process;
        end generate;
    end generate;
    
    
    adder_v_gen: for I in 0 to 2 generate
        first_gen: if (I=0) generate
            adder_v_proc: process (clk_i, ready_i, addr_dsv_line_delay)
            begin
                if (rising_edge(clk_i)) then
                    if (ready_i='1' and addr_dsv_line(0)='1') then--addr_dsv_line_delay(0)(0)
                        adder_v_reg(0) <= "0000"&downsample_h_reg_pr + previous_v_reg(0)(to_integer(addr_dsv_pixel));--addr_dsv_pixel_delay(0)
                    end if;
                end if;
            end process;
        end generate;
        
        other_gen: if (I>0) generate
                signal ones : unsigned(I-1 downto 0) := (others=>'1');
            begin
                adder_h_proc: process (clk_i, ready_i, addr_dsv_line_delay)
                begin
                    if (rising_edge(clk_i)) then
                        if (ready_i='1' and addr_dsv_line_delay(I-1)(I)='1' and addr_dsv_line_delay(I-1)(I-1 downto 0)=ones) then
                            adder_v_reg(I) <= adder_v_reg(I-1) + previous_v_reg(I)(to_integer(addr_dsv_pixel_delay(I-1)));
                        end if;
                    end if;
                end process;
        end generate;
    end generate;
    
    ds_v_gen: for I in 0 to 2 generate
        downsample_v_reg(I) <= adder_v_reg(I)(7+I+1 downto I+1);
    end generate;
    
    -- Choose DSv according to PR -- MAYBE THE MATCHING PR-DS IS THE INVERSE
--    downsample_v_pr <= downsample_v_reg(0) when (prv_array="100") else
--                       downsample_v_reg(1) when (prv_array="011") else
--                       downsample_v_reg(2) when (prv_array="001" or prv_array="010") else
--                       downsample_h_reg_pr;
                       
    downsample_v_pr <= downsample_h_reg_pr when (prv_array="100") else
                       downsample_v_reg(2) when (prv_array="011") else
                       downsample_v_reg(1) when (prv_array="001" or prv_array="010") else
                       downsample_v_reg(0);
                           
    -- Choose ready signal for DSv (to mark 1st valid DS pixel)
--    pixelv_calculated <= addr_dsv_line(0) when (prv_array="100") else
--                         (addr_dsv_line_delay(0)(1) and addr_dsv_line_delay(0)(0)) when (prv_array="011") else
--                         (addr_dsv_line_delay(1)(2) and addr_dsv_line_delay(1)(1) and addr_dsv_line_delay(1)(0)) when (prv_array="001" or prv_array="010") else
--                         pixelv_read;
                         
    pixelv_calculated <= pixelv_read when (prv_array="100") else
                         (addr_dsv_line_delay(1)(2) and addr_dsv_line_delay(1)(1) and addr_dsv_line_delay(1)(0)) when (prv_array="011") else
                         (addr_dsv_line_delay(0)(1) and addr_dsv_line_delay(0)(0)) when (prv_array="001" or prv_array="010") else
                         addr_dsv_line(0);
                         
--    pixel_reg <= addr_dsv_line_delay(0)(0) when (prv_array="100") else
--                 (addr_dsv_line_delay(1)(1) and addr_dsv_line_delay(1)(0)) when (prv_array="011") else
--                 (addr_dsv_line_delay(2)(2) and addr_dsv_line_delay(2)(1) and addr_dsv_line_delay(2)(0)) when (prv_array="001" or prv_array="010") else
--                 pixelv_read_delay;
                 
    pixel_reg <= pixelv_read_delay when (prv_array="100") else
                 (addr_dsv_line_delay(2)(2) and addr_dsv_line_delay(2)(1) and addr_dsv_line_delay(2)(0)) when (prv_array="011") else
                 (addr_dsv_line_delay(1)(1) and addr_dsv_line_delay(1)(0)) when (prv_array="001" or prv_array="010") else
                 addr_dsv_line_delay(0)(0);
                         
    -- Saving results to external memory - state machine
    save_next_proc: process(clk_i, reset_i, ready_i)
    begin
        if (reset_i='0') then
            save_state_current <= IDLE;
        elsif (rising_edge(clk_i)) then
            if (ready_i='1') then
                save_state_current <= save_state_next;
            end if;
        end if;
    end process;
    
    save_state_proc: process(clk_i, reset_i, save_state_current,
                            pixelv_calculated)
    begin
        case save_state_current is
            when IDLE =>
                if (pixelv_calculated='1') then
                    save_state_next <= SAVE_DS;
                else
                    save_state_next <= IDLE;
                end if;
                
            when SAVE_DS =>
                if (pixelsave_last='1') then
                    save_state_next <= IDLE;
                else
                    save_state_next <= SAVE_DS;
                end if;

            when others =>
                save_state_next <= IDLE;
        end case;
    end process;
    
    hle_switch_reg <= '0' when (save_state_current = SAVE_DS) else '1';
    pixelv_save <= '1' when (save_state_current = SAVE_DS) else '0';
    
    -- External memory addresses to save pixels
    dso_pixel_addr_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            addr_dso_pixel <= (others => '0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and pixelv_save='1') then
                if (addr_dso_pixel=max_pixel) then
                    addr_dso_pixel <= (others => '0');
                else
                    addr_dso_pixel <= addr_dso_pixel + 1;
                end if;
            end if;
            
            addr_dso_pixel_delay <= addr_dso_pixel;
        end if;
    end process;
    
    dso_line_addr_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            addr_dso_line <= (others => '0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and pixelv_save='1') then
                if (addr_dso_pixel=max_pixel) then
                    if (addr_dso_line=max_line) then
                        addr_dso_line <= (others => '0');
                    else
                        addr_dso_line <= addr_dso_line + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    pixelsave_last <= '1' when (addr_dso_line=max_line and addr_dso_pixel=max_pixel) else '0';
    
    -- An extra buffer for the line we are saving (depending on the PR it will be repeated)
    buffer_line_proc: process(clk_i, pixelv_calculated)
    begin
        if (rising_edge(clk_i)) then
            if (pixel_reg='1') then
                downsample_v_reg_pr(to_integer(addr_dso_pixel)) <= downsample_v_pr;
            end if;
        end if;
    end process;
    
    -- Address and data out
    addr_w_o_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            addr_w_ds_o <= std_logic_vector((addr_dso_line(5 downto 0) & "00000") +
                                              (addr_dso_line(7 downto 0) & "000") +
                                              addr_dso_pixel);
                                              
            switch_ds_hle_o <= hle_switch_reg;
            pixelv_read_delay <= pixelv_read;
        end if;
    end process;
    
    DS_o_mock <= std_logic_vector(downsample_v_pr);--std_logic_vector(downsample_v_reg_pr(to_integer(addr_dso_pixel_delay)));
    DS_o <= std_logic_vector(downsample_v_reg_pr(to_integer(addr_dso_pixel_delay)));
    
end Behavioral;
