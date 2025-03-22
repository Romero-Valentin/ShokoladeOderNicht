-------------------------------------------------
-- Designer      : Valentin Romero
-- Creation date : 22/03/2025
--
--
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
entity servo_handler is
	generic (
		G_CLOCK_FREQ_KHZ : positive := 10
	);
    port(
		-- Clock
		clock     : in  std_logic;
		servo_ctl : out std_logic
    );
end servo_handler;

architecture synth of servo_handler is

---------------------------------------
--            CONSTANT               --
---------------------------------------
constant C_CLOCK_PERIOD_US      : positive := 100;--1000 * 1/G_CLOCK_FREQ_KHZ;
constant C_PWM_PERIOD_US        : positive := (1000 * 20) / C_CLOCK_PERIOD_US;
constant C_DUTY_PERIOD_MIN_US   : positive := (1000 * 1)  / C_CLOCK_PERIOD_US;
constant C_DUTY_PERIOD_MAX_US   : positive := (1000 * 2)  / C_CLOCK_PERIOD_US;
---------------------------------------
--            SIGNALS                --
---------------------------------------

signal s_intensity_counter 	: integer range 0 to C_PWM_PERIOD_US;
signal s_turn_counter 		: integer range 0 to 30;
signal s_turn 			    : std_logic := '0';

---------------------------------------
--            BEHAVIOR               --
---------------------------------------
begin

	counter_proc: process(clock)
	begin
		if rising_edge(clock) then
			if( s_intensity_counter >= C_PWM_PERIOD_US ) then 		s_intensity_counter <= 0;                      
			else 												    s_intensity_counter <= s_intensity_counter + 1;
			end if;
		end if;
	end process;

	turn_proc: process(clock)
	begin
		if rising_edge(clock) then
			if( s_intensity_counter >= C_PWM_PERIOD_US ) then 		
				if( s_turn_counter >= 30 ) then		s_turn_counter <= 0;					s_turn <= not(s_turn);
				else								s_turn_counter <= s_turn_counter + 1;	s_turn <= s_turn;
				end if;
			end if;           
		end if;
	end process;

	servo_proc: process(s_turn, s_intensity_counter)
	begin
		if( s_turn = '0' ) then
			if( s_intensity_counter >= C_DUTY_PERIOD_MIN_US ) then servo_ctl <= '0';
			else                                                   servo_ctl <= '1';
			end if;
		else
			if( s_intensity_counter >= C_DUTY_PERIOD_MAX_US ) then servo_ctl <= '0';
			else                                                   servo_ctl <= '1';
			end if;
		end if;
	end process;



end;