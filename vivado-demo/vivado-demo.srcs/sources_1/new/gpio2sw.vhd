----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2022 01:08:51 PM
-- Design Name: 
-- Module Name: gpio2sw - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gpio2sw is
    Port ( gpio_i : in STD_LOGIC_VECTOR (31 downto 0);
           sw_0_o : out STD_LOGIC;
            sw_1_o : out STD_LOGIC;
            sw_2_o : out STD_LOGIC;
            sw_3_o : out STD_LOGIC;
            sw_4_o : out STD_LOGIC;
            sw_5_o : out STD_LOGIC;
            sw_6_o : out STD_LOGIC;
            sw_7_o : out STD_LOGIC
           );
end gpio2sw;

architecture Behavioral of gpio2sw is

begin

    sw_0_o <= gpio_i(0);
    sw_1_o <= gpio_i(1);
    sw_2_o <= gpio_i(2);
    sw_3_o <= gpio_i(3);
    sw_4_o <= gpio_i(4);
    sw_5_o <= gpio_i(5);
    sw_6_o <= gpio_i(6);
    sw_7_o <= gpio_i(7);
    
end Behavioral;
