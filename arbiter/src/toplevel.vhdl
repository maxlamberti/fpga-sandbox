library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity toplevel is

    port (
        CLKxCI : in std_logic;
        RSTxRI : in std_logic;
        Key0xSI : in std_logic;
        Key1xSI : in std_logic;
        GLED0xSO : out std_logic;
        RLED0xSO : out std_logic;
        GLED1xSO : out std_logic;
        RLED1xSO : out std_logic
    );

end toplevel;


architecture rtl of toplevel is

    component arbiter
    port (
        CLKxCI : in std_logic;
        RSTxRI : in std_logic;
        Key0xSI : in std_logic;
        Key1xSI : in std_logic;
        GLED0xSO : out std_logic;
        RLED0xSO : out std_logic;
        GLED1xSO : out std_logic;
        RLED1xSO : out std_logic
    );
    end component;

begin

    ArbiterStateMachine : arbiter
    port map (
        CLKxCI => CLKxCI,
        RSTxRI => RSTxRI,
        Key0xSI => Key0xSI,
        Key1xSI => Key1xSI,
        GLED0xSO => GLED0xSO,
        RLED0xSO => RLED0xSO,
        GLED1xSO => GLED1xSO,
        RLED1xSO => RLED1xSO
    );

end rtl;
