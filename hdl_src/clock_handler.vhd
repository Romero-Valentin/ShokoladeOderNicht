-------------------------------------------------
-- Designer      : Valentin Romero
-- Creation date : 15/03/2025
--
-- This module takes advantages of the two internal oscillators to generate a 10kHz and a 48MHz clock.
-------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ice40up;
use ice40up.components.all;

library work;

---------------------------------------
--            ENTITY                 --
---------------------------------------
entity clock_handler is
    port(
		clock_10k : out std_logic;
		clock_48M : out std_logic
    );
end clock_handler;

architecture synth of clock_handler is

---------------------------------------
--            CONSTANT               --
---------------------------------------
constant C_CLOCK_6MHz   : string := "0b11";
constant C_CLOCK_12MHz  : string := "0b10";
constant C_CLOCK_24MHz  : string := "0b01";
constant C_CLOCK_48MHz  : string := "0b00";

---------------------------------------
--            SIGNALS                --
---------------------------------------


---------------------------------------
--            BEHAVIOR               --
---------------------------------------
begin

    -- High frequency on-chip oscillator
    clock_hf : HSOSC
    generic map (
        CLKHF_DIV => C_CLOCK_48MHz
    )
    port map (
		CLKHFPU   => '1', -- Power up the oscillator, stable after 100us
		CLKHFEN   => '1', -- Enable clock output
		CLKHF     => clock_48M
    );
	
	-- Low frequency on-chip oscillator
    clock_lf : LSOSC
    port map (
		CLKLFPU   => '1', -- Power up the oscillator, stable after 100us
		CLKLFEN   => '1', -- Enable clock output
		CLKLF     => clock_10k
    );

end;