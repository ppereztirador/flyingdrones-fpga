----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/06/2022 03:43:42 PM
-- Design Name: 
-- Module Name: division_HV - Behavioral
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

entity division_HV is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           valid_i : in STD_LOGIC;
           ready_i : in STD_LOGIC;           
           diff_accum_i : in STD_LOGIC_VECTOR(NUM_BITS_ACCUM_DIFF-1 downto 0);
           counter_accum_i : in STD_LOGIC_VECTOR(NUM_BITS_COUNTER_DIFF-1 downto 0);
           valid_o : out STD_LOGIC;
           pr_o : out STD_LOGIC_VECTOR (2 downto 0));
end division_HV;

architecture Behavioral of division_HV is
    component serial_divide_uu is
      generic ( M_PP : integer := 16;           -- Size of dividend
                N_PP : integer := 8;            -- Size of divisor
                R_PP : integer := 0;            -- Size of remainder
                S_PP : integer := 0;            -- Skip this many bits (known leading zeros)
    --            COUNT_WIDTH_PP : integer := 5;  -- 2^COUNT_WIDTH_PP-1 >= (M_PP+R_PP-S_PP-1)
                HELD_OUTPUT_PP : integer := 0); -- Set to 1 if stable output should be held
                                                -- from previous operation, during current
                                                -- operation.  Using this option will increase
                                                -- the resource utilization (costs extra d-flip-flops.)
        port(   clk_i      : in  std_logic;
                clk_en_i   : in  std_logic;
                rst_i      : in  std_logic;
                divide_i   : in  std_logic;
                dividend_i : in  std_logic_vector(M_PP-1 downto 0);
                divisor_i  : in  std_logic_vector(N_PP-1 downto 0);
                quotient_o : out std_logic_vector(M_PP+R_PP-S_PP-1 downto 0);
                done_o     : out std_logic
        );
    end component;
    
    signal data_valid, divider_valid, divider_reset : std_logic;
    signal divider_dividend : std_logic_vector(19 downto 0) := "00000000000000000000";
    signal divider_quotient : std_logic_vector(19 downto 0);
    signal divider_divisor : std_logic_vector(12 downto 0) := "0000000000000";
    signal divider_remainder: std_logic_vector(10 downto 0);
    signal divider_datao : std_logic_vector(19 downto 0);
    
    signal divider_quotient_u : unsigned(19 downto 0);

    constant threshold1 : unsigned(19 downto 0) := "00000000000010110000"; -- 0.171875
    constant threshold2 : unsigned(19 downto 0) := "00000000000011100000"; -- 0.21875
    constant threshold3 : unsigned(19 downto 0) := "00000000000101000000"; -- 0.31250
    constant threshold4 : unsigned(19 downto 0) := "00000000000110100000"; -- 0.40625
    
    signal pr_quant : std_logic_vector(2 downto 0);
    signal valid_i_1cycle : std_logic;
    signal valid_1cycle, valid_2cycle : std_logic;
    
    -- PR limits
    signal pr_top, pr_zero : std_logic_vector(22 downto 0);
    constant dividend_max_value : unsigned(NUM_BITS_ACCUM_DIFF-1 downto 0) := "0001111111111";
    
    -- Div valid state machine
    type div_state is (WAIT_VALID_I, WAIT_VALID_DIV);
    signal div_state_current : div_state := WAIT_VALID_I;
    signal divider_valid_filtered : std_logic;
    
