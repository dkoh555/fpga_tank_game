library IEEE;

use IEEE.std_logic_1164.all;

entity VGA_top_level is
	port(
			CLOCK_50 										: in std_logic;
			RESET_N											: in std_logic;

			--Implementing additional inputs for receiving tank and bullet positions
			TANK_A_POSX, TANK_B_POSX, BULL_A_POSX, BULL_B_POSX	: in std_logic_vector(9 downto 0); --Pixel x-coord is from 0 to 640 (2^9 - 1 < 640 < 2^10 - 1)
			BULL_A_POSY, BULL_B_POSY : in std_logic_vector(9 downto 0); --Pixel y-coord is from 0 to 640 (2^8 - 1 < 480 < 2^9 - 1)
	
			--VGA 
			VGA_RED, VGA_GREEN, VGA_BLUE 					: out std_logic_vector(7 downto 0); 
			HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK		: out std_logic


		);
end entity VGA_top_level;

architecture structural of VGA_top_level is

component pixelGenerator is
	port(
			clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
			pixel_row, pixel_column						    : in std_logic_vector(9 downto 0);

			--Modified inputs
			bot_tank_x, top_tank_x, bot_bull_x, top_bull_x	: in std_logic_vector(9 downto 0);
			bot_bull_y, top_bull_y : in std_logic_vector(9 downto 0);

			red_out, green_out, blue_out					: out std_logic_vector(7 downto 0)
		);
end component pixelGenerator;

component VGA_SYNC is
	port(
			clock_50Mhz										: in std_logic;
			horiz_sync_out, vert_sync_out, 
			video_on, pixel_clock, eof						: out std_logic;												
			pixel_row, pixel_column						    : out std_logic_vector(9 downto 0)
		);
end component VGA_SYNC;

--Signals for VGA sync
signal pixel_row_int 										: std_logic_vector(9 downto 0);
signal pixel_column_int 									: std_logic_vector(9 downto 0);
signal video_on_int											: std_logic;
signal VGA_clk_int											: std_logic;
signal eof													: std_logic;

begin

--------------------------------------------------------------------------------------------

	videoGen : pixelGenerator
		port map(CLOCK_50, VGA_clk_int, RESET_N, video_on_int, eof, pixel_row_int, pixel_column_int,
			TANK_A_POSX, TANK_B_POSX, BULL_A_POSX, BULL_B_POSX, BULL_A_POSY, BULL_B_POSY,
			VGA_RED, VGA_GREEN, VGA_BLUE
		);

--------------------------------------------------------------------------------------------
--This section should not be modified in your design.  This section handles the VGA timing signals
--and outputs the current row and column.  You will need to redesign the pixelGenerator to choose
--the color value to output based on the current position.

	videoSync : VGA_SYNC
		port map(CLOCK_50, HORIZ_SYNC, VERT_SYNC, video_on_int, VGA_clk_int, eof, pixel_row_int, pixel_column_int);

	VGA_BLANK <= video_on_int;

	VGA_CLK <= VGA_clk_int;

--------------------------------------------------------------------------------------------	

end architecture structural;