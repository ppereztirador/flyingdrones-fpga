----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2022 03:41:31 PM
-- Design Name: 
-- Module Name: blockHle - Behavioral
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

entity blockHle is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           ready_i : in STD_LOGIC;
           
           -- PRs
           PRH_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           PRV_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           valid_pr_i : in STD_LOGIC;
           
           -- Data from memory
           DS_i : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           switch_ds_hle_i : in STD_LOGIC;
           addr_r_hle_o : out STD_LOGIC_VECTOR(10 DOWNTO 0);
           
           -- Access to hop cache
           addr_hop_o : out STD_LOGIC_VECTOR(17 downto 0);
           req_hop_o : out STD_LOGIC;
           valid_hop_i : in STD_LOGIC;
           value_hop_i : in STD_LOGIC_VECTOR(11 downto 0);
           
           -- Results out
           hop_o : out STD_LOGIC_VECTOR(3 DOWNTO 0);
           first_luma_o : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           pppx_o : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           pppy_o : out STD_LOGIC_VECTOR(1 DOWNTO 0);
           valid_o : out STD_LOGIC;
           ready_o : out STD_LOGIC);
end blockHle;

architecture Behavioral of blockHle is
    signal mem_read_valid, block_enable : std_logic; -- This signal makes the system wait while reading the cache
    signal mem_enable, addr_enable, hop_enable : std_logic;
    signal valid_hop_delay : std_logic;
    
    type val_array is array(integer range <>) of signed(8 downto 0);
    signal previous_memory : val_array(39 downto 0);
    
    -- PRs for this block
    signal prh_value, prv_value : std_logic_vector(2 downto 0);
    
    -- Address for the external memory
    signal addr_r_hle_u, addr_r_hle_pixel, addr_r_hle_line : unsigned(10 downto 0);
    signal pixel_current, line_current : unsigned(10 downto 0);
    signal increment_pixel, increment_line : unsigned(10 downto 0);
    signal max_line : unsigned(10 downto 0) := to_unsigned(SIZE_BLOCK_V-1, 11);
    signal max_pixel : unsigned(10 downto 0) := to_unsigned(SIZE_BLOCK_H-1, 11);
    
    signal pixel_read, pixel_last : std_logic;
    
    -- State machine for external reads
    type mem_state_type is (IDLE, WAIT_SWITCH, START_PIXEL_READ, LAST_PIXEL_READ);
    signal mem_state_current, mem_state_next : mem_state_type := IDLE;
    
    -- Signals to identify the position of the pixel
    signal pixel_corner, pixel_top, pixel_left, pixel_right : std_logic;
    
    -- Prediction
    signal orig : unsigned(6 downto 0);
    signal pixel_value, pixel_cache, pred : signed(8 downto 0);
    signal pred_p_gradient, pred_p_gradient_estimate : signed(9 downto 0);
    signal gradient : signed(9 downto 0);
    signal h1 : unsigned(7 downto 0);
    signal small_hop, last_small_hop : std_logic;
    
    -- Hop cache
    type hop_state_type is (IDLE, WAIT_MEM, CALC_PRED, CALC_HOP_ADDR, WAIT_HOP);
    signal hop_state_current, hop_state_next : hop_state_type := IDLE;
    signal addr_hop_pred, addr_hop_h1 : unsigned(17 downto 0); -- Intermediate signals for the hop address
    signal addr_hop_orig, addr_hop_u : unsigned(17 downto 0); -- Intermediate signals for the hop address
    signal hop_value : signed(8 downto 0);
    
    -- Data for outputs
    signal first_luma_internal : std_logic_vector(7 downto 0);
    signal pppx, pppy : std_logic_vector(1 downto 0);
    
begin
    -- Register PR for this block
    prsave_proc: process(clk_i, reset_i, valid_pr_i)
    begin
        if (reset_i='0') then
            prh_value <= (others=>'0');
            prv_value <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and valid_pr_i='1') then
                prh_value <= PRH_i;
                prv_value <= PRV_i;
            end if;
        end if;
    end process;
    
    -- Each PR will have a different address increment -- MAYBE THE MATCHING PR-DS IS THE INVERSE
