----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2021 04:50:58 PM
-- Design Name: 
-- Module Name: diffH_block - Behavioral
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

entity diffH_block is
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
end diffH_block;

architecture Behavioral of diffH_block is
    signal Y_un, Y_previous : unsigned (7 downto 0);
    signal diff_Y : unsigned(7 downto 0);
    signal diff_quant : std_logic_vector(2 downto 0);
    signal diff_not0 : std_logic_vector(0 downto 0);
    
    signal conditionA, conditionB, conditionC : std_logic;
    
    -- Enable signals to propagate
    signal valid_reg : std_logic_vector(2 downto 0);
begin

    -- Regs for valid signals
    valid_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            valid_reg <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            valid_reg(0) <= valid_i;
            valid_reg(2 downto 1) <= valid_reg(1 downto 0);
        end if;
    end process;
    
    -- Reg for previous number
    Y_un <= unsigned(Y_i);
    
    previous_proc: process(clk_i, reset_i, valid_i)
    begin
        if (reset_i='0') then
            Y_previous <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (valid_i='1' and ready_i='1') then
                Y_previous <= Y_un;
            end if;
        end if;
    end process;
    
    -- Difference (taking into account: first pixel, abs(Y - Yprevious))
    diff_proc: process(clk_i, reset_i, valid_i)
    begin
        if (reset_i='0') then
            diff_Y <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (valid_i='1' and ready_i='1') then
                if (num_pixel_i = "00000000") then
                    diff_Y <= (others=>'0');
                elsif (Y_un > Y_previous) then
                    diff_Y <= Y_un - Y_previous;
                else
                    diff_Y <= Y_previous - Y_un;
                end if;
            end if;
        end if;
    end process;
    
    -- Quantize difference (1 clk behind)
    conditionA <= '1' when (diff_Y(7 downto 5)="000") else '0';
    conditionB <= '1' when (diff_Y(4)='0') else '0';
    conditionC <= '1' when (diff_Y(3)='0') else '0';
    
    quantize_proc: process(clk_i, reset_i, valid_reg, conditionA, conditionB, conditionC)
    begin
        if (reset_i='0') then
            diff_quant <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (valid_reg(0)='1' and ready_i='1') then
                if (conditionA='1' and conditionB='1' and conditionC='1') then -- <8
                    diff_quant <= "000";
                elsif (conditionA='1' and conditionB='1') then -- <16
                    diff_quant <= "001";
                elsif (conditionA='1' and conditionB='0' and conditionC='1') then -- <24
                    diff_quant <= "010";
                elsif (conditionA='1') then -- <32
                    diff_quant <= "011";
                else -- >=32
                    diff_quant <= "100";
                end if;
            end if;
        end if;
    end process;
    
    not0_proc: process(clk_i, reset_i, valid_reg, conditionA, conditionB, conditionC)
    begin
        if (reset_i='0') then
            diff_not0 <= "0";
        elsif (rising_edge(clk_i)) then
            if (valid_reg(0)='1' and ready_i='1') then
                if (conditionA='1' and conditionB='1' and conditionC='1') then -- <8
                    diff_not0 <= "0";
                else
                    diff_not0 <= "1";
                end if;
            end if;
        end if;
    end process;
    
    -- Out
    valid_o <= valid_reg(1);--2;
    diff_quant_o <= diff_quant;
    diff_not0_o <= diff_not0; 

end Behavioral;
