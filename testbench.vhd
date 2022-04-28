LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT vga
    PORT(
     clk            : in std_logic;
     switch_in      : in std_logic;
	 h_sync_signal  : out std_logic;
	 v_sync_signal  : out std_logic;
	
	 R: out std_logic_vector(3 downto 0);
	 G: out std_logic_vector(3 downto 0);
	 B: out std_logic_vector(3 downto 0);
	 
	 h_disp           : out std_logic;
	 v_disp           : out std_logic);
	end component;
    
   --Inputs
    signal clock       : std_logic := '1';
	signal noisy_sw    : std_logic := '0';
	
	signal h_d         :std_logic;
	signal v_d         :std_logic;

 	--Outputs
    signal h_sync_signal            : std_logic;
	signal v_sync_signal            : std_logic;
	signal red_out     : std_logic_vector(3 downto 0);
	signal green_out   : std_logic_vector(3 downto 0);
	signal blue_out    : std_logic_vector(3 downto 0);
	
   -- Clock period definitions
   constant clk_period : time := 40 ns;
   
BEGIN
 
 
-- Instantiate the Unit Under Test (UUT)
   uut: vga PORT MAP (
          clk => clock,
          switch_in => noisy_sw,
          h_sync_signal => h_sync_signal,
		  v_sync_signal => v_sync_signal,
		  R => red_out,
		  G => green_out,
		  B => blue_out,
		  h_disp => h_d,
		  v_disp => v_d	 
        );

   -- Clock process definitions
clock <= not clock after clk_period/2;


noisy_sw <= '1' after 5 ms, '0' after 20 ms, '1' after 21 ms;

process(clock)

--save frame to file
	variable pixel_r : integer range 0 to 15;
	variable pixel_g : integer range 0 to 15;
	variable pixel_b : integer range 0 to 15;
	
	variable pixel_counter : integer range 0 to 307200; --counting total nb of pixels in frame

	file frame: text open write_mode is "frame.ppm";
	variable L: line;
	variable frame_header: boolean:=false;
	
	variable header    : string(1 to 2) := "P3";
	variable res       : string(1 to 10):= "800 521 15";
	variable ws        : string(1 to 1) := " ";  

begin

if (rising_edge(clock)) then
 
	if not frame_header then
		write(L, header);
		writeline(frame, L);
		write(L, res);
		writeline(frame, L);
		frame_header := true;
	end if;
	

	--if (h_display_time_signal = '1' and v_display_time_signal = '1') then
		
		pixel_r := to_integer(unsigned(red_out));
		pixel_g := to_integer(unsigned(green_out));
		pixel_b := to_integer(unsigned(blue_out));
		
		write(L, pixel_r);
		write(L, ws);
		write(L, pixel_g);
		write(L, ws);
		write(L, pixel_b);
		write(L, ws);
			
		
		pixel_counter := pixel_counter + 1;
		
		if pixel_counter mod 640 = 0 then
			writeline(frame, L);
		end if;
		
		if pixel_counter = 307200 then
			assert false report "Video frame created" severity NOTE;
			
		end if;

	--end if;

end if;

end process;


END;
