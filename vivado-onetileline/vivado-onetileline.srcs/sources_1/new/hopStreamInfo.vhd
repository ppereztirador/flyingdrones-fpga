----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/18/2022 11:32:32 AM
-- Design Name: 
-- Module Name: hopStreamInfo - Behavioral
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
library UNISIM;
use UNISIM.vcomponents.all;

library UNIMACRO;
use UNIMACRO.vcomponents.all;

library WORK;
use WORK.lhe_lib.ALL;

entity hopStreamInfo is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           user_i : in STD_LOGIC;
           arm_i : in STD_LOGIC;
           
           first_luma_i : in vector_array_8(SIZE_H_BK-1 downto 0);
           ppp_i : in vector_array_4(SIZE_H_BK-1 downto 0);
           valid_i : in std_logic_vector(SIZE_H_BK-1 downto 0);
           sw_i : in std_logic_vector(SIZE_H_BK-1 downto 0);
           ready_hop_i : in std_logic_vector(SIZE_H_BK-1 downto 0);
           
           num_block_i : in std_logic_vector(7 downto 0);
           first_luma_o : out std_logic_vector(7 downto 0);
           ppp_o : out std_logic_vector(3 downto 0)
           );
end hopStreamInfo;

architecture Behavioral of hopStreamInfo is
    signal di_mem, do_mem : std_logic_vector(11 downto 0);
    signal waddr_mem, raddr_mem : std_logic_vector(9 downto 0);
    signal we_mem : std_logic_vector(1 downto 0);
    signal waddr_u : unsigned(9 downto 0);
    constant waddr_u_max : unsigned(9 downto 0) := to_unsigned(SIZE_H_BK-1, 10);
    signal reset_mem : std_logic;
    
    signal first_luma_current : std_logic_vector(7 downto 0);
    signal ppp_current : std_logic_vector(3 downto 0);
    signal valid_filtered : std_logic_vector(SIZE_H_BK-1 downto 0);
    signal valid_current : std_logic;
    signal first_luma_reg: vector_array_8(SIZE_H_BK-1 downto 0);
    signal ppp_reg: vector_array_4(SIZE_H_BK-1 downto 0);
    signal valid_reg : std_logic_vector(SIZE_H_BK-1 downto 0);
    
    signal reset_with_user : std_logic;
    
    type memory_state_type is (IDLE, WAIT_FRAME, WAIT_DOWN, SAVE_DATA);
    signal memory_state_current, memory_state_next : memory_state_type;
    constant max_num_block : unsigned(7 downto 0) := to_unsigned(SIZE_H_BK-1, 8);
    constant ones : std_logic_vector(SIZE_H_BK-1 downto 0) := (others=>'1');
    
    -- debug
    attribute mark_debug : string;
    attribute mark_debug of reset_i : signal is "true";
    attribute mark_debug of user_i : signal is "true";
    attribute mark_debug of arm_i : signal is "true";
    attribute mark_debug of valid_current : signal is "true";
    attribute mark_debug of di_mem : signal is "true";
    attribute mark_debug of do_mem : signal is "true";
    attribute mark_debug of num_block_i : signal is "true";
    attribute mark_debug of waddr_mem : signal is "true";
    
