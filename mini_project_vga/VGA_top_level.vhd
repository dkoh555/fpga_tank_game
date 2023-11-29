library IEEE;

use IEEE.std_logic_1164.all;
use WORK.tank_const.all;

entity VGA_top_level is
	port(
			-- Clock and Reset signals
			CLOCK_50 : in std_logic;
			other_clk : in std_logic;
			RESET_N : in std_logic;
			WINNER : in std_logic_vector(1 downto 0);
			-- Inputs for tank and bullet positions
			TANK_A_POSX, TANK_A_POSY : in std_logic_vector(9 downto 0); 
			TANK_B_POSX, TANK_B_POSY : in std_logic_vector(9 downto 0); 
			BULL_A_POSX, BULL_A_POSY : in std_logic_vector(9 downto 0); 
			BULL_B_POSX, BULL_B_POSY : in std_logic_vector(9 downto 0);
			--VGA 
			VGA_RED, VGA_GREEN, VGA_BLUE : out std_logic_vector(7 downto 0); 
			HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK : out std_logic


		);
end entity VGA_top_level;

architecture structural of VGA_top_level is

component pixelGenerator is
	port(
			winner : in std_logic_vector(1 downto 0);
			clk, other_clk, ROM_clk, rst_n, video_on, eof : in std_logic;
			pixel_row, pixel_column	: in std_logic_vector(9 downto 0);
			top_tank_x, top_tank_y : in std_logic_vector(9 downto 0); 
			bot_tank_x, bot_tank_y	: in std_logic_vector(9 downto 0);
			top_bull_x, top_bull_y : in std_logic_vector(9 downto 0);
			bot_bull_x, bot_bull_y : in std_logic_vector(9 downto 0);
			red_out, green_out, blue_out : out std_logic_vector(7 downto 0)
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
		port map(
			winner => winner,
			clk => CLOCK_50, 
			other_clk => other_clk,
			ROM_clk => VGA_clk_int, 
			rst_n => RESET_N, 
			video_on => video_on_int, 
			eof => eof, 
			pixel_row => pixel_row_int, 
			pixel_column => pixel_column_int,
			top_tank_x => TANK_A_POSX, 
			top_tank_y => TANK_A_POSY,
			bot_tank_x => TANK_B_POSX,
			bot_tank_y => TANK_B_POSY,
			top_bull_x => BULL_A_POSX, 
			top_bull_y => BULL_A_POSY,
			bot_bull_x => BULL_B_POSX, 
			bot_bull_y => BULL_B_POSY,
			red_out => VGA_RED, 
			green_out => VGA_GREEN,
			blue_out => VGA_BLUE
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