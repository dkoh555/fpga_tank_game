-- Import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.score_const.all;

-- Score entity
entity score_stop is 

    port (
        clk : in std_logic;
        rst : in std_logic;
        tank1_score : in std_logic_vector (1 downto 0);
        tank2_score : in std_logic_vector (1 downto 0);
        real_clk : out std_logic
    );

end entity score_stop;

architecture behavioral of score_stop is

    signal internal_clk : std_logic;

begin

    process (tank1_score, tank2_score, clk) begin
        -- If reset = '1'
        if (tank1_score = "11" or tank2_score = "11") then
            -- Stop clock if one tank has won
            internal_clk <= '0';
        -- Otherwise use provided clock
        else
            internal_clk <= clk;
        end if;

    end process;

    real_clk <= internal_clk;

end architecture behavioral;