library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity generator is
port(
    clk                     : in std_logic; --clock input
    v_display_time_signal   : in std_logic; --vertical and horizontal display times 
    h_display_time_signal   : in std_logic;
    col_sw                  : in integer range 0 to 2; -- button changing the color
    R_out                   : out std_logic_vector(3 downto 0) := "0000"; --color outputs
    G_out                   : out std_logic_vector(3 downto 0) := "0000";
    B_out                   : out std_logic_vector(3 downto 0) := "0000"
);
end generator;

architecture Behavioral of generator is
begin

process(clk, h_display_time_signal, v_display_time_signal)

variable row_ptr    : integer range 1 to 480;
variable column_ptr : integer range 0 to 640;

type line_color_array is array (1 to 640) of integer range 0 to 15; --table of 640 + 1 elements, each element has value 0-15

variable temp : line_color_array := (others => 15);

variable color_block    : integer range 0 to 15 := 0; --number of color blocks in line
constant color_depth    : integer := 15;
constant color_value    : integer := 15; --constant with maximum color value

begin

if (rising_edge(clk) and h_display_time_signal = '1' and v_display_time_signal = '1') then
	if (column_ptr = 640) then
	
	   column_ptr := 0;
		
		if (row_ptr = 480) then
			row_ptr := 1;
		else
			row_ptr := row_ptr + 1;
		end if;
		
		if ((row_ptr > 0) and (row_ptr mod 30 = 0)) then --checking if rhe counters have moved to another line
		
			for x in 1 to 640 loop
			
				if (x < 40*(color_depth-color_block)+1) then --assiging color in the line, decrementing color vector every 40 pixels
					temp(x) := color_value;    
				else
					temp(x) := temp(x)-1;
				end if;
			end loop;
			color_block := color_block + 1; --incrementing number of color blocks in given line
		end if;
	end if;
	
	column_ptr := column_ptr +1;
    
    case col_sw is --passing color vector to a color that is pointed by col_sw
        when 0 =>
            R_out <= std_logic_vector(to_unsigned(temp(column_ptr), 4));
            G_out <= "0000";
            B_out <= "0000";
        when 1 =>
            G_out <= std_logic_vector(to_unsigned(temp(column_ptr), 4));
            R_out <= "0000";
            B_out <= "0000";
        when 2 =>
            B_out <= std_logic_vector(to_unsigned(temp(column_ptr), 4));
            G_out <= "0000";
            R_out <= "0000";
    end case;
	
end if;

end process;

end Behavioral;



