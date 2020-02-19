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
        o_address : out std_logic_vector (15 downto 0);
        o_data : out std_logic_vector (7 downto 0);
        r_mem_load : in STD_LOGIC;
        r0_load : in STD_LOGIC;
        r1_load : in STD_LOGIC;
        r2_load : in STD_LOGIC;
        sel_addr : in STD_LOGIC;
        l_mask : in std_logic_vector(3 downto 0)
    );
end component;

signal r_mem_load : STD_LOGIC;
signal r0_load : STD_LOGIC;
signal r1_load : STD_LOGIC;
signal r2_load : STD_LOGIC;
signal sel_addr : STD_LOGIC;
signal l_mask : std_logic_vector (3 downto 0);

type S is (S0,S1,S2,S3,S4);
signal cur_state, next_state : S;
begin
    DATAPATH0: datapath port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_data => i_data,
        o_address => o_address,
        o_data => o_data,
        r_mem_load => r_mem_load,
        r0_load => r0_load,
        r1_load => r1_load,
        r2_load => r2_load,
        sel_addr => sel_addr,
        l_mask => l_mask
    );
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if i_start = '1' then
                    next_state <= S1;
                end if;
            when S1 =>
                next_state <= S2;
            when S2 =>
                next_state <= S3;
            when S3 =>
                next_state <= S4;
            when S4 =>
               --  next_state <= S5;
            -- when S5 =>
                next_state <= S0;
        end case;
    end process;

    process(cur_state) -- State values
    begin
        r_mem_load <= '0';
        r0_load <= '0';
        r1_load <= '0';
        r2_load <= '0';
        sel_addr <= '0';
        l_mask  <= "0000";
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        case cur_state is -- TODO : handle o_en
            when S0 =>
                l_mask <= "1000";
                r_mem_load <= '1';
                o_en <= '1';
            when S1 =>
                l_mask <= "0100";
                o_en <= '1';
            when S2 =>
                l_mask <= "0010";
                r0_load <= '1';
                o_en <= '1';
            when S3 =>
                l_mask <= "0001";
                r1_load <= '1';
                o_en <= '1';
            when S4 =>
                r2_load <= '1';
            -- when S5 =>
                sel_addr <= '1';
                o_en <= '1';
                o_we <= '1';
                o_done <= '1';
        end case;
    
        end process;
end Behavioral;
