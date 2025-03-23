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
		G_CLOCK_FREQ_KHZ : positive := 10;
		C_LUT_DEPTH      : positive := 5
	);
    port(
		clock       : in  std_logic;
		angle_index : in  integer range 0 to C_LUT_DEPTH-1;
		servo_ctl   : out std_logic
    );
end servo_handler;

architecture synth of servo_handler is

---------------------------------------
--            CONSTANT               --
---------------------------------------
--
-- time(ms)  :  0       2                        20     22                       20 21
-- servo_ctl :  _|------|________________________|------|________________________|--|________________________
--
constant C_CLOCK_PERIOD_US      : positive := 1000 * 1/G_CLOCK_FREQ_KHZ;         -- 0.1 ms
constant C_PWM_PERIOD_US        : positive := 1000 * 20;                         -- 20  ms
constant C_DUTY_PERIOD_MIN_US   : positive := 1000 * 5  /10;                     -- 0.5 ms
constant C_DUTY_PERIOD_MAX_US   : positive := 1000 * 25 /10;                     -- 2.5 ms

constant C_PWM_NB_CLK           : positive := C_PWM_PERIOD_US       / C_CLOCK_PERIOD_US; -- 200
constant C_DUTY_MIN_NB_CLK      : positive := C_DUTY_PERIOD_MIN_US  / C_CLOCK_PERIOD_US; -- 5
constant C_DUTY_MAX_NB_CLK      : positive := C_DUTY_PERIOD_MAX_US  / C_CLOCK_PERIOD_US; -- 25

constant C_DUTY_STEP_NB_CLK     : positive := (C_DUTY_MAX_NB_CLK - C_DUTY_MIN_NB_CLK) / (C_LUT_DEPTH - 1); -- 4

---------------------------------------
--              LUT                  --
---------------------------------------
-- Define a constant lookup table with 5 entries to have : lut(angle) = nb_clk
type t_LUT_angle is array (0 to C_LUT_DEPTH-1) of integer;
constant LUT_angle : t_LUT_angle := (
	0  =>                           C_DUTY_MIN_NB_CLK, -- 0
	1  => 1  * C_DUTY_STEP_NB_CLK + C_DUTY_MIN_NB_CLK, -- 45 
	2  => 2  * C_DUTY_STEP_NB_CLK + C_DUTY_MIN_NB_CLK, -- 90
	3  => 3  * C_DUTY_STEP_NB_CLK + C_DUTY_MIN_NB_CLK, -- 135
	4  =>                           C_DUTY_MAX_NB_CLK  -- 180
);
---------------------------------------
--              TYPE                 --
---------------------------------------
type state_type is (WAITING_ANGLE, CONTROL_SERVO);

---------------------------------------
--            SIGNALS                --
---------------------------------------
signal current_state        : state_type;
signal next_state           : state_type;

signal s_new_angle 	        : std_logic;
signal s_servo_ON_counter 	: integer range 0 to C_PWM_NB_CLK;
signal s_nb_of_control 	    : integer range 0 to 10;
signal s_old_angle_index 	: integer range 0 to C_LUT_DEPTH-1;

---------------------------------------
--            BEHAVIOR               --
---------------------------------------
begin

    s_old_angle_index <= angle_index when rising_edge(clock) 				else s_old_angle_index;
	current_state     <= next_state  when rising_edge(clock)				else current_state;
	s_new_angle       <= '1'         when s_old_angle_index /= angle_index 	else '0';
	
    -- State logic
    process(current_state, s_new_angle, s_servo_ON_counter, s_nb_of_control)
    begin
        case current_state is
            when WAITING_ANGLE =>
                if s_new_angle = '1' then		next_state <= CONTROL_SERVO;
                else							next_state <= WAITING_ANGLE;
                end if;

            when CONTROL_SERVO =>
                if s_servo_ON_counter >= C_PWM_NB_CLK and s_nb_of_control >= 6 then		next_state <= WAITING_ANGLE;
                else																	next_state <= CONTROL_SERVO;
                end if;
        end case;
    end process;

	nb_control_proc: process(clock)
	begin
		if rising_edge(clock) then
			if (current_state = WAITING_ANGLE) 			then 	s_nb_of_control <= 0;
			elsif (s_servo_ON_counter >= C_PWM_NB_CLK) 	then 	s_nb_of_control <= s_nb_of_control + 1;
			else 												s_nb_of_control <= s_nb_of_control;
			end if;
		end if;
	end process;

	counter_proc: process(clock)
	begin
		if rising_edge(clock) then
			if( s_servo_ON_counter >= C_PWM_NB_CLK OR next_state = WAITING_ANGLE) then 	s_servo_ON_counter <= 0;                      
			else 												    					s_servo_ON_counter <= s_servo_ON_counter + 1;
			end if;
		end if;
	end process;

	servo_proc: process(next_state, s_servo_ON_counter, angle_index)
	begin
		if( next_state = WAITING_ANGLE )  							then servo_ctl <= '0';
		elsif( s_servo_ON_counter >= LUT_angle(angle_index) )  		then servo_ctl <= '0';
		else                                                   		 	 servo_ctl <= '1';
		end if;
	end process;



end;