begin
    divider_dividend <= diff_accum_i(9 downto 0) & "0000000000";
    divider_divisor <= counter_accum_i & "00";
    data_valid <= valid_i;
    divider_reset <= not reset_i;

    pr_div_inst: serial_divide_uu
    generic map (
        M_PP => 20,           -- Size of dividend
        N_PP => 13,           -- Size of divisor
        R_PP => 0             -- Size of remainder
        ) -- Set to 1 if stable output should be held
                                    -- from previous operation, during current
                                    -- operation.  Using this option will increase
                                    -- the resource utilization (costs extra d-flip-flops.)
    port map(
        clk_i => clk_i,
        clk_en_i => ready_i,
        rst_i => divider_reset,
        divide_i => data_valid,
        dividend_i => divider_dividend,
        divisor_i => divider_divisor,
        quotient_o => divider_datao,
        done_o => divider_valid
    );
    
    divider_quotient <= divider_datao;
    divider_remainder <= "00000000000";
    
    divider_quotient_u <= unsigned(divider_quotient);
    
    -- Check if dividend is over the bit limit or div0 and should produce the max PR
    pr_top_proc: process(clk_i, diff_accum_i, pr_top)
    begin
        if (rising_edge(clk_i)) then
            if (unsigned(diff_accum_i) > dividend_max_value or (counter_accum_i="00000000000")) then -- !!OJO QUITAR EL SHIFT!! "00"&unsigned(diff_accum_i(NUM_BITS_ACCUM_DIFF-1 downto 2))
                pr_top(0) <= '1';
            else
                pr_top(0) <= '0';
            end if;
            
            pr_top(22 downto 1) <= pr_top(21 downto 0);
        end if;
    end process;
    
    pr_zero_proc: process(clk_i, diff_accum_i, pr_zero)
    begin
        if (rising_edge(clk_i)) then
            if (diff_accum_i="0000000000000") then -- !!OJO QUITAR EL SHIFT!! "00"&unsigned(diff_accum_i(NUM_BITS_ACCUM_DIFF-1 downto 2))
                pr_zero(0) <= '1';
            else
                pr_zero(0) <= '0';
            end if;
            
            pr_zero(22 downto 1) <= pr_zero(21 downto 0);
        end if;
    end process;
    
    quant_proc: process(clk_i, divider_quotient_u, pr_top)
    begin
        if rising_edge(clk_i) then
            if (pr_zero(19)='1') then
                pr_quant <= "001";
            elsif (pr_top(19)='1') then -- if div by 0 -> infty or div>top
                pr_quant <= "101";
            elsif (divider_quotient_u < threshold1) then
                pr_quant <= "001";
            elsif (divider_quotient_u < threshold2) then
                pr_quant <= "010";
            elsif (divider_quotient_u < threshold3) then
                pr_quant <= "011";
            elsif (divider_quotient_u < threshold4) then
                pr_quant <= "100";
            else
                pr_quant <= "101";
            end if;
        end if;
    end process;
    
    pr_o <= pr_quant;--diff_accum_i(9 downto 7);
    
    -- Valid
    valid_proc: process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            valid_1cycle <= divider_valid;
            valid_2cycle <= valid_1cycle;
            valid_i_1cycle <= valid_i;
        end if;
    end process;
    
    div_filter_proc: process(clk_i, reset_i, valid_i, divider_valid, div_state_current)
    begin
        if (reset_i='0') then
            div_state_current <= WAIT_VALID_I;
        elsif (rising_edge(clk_i)) then
            case div_state_current is
                when WAIT_VALID_I =>
                    if (valid_i='1') then
                        div_state_current <= WAIT_VALID_DIV;
                    else
                        div_state_current <= WAIT_VALID_I;
                    end if;
                    divider_valid_filtered <= '0';
                    
                when WAIT_VALID_DIV =>
                    if (divider_valid='1') then
                        div_state_current <= WAIT_VALID_I;
                        divider_valid_filtered <= '1';
                    else
                        div_state_current <= WAIT_VALID_DIV;
                        divider_valid_filtered <= '0';
                    end if;
                    
                when others =>
                    div_state_current <= WAIT_VALID_I;
                    divider_valid_filtered <= '0';
            end case;
        end if;
    end process;
    
    valid_o <= divider_valid_filtered;--valid_1cycle and not valid_2cycle;

end Behavioral;
