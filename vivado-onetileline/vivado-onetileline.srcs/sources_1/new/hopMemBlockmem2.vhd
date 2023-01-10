----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/13/2022 02:34:48 PM
-- Design Name: 
-- Module Name: hopMemBlockmem - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;
Library UNIMACRO;
use UNIMACRO.vcomponents.all;

library WORK;
use WORK.lhe_lib.ALL;

entity hopMemBlockmem2 is
    Generic (NUMBER_MEMORIES : integer := SIZE_H_BK);
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           user_i : in STD_LOGIC;
           arm_i : in STD_LOGIC;
--           user_temp_i : in STD_LOGIC;
           
           hop_i : in vector_array_4(NUMBER_MEMORIES-1 downto 0);
           valid_hop_i : in STD_LOGIC_VECTOR(NUMBER_MEMORIES-1 downto 0);
           ready_hop_i : in std_logic_vector(NUMBER_MEMORIES-1 downto 0);
           mem_block_i : in STD_LOGIC_VECTOR(NUMBER_MEMORIES-1 downto 0);
           
           read_addr_i : in STD_LOGIC_VECTOR(14 downto 0);
           hop_read_o : out STD_LOGIC_VECTOR(8 downto 0);
           valid_rw_o : out STD_LOGIC;
           mem_full_o : out STD_LOGIC;
           mem_empty_o : out STD_LOGIC);
end hopMemBlockmem2;

architecture Behavioral of hopMemBlockmem2 is
    COMPONENT hop_mem_gen
      PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        clkb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
      );
    END COMPONENT;

    signal valid_reg : std_logic_vector(NUMBER_MEMORIES-1 downto 0);
    signal hop_reg : vector_array_4(NUMBER_MEMORIES-1 downto 0);
    signal mem_block_reg : std_logic_vector(NUMBER_MEMORIES-1 downto 0);
    signal fifo_write, fifo_reset : std_logic;
    signal fifo_read, fifo_read_1cycle : std_logic;
    signal fifo_read_delay : std_logic_vector(2 downto 0);
    signal fifo_data : std_logic_vector(8 downto 0);
    signal current_block : unsigned(integer(ceil(log2(real(NUMBER_MEMORIES))))-1 downto 0);
    
    signal write_addr_u, read_addr_u : unsigned(14 downto 0);
    signal write_addr, read_addr : std_logic_vector(14 downto 0);
    signal fifo_write_enable : std_logic_vector(0 downto 0);
    constant max_addr_u : unsigned(14 downto 0) := to_unsigned(640*40-1,15);
    
    signal reset_with_user : std_logic;
    
    type memory_state_type is (IDLE, WAIT_FRAME, WAIT_DOWN, SAVE_DATA);
    signal memory_state_current, memory_state_next : memory_state_type;
    
    signal current_memblock_u : unsigned(7 downto 0);
    constant ones : std_logic_vector(NUMBER_MEMORIES-1 downto 0) := (others=>'1');

--    attribute mark_debug : string;
--    attribute mark_debug of reset_i : signal is "true";
--    attribute mark_debug of user_i : signal is "true";
--    attribute mark_debug of fifo_write : signal is "true";
--    attribute mark_debug of mem_block_reg : signal is "true";
--    attribute mark_debug of write_addr : signal is "true";
--    attribute mark_debug of read_addr_i : signal is "true";
--    attribute mark_debug of fifo_data : signal is "true";
--    attribute mark_debug of hop_read_o : signal is "true";
--    attribute mark_debug of valid_hop_i : signal is "true";
--    attribute mark_debug of arm_i : signal is "true";
--    attribute mark_debug of mem_empty_o : signal is "true";
--    attribute mark_debug of memory_state_current : signal is "true";
begin

    -- Memory
    hop_mem_inst : hop_mem_gen
      PORT MAP (
        clka => clk_i,
        wea => fifo_write_enable,
        addra => write_addr,
        dina => fifo_data,
        clkb => clk_i,
        addrb => read_addr,
        doutb => hop_read_o
      );
      
    -- Register hops/valids
    reg_hop_gen: for I in 0 to NUMBER_MEMORIES-1 generate
        reg_hop_proc: process(clk_i, reset_i, valid_hop_i, reset_with_user)
        begin
            if (reset_with_user='0') then
                hop_reg(I) <= (others=>'0');
            elsif (rising_edge(clk_i)) then
                if (valid_hop_i(I)='1') then
                    hop_reg(I) <= hop_i(I);
                end if;
            end if;
        end process;
    end generate;
    
    reg_mem_gen: for I in 0 to NUMBER_MEMORIES-1 generate
        reg_hop_proc: process(clk_i, reset_i, valid_hop_i, reset_with_user)
        begin
            if (reset_with_user='0') then
                mem_block_reg(I) <= '0';
            elsif (rising_edge(clk_i)) then
                if (valid_hop_i(I)='1' and memory_state_current=SAVE_DATA) then
                    mem_block_reg(I) <= mem_block_i(I);
                end if;
            end if;
        end process;
    end generate;
    
    reg_valid_gen: for I in 0 to NUMBER_MEMORIES-1 generate
        reg_valid_proc: process(clk_i, reset_i, current_block, reset_with_user, valid_hop_i)
        begin
            if (reset_with_user='0') then
                valid_reg(I) <= '0';
            elsif (rising_edge(clk_i)) then
                if (valid_hop_i(I)='1' and memory_state_current=SAVE_DATA) then
                    valid_reg(I) <= '1';
                elsif (to_integer(current_block)=I) then
                    valid_reg(I) <= '0';
                end if;
            end if;
        end process;
    end generate;
    
    -- Round-robin the valids and set the FIFO write signal
    -- Counters for (a)
    changea_proc:  process(clk_i, reset_i, reset_with_user)
    begin
        if (reset_with_user='0') then
            current_block <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (current_block=NUMBER_MEMORIES-1) then
                current_block <= (others=>'0');
            else
                current_block <= current_block + 1;
            end if;
        end if;
    end process;
    
    -- Write FIFO
    fifo_write <= '1' when (valid_reg(to_integer(current_block))='1') else '0';
