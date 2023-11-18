-- Import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Score entity
entity score is 

    port (
        rst : in std_logic;
        other_tank_hit : in std_logic;
        curr_tank_score : out std_logic_vector (1 downto 0);
    );

end entity score;

architecture behavioral of score is

begin

    process (hit, rst) begin
        -- If reset = '1'
        if (rst = '1') then
            -- Reset score to 0
            curr_tank_score <= (others => '0');
        -- If hit becomes 1
        elsif (rising_edge(hit)) then
            -- Increase score by 1
            curr_tank_score <= std_logic_vector(to_unsigned(curr_tank_score) + 1);
        end if;

    end process;

end architecture behavioral;