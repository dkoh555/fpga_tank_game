-- Import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.score_const.all;

-- Score entity
entity score is 

    port (
        rst : in std_logic;
        other_tank_hit : in std_logic;
        curr_tank_score : out std_logic_vector (1 downto 0)
    );

end entity score;

architecture behavioral of score is

    signal internal_curr_tank_score : std_logic_vector (SCORE_WIDTH - 1 downto 0);

begin

    process (other_tank_hit, rst) begin
        -- If reset = '1'
        if (rst = '1') then
            -- Reset score to 0
            internal_curr_tank_score <= (others => '0');
        -- If hit becomes 1
        elsif (rising_edge(other_tank_hit)) then
            -- Increase score by 1
            internal_curr_tank_score <= std_logic_vector(unsigned(internal_curr_tank_score) + to_unsigned(1, SCORE_WIDTH));
        end if;

    end process;

    curr_tank_score <= internal_curr_tank_score;

end architecture behavioral;