--    fifo_w_proc: process(clk_i, valid_reg)
--    begin
--        if (rising_edge(clk_i)) then
--            if (valid_reg(to_integer(current_block))='1') then
--                fifo_write <= '1';
--            else
--                fifo_write <= '0';
--            end if;
--        end if;
--    end process;
    fifo_write_enable(0) <= fifo_write;
    
    -- Addresses
    waddr_proc: process (clk_i, reset_i, fifo_write, reset_with_user)
    begin
        if (reset_with_user='0') then
            write_addr_u <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (fifo_write = '1') then
                if (write_addr_u=max_addr_u) then
                    --write_addr_u <= (others=>'0');
                    write_addr_u <= write_addr_u;
                else
                    write_addr_u <= write_addr_u + 1;
                end if;
            end if;
        end if;
    end process;
    
    write_addr <= std_logic_vector(write_addr_u);
    
    read_addr <= read_addr_i;
    
    -- Data
    data_gen: if (integer(ceil(log2(real(NUMBER_MEMORIES))))=4) generate
        fifo_data <= mem_block_reg(to_integer(current_block)) & std_logic_vector(current_block) & hop_reg(to_integer(current_block));
    end generate;
    
    data_less_gen: if (integer(ceil(log2(real(NUMBER_MEMORIES))))<4) generate
        signal zeros : std_logic_vector(4-integer(ceil(log2(real(NUMBER_MEMORIES))))-1 downto 0);
    begin
        zeros <= (others=>'0');
        fifo_data <= mem_block_reg(to_integer(current_block)) & zeros & std_logic_vector(current_block) & hop_reg(to_integer(current_block));
    end generate;
    
    data_general_gen: if (integer(ceil(log2(real(NUMBER_MEMORIES))))>4) generate
        fifo_data <= mem_block_reg(to_integer(current_block)) & std_logic_vector(current_block(3 downto 0)) & hop_reg(to_integer(current_block));
    end generate;
    
    -- Reset logic with start-of-frame signal (user)
--    rst_user_proc: process(clk_i, reset_i,  user_i)
--    begin
--        if (reset_i='0') then
--            reset_with_user <= '0';
--        elsif (rising_edge(clk_i)) then
--            if ((user_i='1')) then -- and (unsigned(read_addr)=max_addr_u)) then
--                reset_with_user <= '0';
--            else
--                reset_with_user <= '1';
--            end if;
--        end if;
--    end process;
    reset_with_user <= '0' when (reset_i='0' or (user_i='1' and
                                                 memory_state_current/=SAVE_DATA and
                                                 (read_addr>=write_addr)))
                        else '1';

    -- State machine -- don't write until ARM sends reset
    mem_cur_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            memory_state_current <= IDLE;
        elsif (rising_edge(clk_i)) then
            memory_state_current <= memory_state_next;
        end if;
    end process;
    
    mem_nxt_proc: process(memory_state_current, arm_i, user_i, ready_hop_i, read_addr, write_addr)
    begin
        case memory_state_current is
            when IDLE =>
                if (arm_i='1') then
                    memory_state_next <= WAIT_FRAME;
                else
                    memory_state_next <= IDLE;
                end if;
            when WAIT_FRAME =>
                if (user_i='1' and (read_addr>=write_addr)) then
                    memory_state_next <= WAIT_DOWN;
                else 
                    memory_state_next <= WAIT_FRAME;
                end if;
            when WAIT_DOWN =>
                if (ready_hop_i=ones) then
                    memory_state_next <= WAIT_DOWN;
                else
                    memory_state_next <= SAVE_DATA;
                end if;
            when SAVE_DATA =>
                if (ready_hop_i=ones) then
                    memory_state_next <= WAIT_FRAME;
                else
                    memory_state_next <= SAVE_DATA;
                end if;
            when others =>
                memory_state_next <= IDLE;
        end case;
    end process;
    
    -- Status
    mem_full_o <= '1' when (write_addr_u=max_addr_u) else '0';
    mem_empty_o <= '1' when (write_addr_u="000000000000000") else '0';
    valid_rw_o <= '1' when (read_addr < write_addr) else '0';    
end Behavioral;
