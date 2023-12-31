-- Import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;

-- Tank entities
entity tank is
    port (
        -- Inputs
        clk : in std_logic;
        rst : in std_logic;
        tank_in_y : in std_logic_vector (9 downto 0);
        tank_move : in std_logic;
        tank_out_y : out std_logic_vector (9 downto 0);
        tank_out_x : out std_logic_vector (9 downto 0)
    );
end entity tank;

architecture behavioral of tank is

    -- Define signal to keep track of tank x position
    signal internal_tank_x: std_logic_vector (9 downto 0);
    -- Define signals to keep track of tank movement direction (0: Right, 1: Left)
    signal new_direction, direction : std_logic;

begin

    -- Clocked process that moves the tank when either 1. reset or 2. pulse for tank_move recieved
    process (tank_move, rst) begin
        -- If reset, move tank back to middle 
        if (rst = '1') then
            internal_tank_x <= std_logic_vector(to_unsigned(SCREEN_WIDTH / 2, internal_tank_x'length));
            new_direction <= '0';
        -- If tank_move recieved, move based on current direction
        elsif (rising_edge(tank_move)) then
            -- If tank moves to right and does not exceed screen, move it to right
            if (to_integer(unsigned(internal_tank_x)) + TANK_WIDTH / 2 + 1 < SCREEN_WIDTH and direction = '0') then
                internal_tank_x <= std_logic_vector(unsigned(internal_tank_x) + 1);
                new_direction <= '0';
            -- If tank moves to right and does exceed screen, move it to left
            elsif (to_integer(unsigned(internal_tank_x)) + TANK_WIDTH / 2 + 1 >= SCREEN_WIDTH and direction = '0') then
                internal_tank_x <= std_logic_vector(unsigned(internal_tank_x) - 1);
                new_direction <= '1';
            -- If tank moves to left and does not exceed screen, move it to left
            elsif (to_integer(unsigned(internal_tank_x)) - TANK_WIDTH / 2 - 1 > 0 and direction = '1') then
                internal_tank_x <= std_logic_vector(unsigned(internal_tank_x) - 1);
                new_direction <= '1';
            -- If tank moves to left and does exceed screen, move it to right
            else
                internal_tank_x <= std_logic_vector(unsigned(internal_tank_x) + 1);
                new_direction <= '0';
            end if;
        end if;
    end process;
    tank_out_y <= tank_in_y;
    tank_out_x <= internal_tank_x;
    direction <= new_direction;

end architecture behavioral;