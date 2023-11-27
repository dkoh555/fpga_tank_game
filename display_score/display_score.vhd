-- Import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;
use WORK.score_const.all;

-- Bullet entities
entity display_score is

    port (
        -- Inputs
        clk : in std_logic;
        score1 : in std_logic_vector (SCORE_WIDTH - 1 downto 0);
        score2 : in std_logic_vector (SCORE_WIDTH - 1 downto 0);
        -- Outputs
        display1 : out std_logic_vector (7 downto 0);
        display2 : out std_logic_vector (7 downto 0)
    );

end entity display_score;

-- Define behavior of circuit
architecture structural of display_score is
-- Define signals and components
	component leddcd
		port (data_in : in std_logic_vector(3 downto 0);
            segments_out : out std_logic_vector(6 downto 0)
            );
	end component;
begin
-- Define structural design
    player_1_score: leddcd port map (data_in => score1, segments_out => display1);
	player_2_score: leddcd port map (data_in => score2, segments_out => display2);
end architecture structural;