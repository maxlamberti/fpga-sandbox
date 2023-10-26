library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity toplevel is

    port (
        CLKxCI : in std_logic;
        RSTxRI : in std_logic;
        Push0xSI : in std_logic;
        Push1xSI : in std_logic;
        Push2xSI : in std_logic;
        Push3xSI : in std_logic;
        RLEDxSO : out std_logic;
        GLEDxSO : out std_logic
    );

end toplevel;


architecture rtl of toplevel is

    component key_lock_timed
    port (
        CLKxCI : in std_logic;
        RSTxRI : in std_logic;
        KeyValidxSI : in std_logic;
        KeyxDI : in unsigned(2-1 downto 0);
        RLEDxSO : out std_logic;
        GLEDxSO : out std_logic
    );
    end component;

    signal KeyValidxS : std_logic := '0';
    signal KeyxD : unsigned(2-1 downto 0);


begin

    KeyLockStateMachine : key_lock_timed
    port map (
        CLKxCI => CLKxCI,
        RSTxRI => RSTxRI,
        KeyValidxSI => KeyValidxS,
        KeyxDI => KeyxD,
        RLEDxSO => RLEDxSO,
        GLEDxSO => GLEDxSO
    );

    KeyValidxS <=   (Push0xSI and not (Push1xSI or Push2xSI or Push3xSI)) or
                    (Push1xSI and not (Push0xSI or Push2xSI or Push3xSI)) or
                    (Push2xSI and not (Push0xSI or Push1xSI or Push3xSI))or
                    (Push3xSI and not (Push0xSI or Push1xSI or Push2xSI));

    -- set key
    process (all) is
    begin
        KeyxD <= to_unsigned(0, 2);
        if KeyValidxS then
            if Push0xSI then
                KeyxD <= to_unsigned(0, 2);
            elsif Push1xSI then
                KeyxD <= to_unsigned(1, 2);
            elsif Push2xSI then
                KeyxD <= to_unsigned(2, 2);
            elsif Push3xSI then
                KeyxD <= to_unsigned(3, 2);
            end if;
        end if;
    end process;

end rtl;
