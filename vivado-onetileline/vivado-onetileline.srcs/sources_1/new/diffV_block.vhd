-----------
-- NOT YET PROGRAMMED DO NOT USE !!
-----------------------------------------------------------------------------------
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
use IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

library WORK;
use WORK.lhe_lib.ALL;

entity diffV_block is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           valid_i : in STD_LOGIC;
           ready_i : in STD_LOGIC;
           Y_i : in STD_LOGIC_VECTOR (7 downto 0);
           num_pixel_i : in STD_LOGIC_VECTOR(7 downto 0);
           num_pixel_adv_i : in STD_LOGIC_VECTOR(7 downto 0);
           num_line_i : in STD_LOGIC_VECTOR(7 downto 0);
           num_block_i : in STD_LOGIC_VECTOR(7 downto 0);
           num_block_adv_i : in STD_LOGIC_VECTOR(7 downto 0);
           valid_o : out STD_LOGIC;
           diff_quant_o : out STD_LOGIC_VECTOR(2 downto 0);
           diff_not0_o : out STD_LOGIC_VECTOR(0 downto 0)
         );
end diffV_block;

architecture Behavioral of diffV_block is
    signal Y_un, Y_previous_un : unsigned (7 downto 0);
    signal Y_previous : std_logic_vector(7 downto 0);
    
    --type Y_array is array(integer range <>) of unsigned (9 downto 0);
    --signal Y_previous : Y_array(SIZE_H_PX-1 downto 0);

    signal diff_Y : unsigned(7 downto 0);
    signal diff_quant : std_logic_vector(2 downto 0);
    signal diff_not0 : std_logic_vector(0 downto 0);
    
    signal conditionA, conditionB, conditionC : std_logic;
    
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
    
    signal diff_accum : std_logic_vector(NUM_BITS_ACCUM_DIFF-1 downto 0);
    signal counter_accum : std_logic_vector(NUM_BITS_COUNTER_DIFF-1 downto 0);
    
    -- Enable signals to propagate
    signal valid_reg : std_logic_vector(2 downto 0);
    
    -- RAM constants and signals
    constant num_bits_ram : integer := 11; --Table!! --integer(ceil(log2( real(SIZE_H_PX) )));
    constant num_bits_numblock : integer := integer(ceil(log2( real(SIZE_H_BK) )));
    
    signal ram_reset : std_logic;
    signal data_we : std_logic;
    signal ram_we : std_logic_vector(0 downto 0);
    signal ram_address, ram_address_adv : std_logic_vector(num_bits_ram-1 downto 0);
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
    Y_previous_un <= unsigned(Y_previous);
    
    -- Difference (taking into account: first pixel, abs(Y - Yprevious))
    diff_proc: process(clk_i, reset_i, valid_i)
    begin
        if (reset_i='0') then
            diff_Y <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (valid_i='1' and ready_i='1') then
                if (num_line_i = "00000000") then
                    diff_Y <= (others=>'0');
                elsif (Y_un > Y_previous_un) then
                    diff_Y <= Y_un - Y_previous_un;
                else
                    diff_Y <= Y_previous_un - Y_un;
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
    valid_o <= valid_reg(1);--3;
--    diff_accum_o <= diff_accum;
--    counter_accum_o <= counter_accum;
    diff_quant_o <= diff_quant;
    diff_not0_o <= diff_not0; 


-------------------------------------------------------------------------------
    
   -- BRAM_SDP_MACRO: Simple Dual Port RAM
   --                 Artix-7
   -- Xilinx HDL Language Template, version 2020.2
   
   -- Note -  This Unimacro model assumes the port directions to be "downto". 
   --         Simulation of this model with "to" in the port directions could lead to erroneous results.

   -----------------------------------------------------------------------
   --  READ_WIDTH | BRAM_SIZE | READ Depth  | RDADDR Width |            --
   -- WRITE_WIDTH |           | WRITE Depth | WRADDR Width |  WE Width  --
   -- ============|===========|=============|==============|============--
   --    37-72    |  "36Kb"   |      512    |     9-bit    |    8-bit   --
   --    19-36    |  "36Kb"   |     1024    |    10-bit    |    4-bit   --
   --    19-36    |  "18Kb"   |      512    |     9-bit    |    4-bit   --
   --    10-18    |  "36Kb"   |     2048    |    11-bit    |    2-bit   --
   --    10-18    |  "18Kb"   |     1024    |    10-bit    |    2-bit   --
   --     5-9     |  "36Kb"   |     4096    |    12-bit    |    1-bit   --
   --     5-9     |  "18Kb"   |     2048    |    11-bit    |    1-bit   --
   --     3-4     |  "36Kb"   |     8192    |    13-bit    |    1-bit   --
   --     3-4     |  "18Kb"   |     4096    |    12-bit    |    1-bit   --
   --       2     |  "36Kb"   |    16384    |    14-bit    |    1-bit   --
   --       2     |  "18Kb"   |     8192    |    13-bit    |    1-bit   --
   --       1     |  "36Kb"   |    32768    |    15-bit    |    1-bit   --
   --       1     |  "18Kb"   |    16384    |    14-bit    |    1-bit   --
   -----------------------------------------------------------------------

   BRAM_SINGLE_MACRO_inst : BRAM_SDP_MACRO
   generic map (
      BRAM_SIZE => "18Kb", -- Target BRAM, "18Kb" or "36Kb" 
      DEVICE => "7SERIES", -- Target Device: "VIRTEX5", "7SERIES", "VIRTEX6, "SPARTAN6" 
      DO_REG => 0, -- Optional output register (0 or 1)
      INIT => X"000000000000000000",   --  Initial values on output port
      INIT_FILE => "NONE",
      WRITE_WIDTH => 8,   -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
      READ_WIDTH => 8,   -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
      SRVAL => X"000000000000000000",   -- Set/Reset value for port output
      WRITE_MODE => "READ_FIRST" -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE" 
      )
   port map (
      DO => Y_previous,         -- Output read data port, width defined by READ_WIDTH parameter
      DI => Y_i,         -- Input write data port, width defined by WRITE_WIDTH parameter
      RDADDR => ram_address_adv, -- Input read address, width defined by read port depth
      RDCLK => clk_i,   -- 1-bit input read clock
      RDEN => '1',     -- 1-bit input read port enable
      REGCE => '1',   -- 1-bit input read output register enable
      RST => ram_reset,       -- 1-bit input reset 
      WE => ram_we,         -- Input write enable, width defined by write port depth
      WRADDR => ram_address, -- Input write address, width defined by write port depth
      WRCLK => clk_i,   -- 1-bit input write clock
      WREN => '1'      -- 1-bit input write port enable
   );
       -------------------------------------------------------------------------------
   ram_reset <= not reset_i;
   data_we <= valid_i and ready_i;
   ram_we(0) <= data_we;
   ram_address <= "0" & num_pixel_i(5 downto 0) & num_block_i(num_bits_numblock-1 downto 0);--"0" & num_pixel_i(5 downto 0) & num_block_i(num_bits_numblock-1 downto 0);
   ram_address_adv <= "0" & num_pixel_adv_i(5 downto 0) & num_block_adv_i(num_bits_numblock-1 downto 0);--"0" & num_pixel_adv_i(5 downto 0) & num_block_adv_i(num_bits_numblock-1 downto 0);    

end Behavioral;
