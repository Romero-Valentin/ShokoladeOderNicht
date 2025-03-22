-------------------------------------------------
-- Designer      : Valentin Romero
-- Creation date : 15/03/2025
--
-- This module drives uses the internal RGB driver to drive one RGB led.
-- When the RGB are controled by their respective 'enable' bit, they will light up 1/G_INTENSITY_DIVIDER of the time.
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
entity led_handler is
	generic (
		G_INTENSITY_DIVIDER : positive := 16
	);
    port(
		-- Clock
		clock    : in std_logic;
	
		-- Power input
		power_en : in  std_logic; -- Takes 100us to stabilize

		-- PWN input
		red_en   : in  std_logic;
		green_en : in  std_logic;
		blue_en  : in  std_logic;

		-- LED outputs
		red      : out std_logic;
		green    : out std_logic;
		blue     : out std_logic
    );
end led_handler;

architecture synth of led_handler is

---------------------------------------
--            CONSTANT               --
---------------------------------------
constant C_CURRENT_4ma  : string := "0b000001";
constant C_CURRENT_8ma  : string := "0b000011";
constant C_CURRENT_12ma : string := "0b000111";
constant C_CURRENT_16ma : string := "0b001111";
constant C_CURRENT_20ma : string := "0b011111";
constant C_CURRENT_24ma : string := "0b111111";

constant C_CURRENT_MODE_FULL : string := "0"; -- Full current output
constant C_CURRENT_MODE_HALF : string := "1"; -- Halves current output
---------------------------------------
--            SIGNALS                --
---------------------------------------
signal s_intensity_counter 	: integer range 0 to G_INTENSITY_DIVIDER;

signal s_green_pwm 			: std_logic;
signal s_blue_pwm 			: std_logic;
signal s_red_pwm 			: std_logic;

---------------------------------------
--            BEHAVIOR               --
---------------------------------------
begin

	s_green_pwm <= green_en when s_intensity_counter >= G_INTENSITY_DIVIDER else '0';
	s_blue_pwm 	<= blue_en  when s_intensity_counter >= G_INTENSITY_DIVIDER else '0';
	s_red_pwm 	<= red_en   when s_intensity_counter >= G_INTENSITY_DIVIDER else '0';

	-- Use a counter to PWM the LEDs with a duty cycle of 1/G_INTENSITY_DIVIDER
	counter_proc: process(clock)
	begin
		if rising_edge(clock) then
			if( s_intensity_counter >= G_INTENSITY_DIVIDER ) then 	s_intensity_counter <= 0;
			else 													s_intensity_counter <= s_intensity_counter + 1;
			end if;
		end if;
	end process;


    rgb_ctl : RGB1P8V
    generic map (
        CURRENT_MODE => C_CURRENT_MODE_HALF,
        RGB0_CURRENT => C_CURRENT_4ma, -- 4 mA is more than enough
        RGB1_CURRENT => C_CURRENT_4ma,
        RGB2_CURRENT => C_CURRENT_4ma
    )
    port map (
	
		-- Power input
        CURREN   => power_en,
        RGBLEDEN => '1',
		
		-- PWN input
        RGB0PWM  => s_green_pwm,
        RGB1PWM  => s_blue_pwm,
        RGB2PWM  => s_red_pwm,
		
		-- Output
        RGB0     => green,
        RGB1     => blue,
        RGB2     => red
    );

end;