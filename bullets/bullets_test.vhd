library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;
use WORK.tank_const.all;

entity bullets_tb is
	
end entity bullets_tb;

architecture behavioural of bullets_tb is

	-- Bullet component
    component bullet is

        port (
            -- Inputs
            bullet_move : in std_logic;
            rst : in std_logic;
            rst_hit : in std_logic;
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

	--Declaring signals
    signal bullet_move_TB : std_logic := '0';
    signal rst_TB : std_logic := '0';
    signal shoot_TB : std_logic := '0';
    signal curr_tank_x_TB : std_logic_vector (9 downto 0);
    signal curr_tank_y_TB : std_logic_vector (9 downto 0);
    signal other_tank_x_TB : std_logic_vector (9 downto 0);
    signal other_tank_y_TB : std_logic_vector (9 downto 0);
    signal bullet_x_TB : std_logic_vector (9 downto 0);
    signal bullet_y_TB : std_logic_vector (9 downto 0);
    signal hit_TB : std_logic;
    signal rst_hit_TB : std_logic;

	--Signal to determine when testbench is done
	signal TB_done : std_logic;
    signal store_hit_TB : std_logic;

	--File Variables
	file infile : text open read_mode is "bullets_test.in";
	file outfile : text open write_mode is "bullets_test.out";

begin

    dut: bullet
        port map (
            -- Inputs
            bullet_move => bullet_move_TB,
            rst => rst_TB,
            rst_hit => rst_hit_TB,
            shoot => shoot_TB,
            curr_tank_x => curr_tank_x_TB,
            curr_tank_y => curr_tank_y_TB,
            other_tank_x => other_tank_x_TB,
            other_tank_y => other_tank_y_TB,
            -- Outputs
            bullet_x => bullet_x_TB,
            bullet_y => bullet_y_TB,
            hit => hit_TB
        );
					
	process begin
		bullet_move_TB <= not bullet_move_TB;
		wait for 1 ps;
	end process;

    process (hit_TB) begin
        if (rising_edge(hit_TB)) then
            store_hit_TB <= '1';
        end if;
    end process;

				
	process is
	-- Variables for reading and writing strings
	variable my_line : line;
	variable in_curr_tank_x : integer;
	variable in_curr_tank_y : integer;
    variable in_other_tank_x : integer;
	variable in_other_tank_y : integer;
    variable shoot_cycles : integer;
	
	--Begin testbench
	begin
	
		TB_done <= '0';
	
		write(my_line, string'("Beginning to test..."));
		writeline(outfile, my_line);
		
		while not endfile(infile) loop
			--Reading the file and preparing the beginning of the ouput
			readline(infile, my_line);
			-- First term: curr_tank_x
			read(my_line, in_curr_tank_x);
			readline(infile, my_line);
			-- Second term: curr_tank_y
			read(my_line, in_curr_tank_y);
            readline(infile, my_line);
			-- Third term: other_tank_x
			read(my_line, in_other_tank_x);
			readline(infile, my_line);
			-- Fourth term: other_tank_y
			read(my_line, in_other_tank_y);	
            readline(infile, my_line);
            -- Fifth term: move_cycles
			read(my_line, shoot_cycles);	

            --Feeding input for bullet
            curr_tank_x_TB <= std_logic_vector(to_unsigned(in_curr_tank_x, curr_tank_x_TB'length));
            curr_tank_y_TB <= std_logic_vector(to_unsigned(in_curr_tank_y, curr_tank_y_TB'length));
            other_tank_x_TB <= std_logic_vector(to_unsigned(in_other_tank_x, other_tank_x_TB'length));
            other_tank_y_TB <= std_logic_vector(to_unsigned(in_other_tank_y, other_tank_y_TB'length));
			
            rst_hit_TB <= '0';
			rst_TB <= '0';
			wait for 2 ps;
			rst_TB <= '1';
			wait for 6 ps;
			rst_TB <= '0';
			wait for 42 ps;

			std.textio.write(my_line, string'("Curr Tank X: "));
			std.textio.write(my_line, to_integer(unsigned(curr_tank_x_TB)));
            std.textio.write(my_line, string'(", Curr Tank Y: "));
			std.textio.write(my_line, to_integer(unsigned(curr_tank_y_TB)));
            std.textio.write(my_line, string'(", Other Tank X: "));
			std.textio.write(my_line, to_integer(unsigned(other_tank_x_TB)));
            std.textio.write(my_line, string'(", Other Tank Y: "));
			std.textio.write(my_line, to_integer(unsigned(other_tank_y_TB)));
			
			-- Move tank
			for i in 0 to shoot_cycles loop
				shoot_TB <= not shoot_TB;
				wait for 0.1 ps;
				shoot_TB <= not shoot_TB;
				wait for 497.9 ps;
                if (hit_TB = '1') then
                    rst_hit_TB <= '1';
                    wait for 1 ps;
                    rst_hit_TB <= '0';
                    wait for 1 ps;
                else
                    rst_hit_TB <= '0';
                    wait for 2 ps;
                end if;
			end loop;

			--With the calculator result, prepare output for outfile
			
			std.textio.write(my_line, string'(", Hit: "));
            if (store_hit_TB = '1') then
                std.textio.write(my_line, string'("Yes "));
            else
                std.textio.write(my_line, string'("No "));                
            end if;
			std.textio.write(my_line, string'(", Final Bullet X: "));
			std.textio.write(my_line, to_integer(unsigned(bullet_x_TB)));
			std.textio.write(my_line, string'(", Y: "));
			std.textio.write(my_line, to_integer(unsigned(bullet_y_TB)));
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
			
		