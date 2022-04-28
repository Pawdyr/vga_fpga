library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity sync is
    generic(h_front_porch   : integer; --hsync - nb of clks
            h_pulse_width   : integer;
            h_sync_pulse    : integer;
            h_back_porch    : integer;
	        h_display_time  : integer;
	 
	        v_front_porch   : integer;	--vsync - nb of lines
            v_pulse_width   : integer;
            v_sync_pulse    : integer;
            v_back_porch    : integer;
	        v_display_time  : integer);
	 
    port(
        clk                     : in std_logic;         --clock input
        h_sync_signal           : out std_logic := '1'; --horizontal and vertical sync
	    v_sync_signal           : out std_logic := '1'; 
	    h_display_time_signal   : out std_logic := '0'; --horizontal and vertical display time
	    v_display_time_signal   : out std_logic := '0'
	    );
end sync;

architecture Behavioral of sync is

begin

process(clk)

variable counter        : integer range 0 to h_front_porch + h_sync_pulse + h_pulse_width + h_back_porch; --horizontal counter
variable line_counter   : integer range 0 to v_front_porch + v_sync_pulse + v_pulse_width + v_back_porch; --vertical counter

begin

if rising_edge(clk) then

    if counter < h_front_porch then             --driving h_sync signal based on time intervals assigned in generic parameters
        h_sync_signal <= '1';
    elsif counter < h_front_porch + h_pulse_width then
        h_sync_signal <= '0';
    elsif counter < h_front_porch + h_sync_pulse then
        h_sync_signal <= '1';
    elsif counter < h_front_porch + h_sync_pulse + h_pulse_width then
        h_sync_signal <= '0';
    else
        h_sync_signal <= '1';
    end if;     
	                                     --driving h_display_time_signal based on time intervals assigned in generic parameters
	if counter >= (h_front_porch + h_pulse_width + h_back_porch) and counter < (h_front_porch + h_pulse_width + h_back_porch + h_display_time) then
	    h_display_time_signal <= '1';
	else
	    h_display_time_signal <= '0';
	end if;
	 
	if line_counter < v_front_porch then   --driving v_sync signal based on time intervals assigned in generic parameters
        v_sync_signal <= '1';
    elsif line_counter < v_front_porch + v_pulse_width then
        v_sync_signal <= '0';
    elsif line_counter < v_front_porch + v_sync_pulse then
        v_sync_signal <= '1';
    elsif line_counter < v_front_porch + v_sync_pulse + v_pulse_width then
        v_sync_signal <= '0';
    else
        v_sync_signal <= '1';
    end if;     
	 
	                                     --driving v_display_time_signal  based on time intervals assigned in generic parameters
	if line_counter >= (v_front_porch + v_pulse_width + v_back_porch) and line_counter < (v_front_porch + v_pulse_width + v_back_porch + v_display_time) then
	    v_display_time_signal <= '1';
	else
		v_display_time_signal <= '0';
	end if;
    
    counter := counter + 1; --counter management
	if counter = h_sync_pulse then
        counter := 0;
	    line_counter := line_counter + 1;
	end if;
    if line_counter = v_sync_pulse then
        line_counter := 0;
	end if;

end if;

end process;

end Behavioral;