begin
   -- Register data for later
   reg_info_gen: for I in 0 to SIZE_H_BK-1 generate
        reg_hop_proc: process(clk_i, reset_i, valid_i, reset_with_user)
        begin
            if (reset_with_user='0') then
                first_luma_reg(I) <= (others=>'0');
                ppp_reg(I) <= (others=>'0');
            elsif (rising_edge(clk_i)) then
                if (valid_i(I)='1') then
                    first_luma_reg(I) <= first_luma_i(I);
                    ppp_reg(I) <= ppp_i(I);
                end if;
            end if;
        end process;
    end generate;
    
    reg_valid_gen: for I in 0 to SIZE_H_BK-1 generate
        reg_valid_proc: process(clk_i, reset_i, waddr_u, reset_with_user, valid_i)
        begin
            if (reset_with_user='0') then
                valid_reg(I) <= '0';
            elsif (rising_edge(clk_i)) then
                if (valid_i(I)='1' and memory_state_current=SAVE_DATA) then
                    valid_reg(I) <= '1';
                elsif (to_integer(waddr_u)=I) then
                    valid_reg(I) <= '0';
                end if;
            end if;
        end process;
    end generate;

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


   BRAM_SDP_MACRO_inst : BRAM_SDP_MACRO
   generic map (
      BRAM_SIZE => "18Kb", -- Target BRAM, "18Kb" or "36Kb" 
      DEVICE => "7SERIES", -- Target device: "VIRTEX5", "VIRTEX6", "7SERIES", "SPARTAN6" 
      WRITE_WIDTH => 12,    -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
      READ_WIDTH => 12,     -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
      DO_REG => 0, -- Optional output register (0 or 1)
      INIT_FILE => "NONE",
      SIM_COLLISION_CHECK => "ALL", -- Collision check enable "ALL", "WARNING_ONLY", 
                                    -- "GENERATE_X_ONLY" or "NONE"       
      SRVAL => X"000000000000000000", --  Set/Reset value for port output
      WRITE_MODE => "READ_FIRST", -- Specify "READ_FIRST" for same clock or synchronous clocks
                                   --  Specify "WRITE_FIRST for asynchrononous clocks on ports
      INIT => X"000000000000000000" --  Initial values on output port
   )
   port map (
      DO => do_mem,         -- Output read data port, width defined by READ_WIDTH parameter
      DI => di_mem,         -- Input write data port, width defined by WRITE_WIDTH parameter
      RDADDR => raddr_mem, -- Input read address, width defined by read port depth
      RDCLK => clk_i,   -- 1-bit input read clock
      RDEN => '1',     -- 1-bit input read port enable
      REGCE => '1',   -- 1-bit input read output register enable
      RST => reset_mem,       -- 1-bit input reset 
      WE => we_mem,         -- Input write enable, width defined by write port depth
      WRADDR => waddr_mem, -- Input write address, width defined by write port depth
      WRCLK => clk_i,   -- 1-bit input write clock
      WREN => '1'      -- 1-bit input write port enable
   );
   
    di_mem <= ppp_current & first_luma_current;
    ppp_o <= do_mem(11 downto 8);
    first_luma_o <= do_mem(7 downto 0);
    
    waddr_mem <= std_logic_vector(waddr_u);
    we_mem <= valid_current & valid_current;
    
    raddr_mem <= "00" & num_block_i;
    
    reset_mem <= not reset_i;
    
    -- Valid process - only count first valid and reset when the switch is flipped
    -- keeping track of what's going on outside the component
    valid_gen: for I in 0 to SIZE_H_BK-1 generate
        valid_proc: process(clk_i, reset_i, sw_i)
        begin
            if (reset_with_user='0') then
                valid_filtered(I) <= '0';
            elsif (rising_edge(clk_i)) then
                if (sw_i(I)='0' or valid_i(I)='0') then
                    valid_filtered(I) <= '0';
                elsif (valid_i(I)='1' and memory_state_current=SAVE_DATA) then
                    valid_filtered(I) <= '1';
                end if;
            end if;
        end process;
    end generate;
   
    -- Write address process - simply circulate address
    addr_proc: process(clk_i, reset_i)
    begin
        if (reset_with_user='0') then
            waddr_u <= (others=>'0');
        elsif (rising_edge(clk_i)) then
            if (waddr_u=waddr_u_max) then
                waddr_u <= (others=>'0');
            else
                waddr_u <= waddr_u + 1;
            end if;
        end if;
    end process;
    
    valid_current <= valid_reg(to_integer(waddr_u));
    first_luma_current <= first_luma_reg(to_integer(waddr_u));
    ppp_current <= ppp_reg(to_integer(waddr_u));
    
    -- State machine -- don't write until ARM sends reset
    mem_cur_proc: process(clk_i, reset_i)
    begin
        if (reset_i='0') then
            memory_state_current <= IDLE;
        elsif (rising_edge(clk_i)) then
            memory_state_current <= memory_state_next;
        end if;
    end process;
    
    mem_nxt_proc: process(memory_state_current, arm_i, user_i, ready_hop_i, num_block_i)
    begin
        case memory_state_current is
            when IDLE =>
                if (arm_i='1') then
                    memory_state_next <= WAIT_FRAME;
                else
                    memory_state_next <= IDLE;
                end if;
            when WAIT_FRAME =>
                if (user_i='1') then
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
   
    reset_with_user <= '0' when (reset_i='0' or (user_i='1' and
                                                 memory_state_current/=SAVE_DATA and
                                                 (unsigned(num_block_i)>=max_num_block)))
                        else '1';
end Behavioral;
