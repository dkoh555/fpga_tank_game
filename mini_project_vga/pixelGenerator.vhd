library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pixelGenerator is
	port(
			clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
			pixel_row, pixel_column						    : in std_logic_vector(9 downto 0);

			--Implementing additional inputs for receiving tank and bullet positions
			top_tank_x, bot_tank_x, top_bull_x, bot_bull_x	: in std_logic_vector(9 downto 0); --Pixel x-coord is from 0 to 640 (2^9 - 1 < 640 < 2^10 - 1)
			top_bull_y, bot_bull_y : in std_logic_vector(8 downto 0); --Pixel y-coord is from 0 to 640 (2^8 - 1 < 480 < 2^9 - 1)

			red_out, green_out, blue_out					: out std_logic_vector(7 downto 0)
		);
end entity pixelGenerator;

architecture behavioral of pixelGenerator is

constant color_red 	 	 : std_logic_vector(2 downto 0) := "000";
constant color_green	 : std_logic_vector(2 downto 0) := "001";
constant color_blue 	 : std_logic_vector(2 downto 0) := "010";
constant color_yellow 	 : std_logic_vector(2 downto 0) := "011";
constant color_magenta 	 : std_logic_vector(2 downto 0) := "100";
constant color_cyan 	 : std_logic_vector(2 downto 0) := "101";
constant color_black 	 : std_logic_vector(2 downto 0) := "110";
constant color_white	 : std_logic_vector(2 downto 0) := "111";

--Additional constants for tank and bullet dimensions
constant tank_width		: integer := 80;
constant tank_length	: integer := 40;
constant bull_width		: integer := 5;
constant bull_length	: integer := 25;
--Additional constants for tank's set y-coords
constant top_tank_row_int	: integer := 10; --Space between tank and upper/lower screen boundary
constant bot_tank_row_int		: integer := 430; --Number comes from (480 - 10 - 40) = 430
	
component colorROM is
	port
	(
		address		: in std_logic_vector (2 downto 0);
		clock		: in std_logic  := '1';
		q			: out std_logic_vector (29 downto 0)
	);
end component colorROM;

signal colorAddress : std_logic_vector (2 downto 0);
signal color        : std_logic_vector (29 downto 0);

signal pixel_row_int, pixel_column_int : natural;

--Additional signals for holding and converting tank and bullet positions from std_logic_vector to integers
signal top_tank_col_int, bot_tank_col_int, top_bull_col_int, bot_bull_col_int, top_bull_row_int, bot_bull_row_int : natural;

begin

--------------------------------------------------------------------------------------------
	
	red_out <= color(27 downto 20);
	green_out <= color(17 downto 10);
	blue_out <= color(7 downto 0);

	pixel_row_int <= to_integer(unsigned(pixel_row));
	pixel_column_int <= to_integer(unsigned(pixel_column));

	--Converting tank and bullet positions from std_logic_vector to integers
	top_tank_col_int <= to_integer(unsigned(top_tank_x));
	bot_tank_col_int <= to_integer(unsigned(bot_tank_x));
	top_bull_col_int <= to_integer(unsigned(top_bull_x));
	bot_bull_col_int <= to_integer(unsigned(bot_bull_x));
	top_bull_row_int <= to_integer(unsigned(top_bull_y));
	bot_bull_row_int <= to_integer(unsigned(bot_bull_y));
	
--------------------------------------------------------------------------------------------	
	
	colors : colorROM
		port map(colorAddress, ROM_clk, color);

--------------------------------------------------------------------------------------------	

	pixelDraw : process(clk, rst_n) is
	
	begin
			
		if (rising_edge(clk)) then
		
			if (pixel_column_int > top_tank_col_int and pixel_column_int < (top_tank_col_int + tank_width)
				and pixel_row_int > top_tank_row_int and pixel_row_int < (top_tank_row_int + tank_length)) then --Top tank visulization
				colorAddress <= color_green;
			elsif (pixel_column_int > bot_tank_col_int and pixel_column_int < (bot_tank_col_int + tank_width)
				and pixel_row_int > bot_tank_row_int and pixel_row_int < (bot_tank_row_int + tank_length)) then --Bottom tank visualization
				colorAddress <= color_yellow;
			elsif (pixel_column_int > top_bull_col_int and pixel_column_int < (top_bull_col_int + bull_width)
				and pixel_row_int > top_bull_row_int and pixel_row_int < (top_bull_row_int + bull_length)) then --Top bullet visualization
				colorAddress <= color_red;
			elsif (pixel_column_int > bot_bull_col_int and pixel_column_int < (bot_bull_col_int + bull_width)
				and pixel_row_int > bot_bull_row_int and pixel_row_int < (bot_bull_row_int + bull_length)) then --Bottom bullet visualization
				colorAddress <= color_blue;
			else
				colorAddress <= color_black;
			end if;
			
		end if;
		
	end process pixelDraw;	

--------------------------------------------------------------------------------------------
	
end architecture behavioral;		