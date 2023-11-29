library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;
use WORK.tank_const.all;
use WORK.score_const.all;

entity overall_tb is
	
end entity overall_tb;

architecture behavioural of overall_tb is

	-- Counter component
	component move_object is
		port (
			clk : in std_logic;
			rst : in std_logic;
			pulse : out std_logic
		);
	end component move_object;

    --Tank component
    component tank is
        port (
			-- Inputs
			clk : in std_logic;
			rst : in std_logic;
			tank_in_y : in std_logic_vector (9 downto 0);
			pulse : in std_logic;
			speed : in std_logic_vector (1 downto 0);
			-- Outputs
			tank_out_y : out std_logic_vector (9 downto 0);
			tank_out_x : out std_logic_vector (9 downto 0)
    	);
    end component tank;

	-- Bullet component
    component bullet is

        port (
            -- Inputs
			clk : in std_logic;
			pulse : in std_logic; -- If pulse 1, move bullet
			rst : in std_logic;
			shoot : in std_logic;
			curr_tank_x : in std_logic_vector (9 downto 0);
			curr_tank_y : in std_logic_vector (9 downto 0);
			other_tank_x : in std_logic_vector (9 downto 0);
			other_tank_y : in std_logic_vector (9 downto 0);
			-- Outputs
			bullet_x : out std_logic_vector (9 downto 0);
			bullet_y: out std_logic_vector (9 downto 0);
			hit : out std_logic
			);
    
    end component bullet;

    -- Score component
    component score is
        port (
		clk : in std_logic;
        rst : in std_logic;
        other_tank_hit : in std_logic;
        curr_tank_score : out std_logic_vector (SCORE_WIDTH - 1 downto 0)
    );
    end component score;

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

	--Declaring bullet signals
    signal clk_TB : std_logic := '0';
	signal pulse_TB : std_logic;
    signal rst_TB : std_logic := '0';
    signal shoot_TB : std_logic := '0';
    signal bullet1_x_TB : std_logic_vector (9 downto 0);
    signal bullet1_y_TB : std_logic_vector (9 downto 0);
    signal bullet2_x_TB : std_logic_vector (9 downto 0);
    signal bullet2_y_TB : std_logic_vector (9 downto 0);
    signal hit1_TB : std_logic;
    signal hit2_TB : std_logic;

    --Declaring tank signals
    signal tank1_x_TB : std_logic_vector (9 downto 0);
    signal tank1_y_TB : std_logic_vector (9 downto 0);
    signal tank2_x_TB : std_logic_vector (9 downto 0);
    signal tank2_y_TB : std_logic_vector (9 downto 0);

    --Declaring score signals
    signal score1_TB : std_logic_vector (1 downto 0);
    signal score2_TB : std_logic_vector (1 downto 0);

    --Declaring gamestate signals
    signal winner_TB : std_logic_vector (1 downto 0);

	--Signal to determine when testbench is done
	signal TB_done : std_logic;
    signal store_hit1_TB : std_logic;
    signal store_hit2_TB : std_logic;

	--File Variables
	file infile : text open read_mode is "overall_test.in";
	file outfile : text open write_mode is "overall_test.out";

