-- Import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;

-- Bullet entities
entity bullet is

    port (
        -- Inputs
        clk : in std_logic;
        pulse : in std_logic; -- If pulse 1, move bullet
        rst : in std_logic;
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

end entity bullet;

architecture behavioral of bullet is
    
    signal curr_bullet_x, curr_bullet_y : std_logic_vector (9 downto 0);

    function get_collision (signal other_tank_x, other_tank_y, bullet_x, bullet_y: std_logic_vector) return std_logic is
		variable collision : std_logic;
	begin
        -- If within tank boundaries
        if ( (unsigned(other_tank_x) - to_unsigned(TANK_WIDTH/2, other_tank_x'length) <= unsigned(bullet_x)) and 
             (unsigned(other_tank_x) + to_unsigned(TANK_WIDTH/2, other_tank_x'length) >= unsigned(bullet_x)) and
             (unsigned(other_tank_y) - to_unsigned(TANK_HEIGHT/2, other_tank_y'length) <= unsigned(bullet_y)) and
             (unsigned(other_tank_y) + to_unsigned(TANK_HEIGHT/2, other_tank_y'length) >= unsigned(bullet_y))) then
                collision := '1';
        else 
                collision := '0';
        end if;
        return collision;
	end function get_collision;

    type state is (s_a, s_b, s_c, s_d);
    signal curr_state, next_state : state;

begin

    process (clk, rst) begin
        if (rst = '1') then
            curr_state <= s_a;
        elsif (rising_edge(clk)) then
            curr_state <= next_state;
        end if;
    end process;

    process (curr_state, shoot, pulse) begin

        next_state <= curr_state;

        case curr_state is
            -- Idle state
            when s_a =>
                -- Initial bullet conditions
                curr_bullet_x <= curr_tank_x;
                curr_bullet_y <= curr_tank_y;
                hit <= '0';
                -- Check if bullet has been shot
                if (shoot = '1') then
                    next_state <= s_b;
                else
                    next_state <= s_a;  
                end if;
            -- Waiting for pulse state
            when s_b =>
                -- Bullet has not yet moved
                curr_bullet_x <= curr_bullet_x;
                curr_bullet_y <= curr_bullet_y;
                hit <= '0';
                -- Move to state based on current speed
                if (pulse = '1') then
                    next_state <= s_c;
                end if;
            -- Pulse recieved state
            when s_c =>
                -- Keep bullet at same location
                curr_bullet_x <= curr_bullet_x;
                -- If bullet direction is down
                if (unsigned(curr_tank_y) < to_unsigned(SCREEN_WIDTH/2, 10)) then
                    curr_bullet_y <= std_logic_vector(unsigned(curr_bullet_y) + to_unsigned(1, curr_bullet_y'length));
                -- If bullet direction is up
                else
                    curr_bullet_y <= std_logic_vector(unsigned(curr_bullet_y) - to_unsigned(1, curr_bullet_y'length));
                end if;
                -- Hit is still 0
                hit <= '0';
                -- If collision, move to collision state
                if (get_collision(other_tank_x, other_tank_y, curr_bullet_x, curr_bullet_y) = '1') then
                    next_state <= s_d;
                -- If not collision but valid, move back to waiting state
                elsif ( unsigned(curr_bullet_x) <= to_unsigned(SCREEN_WIDTH, curr_bullet_x'length) and 
                        unsigned(curr_bullet_x) >= to_unsigned(0, curr_bullet_x'length) and
                        unsigned(curr_bullet_y) <= to_unsigned(SCREEN_HEIGHT, curr_bullet_y'length) and 
                        unsigned(curr_bullet_y) >= to_unsigned(0, curr_bullet_x'length)) then
                    next_state <= s_b;
                -- If not valid, move back to initial state
                else
                    next_state <= s_a;
                end if;
            -- Hit state
            when s_d =>
                curr_bullet_x <= curr_tank_x;
                curr_bullet_y <= curr_tank_y;
                hit <= '1';
                next_state <= s_a;
        end case;

        bullet_x <= curr_bullet_x;
        bullet_y <= curr_bullet_y;

    end process;

end architecture behavioral;