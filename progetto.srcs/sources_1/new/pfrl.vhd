
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- MAIN

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

type S is (INIT,LOAD_WZ,ENCODE,SAVE,DONE,WAIT_START);
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
        if falling_edge(i_clk) then
            if(i_rst = '1') then
                cur_state <= INIT;
            else
                cur_state <= next_state;
            end if;
        end if;
    end process;
    
    process(cur_state, i_start, enc_rdy)
    begin
        next_state <= cur_state;
        case cur_state is
            when INIT =>
                if i_start = '1' then
                    next_state <= LOAD_WZ;
                end if;
            when LOAD_WZ =>
                if enc_rdy = '1' then
                    next_state <= ENCODE;
                end if;
            when ENCODE =>
                next_state <= SAVE;
            when SAVE =>
                next_state <= DONE;
            when DONE =>
                if i_start = '1' then
                    next_state <= DONE;
                else 
                    next_state <= WAIT_START;
                end if;
            when WAIT_START =>
                if i_start = '1' then
                    next_state <= ENCODE;
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
        case cur_state is
            when INIT =>
            when LOAD_WZ =>
                count_en <= '1';
                o_en <= '1';
                sel_counter <= '1';
            when ENCODE =>
                addr <= "1000";
                o_en <= '1';
                r_cache_load <= '1';
            when SAVE =>
                addr <= "1001";
                o_en <= '1';
                o_we <= '1';
            when DONE =>
                o_done <= '1';
            when WAIT_START =>
        end case;
    
        end process;
end Behavioral;

-- MAIN

-- DATAPATH

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
    Port ( i_addr : in STD_LOGIC_VECTOR (6 downto 0);
           i_load_wz : in STD_LOGIC;
           o_hit : out STD_LOGIC;
           o_diff : out STD_LOGIC_VECTOR (1 downto 0);
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

TYPE offs_type is array (0 to 7) of std_logic_vector (1 downto 0);
signal offs : offs_type;
signal offs_or : std_logic_vector (1 downto 0);
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
    GEN_WZ: for I in 0 to 7 generate
        WZX: wz_enc port map (
            i_addr => i_data (6 downto 0),
            i_load_wz => counter_one_hot(I),
            o_hit => wz_hit_one_hot(I),
            o_diff => offs(I),
            i_clk => i_clk
        );
    end generate;
    
    --offs_or
    offs_or <= (offs(0) or offs(1) or offs(2) or offs(3) or offs(4) or offs(5) or offs(6) or offs(7));
    
    --offs_one_hot
    with offs_or select
        offs_one_hot <= "0001" when "00",
                        "0010" when "01",
                        "0100" when "10",
                        "1000" when "11",
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

-- DATAPATH

-- COUNTER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
    process(i_clk,i_rst)
    begin
        if falling_edge(i_clk) then
            if i_rst = '1' then
                cur_state <= S0;
            else
                cur_state <= next_state;
            end if;
        end if; 
    end process;
    
    process(cur_state, i_en)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 => if i_en = '1' then
                    next_state <= S1;
                end if;
            --when S0 => next_state <= S1;
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
            --when Swait =>
                --o_base2 <= "000";
                --o_one_hot <= "00000000";
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

-- COUNTER

-- WZ_ENC

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity wz_enc is
    Port ( i_addr : in STD_LOGIC_VECTOR (6 downto 0);
           i_load_wz : in STD_LOGIC;
           o_hit : out STD_LOGIC;
           o_diff : out STD_LOGIC_VECTOR (1 downto 0);
           i_clk : in STD_LOGIC);
end wz_enc;

architecture Behavioral of wz_enc is

signal o_r_wz : STD_LOGIC_VECTOR (6 downto 0);
signal lt_wz_addr : STD_LOGIC;
signal sub_addr_wz : STD_LOGIC_VECTOR (6 downto 0); --TODO check if using only 4 bits is problematic
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
    
    -- sub_addr_wz
    sub_addr_wz <= i_addr(6 downto 0) - o_r_wz(6 downto 0);
    
    -- o_hit
    hit <=  '1' when sub_addr_wz (6 downto 2) = "00000000" else '0';
                
    o_hit <= hit;
    
    --o_diff
    with hit select
        o_diff <=   sub_addr_wz (1 downto 0) when '1',
                    "00" when '0',
                    "XX" when others;

end Behavioral;

-- WZ_ENC