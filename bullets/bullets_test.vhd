library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

entity tanks_tb is
	
end entity tanks_tb;

architecture behavioural of tanks_tb is

	--Tank component
    component tank is
        port (
            -- Inputs
            clk : in std_logic;
            rst : in std_logic;
            tank_in_y : in std_logic_vector (9 downto 0);
            tank_move : in std_logic;
            tank_out_y : in std_logic_vector (9 downto 0);
            tank_out_x : in std_logic_vector (9 downto 0);
        );
        generic (
            screen_width : natural := 640;
            screen_height : natural := 480;
            tank_width: natural := 20;
            tank_height: natural := 10;
        );
    end component tank;

	--Declaring signals
    signal clk_TB : in std_logic := '0';
    signal rst_TB : in std_logic := '0';
    signal tank_in_y_TB : in std_logic_vector (9 downto 0);
    signal tank_move_TB : in std_logic;
    signal tank_out_y_TB : in std_logic_vector (9 downto 0);
    signal tank_out_x_TB : in std_logic_vector (9 downto 0);

	--Signals for writing to result to output file
	signal internal_quotient_TB : std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
	signal internal_overflow_TB : std_logic;
	signal internal_remainder_TB: std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
	
	--Signal to determine when testbench is done
	signal TB_done : std_logic;

	--File Variables
	file infile : text open read_mode is "bullets_test.in";
	file outfile : text open write_mode is ".out";

begin

    dut: tank
        port (
            -- Inputs
            clk => clk_TB,
            rst => rst_TB,
            tank_in_y => tank_in_y_TB,
            tank_move => tank_move_TB,
            tank_out_y => tank_out_y_TB,
            tank_out_x => tank_out_x_TB
        );
        generic (
            screen_width => 640,
            screen_height => 480,
            tank_width => 20,
            tank_height => 10
        );
					
	process begin
		clk_TB <= not clk_TB;
		wait for 1 ps;	
	end process;

				
	process is
	-- Variables for reading and writing strings
	variable my_line : line;
	variable term_one : integer;
	variable term_two : integer;
	
	--Begin testbench
	begin
	
		TB_done <= '0';
	
		write(my_line, string'("Beginning to test..."));
		writeline(outfile, my_line);
		
		while not endfile(infile) loop
			--Reading the file and preparing the beginning of the ouput
			readline(infile, my_line);
			-- First term: starting y position
			read(my_line, term_one);
			readline(infile, my_line);
			-- Second term: number of move calls
			read(my_line, term_two);	
			
			rst_TB <= '0';
			--Feeding input for tank
			tank_in_y_TB <= std_logic_vector(to_signed(term_one, 10));

			wait for 2 ps;
			rst_TB <= '1';
			wait for 6 ps;
			rst_TB <= '0';
			wait for 2 ps;
			
			-- Move tank
			for i in 0 to term_two loop
				tank_move_TB <= not tank_move_TB;
				wait for 5 ps;
			end loop;

			--With the calculator result, prepare output for outfile
			std.textio.write(my_line, string'("Input Tank Y: "));
			std.textio.write(my_line, to_integer(unsigned(tank_in_y_TB)));
			std.textio.write(my_line, string'(", Cycles: "));
			std.textio.write(my_line, termtwo);
			std.textio.write(my_line, string'(", Final Tank Y: "));
			std.textio.write(my_line, to_integer(unsigned(tank_out_y)));
			std.textio.write(my_line, string'(", Final Tank X: "));
			std.textio.write(my_line, to_integer(unsigned(tank_out_x)));
			writeline(outfile, my_line);
			
			wait for 5 ps;
			
			rst_TB <= '1';
			
			wait for 5 ps;
			
		end loop;
		
		write(my_line, string'("Finishing test..."));
		writeline(outfile, my_line);
		
		TB_done <= '1';
		wait for 5 ps;
		
		wait;
		
	end process;
	
end architecture behavioural;
			
		