library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;

entity pixelGenerator is
	port(	
			winner : in std_logic_vector(1 downto 0);
			clk, ROM_clk, rst_n, video_on, eof : in std_logic;
			pixel_row, pixel_column	: in std_logic_vector(9 downto 0);
			top_tank_x, top_tank_y : in std_logic_vector(9 downto 0); 
			bot_tank_x, bot_tank_y	: in std_logic_vector(9 downto 0);
			top_bull_x, top_bull_y : in std_logic_vector(9 downto 0);
			bot_bull_x, bot_bull_y : in std_logic_vector(9 downto 0);
			red_out, green_out, blue_out : out std_logic_vector(7 downto 0)
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
signal top_tank_col_int, top_tank_row_int, bot_tank_col_int, bot_tank_row_int, top_bull_col_int, bot_bull_col_int, top_bull_row_int, bot_bull_row_int : natural;

begin

--------------------------------------------------------------------------------------------
	
	red_out <= color(27 downto 20);
	green_out <= color(17 downto 10);
	blue_out <= color(7 downto 0);

	pixel_row_int <= to_integer(unsigned(pixel_row));
	pixel_column_int <= to_integer(unsigned(pixel_column));

	--Converting tank and bullet positions from std_logic_vector to integers
	top_tank_col_int <= to_integer(unsigned(top_tank_x));
	top_tank_row_int <= to_integer(unsigned(top_tank_y));
	bot_tank_col_int <= to_integer(unsigned(bot_tank_x));
	bot_tank_row_int <= to_integer(unsigned(bot_tank_y));
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
		
			if (winner = "00") then
				if (pixel_column_int > (top_tank_col_int - TANK_WIDTH/2) and pixel_column_int < (top_tank_col_int + TANK_WIDTH/2)
					and pixel_row_int > (top_tank_row_int - TANK_HEIGHT/2) and pixel_row_int < (top_tank_row_int + TANK_HEIGHT/2) ) then --Top tank visulization
					colorAddress <= color_green;
				elsif (pixel_column_int > (bot_tank_col_int - TANK_WIDTH/2) and pixel_column_int < (bot_tank_col_int + TANK_WIDTH/2)
					and pixel_row_int > (bot_tank_row_int - TANK_HEIGHT/2) and pixel_row_int < (bot_tank_row_int + TANK_HEIGHT/2) ) then --Bottom tank visualization
					colorAddress <= color_yellow;
				elsif (pixel_column_int > (top_bull_col_int - BULLET_SIZE/2) and pixel_column_int < (top_bull_col_int + BULLET_SIZE/2)
					and pixel_row_int > (top_bull_row_int - BULLET_SIZE/2) and pixel_row_int < (top_bull_row_int + BULLET_SIZE/2) ) then --Top bullet visualization
					colorAddress <= color_red;
				elsif (pixel_column_int > (bot_bull_col_int - BULLET_SIZE/2) and pixel_column_int < (bot_bull_col_int + BULLET_SIZE/2)
					and pixel_row_int > (bot_bull_row_int - BULLET_SIZE/2) and pixel_row_int < (bot_bull_row_int + BULLET_SIZE/2) ) then --Bottom bullet visualization
					colorAddress <= color_blue;
				else
					colorAddress <= color_black;
				end if;
			elsif (winner = "10") then
				if (pixel_column_int > (bot_tank_col_int - TANK_WIDTH/2) and pixel_column_int < (bot_tank_col_int + TANK_WIDTH/2)
					and pixel_row_int > (bot_tank_row_int - TANK_HEIGHT/2) and pixel_row_int < (bot_tank_row_int + TANK_HEIGHT/2) ) then --Bottom tank visualization
					colorAddress <= color_yellow;
				elsif (pixel_column_int > (bot_bull_col_int - BULLET_SIZE/2) and pixel_column_int < (bot_bull_col_int + BULLET_SIZE/2)
					and pixel_row_int > (bot_bull_row_int - BULLET_SIZE/2) and pixel_row_int < (bot_bull_row_int + BULLET_SIZE/2) ) then --Bottom bullet visualization
					colorAddress <= color_blue;
				else
					colorAddress <= color_black;
				end if;
			else
				if (pixel_column_int > (top_tank_col_int - TANK_WIDTH/2) and pixel_column_int < (top_tank_col_int + TANK_WIDTH/2)
					and pixel_row_int > (top_tank_row_int - TANK_HEIGHT/2) and pixel_row_int < (top_tank_row_int + TANK_HEIGHT/2) ) then --Top tank visulization
					colorAddress <= color_green;
				elsif (pixel_column_int > (top_bull_col_int - BULLET_SIZE/2) and pixel_column_int < (top_bull_col_int + BULLET_SIZE/2)
					and pixel_row_int > (top_bull_row_int - BULLET_SIZE/2) and pixel_row_int < (top_bull_row_int + BULLET_SIZE/2) ) then --Top bullet visualization
					colorAddress <= color_red;
				else
					colorAddress <= color_black;
				end if;
			end if;	
			
		end if;
		
	end process pixelDraw;	

--------------------------------------------------------------------------------------------
	
end architecture behavioral;		