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
        i_rst : in STD_LOGIC;
        i_data : in std_logic_vector (7 downto 0);
        o_data : out std_logic_vector (7 downto 0);
        o_address : out std_logic_vector (15 downto 0);
        o_enc_rdy : out std_logic;
        i_count_en : in std_logic;
        i_addr : in std_logic_vector (3 downto 0);
        i_sel_counter : in std_logic);
end datapath;

architecture Behavioral of datapath is
component wz_enc is 
    Port ( i_addr : in STD_LOGIC_VECTOR (7 downto 0);
           i_load_wz : in STD_LOGIC;
           o_hit : out STD_LOGIC;
           o_diff : out STD_LOGIC_VECTOR (3 downto 0);
           i_clk : in STD_LOGIC);
end component;

component counter is
    Port ( i_en : in STD_LOGIC;
           i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           o_base2 : out STD_LOGIC_VECTOR (2 downto 0);
           o_one_hot : out STD_LOGIC_VECTOR (7 downto 0);
           o_done : out STD_LOGIC);
end component;

signal os0, os1, os2, os3, os4, os5, os6, os7 : std_logic_vector (3 downto 0);
signal offs_and : std_logic_vector (3 downto 0);
signal offs_one_hot : std_logic_vector (3 downto 0);
signal wz_hit_one_hot : std_logic_vector (7 downto 0);
signal wz_hit_base_2 : std_logic_vector (2 downto 0);
signal enc_addr : std_logic_vector (7 downto 0);

signal counter_one_hot : std_logic_vector (7 downto 0);
signal counter_base_2 : std_logic_vector (2 downto 0);

begin
    CNT: counter port map (
        i_en => i_count_en,
        i_clk => i_clk,
        i_rst => i_rst,
        o_base2 => counter_base_2,
        o_one_hot => counter_one_hot,
        o_done => o_enc_rdy
    );
    -- TODO Replace with `for I in 7 downto 0 generate`
    WZ0: wz_enc port map (
        i_addr => i_data,
        i_load_wz => counter_one_hot(0),
        o_hit => wz_hit_one_hot(0),
        o_diff => os0,
        i_clk => i_clk
    );
    WZ1: wz_enc port map (
        i_addr => i_data,
        i_load_wz => counter_one_hot(1),
        o_hit => wz_hit_one_hot(1),
        o_diff => os1,
        i_clk => i_clk
    );
    WZ2: wz_enc port map (
        i_addr => i_data,
        i_load_wz => counter_one_hot(2),
        o_hit => wz_hit_one_hot(2),
        o_diff => os2,
        i_clk => i_clk
    );
    WZ3: wz_enc port map (
        i_addr => i_data,
        i_load_wz => counter_one_hot(3),
        o_hit => wz_hit_one_hot(3),
        o_diff => os3,
        i_clk => i_clk
    );
    WZ4: wz_enc port map (
        i_addr => i_data,
        i_load_wz => counter_one_hot(4),
        o_hit => wz_hit_one_hot(4),
        o_diff => os4,
        i_clk => i_clk
    );
    WZ5: wz_enc port map (
        i_addr => i_data,
        i_load_wz => counter_one_hot(5),
        o_hit => wz_hit_one_hot(5),
        o_diff => os5,
        i_clk => i_clk
    );
    WZ6: wz_enc port map (
        i_addr => i_data,
        i_load_wz => counter_one_hot(6),
        o_hit => wz_hit_one_hot(6),
        o_diff => os6,
        i_clk => i_clk
    );
    WZ7: wz_enc port map (
        i_addr => i_data,
        i_load_wz => counter_one_hot(7),
        o_hit => wz_hit_one_hot(7),
        o_diff => os7,
        i_clk => i_clk
    );
    
    --offs_and
    offs_and <= (os0 and os1 and os2 and os3 and os4 and os5 and os6 and os7);
    
    --offs_one_hot
    with offs_and select
        offs_one_hot <= "0001" when "0000",
                        "0010" when "0001",
                        "0100" when "0010",
                        "1000" when "0011",
                        "XXXX" when others;
    
    --wz_hot_base_2
    with wz_hit_one_hot select
        wz_hit_base_2 <=    "000" when "00000001",
                            "001" when "00000010",
                            "010" when "00000100",
                            "011" when "00001000",
                            "100" when "00010000",
                            "101" when "00100000",
                            "110" when "01000000",
                            "111" when "10000000",
                            "XXX" when others;
    --enc_addr
    enc_addr <= '1' & wz_hit_base_2 & offs_one_hot;
    
    --o_data
    with wz_hit_one_hot select
        o_data <=   i_data when "00000000",
                    enc_addr when others;
    
    --o_address
    with i_sel_counter select
        o_address <=    "0000000000000" & counter_base_2 when '1',
                        "000000000000" & i_addr when '0',
                        "XXXXXXXXXXXXXXXX" when others;
end Behavioral;
