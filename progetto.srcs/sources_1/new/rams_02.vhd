-- Single-Port Block RAM Write-First Mode (recommended template)
--
-- File: rams_02.vhd
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY rams_sp_wf IS
    PORT (
        clk : IN std_logic;
        we : IN std_logic;
        en : IN std_logic;
        addr : IN std_logic_vector(15 DOWNTO 0);
        di : IN std_logic_vector(7 DOWNTO 0);
        do : OUT std_logic_vector(7 DOWNTO 0)
    );
END rams_sp_wf;
ARCHITECTURE syn OF rams_sp_wf IS
    TYPE ram_type IS ARRAY (65535 DOWNTO 0) OF std_logic_vector(7 DOWNTO 0);
    SIGNAL RAM : ram_type;
BEGIN
    PROCESS (clk)
    BEGIN
        IF clk'event AND clk = '1' THEN
            IF en = '1' THEN
                IF we = '1' THEN
                    RAM(conv_integer(addr)) <= di;
                    do <= di;
                ELSE
                    do <= RAM(conv_integer(addr));
                END IF;
            END IF;
        END IF;
    END PROCESS;
END syn;