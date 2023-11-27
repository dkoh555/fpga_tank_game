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
    signal curr_state : std_logic_vector(2 downto 0);
    signal next_state : std_logic_vector(2 downto 0);
    -- Define state logic vector values
    constant IDLE : std_logic_vector(2 downto 0) := "000";
    constant RESET : std_logic_vector(2 downto 0) := "001";
    constant UPDATE : std_logic_vector(2 downto 0) := "010";
    constant MOVE_LEFT : std_logic_vector(2 downto 0) := "011";
    constant MOVE_RIGHT : std_logic_vector(2 downto 0) := "100";

begin

    -- Clocked process of FSM
    clocked_process : process(rst, clk) begin
        -- Initialize signals to avoid latches

        if (rst = '1') then
            curr_state <= RESET;
        elsif (rising_edge(clk)) then
            curr_state <= next_state;
        end if;
    end process;

    -- Combinational process of FSM; contains the different states and their instructions
    combinational_process : process(curr_state, pulse, internal_tank_x, direction, speed) begin
        -- Initialzie signals to RESET values to avoid inferring latches
        internal_tank_x <= std_logic_vector(to_unsigned(SCREEN_WIDTH / 2, internal_tank_x'length));
        new_direction <= '0';

        -- Case statement to decide what happens to the tank
        case curr_state is
            -- When IDLE, simply wait for the pulse
            when IDLE =>
                -- When pulse is received, make the next state UPDATE
                if (pulse = '1') then
                    next_state <= UPDATE;
                else
                    next_state <= IDLE;
                end if;

            -- When RESET, shift the positions of the tank back to the center of the screen
            -- then set state back to IDLE
            when RESET =>
                internal_tank_x <= std_logic_vector(to_unsigned(SCREEN_WIDTH / 2, internal_tank_x'length));
                new_direction <= '0';
                next_state <= IDLE;

            -- When UPDATE, check the current conditions of the tank and adjust its state accordingly
            when UPDATE =>
                -- If tank moves to right and does exceed screen
                -- OR if tank moves to left and does not exceed screen, change state to MOVE_LEFT
                if ((to_integer(unsigned(internal_tank_x)) + TANK_WIDTH / 2 + 1 >= SCREEN_WIDTH and direction = '0')
                    or (to_integer(unsigned(internal_tank_x)) - TANK_WIDTH / 2 - 1 > 0 and direction = '1')) then
                    next_state <= MOVE_LEFT;
                -- If tank moves to right and does not exceed screen
                -- OR if tank moves to left and does exceed screen (all other conditions), change state to MOVE_RIGHT
                else
                    next_state <= MOVE_RIGHT;
                end if;

            -- When MOVE_LEFT, move the tank left and set state to IDLE
            when MOVE_LEFT =>
                internal_tank_x <= std_logic_vector(unsigned(internal_tank_x) - resize(5 * unsigned(speed), 10));
                new_direction <= '1';
                next_state <= IDLE;

            -- when MOVE_RIGHT, move the tank right and set state to IDLE
            when MOVE_RIGHT =>
                internal_tank_x <= std_logic_vector(unsigned(internal_tank_x) + resize(5 * unsigned(speed), 10));
                new_direction <= '0';
                next_state <= IDLE;
            -- For all other possible state values, remain in IDLE
            when others =>
                next_state <= curr_state;
        end case;
    end process;

    tank_out_y <= tank_in_y;
    tank_out_x <= internal_tank_x;
    direction <= new_direction;

end architecture behavioral;