--    increment_pixel <= "00000000001" when (prh_value="101") else
--                       "00000000010" when (prh_value="100") else
--                       "00000000100" when (prh_value="011") else
--                       "00000001000";
                       
--    max_pixel <= to_unsigned(SIZE_BLOCK_H-1, 11) when (prh_value="101") else
--                 to_unsigned(SIZE_BLOCK_H-2, 11) when (prh_value="100") else
--                 to_unsigned(SIZE_BLOCK_H-4, 11) when (prh_value="011") else
--                 to_unsigned(SIZE_BLOCK_H-8, 11);                   
                       
--    increment_line <= "00000000001" when (prv_value="101") else
--                      "00000000010" when (prv_value="100") else
--                      "00000000100" when (prv_value="011") else
--                      "00000001000";
                      
--    max_line <= to_unsigned(SIZE_BLOCK_V-1, 11) when (prv_value="101") else
--                to_unsigned(SIZE_BLOCK_V-2, 11) when (prv_value="100") else
--                to_unsigned(SIZE_BLOCK_V-4, 11) when (prv_value="011") else
--                to_unsigned(SIZE_BLOCK_V-8, 11);

    increment_pixel <= "00000001000" when (prh_value="101") else
                       "00000000100" when (prh_value="100") else
                       "00000000010" when (prh_value="011") else
                       "00000000001";
                       
    max_pixel <= to_unsigned(SIZE_BLOCK_H-8, 11) when (prh_value="101") else
                 to_unsigned(SIZE_BLOCK_H-4, 11) when (prh_value="100") else
                 to_unsigned(SIZE_BLOCK_H-2, 11) when (prh_value="011") else
                 to_unsigned(SIZE_BLOCK_H-1, 11);                   
                       
    increment_line <= "00000001000" when (prv_value="101") else
                      "00000000100" when (prv_value="100") else
                      "00000000010" when (prv_value="011") else
                      "00000000001";
                      
    max_line <= to_unsigned(SIZE_BLOCK_V-8, 11) when (prv_value="101") else
                to_unsigned(SIZE_BLOCK_V-4, 11) when (prv_value="100") else
                to_unsigned(SIZE_BLOCK_V-2, 11) when (prv_value="011") else
                to_unsigned(SIZE_BLOCK_V-1, 11);
    
    ----------------------------------------------------------------------------

    -- Register valid
    validhop_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            valid_hop_delay <= valid_hop_i;
        end if;
    end process;

    -- State machine -start to read only after a PR has been signaled
    mem_next_proc: process(clk_i, reset_i, ready_i)
    begin
        if (reset_i='0') then
            mem_state_current <= IDLE;
        elsif (rising_edge(clk_i)) then
            if (ready_i='1') then
                mem_state_current <= mem_state_next;
            end if;
        end if;
    end process;
    
    mem_state_proc: process(clk_i, reset_i, mem_state_current,
                            pixel_last, switch_ds_hle_i)
    begin
        case mem_state_current is
            when IDLE =>
                if (switch_ds_hle_i='0') then
                    mem_state_next <= WAIT_SWITCH;
                else
                    mem_state_next <= IDLE;
                end if;
                
            when WAIT_SWITCH =>
                if (switch_ds_hle_i='1') then
                    mem_state_next <= START_PIXEL_READ;
                else
                    mem_state_next <= WAIT_SWITCH;
                end if;
                
            when START_PIXEL_READ =>
                if (pixel_last='1') then
                    mem_state_next <= LAST_PIXEL_READ;
                else
                    mem_state_next <= START_PIXEL_READ;
                end if;
                
            when LAST_PIXEL_READ =>
                mem_state_next <= IDLE;

            when others =>
                mem_state_next <= IDLE;
        end case;
    end process;
    
    pixel_read <= '1' when (mem_state_current=START_PIXEL_READ or mem_state_current=LAST_PIXEL_READ) else '0';
    
    -- Memory addresses
    mem_pixel_addr_proc: process(clk_i, reset_i, ready_i, pixel_read, block_enable, mem_state_current, max_pixel)
    begin
        if (reset_i='0') then
            addr_r_hle_pixel <= (others => '0');
        elsif (rising_edge(clk_i)) then
            if (mem_state_current=IDLE) then
                addr_r_hle_pixel <= (others => '0');
            elsif (ready_i='1' and pixel_read='1' and block_enable='1') then
                if (addr_r_hle_pixel=max_pixel) then
                    addr_r_hle_pixel <= (others => '0');
                else
                    addr_r_hle_pixel <= addr_r_hle_pixel + increment_pixel;
                end if;
            end if;
        end if;
    end process;
    
    mem_line_addr_proc: process(clk_i, reset_i, mem_state_current)
    begin
        if (reset_i='0') then
            addr_r_hle_line <= (others => '0');
        elsif (rising_edge(clk_i)) then
            if (mem_state_current=IDLE) then
                    addr_r_hle_line <= (others => '0');
            elsif (ready_i='1' and pixel_read='1' and block_enable='1') then
                if (addr_r_hle_pixel=max_pixel) then
                    if (addr_r_hle_line=max_line) then
                        addr_r_hle_line <= (others => '0');
                    else
                        addr_r_hle_line <= addr_r_hle_line + increment_line;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    addr_r_hle_u <= (addr_r_hle_line(5 downto 0) & "00000") +
                    (addr_r_hle_line(7 downto 0) & "000") +
                    addr_r_hle_pixel;
    addr_r_hle_o <= std_logic_vector(addr_r_hle_u);
    
    pixel_last <= '1' when (addr_r_hle_pixel=max_pixel and addr_r_hle_line=max_line) else '0';
    
    -- Register current pixel for the rest of the operations
    currentpx_proc: process (clk_i, ready_i, block_enable)
    begin
        if (rising_edge(clk_i)) then
            if (ready_i='1' and block_enable='1') then
                pixel_current <= addr_r_hle_pixel;
                line_current <= addr_r_hle_line;
                assert (to_integer(pixel_current)<40) report "Pixel >= 40: " & integer'image(to_integer(pixel_current)) severity warning;
            end if;
        end if;
    end process;
    
    -- Signals to identify the position based on address
    pixel_corner <= '1' when (line_current="00000000000" and pixel_current="00000000000") else '0';
    pixel_top <= '1' when (line_current="00000000000") else '0';
    pixel_left <= '1' when (pixel_current="00000000000") else '0';
    pixel_right <= '1' when (pixel_current=max_pixel) else '0';
    
    -- Calculate pixel value based on neighbours
    neighbour_proc: process (clk_i, reset_i, ready_i, mem_enable)
        variable pred_full : signed(8 downto 0);
    begin
        if (reset_i='0') then
            pred_full := (others=>'0');
            pred <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and mem_enable='1') then
                if (pixel_corner='1') then
                    pred_full := "0" & signed(DS_i);
                    pred <= pred_full;
                elsif (pixel_top='1') then
                    pred_full := previous_memory(to_integer(pixel_current-increment_pixel));
                    pred <= pred_full;
                elsif (pixel_left='1') then
                    pred_full := previous_memory(0);
                    pred <= pred_full;
                elsif (pixel_right='1') then
                    pred_full := previous_memory(to_integer(pixel_current-increment_pixel)) + previous_memory(to_integer(pixel_current));
                    pred <= "0" & pred_full(8 downto 1);
                else
                    pred_full := previous_memory(to_integer(pixel_current-increment_pixel)) + previous_memory(to_integer(pixel_current+increment_pixel));
                    pred <= "0" & pred_full(8 downto 1); 
                end if;
            end if;
        end if;
    end process;
    
    pred_p_gradient_estimate <= "0"&pred + gradient;
    
    pred_proc: process (clk_i, reset_i, ready_i, mem_read_valid)
    begin
        if (reset_i='0') then
            pred_p_gradient <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and mem_read_valid='1') then
                if (pred_p_gradient_estimate>"0011111111") then
                    pred_p_gradient <= "0011111111";
                elsif (pred_p_gradient_estimate<"0000000000") then
                    pred_p_gradient <= "0000000000";
                else
                    pred_p_gradient <= pred_p_gradient_estimate;
                end if;
            end if;
        end if;
    end process;
    
    orig_proc:  process (clk_i, reset_i, ready_i, mem_enable)
    begin
        if (reset_i='0') then
            orig <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and mem_enable='1') then
                if (DS_i(7)='0') then -- <128
                    orig <= unsigned(DS_i(6 downto 0));
                else
                    orig <= unsigned(not(DS_i(6 downto 0))); -- 255 - ds
                end if;
            end if;
        end if;
    end process;
    
    -- Hop temporal memory (save the previous hop result)
    prev_mem_proc: process(clk_i, reset_i, ready_i, hop_enable)
    begin
        if (rising_edge(clk_i)) then
            if (ready_i='1' and hop_enable='1') then
            -- TEMP MODIFICATIONS TO SEE WHAT'S HAPPENING WITH ADDRESSES>39
            assert (to_integer(pixel_current)<40) report "Pixel >= 40: " & integer'image(to_integer(pixel_current)) severity warning;
            if (to_integer(pixel_current)<40) then
                previous_memory(to_integer(pixel_current)) <= '0' & signed(value_hop_i(7 downto 0));
            else
                previous_memory(39) <= '0' & signed(value_hop_i(7 downto 0));
            end if;
            --    previous_memory(to_integer(pixel_current)) <= '0' & signed(value_hop_i(7 downto 0));
            end if;
        end if;
    end process;
    
    -- Request hops from cache - state machine
    hop_next_proc: process(clk_i, reset_i, ready_i)
    begin
        if (reset_i='0') then
            hop_state_current <= IDLE;
        elsif (rising_edge(clk_i)) then
            if (ready_i='1') then
                hop_state_current <= hop_state_next;
            end if;
        end if;
    end process;
    
    hop_state_proc: process(clk_i, reset_i, hop_state_current,
                            pixel_read, valid_hop_i)
    begin
        case hop_state_current is
            when IDLE =>
                if (pixel_read='1') then
                    hop_state_next <= WAIT_MEM;
                else
                    hop_state_next <= IDLE;
                end if;
                
            when WAIT_MEM =>
                hop_state_next <= CALC_PRED;
                    
            when CALC_PRED =>
                hop_state_next <= CALC_HOP_ADDR;
                
            when CALC_HOP_ADDR =>
                hop_state_next <= WAIT_HOP;
                
            when WAIT_HOP =>
                if (valid_hop_i='1') then
                    hop_state_next <= IDLE;
                else
                    hop_state_next <= WAIT_HOP;
                end if;

            when others =>
                hop_state_next <= IDLE;
        end case;
    end process;
    
    hop_enable <= '1' when (hop_state_current=WAIT_HOP) else '0';
    mem_read_valid <= '1' when (hop_state_current=CALC_PRED) else '0';
    mem_enable <= '1' when (hop_state_current=WAIT_MEM) else '0';
    block_enable <= '1' when (hop_state_current=IDLE) else '0';
    addr_enable <= '1' when (hop_state_current=CALC_HOP_ADDR) else '0';
    
    req_hop_o <= hop_enable;
    
    -- Intermediate signals for the hop address
    addr_hop_orig <= (orig & "000") - ("000" & orig) & "00000000";-- 7 * 256 * orig = (orig<<3 - orig) << 8
    addr_hop_pred <= "00000" & ((unsigned(pred_p_gradient) & "000") - ("000" & unsigned(pred_p_gradient)));-- 7 * pred = pred<<3 - pred
    addr_hop_h1 <= "0000000000" & (h1 - "00000100"); 
    
    -- Hop address
    --addr_hop_o <= "0000000000" & DS_i; -- Temporarily for test
    addr_hop_proc: process (clk_i, reset_i, ready_i, addr_enable)
    begin
        if (reset_i='0') then
            addr_hop_u <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and addr_enable='1') then
                addr_hop_u <= addr_hop_orig + addr_hop_pred + addr_hop_h1;
            end if;
        end if;
    end process;
    
    addr_hop_o <= std_logic_vector(addr_hop_u);
    
    hop_value <= "00000" & signed(value_hop_i(11 downto 8));
    
    -- Small hop
    small_proc: process (clk_i, reset_i, ready_i, addr_enable)
    begin
        if (reset_i='0') then
            small_hop <= '1';
            last_small_hop <= '1';
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and valid_hop_i='1') then
                --if (hop_value<="000000101" and hop_value>="000000011") then -- maybe rewrite the condition
                if (hop_value="000000101" or hop_value="000000100" or hop_value="000000011") then -- maybe rewrite the condition
                    small_hop <= '1';
                else
                    small_hop <= '0';
                end if;
                
                last_small_hop <= small_hop; 
            end if;
        end if;
    end process;
    
    -- Update gradient
    grad_proc:  process (clk_i, reset_i, ready_i, valid_hop_i)
    begin
        if (reset_i='0') then
            gradient <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and valid_hop_delay='1') then
                if (hop_value="000000101") then
                    gradient <= "0000000001";
                elsif (hop_value="000000011") then
                    gradient <= "1111111111";
                elsif (small_hop='0') then
                    gradient <= "0000000000";
                else
                    gradient <= gradient;
                end if;
            end if;
        end if;
    end process;
    
    -- Upgrade h1
    h1_proc:  process (clk_i, reset_i, ready_i, valid_hop_i)
    begin
        if (reset_i='0') then
            h1 <= "00000101";
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and valid_hop_delay='1') then
                if (small_hop='1' and last_small_hop='1' and h1>"00000100") then
                    h1 <= h1 - 1;
                elsif (hop_value="000000111" or hop_value="000001000" or
                       hop_value="000000001" or hop_value="000000000") then
                    h1 <= "00001010";
                else
                h1 <= h1;
                end if;
                 
            end if;
        end if;
    end process;
    
    -- Other signals
    luma_proc: process (clk_i, reset_i, ready_i, mem_enable)
    begin
        if (reset_i='0') then
            first_luma_internal <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and mem_enable='1') then
                if (pixel_corner='1') then
                    first_luma_internal <= DS_i;
                end if;
            end if;
        end if;
    end process;
    
    ppp_proc: process(clk_i, reset_i, valid_pr_i)
    begin
        if (reset_i='0') then
            pppx <= (others=>'0');
            pppy <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (ready_i='1' and valid_pr_i='1') then
                case PRH_i is
                    when "001" =>
                        pppx <= "00";
                    when "010" =>
                        pppx <= "00";
                    when "011" =>
                        pppx <= "01";
                    when "100" =>
                        pppx <= "10";
                    when "101" =>
                        pppx <= "11";
                    when others =>
                        pppx <= "11";
                end case;
                
                case PRV_i is
                    when "001" =>
                        pppy <= "00";
                    when "010" =>
                        pppy <= "00";
                    when "011" =>
                        pppy <= "01";
                    when "100" =>
                        pppy <= "10";
                    when "101" =>
                        pppy <= "11";
                    when others =>
                        pppy <= "11";
                end case;
                
            end if;
        end if;
    end process; 
    
    -- Outputs
    first_luma_o <= first_luma_internal;
    pppx_o <= pppx;
    pppy_o <= pppy;
    
    hop_o_proc: process (clk_i, valid_hop_delay)
    begin
        if (rising_edge(clk_i)) then
            if (valid_hop_delay='1') then
                hop_o <= std_logic_vector(hop_value(3 downto 0));
            end if;
            valid_o <= valid_hop_delay;
        end if;
    end process;
    
    -- Ready after last hop
    ready_o <= '1' when (mem_state_current=IDLE and hop_state_current=IDLE) else '0';
    
    
end Behavioral;
