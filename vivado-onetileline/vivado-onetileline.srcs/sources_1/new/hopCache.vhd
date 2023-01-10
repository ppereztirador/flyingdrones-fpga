----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/16/2022 11:25:42 AM
-- Design Name: 
-- Module Name: hopCache - Behavioral
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

entity hopCache is
    Generic (SIZE_CACHE_VECTOR : integer := SIZE_H_BK/2);
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           
           address_block_a_i : in vector_array_hop_address(SIZE_CACHE_VECTOR-1 downto 0);
           address_block_b_i : in vector_array_hop_address(SIZE_CACHE_VECTOR-1 downto 0);
           
           req_block_a_i : in std_logic_vector(SIZE_CACHE_VECTOR-1 downto 0);
           req_block_b_i : in std_logic_vector(SIZE_CACHE_VECTOR-1 downto 0);
           
           valid_block_a_o : out std_logic_vector(SIZE_CACHE_VECTOR-1 downto 0);
           valid_block_b_o : out std_logic_vector(SIZE_CACHE_VECTOR-1 downto 0);
           
           data_block_a_o : out std_logic_vector(11 downto 0);
           data_block_b_o : out std_logic_vector(11 downto 0)
           );
end hopCache;

architecture Behavioral of hopCache is

    COMPONENT blk_mem_hopcache
      PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
        clkb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
      );
    END COMPONENT;
    
    signal addra, addrb : std_logic_vector(17 downto 0);

    -- Memory arbitration
    --signal current_block_a, current_block_b : std_logic_vector((SIZE_H_BK/2)-1 downto 0);
    signal current_block_a, current_block_b : unsigned(integer(ceil(log2(real(SIZE_CACHE_VECTOR))))-1 downto 0);
    
    type arb_state_type is (CHECK_REQ, WAIT_MEM, VALID_MEM, CHANGE_BLOCK);
    signal arb_state_current_a, arb_state_next_a : arb_state_type := CHECK_REQ;
    signal arb_state_current_b, arb_state_next_b : arb_state_type := CHECK_REQ;
    
    signal wait_counter_a, wait_counter_b : unsigned(1 downto 0); -- At most 2 cycles...
    
begin

    -- Memory
    cache_inst: blk_mem_hopcache
    port map (
        clka => clk_i,
        addra => addra,
        douta => data_block_a_o,
        clkb => clk_i,
        addrb => addrb,
        doutb => data_block_b_o
    );

    -- State machine for block polling (a)
    arb_nexta_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            arb_state_current_a <= CHECK_REQ;
        elsif (rising_edge(clk_i)) then
            arb_state_current_a <= arb_state_next_a;
        end if;
    end process;
    
    arb_statea_proc: process(arb_state_current_a, req_block_a_i, current_block_a, wait_counter_a)
        variable zeros : std_logic_vector(SIZE_CACHE_VECTOR-1 downto 0);
    begin
        zeros := (others=>'0');
        
        case arb_state_current_a is
            when CHECK_REQ =>
                --if ((req_block_a_i and current_block_a) = zeros) then -- No req in current block
                if (req_block_a_i(to_integer(current_block_a)) = '0') then -- No req in current block
                    arb_state_next_a <= CHANGE_BLOCK;
                else
                    arb_state_next_a <= WAIT_MEM;
                end if;
                
            when WAIT_MEM =>
                --if (wait_counter_a="10") then
                    arb_state_next_a <= VALID_MEM;
                --else
                --    arb_state_next_a <= WAIT_MEM;
                --end if;
                
            when VALID_MEM =>
                arb_state_next_a <= CHECK_REQ;
                
            when CHANGE_BLOCK =>
                arb_state_next_a <= CHECK_REQ;
                
            when OTHERS =>
                arb_state_next_a <= CHECK_REQ;
        end case;
    end process;
    
    -- Counters for (a)
    arb_waita_proc: process(clk_i, reset_i, arb_state_current_a)
    begin
        if (reset_i='0') then
            wait_counter_a <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (wait_counter_a="11") then
                wait_counter_a <= (others=>'0');
            elsif (arb_state_current_a=WAIT_MEM) then
                wait_counter_a <= wait_counter_a + 1;
            end if;
        end if;
    end process;
    
    changea_proc:  process(clk_i, reset_i, arb_state_current_a)
        variable zeros : std_logic_vector(SIZE_CACHE_VECTOR-2 downto 0);
    begin
        zeros := (others=>'0');
        
        if (reset_i='0') then
            --current_block_a <= zeros & '1';
            current_block_a <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (arb_state_current_a=VALID_MEM or arb_state_current_a=CHANGE_BLOCK) then
                --current_block_a <= current_block_a((SIZE_H_BK/2)-2 downto 0) & current_block_a((SIZE_H_BK/2)-1);
                if (current_block_a=SIZE_CACHE_VECTOR-1) then
                    current_block_a <= (others=>'0');
                else 
                    current_block_a <= current_block_a + 1;
                end if;
            end if;
        end if;
    end process;


    -- State machine for block polling (b)
    arb_nextb_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            arb_state_current_b <= CHECK_REQ;
        elsif (rising_edge(clk_i)) then
            arb_state_current_b <= arb_state_next_b;
        end if;
    end process;
    
    arb_stateb_proc: process(arb_state_current_b, req_block_b_i, current_block_b, wait_counter_b)
        variable zeros : std_logic_vector(SIZE_CACHE_VECTOR-1 downto 0);
    begin
        zeros := (others=>'0');
        
        case arb_state_current_b is
            when CHECK_REQ =>
                --if ((req_block_b_i and current_block_b) = zeros) then -- No req in current block
                if (req_block_b_i(to_integer(current_block_b)) = '0') then -- No req in current block
                    arb_state_next_b <= CHANGE_BLOCK;
                else
                    arb_state_next_b <= WAIT_MEM;
                end if;
                
            when WAIT_MEM =>