begin


	counter : move_object
		port map (
			clk => clk_TB,
			rst => rst_TB,
			pulse => pulse_TB
		);

    dut_bullet1: bullet
        port map (
            -- Inputs
            clk => clk_TB,
			pulse => pulse_TB,
            rst => rst_TB,
            shoot => shoot_TB,
            curr_tank_x => tank1_x_TB,
            curr_tank_y => tank1_y_TB,
            other_tank_x => tank2_x_TB,
            other_tank_y => tank2_y_TB,
            -- Outputs
            bullet_x => bullet1_x_TB,
            bullet_y => bullet1_y_TB,
            hit => hit1_TB
        );

    dut_bullet2: bullet
        port map (
            -- Inputs
            clk => clk_TB,
			pulse => pulse_TB,
            rst => rst_TB,
            shoot => '0',
            curr_tank_x => tank2_x_TB,
            curr_tank_y => tank2_y_TB,
            other_tank_x => tank1_x_TB,
            other_tank_y => tank1_y_TB,
            -- Outputs
            bullet_x => bullet2_x_TB,
            bullet_y => bullet2_y_TB,
            hit => hit2_TB
        );

    dut_tank1: tank
        port map (
            -- Inputs
            clk => clk_TB,
            rst => rst_TB,
            tank_in_y => std_logic_vector(to_unsigned(430, 10)),
            pulse => pulse_TB,
			speed => "01",
			-- Outputs
            tank_out_y => tank1_y_TB,
            tank_out_x => tank1_x_TB
        );

    dut_tank2: tank
        port map (
            -- Inputs
            clk => clk_TB,
            rst => '1',
            tank_in_y => std_logic_vector(to_unsigned(50, 10)),
            pulse => pulse_TB,
			speed => "01",
			-- Outputs
            tank_out_y => tank2_y_TB,
            tank_out_x => tank2_x_TB
        );

    dut_score1: score
        port map (
            -- Inputs
			clk => clk_TB,
            rst => rst_TB,
            other_tank_hit => hit1_TB,
            -- Outputs
            curr_tank_score => score1_TB
        );

    dut_score2: score
        port map (
            -- Inputs
			clk => clk_TB,
            rst => rst_TB,
            other_tank_hit => hit2_TB,
            -- Outputs
            curr_tank_score => score2_TB
        );

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

    process (rst_TB, hit1_TB) begin
        if (rst_TB = '1') then 
            store_hit1_TB <= '0';
        elsif (rising_edge(hit1_TB)) then
            store_hit1_TB <= '1';
        end if;
    end process;

    process (rst_TB, hit2_TB) begin
        if (rst_TB = '1') then 
            store_hit2_TB <= '0';
        elsif (rising_edge(hit2_TB)) then
            store_hit2_TB <= '1';
        end if;
    end process;

				
	process is
	-- Variables for reading and writing strings
	variable my_line : line;
    variable shoot_cycles : integer;
	
	--Begin testbench
	begin
	
		TB_done <= '0';
	
		write(my_line, string'("Beginning to test..."));
		writeline(outfile, my_line);
		
		while not endfile(infile) loop
			--Reading the file and preparing the beginning of the ouput
			readline(infile, my_line);
            -- Only term: move_cycles
			read(my_line, shoot_cycles);	
			
			rst_TB <= '0';
			wait for 2 ps;
			rst_TB <= '1';
			wait for 10 ps;
			rst_TB <= '0';
			wait for 2 ps;

			-- Move tank
			for i in 0 to shoot_cycles loop
				shoot_TB <= not shoot_TB;
				wait for 2 ps;
				shoot_TB <= not shoot_TB;
				wait until rising_edge(pulse_TB);
			end loop;

			--With the calculator result, prepare output for outfile

            std.textio.write(my_line, string'("Tank 1 X: "));
			std.textio.write(my_line, to_integer(unsigned(tank1_x_TB)));
            std.textio.write(my_line, string'(", Y: "));
			std.textio.write(my_line, to_integer(unsigned(tank1_y_TB)));
            std.textio.write(my_line, string'(", Tank 2 X: "));
			std.textio.write(my_line, to_integer(unsigned(tank2_x_TB)));
            std.textio.write(my_line, string'(", Y: "));
			std.textio.write(my_line, to_integer(unsigned(tank2_y_TB)));			
			std.textio.write(my_line, string'(", Hit Tank 1: "));
            if (store_hit1_TB = '1') then
                std.textio.write(my_line, string'("Yes "));
            else
                std.textio.write(my_line, string'("No "));                
            end if;
            std.textio.write(my_line, string'(", Hit Tank 2: "));
            if (store_hit2_TB = '1') then
                std.textio.write(my_line, string'("Yes "));
            else
                std.textio.write(my_line, string'("No "));                
            end if;
			std.textio.write(my_line, string'(", Final Bullet 1 X: "));
			std.textio.write(my_line, to_integer(unsigned(bullet1_x_TB)));
			std.textio.write(my_line, string'(", Y: "));
			std.textio.write(my_line, to_integer(unsigned(bullet1_y_TB)));
            std.textio.write(my_line, string'(", Final Bullet 2 X: "));
			std.textio.write(my_line, to_integer(unsigned(bullet2_x_TB)));
			std.textio.write(my_line, string'(", Y: "));
			std.textio.write(my_line, to_integer(unsigned(bullet2_y_TB)));
            std.textio.write(my_line, string'(", Score 1: "));
			std.textio.write(my_line, to_integer(unsigned(score1_TB)));
            std.textio.write(my_line, string'(", Score 2: "));
			std.textio.write(my_line, to_integer(unsigned(score2_TB)));
            std.textio.write(my_line, string'(", Winner: "));
            if (winner_TB = "00") then
                std.textio.write(my_line, string'("None"));
            elsif (winner_TB = "01") then
                std.textio.write(my_line, string'("Player 1"));
            else
                std.textio.write(my_line, string'("Player 2"));                
            end if;
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
			
		