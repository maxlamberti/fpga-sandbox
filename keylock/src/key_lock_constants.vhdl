library ieee;
use ieee.numeric_std.all;


package key_lock_constants is

    type CombinationArray is array (natural range <>) of unsigned(2-1 downto 0);    
    constant OPEN_LOCK_TIMEOUT : unsigned(31-1 downto 0) := to_unsigned(10, 31);
    constant CORRECT_COMBINATION : CombinationArray(0 to 2) := (to_unsigned(0, 2), to_unsigned(2, 2), to_unsigned(1, 2)); -- u, r, l

end package key_lock_constants;
