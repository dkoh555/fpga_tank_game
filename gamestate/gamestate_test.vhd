library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;
use WORK.score_const.all;

entity gamestate_tb is
	
end entity gamestate_tb;

architecture behavioural of gamestate_tb is

	-- gamestate component
    component gamestate is

        port (
            rst : in std_logic;
            clk : in std_logic;
            score1 : in std_logic_vector (SCORE_WIDTH - 1 downto 0);
            score2 : in std_logic_vector (SCORE_WIDTH - 1 downto 0);
            winner : out std_logic_vector (SCORE_WIDTH - 1 downto 0)
        );
    
    end component gamestate;

	--Declaring signals
    signal rst_TB : std_logic := '0';
    signal clk_TB : std_logic := '0';
    signal score1_TB : std_logic_vector (SCORE_WIDTH - 1 downto 0);
    signal score2_TB : std_logic_vector (SCORE_WIDTH - 1 downto 0);
    signal winner_TB : std_logic_vector (SCORE_WIDTH - 1 downto 0);


	--Signal to determine when testbench is done
	signal TB_done : std_logic;

	--File Variables
	file infile : text open read_mode is "gamestate_test.in";
	file outfile : text open write_mode is "gamestate_test.out";

begin

    dut: gamestate
        port map (
            -- Inputs
            rst => rst_TB,
            clk => clk_TB,
            score1 => score1_TB,
            score2 => score2_TB,
            -- Outputs
            winner => winner_TB
        );

    process begin
        clk_TB <= not clk_TB;
        wait for 1 ps;
    end process;
									
	process is
	-- Variables for reading and writing strings
	variable my_line : line;
	variable score1_read : integer;
    variable score2_read : integer;

	
	--Begin testbench
	begin

		TB_done <= '0';
	
		write(my_line, string'("Beginning to test..."));
		writeline(outfile, my_line);
		
		while not endfile(infile) loop
			--Reading the file and preparing the beginning of the ouput
			readline(infile, my_line);
			-- First term: score1
			read(my_line, score1_read);
            readline(infile, my_line);
            -- First term: score1
			read(my_line, score2_read);

            score1_TB <= std_logic_vector(to_unsigned(score1_read, SCORE_WIDTH));
            score2_TB <= std_logic_vector(to_unsigned(score2_read, SCORE_WIDTH));

            rst_TB <= '0';
			wait for 2 ps;
			rst_TB <= '1';
			wait for 6 ps;
			rst_TB <= '0';
			wait for 32 ps;

			std.textio.write(my_line, string'("Score 1: "));
			std.textio.write(my_line, score1_read);
            std.textio.write(my_line, string'(", Score 2: "));
			std.textio.write(my_line, score2_read);
			std.textio.write(my_line, string'(", Winner: "));
			std.textio.write(my_line, to_integer(unsigned(winner_TB)));
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
			
		