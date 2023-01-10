----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/26/2021 05:56:53 PM
-- Design Name: 
-- Module Name: diff_H_oneline - Behavioral
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

entity diff_H_oneline is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           valid_i : in STD_LOGIC;
           ready_i : in STD_LOGIC;
           Y_i : in STD_LOGIC_VECTOR (7 downto 0);
           num_pixel_i : in STD_LOGIC_VECTOR(7 downto 0);
           num_line_i : in STD_LOGIC_VECTOR(7 downto 0);
           num_block_i : in STD_LOGIC_VECTOR(7 downto 0);
           --valid_o : out STD_LOGIC_VECTOR(SIZE_H_BK-1 downto 0);
           valid_single_o : out STD_LOGIC;
           diff_accum_single_o : out STD_LOGIC_VECTOR(NUM_BITS_ACCUM_DIFF-1 downto 0);
           counter_accum_single_o : out STD_LOGIC_VECTOR(NUM_BITS_COUNTER_DIFF-1 downto 0)--;
           --diff_accum_o : out vector_array_accum(SIZE_H_BK-1 downto 0);
           --counter_accum_o : out vector_array_counter(SIZE_H_BK-1 downto 0)
           );
end diff_H_oneline;

architecture Behavioral of diff_H_oneline is
    signal diff_quant_total, diff_quant_delay1 : std_logic_vector(2 downto 0);
    signal diff_not0_total, diff_not0_delay1 : std_logic_vector(0 downto 0);
    
    signal num_block_1cycle, num_block_2cycle, num_block_3cycle : std_logic_vector(7 downto 0);
    
    -- difference blocks
    component diffH_block is
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               valid_i : in STD_LOGIC;
               ready_i : in STD_LOGIC;
               Y_i : in STD_LOGIC_VECTOR (7 downto 0);
               num_pixel_i : in STD_LOGIC_VECTOR(7 downto 0);
               valid_o : out STD_LOGIC;
               diff_quant_o : out STD_LOGIC_VECTOR(2 downto 0);
               diff_not0_o : out STD_LOGIC_VECTOR(0 downto 0)
             );
    end component;
    
    signal valid_i_block : std_logic_vector(SIZE_H_BK-1 downto 0);
    signal valid_o_diff, valid_o_diff_1cycle : std_logic;
    signal reset_block, reset_block_1cycle, reset_block_2cycle, reset_block_3cycle : std_logic_vector(SIZE_H_BK-1 downto 0);
    signal valid_single, valid_single_1cycle, valid_single_2cycle, valid_single_3cycle : std_logic;
    
    component accumulator is
        Generic ( NUM_BITS_IN : integer := 8;
                  NUM_BITS_OUT : integer := 13
              );
        Port ( clk_i : in STD_LOGIC;
               reset_i : in STD_LOGIC;
               en_i : in STD_LOGIC;
               data_i : in STD_LOGIC_VECTOR (NUM_BITS_IN-1 downto 0);
               accum_o : out STD_LOGIC_VECTOR (NUM_BITS_OUT-1 downto 0));
    end component;
    
    signal diff_accum : vector_array_accum(SIZE_H_BK-1 downto 0);
    signal counter_accum : vector_array_counter(SIZE_H_BK-1 downto 0);
    signal counter_accum_debug : vector_array_counter(2 downto 0);
    
    signal diff_accum_single : STD_LOGIC_VECTOR(NUM_BITS_ACCUM_DIFF-1 downto 0) := "0000000000000";
    signal counter_accum_single : STD_LOGIC_VECTOR(NUM_BITS_COUNTER_DIFF-1 downto 0) := "00000000000";
    
    --
    attribute mark_debug : string;
    --attribute mark_debug of Y_i : signal is "true";
    --attribute mark_debug of valid_i : signal is "true";
    --attribute mark_debug of ready_i : signal is "true";
    --attribute mark_debug of num_block_2cycle : signal is "true";
    --attribute mark_debug of valid_single_2cycle : signal is "true";
    --attribute mark_debug of valid_o_diff : signal is "true";
    --attribute mark_debug of diff_accum_single : signal is "true";
    --attribute mark_debug of counter_accum_single : signal is "true";
    --attribute mark_debug of diff_quant_delay1 : signal is "true";
    --attribute mark_debug of diff_quant_total : signal is "true";
    --attribute mark_debug of diff_not0_total : signal is "true";
    --attribute mark_debug of valid_i_block : signal is "true";
    --attribute mark_debug of reset_block : signal is "true";
    --attribute mark_debug of counter_accum_debug : signal is "true";
    --attribute mark_debug of num_pixel_i : signal is "true";
    --attribute mark_debug of num_line_i : signal is "true";
    --attribute mark_debug of num_block_i : signal is "true";
