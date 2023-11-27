-- Import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.score_const.all;

-- Gamestate entity
entity gamestate is 

    port (
        rst : in std_logic;
        clk : in std_logic;
        score1 : in std_logic_vector (SCORE_WIDTH - 1 downto 0);
        score2 : in std_logic_vector (SCORE_WIDTH - 1 downto 0);
        winner : out std_logic_vector (SCORE_WIDTH - 1 downto 0)
    );

end entity gamestate;

architecture behavioral of gamestate is

    signal internal_winner : std_logic_vector (SCORE_WIDTH - 1 downto 0);

begin

    process (clk, rst) begin
        -- If reset = '1'
        if (rst = '1') then
            -- No winner
            internal_winner <= (others => '0');
        -- If score increases
        elsif (rising_edge(clk)) then
            -- Default winner is 0
            internal_winner <= (others => '0');
            -- Check scores of each player
            if (to_unsigned(WINNING_SCORE, SCORE_WIDTH) = unsigned(score1)) then
                internal_winner <= (0 => '1', others => '0');
            elsif (to_unsigned(winning_score, SCORE_WIDTH) = unsigned(score2)) then
                internal_winner <= (1 => '1', others => '0');
            end if;            
        end if;

    end process;

    winner <= internal_winner;

end architecture behavioral;