library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debouncer is
    generic(
        CLKF: INTEGER; --clk frequency [MHz]
        STAB: INTEGER  --stable time [ms]
        );
    Port ( 
        clk          : in STD_LOGIC;
        sw_in        : in STD_LOGIC;                        --noisy input
        sw_out       : out std_logic := '0'    --filtered output
        );
end debouncer;

architecture Behavioral of debouncer is

--signal clicked  : std_logic := '0';
signal input    : std_logic_vector(1 downto 0) := "00";     --register at the input of the device
signal start    : std_logic;

constant STAB_CLKS : integer := STAB * CLKF * 1000;         --constant with value of stable clock periods

begin

start <= input(0) xor input(1);                             --determining whether there is a change in input

debounce:
process(clk, start)
    variable counter : integer range 0 to STAB_CLKS;        --counter with stable clks;
begin
    if (rising_edge(clk)) then
        input(0) <= sw_in;                                  --storing next inputs in the register
        input(1) <= input(0);
        
        if (start = '1') then                               --starting to count the nonchanging input
            counter := 0;
        elsif ( counter < STAB_CLKS ) then                  --checking if the input was stable for STAB_CLKS
            counter := counter + 1;
        else 
            sw_out <= input(1);                             --outputing stable value
        end if;
    end if;  
end process debounce; 

end Behavioral;