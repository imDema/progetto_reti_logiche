----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.03.2020 11:54:46
-- Design Name: 
-- Module Name: wz_enc - Behavioral
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

entity wz_enc is
    Port ( i_addr : in STD_LOGIC_VECTOR (7 downto 0);
           i_load_wz : in STD_LOGIC;
           o_hit : out STD_LOGIC;
           o_diff : out STD_LOGIC_VECTOR (1 downto 0);
           i_clk : in STD_LOGIC);
end wz_enc;

architecture Behavioral of wz_enc is

signal o_r_wz : STD_LOGIC_VECTOR (7 downto 0);
signal lt_wz_addr : STD_LOGIC;
signal sub_addr_wz : STD_LOGIC_VECTOR (7 downto 0); --TODO check if using only 4 bits is problematic
signal lt_sub_100 : STD_LOGIC;
signal hit : STD_LOGIC;

begin
    --r_wz
    process(i_clk)
    begin
        if falling_edge(i_clk) then
            if(i_load_wz = '1') then
                o_r_wz <= i_addr;
            end if;
        end if;
    end process;
    
    -- lt_wz_addr
    lt_wz_addr <= '1' when (o_r_wz <= i_addr) else '0';
    
    -- sub_addr_wz
    sub_addr_wz <= i_addr(7 downto 0) - o_r_wz(7 downto 0);
    
    -- lt_sub_100
    lt_sub_100 <= '1' when (sub_addr_wz < "0100") else '0';
    
    -- o_hit
    hit <= (lt_wz_addr and lt_sub_100);
    o_hit <= hit;
    
    --o_diff
    with hit select
        o_diff <=   sub_addr_wz (1 downto 0) when '1',
                    "00" when '0',
                    "XX" when others;

end Behavioral;
