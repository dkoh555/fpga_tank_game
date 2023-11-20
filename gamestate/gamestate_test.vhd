library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

entity gamestate_tb is
	
end entity gamestate_tb;

architecture behavioural of gamestate_tb is

	-- gamestate component
    component gamestate is

        port (
        rst : in std_logic;
        other_tank_hit : in std_logic;
        curr_tank_score : out std_logic_vector (1 downto 0)
    );
    
    end component gamestate;

	--Declaring signals
    signal rst_TB : std_logic;
    signal other_tank_hit_TB : std_logic;
    signal curr_tank_gamestate_tb : std_logic_vector (1 downto 0);

	--Signal to determine when testbench is done
	signal TB_done : std_logic;
    signal store_hit_TB : std_logic;

	--File Variables
	file infile : text open read_mode is "score_test.in";
	file outfile : text open write_mode is "score_test.out";

begin

    dut: score
        port map (
            -- Inputs
            rst => rst_TB,
            other_tank_hit => other_tank_hit_TB,
            -- Outputs
            curr_tank_score => curr_tank_gamestate_tb
        );
									
	process is
	-- Variables for reading and writing strings
	variable my_line : line;
	variable num_hits : integer;
	
	--Begin testbench
	begin
	
		TB_done <= '0';
	
		write(my_line, string'("Beginning to test..."));
		writeline(outfile, my_line);
		
		while not endfile(infile) loop
			--Reading the file and preparing the beginning of the ouput
			readline(infile, my_line);
			-- First term: num_hits
			read(my_line, num_hits);

            other_tank_hit_TB <= '0';
            rst_TB <= '0';
			wait for 2 ps;
			rst_TB <= '1';
			wait for 6 ps;
			rst_TB <= '0';
			wait for 42 ps;

			std.textio.write(my_line, string'("Expected Num Hits: "));
			std.textio.write(my_line, num_hits);
			
			-- Move tank
			for i in 0 to num_hits loop
				other_tank_hit_TB <= '1';
                wait for 0.1 ps;
                other_tank_hit_TB <= '0';
                wait for 4.9 ps;
			end loop;

			--With the calculator result, prepare output for outfile
			
			std.textio.write(my_line, string'(", Actual Num Hits: "));
			std.textio.write(my_line, to_integer(unsigned(curr_tank_gamestate_tb)));
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
			
		