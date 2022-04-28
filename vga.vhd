library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity vga is
	port(
	   clk             : in std_logic;     --clock imput
	   switch_in       : in std_logic;     --debounced switch input
	   h_sync_signal   : out std_logic;    --sync signals management
	   v_sync_signal   : out std_logic;

	   R               : out std_logic_vector(3 downto 0); --color vecors
	   G               : out std_logic_vector(3 downto 0);
	   B               : out std_logic_vector(3 downto 0);
	   
	   h_disp           : out std_logic;   --display time signals used to debugging
	   v_disp           : out std_logic);
	   
end vga;

architecture Behavioral of vga is

signal h_display_time_check: std_logic; --time to send color data
signal v_display_time_check: std_logic; --time to send color data
signal switch : std_logic := '0';       --debounced button input
signal color_pick_sig : integer range 0 to 2 := 0;  --representing color state

signal R_check : std_logic_vector(3 downto 0);  --color signals
signal G_check : std_logic_vector(3 downto 0);
signal B_check : std_logic_vector(3 downto 0);

component sync is                  --
    generic(
        h_front_porch   : integer; --hsync - nb of clks
        h_pulse_width   : integer;
        h_sync_pulse    : integer;
        h_back_porch    : integer;
	    h_display_time  : integer;
	 
	    v_front_porch   : integer;	--vsync - nb of lines
        v_pulse_width   : integer;
        v_sync_pulse    : integer;
        v_back_porch    : integer;
	    v_display_time  : integer);
	 
    Port(
        clk: in std_logic;
        h_sync_signal: out std_logic;
	    v_sync_signal: out std_logic;
	    h_display_time_signal: out std_logic;
	    v_display_time_signal: out std_logic);
end component;

component generator is
    port(
        clk                     : in std_logic;
        v_display_time_signal   : in std_logic;
        h_display_time_signal   : in std_logic;
        col_sw                  : in integer range 0 to 2;        -- button changing the color
        R_out                   : out std_logic_vector(3 downto 0) := "0000";
        G_out                   : out std_logic_vector(3 downto 0) := "0000";
        B_out                   : out std_logic_vector(3 downto 0) := "0000"
        );
end component;

component debouncer is
    generic(
        CLKF: INTEGER; --clk frequency [MHz]
        STAB: INTEGER  --stable time bit [ns]
        );
    port(
        clk          : in STD_LOGIC;
        sw_in        : in STD_LOGIC;                        --noisy input
        sw_out       : out std_logic := '0'        --filtered output
        );
end component;        

begin

S: sync         --initiating the sync component
generic map(    --generic initiation
    h_front_porch   => 16,
    h_pulse_width   => 96,
    h_sync_pulse    => 800,
    h_back_porch    => 48,
    h_display_time  => 640,

    v_front_porch   => 10,
    v_pulse_width   => 2,
    v_sync_pulse    => 521,
    v_back_porch    => 29,
    v_display_time  => 480)

port map(       --port initiation
    clk=>clk,
    h_sync_signal   =>h_sync_signal,
    v_sync_signal   =>v_sync_signal,
    h_display_time_signal => h_display_time_check,
    v_display_time_signal => v_display_time_check);
    
Gen: generator --initiating the generator component
port map(
    clk => clk,
    h_display_time_signal => h_display_time_check,
    v_display_time_signal => v_display_time_check,
    col_sw => color_pick_sig,
    R_out => R_check,
    G_out => G_check,
    B_out => B_check
    );
    
Deb: debouncer --initating the debouncer component
generic map(
    CLKF => 25,
    STAB => 10
    )
port map(
    clk => clk,
    sw_in => switch_in,
    sw_out => switch
    );
    
    
v_disp <= v_display_time_check;
h_disp <= h_display_time_check;   
 
determine_color: process(switch)    --picking color to display based on number of button presses
variable color_pick : integer range 0 to 2 := 0;
begin

    if(rising_edge(switch)) then 
        color_pick := color_pick + 1;
        
        if (color_pick = 0) then color_pick_sig <= 0;
        elsif (color_pick = 1) then color_pick_sig <= 1;
        else
            color_pick_sig <= 2;
            color_pick := 0;
        end if;
             
    end if;

end process determine_color;
    
check_disp_time: process(v_display_time_check, h_display_time_check, R_check, G_check, B_check) --displaying color only in display time
begin
    if(v_display_time_check = '1' and h_display_time_check = '1') then
        R <= R_check;
        G <= G_check;
        B <= B_check;
    else
        R <= "0000";
        G <= "0000";
        B <= "0000";
    end if;  
end process check_disp_time;
end Behavioral;

