library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity key_lock_timed is
    port (
        CLKxCI : in std_logic;
        RSTxRI : in std_logic;
        KeyValidxSI : in std_logic;
        KeyxDI : in unsigned(2-1 downto 0);
        RLEDxSO : out std_logic;
        GLEDxSO : out std_logic
    );
end key_lock_timed;


architecture rtl of key_lock_timed is

    type LockStateEnum is (LOCK_OPEN, LOCK_CLOSED);
    type CombinationCheckStateEnum is (COMBINATION_WRONG, COMBINATION_OK);
    type CombinationArray is array (natural range <>) of unsigned(2-1 downto 0);    

    constant OPEN_LOCK_TIMEOUT : unsigned(31-1 downto 0) := to_unsigned(1000000000, 31);
    constant CORRECT_COMBINATION : CombinationArray(2 downto 0) := (to_unsigned(0, 2), to_unsigned(2, 2), to_unsigned(1, 2)); -- u, r, l

    signal KeyValidxSP : std_logic;
    signal KeyValidRisesxS : std_logic;
    
    signal LockStatexSP : LockStateEnum;
    signal LockStatexSN : LockStateEnum;

    signal CombinationStatexSP : CombinationCheckStateEnum;
    signal CombinationStatexSN : CombinationCheckStateEnum;

    signal DigitIndexxP : unsigned(2-1 downto 0);
    signal DigitIndexxN : unsigned(2-1 downto 0);

    signal OpenTimeCounterxDP : UNSIGNED(31-1 downto 0);
    signal OpenTimeCounterxDN : UNSIGNED(31-1 downto 0);

begin

    -- registers
    process (all) is
    begin
    
        if RSTxRI = '1' then

            KeyValidxSP <= '0';
            DigitIndexxP <= to_unsigned(0, 2);
            CombinationStatexSP <= COMBINATION_OK;
            LockStatexSP <= LOCK_CLOSED;
            OpenTimeCounterxDP <= (others => '0');

        elsif CLKxCI = '1' and CLKxCI'event then

            KeyValidxSP <= KeyValidxSI;
            DigitIndexxP <= DigitIndexxN;
            CombinationStatexSP <= CombinationStatexSN;
            LockStatexSP <= LockStatexSN;
            OpenTimeCounterxDP <= OpenTimeCounterxDN;

        end if;
        
    end process;

    -- button is pressed
    KeyValidRisesxS <= (not KeyValidxSP) and KeyValidxSI;

    -- digit index counter for which key index we are checking
    process (all) is
    begin

        DigitIndexxN <= DigitIndexxP;
        
        if KeyValidRisesxS = '1' then

            -- iterate, or wrap if reached final key entry
            if DigitIndexxP = to_unsigned(2, 2) then
                DigitIndexxN <= to_unsigned(0, 2);
            else
                DigitIndexxN <= DigitIndexxP + 1;
            end if;

        end if;
    end process;


    -- combination state changes
    process (all) is
    begin

        CombinationStatexSN <= CombinationStatexSP;
        
        if KeyValidRisesxS = '1' and CombinationStatexSP = COMBINATION_OK and KeyxDI /= CORRECT_COMBINATION(to_integer(DigitIndexxP)) then
            CombinationStatexSN <= COMBINATION_WRONG;
        end if;

        if KeyValidRisesxS = '0' and DigitIndexxP = to_unsigned(0, 2) then
            CombinationStatexSN <= COMBINATION_OK;
        end if;

    end process;

    -- lock state change and open timer
    process (all) is
        begin

        LockStatexSN <= LockStatexSP;
        OpenTimeCounterxDN <= OpenTimeCounterxDP;

        if KeyValidRisesxS = '1' and DigitIndexxP = to_unsigned(2, 2) and CombinationStatexSP = COMBINATION_OK then
            LockStatexSN <= LOCK_OPEN;
        end if;
        
        -- control open lock state, either increment or time out the open state
        if LockStatexSP = LOCK_OPEN and OpenTimeCounterxDP = OPEN_LOCK_TIMEOUT then
            LockStatexSN <= LOCK_CLOSED;
            OpenTimeCounterxDN <= to_unsigned(0, 31);
        elsif LockStatexSP = LOCK_OPEN then
            OpenTimeCounterxDN <= OpenTimeCounterxDP + 1;
        end if;
        
    end process;

    -- set output leds
    process (all) is
    begin

        if LockStatexSP = LOCK_OPEN then
            GLEDxSO <= '1';
            RLEDxSO <= '0';
        elsif DigitIndexxP = to_unsigned(0, 2) then
            GLEDxSO <= '0';
            RLEDxSO <= '1';
        else
            GLEDxSO <= '0';
            RLEDxSO <= '0';
        end if;

    end process;
    

end rtl;