--                if (wait_counter_b="10") then
                    arb_state_next_b <= VALID_MEM;
--                else
--                    arb_state_next_b <= WAIT_MEM;
--                end if;
                
            when VALID_MEM =>
                arb_state_next_b <= CHECK_REQ;
                
            when CHANGE_BLOCK =>
                arb_state_next_b <= CHECK_REQ;
                
            when OTHERS =>
                arb_state_next_b <= CHECK_REQ;
        end case;
    end process;
    
    -- Counters for (b)
    arb_waitb_proc: process(clk_i, reset_i, arb_state_current_b)
    begin
        if (reset_i='0') then
            wait_counter_b <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (wait_counter_b="11") then
                wait_counter_b <= (others=>'0');
            elsif (arb_state_current_b=WAIT_MEM) then
                wait_counter_b <= wait_counter_b + 1;
            end if;
        end if;
    end process;
    
    changeb_proc:  process(clk_i, reset_i, arb_state_current_b)
        variable zeros : std_logic_vector(SIZE_CACHE_VECTOR-2 downto 0);
    begin
        zeros := (others=>'0');
        
        if (reset_i='0') then
            --current_block_b <= zeros & '1';
            current_block_b <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (arb_state_current_b=VALID_MEM or arb_state_current_b=CHANGE_BLOCK) then
                --current_block_b <= current_block_b((SIZE_H_BK/2)-2 downto 0) & current_block_b((SIZE_H_BK/2)-1);
                if (current_block_b=SIZE_CACHE_VECTOR-1) then
                    current_block_b <= (others=>'0');
                else
                    current_block_b <= current_block_b + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Addresses
    addra <= address_block_a_i(to_integer(current_block_a));
    addrb <= address_block_b_i(to_integer(current_block_b));
    
    -- Valid
    valida_gen: for I in 0 to SIZE_CACHE_VECTOR-1 generate
        valid_block_a_o(I) <= '1' when (arb_state_current_a=VALID_MEM and 
                                        current_block_a=to_unsigned(I, integer(ceil(log2(real(SIZE_CACHE_VECTOR))))))
                                  else '0';
        valid_block_b_o(I) <= '1' when (arb_state_current_b=VALID_MEM and 
                                        current_block_b=to_unsigned(I, integer(ceil(log2(real(SIZE_CACHE_VECTOR))))))
                                  else '0';
    end generate;

end Behavioral;
