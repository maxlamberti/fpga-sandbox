--=============================================================================
-- @file key_lock_timed_tb.vhdl
--=============================================================================
-- Standard library
library ieee;
library std;
-- Standard packages
use std.env.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.key_lock_constants.all;

--=============================================================================
--
-- key_lock_timed_tb
--
-- @brief This file specifies the testbench for the RGB LED lab (lab 2).
--
-- This test will
--
--=============================================================================

--=============================================================================
-- ENTITY DECLARATION FOR key_lock_timed_tb
--=============================================================================
entity key_lock_timed_tb is
end key_lock_timed_tb;

--=============================================================================
-- ARCHITECTURE DECLARATION
--=============================================================================
architecture tb of key_lock_timed_tb is

  -- Constants
  constant CLK_HIGH : time := 4ns;      -- 125 MHz clk freq
  constant CLK_LOW  : time := 4ns;
  constant CLK_PER  : time := CLK_LOW + CLK_HIGH;
  constant CLK_STIM : time := 1ns;      -- Used to push us a little bit after the clock edge
  constant CLK_LIM  : integer := 2**22; -- Stops simulation from running forever if circuit is not correct

  constant CNT_ADD : integer := 2**17;      -- Value to add to counter for each button press
  constant CNT_LIM : integer := 2**20 - 1;  -- Max value of counter

  -- DUT signals
  signal CLKxCI : std_logic := '0';
  signal RSTxRI : std_logic := '1';
  signal KeyValidxSI : std_logic := '0';
  signal KeyxDI : unsigned(2-1 downto 0) := to_unsigned(0, 2);
  signal RLEDxSO : std_logic := '0';
  signal GLEDxSO : std_logic := '0';

--=============================================================================
-- COMPONENT DECLARATIONS
--=============================================================================
  component key_lock_timed is
    port (
        CLKxCI : in std_logic;
        RSTxRI : in std_logic;
        KeyValidxSI : in std_logic;
        KeyxDI : in unsigned(2-1 downto 0);
        RLEDxSO : out std_logic;
        GLEDxSO : out std_logic
    );
  end component;

--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
begin

--=============================================================================
-- COMPONENT INSTANTIATIONS
--=============================================================================
  dut: key_lock_timed
    port map (
        CLKxCI => CLKxCI,
        RSTxRI => RSTxRI,
        KeyValidxSI => KeyValidxSI,
        KeyxDI => KeyxDI,
        RLEDxSO => RLEDxSO,
        GLEDxSO => GLEDxSO
    );

--=============================================================================
-- CLOCK PROCESS
-- Process for generating the clock signal
--=============================================================================
  p_clock: process is
  begin
    CLKxCI <= '0';
    wait for CLK_LOW;
    CLKxCI <= '1';
    wait for CLK_HIGH;
  end process p_clock;

--=============================================================================
-- RESET PROCESS
-- Process for generating the reset signal
--=============================================================================
  p_reset: process is
  begin
    RSTxRI <= '1';
    wait until rising_edge(CLKxCI);   -- Align to clock rising edge
    wait for (2*CLK_PER + CLK_STIM);  -- Align to CLK_STIM ns after rising edge
    RSTxRI <= '0';
    wait;
  end process p_reset;

--=============================================================================
-- TEST PROCESSS
--=============================================================================
  p_stim: process


  begin

    wait until RSTxRI = '0';
    wait for CLK_PER;
    assert GLEDxSO = '0' and RLEDxSO = '1' report "Unexpected LED light state on idle." severity error;

    --------------------------------
    -- enter correct key combination
    --------------------------------
    
    KeyxDI <= CORRECT_COMBINATION(0);
    KeyValidxSI <= '1';
    wait for 4 * CLK_PER;

    KeyxDI <= to_unsigned(0, 2);
    KeyValidxSI <= '0';
    wait for 2 * CLK_PER;

    KeyxDI <= CORRECT_COMBINATION(1);
    KeyValidxSI <= '1';
    wait for 4 * CLK_PER;

    assert GLEDxSO = '0' and RLEDxSO = '0' report "Unexpected LED light state while inputting." severity error;

    KeyxDI <= to_unsigned(0, 2);
    KeyValidxSI <= '0';
    wait for 2 * CLK_PER;

    KeyxDI <= CORRECT_COMBINATION(2);
    KeyValidxSI <= '1';
    wait for 4 * CLK_PER;

    assert GLEDxSO = '0' and RLEDxSO = '0' report "Unexpected LED light state while inputting." severity error;

    KeyxDI <= to_unsigned(0, 2);
    KeyValidxSI <= '0';
    wait for 2 * CLK_PER;

    assert GLEDxSO = '1' and RLEDxSO = '0' report "Unexpected LED light state when open." severity error;

    wait for to_integer(OPEN_LOCK_TIMEOUT) * CLK_PER;
    assert GLEDxSO = '0' and RLEDxSO = '1' report "Expected LED light state to be off after  long open time." severity error;

    
    ----------------------------------
    -- enter incorrect key combination
    ----------------------------------
    
    KeyxDI <= to_unsigned(0, 2);
    KeyValidxSI <= '1';
    wait for 4 * CLK_PER;

    KeyxDI <= to_unsigned(0, 2);
    KeyValidxSI <= '0';
    wait for 2 * CLK_PER;

    KeyxDI <= to_unsigned(0, 2);
    KeyValidxSI <= '1';
    wait for 4 * CLK_PER;

    assert GLEDxSO = '0' and RLEDxSO = '0' report "Unexpected LED light state while inputting." severity error;

    KeyxDI <= to_unsigned(0, 2);
    KeyValidxSI <= '0';
    wait for 2 * CLK_PER;

    KeyxDI <= to_unsigned(0, 2);
    KeyValidxSI <= '1';
    wait for 4 * CLK_PER;

    assert GLEDxSO = '0' and RLEDxSO = '0' report "Unexpected LED light state while inputting." severity error;

    KeyxDI <= to_unsigned(0, 2);
    KeyValidxSI <= '0';
    wait for 2 * CLK_PER;

    assert GLEDxSO = '0' and RLEDxSO = '1' report "Unexpected LED light state inputting false key code." severity error;

    stop(0);

  end process;
end tb;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
