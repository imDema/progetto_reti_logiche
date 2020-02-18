----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.12.2019 13:08:54
-- Design Name: 
-- Module Name: datapath - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath is
    Port ( 
        i_clk : in STD_LOGIC;
        i_res : in STD_LOGIC;
        i_data : in std_logic_vector (7 downto 0);
        o_address : out std_logic_vector (15 downto 0);
        o_data : out std_logic_vector (7 downto 0);
        r_mem_load : in STD_LOGIC;
        r0_load : in STD_LOGIC;
        r1_load : in STD_LOGIC;
        r2_load : in STD_LOGIC;
        w_addr : in std_logic_vector (7 downto 0);
        sel_addr : in STD_LOGIC;
        l_mask : in std_logic_vector(3 downto 0));
end datapath;

architecture Behavioral of datapath is
signal o_r_mem : std_logic_vector(7 downto 0); --
signal o_r0 : std_logic; --
signal o_r1 : std_logic; --
signal o_r2 : std_logic; --
signal lt_ram_mem : std_logic; --
signal sub_ram_mem : std_logic_vector(7 downto 0); --
signal cat_regs : std_logic_vector(3 downto 0); --
signal one_hot_diff : std_logic_vector(3 downto 0); --
signal lt_sub_100 : std_logic; --

begin
    -- reg_mem
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_r_mem <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r_mem_load = '1') then
                o_r_mem <= i_data;
            end if;
        end if;
    end process;
    
    --r0
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_r0 <= '0';
        elsif i_clk'event and i_clk = '1' then
            if(r0_load = '1') then
                o_r0 <= lt_ram_mem;
            end if;
        end if;
    end process;
    --r1
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_r1 <= '0';
        elsif i_clk'event and i_clk = '1' then
            if(r1_load = '1') then
                o_r1 <= lt_ram_mem;
            end if;
        end if;
    end process;
    --r2
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_r2 <= '0';
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1') then
                o_r2 <= lt_ram_mem;
            end if;
        end if;
    end process;
    
    -- lt_ram_mem
    lt_ram_mem <= '1' when (i_data < o_r_mem) else '0';
    
    -- sub_ram_mem
    sub_ram_mem <= o_r_mem(7 downto 0) - i_data (7 downto 0);
    
    -- cat__regs
    cat_regs <= '0' & o_r0 & o_r1 & o_r2;
    
    -- one_hot_diff
    with sub_ram_mem select
        one_hot_diff <=  "0001" when "0000",
                        "0010" when "0001",
                        "0100" when "0010",
                        "1000" when "0011",
                        "XXXX" when others;
                        
    -- lt_sub_100
    lt_sub_100 <= '1' when (sub_ram_mem < "0100") else '0';
    
    -- o_address
    with sel_addr select
        o_address <=    "000000000000" & w_addr when '1', -- TODO can probably be turned into a constant
                        "000000000000" & (cat_regs or l_mask) when '0',
                        "XXXXXXXXXXXXXXXX" when others;
    
    --o_data
    with (lt_sub_100 and lt_ram_mem) select
        o_data <=   ("1000" and cat_regs) & one_hot_diff when '1',
                    o_r_mem when '0',
                    "XXXXXXXX" when others;

end Behavioral;
