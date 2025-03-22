-------------------------------------------------
-- Designer      : Valentin Romero
-- Creation date : 15/03/2025
--
-- 
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ice40up;
use ice40up.components.all;

library work;
use work.all;


entity top is
    port(
		red     : out std_logic;
		green   : out std_logic;
		blue    : out std_logic;
		gpio_23 : out std_logic
    );
end top;

architecture synth of top is

signal clock_48M  	: std_logic;
signal clock_10k 	: std_logic;
--signal reset      : std_logic;
signal count		: unsigned(25 downto 0);
signal led0_en		: std_logic;
signal led1_en		: std_logic;
signal led2_en		: std_logic;

begin

	led_handler : entity work.led_handler
	generic map ( G_INTENSITY_DIVIDER => 16 )
	port map (
		-- Clock
		clock    => clock_10k,
	
		-- Power input
		power_en => '1', -- Takes 100us to stabilize
		
		-- PWN input
		red_en   => led0_en,
		green_en => led1_en,
		blue_en  => led2_en,
		
		-- LED outputs
		red     => red,
		green   => green,
		blue    => blue
	);


	clock_handler : entity work.clock_handler
	port map (
		clock_10k => clock_10k,
		clock_48M => clock_48M
	);
	
	servo_handler : entity work.servo_handler
	generic map ( G_CLOCK_FREQ_KHZ => 10 )
	port map (
		-- Clock
		clock     => clock_10k,
		servo_ctl => gpio_23
	);
	
	led0_en <= count(25) and count(24);
	led1_en <= count(25) and not count(24);
	led2_en <= not count(25) and count(24);

	count_proc: process(clock_48M)
	begin
		if rising_edge(clock_48M) then
			count <= count+1;
		end if;
	end process;

end;