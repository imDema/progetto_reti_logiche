----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.12.2019 12:46:47
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
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

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in std_logic_vector (7 downto 0);
           o_address : out std_logic_vector (15 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out std_logic_vector (7 downto 0));
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component datapath is 
    Port ( 
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_data : in std_logic_vector (7 downto 0);
        o_data : out std_logic_vector (7 downto 0);
        o_address : out std_logic_vector (15 downto 0);
        o_enc_rdy : out std_logic;
        i_count_en : in std_logic;
        i_addr : in std_logic_vector (3 downto 0);
        i_sel_counter : in std_logic);
end component;

signal count_en : STD_LOGIC;
signal addr : std_logic_vector (3 downto 0);
signal sel_counter : STD_LOGIC;
signal enc_rdy : std_logic;
signal i_r_cache : std_logic_vector(7 downto 0); -- TODO check if removable
signal o_r_cache : std_logic_vector(7 downto 0); -- TODO check if removable
signal r_cache_load : std_logic;

type S is (S0,S1,S2,S3,S4,S5);
signal cur_state, next_state : S;
begin
    DATAPATH0: datapath port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_data => i_data,
        o_data => i_r_cache,
        o_address => o_address,
        o_enc_rdy => enc_rdy,
        i_count_en => count_en,
        i_addr => addr,
        i_sel_counter => sel_counter
    );
    
    R_CACHE: process(i_clk) -- R_CACHE
    begin
        if falling_edge(i_clk) then
            if(r_cache_load = '1') then
                o_r_cache <= i_r_cache;
            end if;
        end if;
    end process;
    
    o_data <= o_r_cache;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif falling_edge(i_clk) then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start, enc_rdy)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if i_start = '1' then
                    next_state <= S1;
                end if;
            when S1 =>
                if enc_rdy = '1' then
                    next_state <= S2;
                end if;
            when S2 =>
                next_state <= S3;
            when S3 =>
                next_state <= S4;
            when S4 =>
               if i_start = '1' then
                    next_state <= S2;
                else
                    next_state <= S5;
                end if;
            when S5 =>
                if i_start = '1' then
                    next_state <= S2;
                end if;
        end case;
    end process;

    process(cur_state) -- State values
    begin
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        count_en <= '0';
        sel_counter <= '0';
        addr <= "0000";
        r_cache_load <= '0';
        case cur_state is -- TODO : handle o_en
            when S0 =>
            when S1 =>
                count_en <= '1';
                o_en <= '1';
                sel_counter <= '1';
            when S2 =>
                addr <= "1000";
                o_en <= '1';
                r_cache_load <= '1';
            when S3 =>
                addr <= "1001";
                o_en <= '1';
                o_we <= '1';
            when S4 =>
                o_done <= '1';
            when S5 =>
        end case;
    
        end process;
end Behavioral;
