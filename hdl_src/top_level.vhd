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
		blue    : out std_logic
    );
end top;

architecture synth of top is

signal clock      : std_logic;
--signal reset      : std_logic;
signal count:   unsigned(25 downto 0);
signal led0_en: std_logic;
signal led1_en: std_logic;
signal led2_en: std_logic;

begin

    u0 : entity work.led_handler
    port map (
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
	
	
	u1 : entity work.clock_handler
    port map (
		clock_10k => open,
		clock_48M => clock
    );
	
	
	led0_en <= count(25) and count(24);
    led1_en <= count(25) and not count(24);
    led2_en <= not count(25) and count(24);

    count_proc: process(clock)
    begin
        if rising_edge(clock) then
            count <= count+1;
        end if;
    end process;

end;