begin
---
counter_accum_debug <= counter_accum(2 downto 0);
---

    -- The diff blocks
    diffH_inst: diffH_block
        port map(
            clk_i => clk_i,
            reset_i => reset_i,
            valid_i => valid_i,
            ready_i => ready_i,
            Y_i => Y_i,
            num_pixel_i => num_pixel_i,
            valid_o => valid_o_diff,
            diff_quant_o => diff_quant_total,
            diff_not0_o => diff_not0_total
        );
            
    -- Valid logic -- decide when it is each adder's turn
    valid_gen: for I in 0 to SIZE_H_BK-1 generate
    begin
        valid_proc: process(clk_i, reset_i, num_block_1cycle)
        begin
            if (rising_edge(clk_i)) then
                if (num_block_1cycle = std_logic_vector(to_unsigned(I,8))) then
                    valid_i_block(I) <= valid_o_diff;
                else
                    valid_i_block(I) <= '0';
                end if;
            end if;
        end process;
    end generate;
    
    -- Delay the results 1 cycle to match "valid"
    diff_delay_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            diff_quant_delay1 <= diff_quant_total;
            diff_not0_delay1 <= diff_not0_total;
        end if;
    end process;
    
    -- Reset logic -- decide when it is time to reset the adder
    reset_gen: for I in 0 to SIZE_H_BK-1 generate
    begin
        reset_proc: process(clk_i, reset_i, num_pixel_i, num_line_i, num_block_i)
        begin
            if (reset_i='0') then
                reset_block(I) <= '0';
            elsif (rising_edge(clk_i)) then
                if (num_pixel_i=std_logic_vector(to_unsigned(SIZE_BLOCK_H-1,8)) and
                    num_line_i=std_logic_vector(to_unsigned(SIZE_BLOCK_V-1,8)) and
                    num_block_i = std_logic_vector(to_unsigned(I,8))) then
                    
                    reset_block(I) <= '0';
                else
                    reset_block(I) <= '1';
                end if;
            end if;
        end process;
    end generate;
    
    reset_propagate_gen: for I in 0 to SIZE_H_BK-1 generate
    begin
        reset_proc: process(clk_i)
        begin
            if (rising_edge(clk_i)) then
                reset_block_1cycle(I) <= reset_block(I);
                reset_block_2cycle(I) <= reset_block_1cycle(I);
                reset_block_3cycle(I) <= reset_block_2cycle(I);
            end if;
        end process;
    end generate;
    
    -- Accumulators - one for differences and one for dif>0
    diff_gen: for I in 0 to SIZE_H_BK-1 generate
        signal en_accumulator : std_logic;
    begin
        en_accumulator <=valid_i_block(I) and ready_i;
         
        diff_acc_inst: accumulator
        generic map (
            NUM_BITS_IN => 3,
            NUM_BITS_OUT => NUM_BITS_ACCUM_DIFF
        )
        port map (
            clk_i => clk_i,
            reset_i => reset_block_3cycle(I),
            en_i => en_accumulator,
            data_i => diff_quant_total,
            accum_o => diff_accum(I)
        );
        
        count_acc_inst: accumulator
        generic map (
            NUM_BITS_IN => 1,
            NUM_BITS_OUT => NUM_BITS_COUNTER_DIFF
        )
        port map (
            clk_i => clk_i,
            reset_i => reset_block_3cycle(I),
            en_i => en_accumulator,
            data_i => diff_not0_total,
            accum_o => counter_accum(I)
        );
    end generate;
    
    -- Valid logic - propagate
--    valid_out_gen: for I in 0 to SIZE_H_BK-1 generate
--    begin
--        valid_proc: process(clk_i)
--        begin
--            if (rising_edge(clk_i)) then
--                valid_o(I) <= valid_i_block(I);
--            end if;
--        end process;
--    end generate;
    
    valid_single_proc: process(clk_i, num_pixel_i, num_line_i)
    begin
        if (rising_edge(clk_i)) then
            if (num_pixel_i=std_logic_vector(to_unsigned(SIZE_BLOCK_H-1,8)) and
                num_line_i=std_logic_vector(to_unsigned(SIZE_BLOCK_V-1,8))) then
                valid_single <= '1';
            else
                valid_single <= '0';
            end if;
            
            valid_single_1cycle <= valid_single;
            valid_single_2cycle <= valid_single_1cycle;
            valid_single_3cycle <= valid_single_2cycle;
            
            num_block_1cycle <= num_block_i;
            num_block_2cycle <= num_block_1cycle;
            num_block_3cycle <= num_block_2cycle;
        end if;
    end process;
    
    -- Accumulators on one single output
    diff_acc_proc: process(clk_i, valid_single_1cycle)
    begin
        if (rising_edge(clk_i)) then
            if (valid_single_2cycle = '1') then
                diff_accum_single <= diff_accum(to_integer(unsigned(num_block_3cycle)));
                counter_accum_single <= counter_accum(to_integer(unsigned(num_block_3cycle)));
            end if;
        end if;
    end process;
    
    -- Out
    diff_accum_single_o <= diff_accum_single;
    counter_accum_single_o <= counter_accum_single;
    
    --diff_accum_o <= diff_accum;
    --counter_accum_o <= counter_accum;
    valid_single_o <= valid_single_3cycle;

end Behavioral;
