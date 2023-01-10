----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2021 04:03:39 PM
-- Design Name: 
-- Module Name: accumulator - Behavioral
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

entity accumulator is
    Generic ( NUM_BITS_IN : integer := 8;
              NUM_BITS_OUT : integer := 13
          );
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           en_i : in STD_LOGIC;
           data_i : in STD_LOGIC_VECTOR (NUM_BITS_IN-1 downto 0);
           accum_o : out STD_LOGIC_VECTOR (NUM_BITS_OUT-1 downto 0));
end accumulator;

architecture Behavioral of accumulator is
    signal intermediate_accum : unsigned (NUM_BITS_OUT-1 downto 0); 
begin

    accum_proc: process(clk_i, reset_i, en_i)
    begin
        if (reset_i='0') then
            intermediate_accum <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (en_i='1') then
                intermediate_accum <= intermediate_accum + unsigned(data_i);
            end if;
        end if;
    end process;
    
    accum_o <= std_logic_vector(intermediate_accum);


end Behavioral;
