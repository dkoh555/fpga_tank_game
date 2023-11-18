-- Import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Gamestate entity
entity gamestate is 

    port (
        rst : in std_logic;
        clk : in std_logic;
        score1 : in std_logic_vector (1 downto 0);
        score2 : in std_logic_vector (1 downto 0);
        winner : out std_logic_vector (1 downto 0);
    );

    generic (
        winning_score : std_logic_vector (1 downto 0);
    );

end entity gamestate;

architecture behavioral of gamestate is

begin

    process (clk, rst) begin
        -- If reset = '1'
        if (rst = '1') then
            -- No winner
            winner <= (others => '0');
        -- If score increases
        elsif (rising_edge(clk)) then
            -- Default winnter is 0
            winner <= (others => '0');
            -- Check scores of each player
            if (winning_score = score1) then
                winner <= (0 => '1', others => '0');
            elsif (winning_score = score2) then
                winner <= (1 => '1', others => '0');
            end if;            
        end if;

    end process;

end architecture behavioral;