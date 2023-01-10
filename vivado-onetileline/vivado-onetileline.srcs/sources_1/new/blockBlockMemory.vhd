library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity blockBlockMemory is
    Port ( clk_i : in STD_LOGIC;
           reset_i : in STD_LOGIC;
           valid_i : in STD_LOGIC;
           ready_i : in STD_LOGIC;
           valid_ds_i : in STD_LOGIC;
           switch_y_ds_i : in STD_LOGIC;
           switch_ds_hle_i : in STD_LOGIC;
           -- Write - Y (cam)
           num_pixel_i: in STD_LOGIC_VECTOR(7 downto 0);
           num_line_i: in STD_LOGIC_VECTOR(7 downto 0);
           Y_i : in STD_LOGIC_VECTOR(7 downto 0);
           
           -- Read - DS
           addr_r_ds_i : in STD_LOGIC_VECTOR(10 downto 0);
           Y_o : out STD_LOGIC_VECTOR(7 downto 0);
           
           -- Write - DS
           addr_w_ds_i : in  STD_LOGIC_VECTOR(10 downto 0);
           DS_i : in STD_LOGIC_VECTOR(7 downto 0);
           
           -- Read - HLE
           addr_r_hle_i : in  STD_LOGIC_VECTOR(10 downto 0);
           DS_o : out STD_LOGIC_VECTOR(7 downto 0)
       );
end blockBlockMemory;

architecture Behavioral of blockBlockMemory is

    COMPONENT blk_mem_lheblock
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END COMPONENT;
    
    signal write_en_a, write_en_b : std_logic_vector(0 downto 0);
    signal addr_a, addr_b : std_logic_vector(10 downto 0);
    signal addr_cam : unsigned(10 downto 0);
    signal data_i_a, data_i_b : std_logic_vector(7 downto 0);
    signal data_o_a, data_o_b : std_logic_vector(7 downto 0); 

begin

    mem_inst: blk_mem_lheblock
    port map (
        clka => clk_i,
        ena => '1',
        wea => write_en_a,
        addra => addr_a,
        dina => data_i_a,
        douta => data_o_a,
        clkb => clk_i,
        enb => '1',
        web => write_en_b,
        addrb => addr_b,
        dinb => data_i_b,
        doutb => data_o_b
    );
    
    -- Port A - write data from cam and read later for downsampling
    --cam_proc: process(clk_i)
    --begin
    --    if (falling_edge(clk_i)) then
    --        if (switch_y_ds_i='1') then
    --            addr_a <= addr_r_ds_i;
    --        else
    --            addr_a <= std_logic_vector(addr_cam);
    --        end if;
    --                    
            data_i_a <= Y_i;
    --    end if;
    --end process;
    
    addr_cam <= unsigned(num_line_i(5 downto 0) & "00000") +
                unsigned(num_line_i & "000") +
                unsigned("000" & num_pixel_i);
                
    addr_a <= addr_r_ds_i when (switch_y_ds_i='1') else
              std_logic_vector(addr_cam);
    write_en_a(0) <= valid_i and ready_i and (not switch_y_ds_i);
    
    Y_o <= data_o_a;
    
    -- Port B - write data from downsampling and read later for coding
    addr_b <= addr_r_hle_i when (switch_ds_hle_i='1') else
              addr_w_ds_i;
    write_en_b(0) <= valid_ds_i and ready_i and (not switch_ds_hle_i);
    data_i_b <= DS_i;
    DS_o <= data_o_b;

end Behavioral;
