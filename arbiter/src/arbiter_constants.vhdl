library ieee;
use ieee.numeric_std.all;


package arbiter_constants is

    constant TIMEOUT_BITS : integer := 31;
    constant ARBITER_TIMEOUT : unsigned(TIMEOUT_BITS-1 downto 0) := to_unsigned(100000000, TIMEOUT_BITS);

end package arbiter_constants;
