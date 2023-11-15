library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arbiter_constants.all;


entity arbiter is
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
end arbiter;


architecture rtl of arbiter is

    type RequesterPriority is (SUBSYSTEM_0, SUBSYSTEM_1);

    signal PriorityStatexP : RequesterPriority;
    signal PriorityStatexN : RequesterPriority;

    signal TimeoutCounterxP : unsigned(TIMEOUT_BITS-1 downto 0);
    signal TimeoutCounterxN : unsigned(TIMEOUT_BITS-1 downto 0);

begin

    -- registers
    process (all) is
    begin
    
        if RSTxRI = '1' then

            PriorityStatexP <= SUBSYSTEM_0;
            TimeoutCounterxP <= (others => '0');

        elsif CLKxCI = '1' and CLKxCI'event then

            PriorityStatexP <= PriorityStatexN;
            TimeoutCounterxP <= TimeoutCounterxN;

        end if;
        
    end process;


    -- time counter
    process (all) is
    begin
    
        TimeoutCounterxN <= (others => '0');
        
        if Key0xSI = '1' and Key1xSI = '1' and TimeoutCounterxP < ARBITER_TIMEOUT then
            TimeoutCounterxN <= TimeoutCounterxP + 1;
        end if;

    end process;
    
    -- set priority
    process (all) is
    begin
    
        PriorityStatexN <= PriorityStatexP;
        

        if Key0xSI = '0' and Key1xSI = '1' then

            PriorityStatexN <= SUBSYSTEM_1;

        elsif Key0xSI = '1' and Key1xSI = '0' then
            
            PriorityStatexN <= SUBSYSTEM_0;

        elsif Key0xSI = '1' and Key1xSI = '1' and TimeoutCounterxP = ARBITER_TIMEOUT  then

            -- switch priority due to timeout
            if PriorityStatexP = SUBSYSTEM_0 then
                PriorityStatexN <= SUBSYSTEM_1;
            else
                PriorityStatexN <= SUBSYSTEM_0;
            end if;
        
        end if;

    end process;

    -- set outputs
    GLED0xSO <= '1' when Key0xSI = '1' and PriorityStatexP = SUBSYSTEM_0 else '0';
    RLED0xSO <= '1' when Key0xSI = '1' and PriorityStatexP = SUBSYSTEM_1 else '0';
    GLED1xSO <= '1' when Key1xSI = '1' and PriorityStatexP = SUBSYSTEM_1 else '0';
    RLED1xSO <= '1' when Key1xSI = '1' and PriorityStatexP = SUBSYSTEM_0 else '0';

end rtl;
