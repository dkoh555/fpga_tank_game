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
        pulse : in std_logic;
        speed : in std_logic_vector (1 downto 0);
        -- Outputs
        tank_out_y : out std_logic_vector (9 downto 0);
        tank_out_x : out std_logic_vector (9 downto 0)
    );
end entity tank;

architecture behavioral of tank is

    -- Define signal to keep track of tank x position
    signal internal_tank_x: std_logic_vector (9 downto 0);
    -- Define signals to keep track of tank movement direction (0: Right, 1: Left)
    signal new_direction, direction : std_logic;
    -- Define signal to keep track of state for the FSM
    type state is (idle, reset, update, move_left, move_right);
    signal resized : std_logic_vector (9 downto 0);
    signal curr_state, next_state : state;

begin

    -- Clocked process of FSM
    clocked_process : process(rst, clk) begin
        -- Initialize signals to avoid latches
        if (rst = '1') then
            curr_state <= reset;
        elsif (rising_edge(clk)) then
            curr_state <= next_state;
        end if;
    end process;

    -- Combinational process of FSM; contains the different states and their instructions
    process(curr_state, pulse, direction, speed) begin

        -- Case statement to decide what happens to the tank
        case curr_state is
            -- When reset, shift the positions of the tank back to the center of the screen
            -- then set state back to idle
            when reset =>
                internal_tank_x <= std_logic_vector(to_unsigned(SCREEN_WIDTH / 2, internal_tank_x'length));
                new_direction <= '0';
                next_state <= idle;

            -- When idle, simply wait for the pulse
            when idle =>
                internal_tank_x <= internal_tank_x;
                new_direction <= new_direction;
                -- When pulse is received, make the next state update
                if (pulse = '1') then
                    next_state <= update;
                else
                    next_state <= idle;
                end if;

            -- When update, check the current conditions of the tank and adjust its state accordingly
            when update =>
                internal_tank_x <= internal_tank_x;
                new_direction <= new_direction;
                -- If tank moves to right and does exceed screen
                -- OR if tank moves to left and does not exceed screen, change state to move_left
                if ((to_integer(unsigned(internal_tank_x)) + TANK_WIDTH / 2 + 1 >= SCREEN_WIDTH and new_direction = '0')
                    or (to_integer(unsigned(internal_tank_x)) - TANK_WIDTH / 2 - 1 > 0 and new_direction = '1')) then
                    next_state <= move_left;
                -- If tank moves to right and does not exceed screen
                -- OR if tank moves to left and does exceed screen (all other conditions), change state to move_right
                else
                    next_state <= move_right;
                end if;

            -- When move_left, move the tank left and set state to idle
            when move_left =>
                internal_tank_x <= std_logic_vector(unsigned(internal_tank_x) - resize(unsigned(speed), 10));
                new_direction <= '1';
                next_state <= idle;

            -- when move_right, move the tank right and set state to idle
            when move_right =>
                internal_tank_x <= std_logic_vector(unsigned(internal_tank_x) + resize(unsigned(speed), 10));
                new_direction <= '0';
                next_state <= idle;

        end case;

    end process;

    tank_out_y <= tank_in_y;
    tank_out_x <= internal_tank_x;
    direction <= new_direction;
    resized <= std_logic_vector(resize(unsigned(speed), 10));

end architecture behavioral;