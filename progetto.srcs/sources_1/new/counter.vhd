----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.03.2020 12:21:04
-- Design Name: 
-- Module Name: counter - Behavioral
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

entity counter is
    Port ( i_en : in STD_LOGIC;
           i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           o_base2 : out STD_LOGIC_VECTOR (2 downto 0);
           o_one_hot : out STD_LOGIC_VECTOR (7 downto 0);
           o_done : out STD_LOGIC);
end counter;

architecture Behavioral of counter is

type S is (S0,S1,S2,S3,S4,S5,S6,S7,S8);
signal cur_state, next_state : S;

begin
    process(i_clk,i_rst,i_en)
    begin
        if i_rst = '1' then
            cur_state <= S0;
        elsif rising_edge(i_clk) then
            cur_state <= next_state;
        end if; 
        
    end process;
    
    process(cur_state, i_en)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 => if (i_en = '1')then
                    next_state <= S1;
                end if;
            when S1 => next_state <= S2;
            when S2 => next_state <= S3;
            when S3 => next_state <= S4;
            when S4 => next_state <= S5;
            when S5 => next_state <= S6;
            when S6 => next_state <= S7;
            when S7 => next_state <= S8;
            when S8 => next_state <= cur_state;
        end case;
    end process;
    
    process(cur_state)
    begin
        o_base2 <= "000";
        o_one_hot <= "00000000";
        o_done <= '0';
        case cur_state is
            when S0 =>
                o_base2 <= "000";
                o_one_hot <= "00000001";
            when S1 =>
                o_base2 <= "001";
                o_one_hot <= "00000010";
            when S2 =>
                o_base2 <= "010";
                o_one_hot <= "00000100";
            when S3 =>
                o_base2 <= "011";
                o_one_hot <= "00001000";
            when S4 =>
                o_base2 <= "100";
                o_one_hot <= "00010000";
            when S5 =>
                o_base2 <= "101";
                o_one_hot <= "00100000";
            when S6 =>
                o_base2 <= "110";
                o_one_hot <= "01000000";
            when S7 =>
                o_base2 <= "111";
                o_one_hot <= "10000000";
            when S8 =>
                o_done <= '1';
                o_base2 <= "000";
                o_one_hot <= "00000000";
        end case;
    end process;

end Behavioral;
