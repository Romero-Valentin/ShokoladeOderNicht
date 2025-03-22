# 48MHz clock - Internal oscillator
create_clock -period 20.83 [get_nets clock_handler.clock_48M]

# 10kHz clock - Internal oscillator - true period 100 000, but Radian only accepts 12 500
create_clock -period 12500 [get_nets clock_handler.clock_10k]