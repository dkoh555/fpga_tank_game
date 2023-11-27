-- Import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;

-- Bullet entities
entity bullet is

    port (
        -- Inputs
        bullet_move : in std_logic;
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
    
    signal internal_shoot_status, internal_bullet_valid, internal_hit : std_logic;
    signal curr_bullet_x, curr_bullet_y : std_logic_vector (9 downto 0);
    signal rst_hit : std_logic;


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

begin

    process (rst, bullet_move) begin
        if (rst = '1') then
            rst_hit <= '0';
        elsif (rising_edge(bullet_move)) then
            if (internal_hit = '1') then
                rst_hit <= '1';
				elsif (rst_hit = '1') then
					rst_hit <= '0';
            end if;
        --elsif (falling_edge(bullet_move)) then
          --  if (rst_hit = '1') then
            --    rst_hit <= '0';
            --end if;
        end if;

    end process;

    process (internal_bullet_valid, shoot) begin
        -- If reset
        if (internal_bullet_valid = '0') then
            -- Set status to not shot
            internal_shoot_status <= '0';
        -- If bullet valid
        elsif (rising_edge(shoot)) then
            -- Set status to shot
            internal_shoot_status <= '1';
        end if;
    end process;
    
    process (rst, rst_hit, internal_shoot_status, bullet_move) begin
        if (rst_hit = '1' or rst = '1') then
            internal_hit <= '0';
            -- Set x value of bullet to tank
            curr_bullet_x <= curr_tank_x;
            -- Set y value of bullet to tank
				if (unsigned(curr_tank_y) < to_unsigned(SCREEN_WIDTH/2, 10)) then
					curr_bullet_y <= std_logic_vector(unsigned(curr_tank_y) + to_unsigned(TANK_HEIGHT/2, 10));
				else
					curr_bullet_y <= std_logic_vector(unsigned(curr_tank_y) - to_unsigned(TANK_HEIGHT/2, 10));
				end if;
            -- Bullet is now valid
            internal_bullet_valid <= '0';
        -- If bullet is called to move and bullet has been shot
        elsif (internal_shoot_status = '0' and internal_hit = '0') then
            internal_hit <= '0';
            -- Set x value of bullet to tank
            curr_bullet_x <= curr_tank_x;
            -- Set y value of bullet to tank
				if (unsigned(curr_tank_y) < to_unsigned(SCREEN_WIDTH/2, 10)) then
					curr_bullet_y <= std_logic_vector(unsigned(curr_tank_y) + to_unsigned(TANK_HEIGHT/2, 10));
				else
					curr_bullet_y <= std_logic_vector(unsigned(curr_tank_y) - to_unsigned(TANK_HEIGHT/2, 10));
				end if;
            -- Bullet is now valid
            internal_bullet_valid <= '1';
        elsif (rising_edge(bullet_move)) then
            -- If status is shot
            if (internal_shoot_status = '1') then
                -- If bullet has collided with other tank
                if (get_collision(other_tank_x, other_tank_y, curr_bullet_x, curr_bullet_y) = '1') then 
                    -- Set x value of bullet to tank
                    curr_bullet_x <= curr_tank_x;
                    -- Set y value of bullet to tank
							if (unsigned(curr_tank_y) < to_unsigned(SCREEN_WIDTH/2, 10)) then
								curr_bullet_y <= std_logic_vector(unsigned(curr_tank_y) + to_unsigned(TANK_HEIGHT/2, 10));
							else
								curr_bullet_y <= std_logic_vector(unsigned(curr_tank_y) - to_unsigned(TANK_HEIGHT/2, 10));
							end if;
                    -- Set hit to 1
                    internal_hit <= '1';
                    -- Bullet is no longer valid
                    internal_bullet_valid <= '0';
                -- If bullet is still in a valid location
                elsif (unsigned(curr_bullet_x) <= to_unsigned(SCREEN_WIDTH, curr_bullet_x'length) and 
                        unsigned(curr_bullet_x) >= to_unsigned(0, curr_bullet_x'length) and
                        unsigned(curr_bullet_y) <= to_unsigned(SCREEN_HEIGHT, curr_bullet_y'length) and 
                        unsigned(curr_bullet_y) >= to_unsigned(0, curr_bullet_x'length)) then
                    if (unsigned(curr_tank_y) < to_unsigned(SCREEN_HEIGHT/2, curr_tank_y'length)) then
                        -- Move bullet by 1
                        curr_bullet_y <= std_logic_vector(unsigned(curr_bullet_y) + 1);
                    else
                        -- Move bullet by -1
                        curr_bullet_y <= std_logic_vector(unsigned(curr_bullet_y) - 1);
                    end if;
                    -- Keep x value of bullet the same
                    curr_bullet_x <= curr_bullet_x;
                    -- Set hit to 0
                    internal_hit <= '0';
                    -- Bullet is still valid
                    internal_bullet_valid <= '1';
                -- If bullet is not in a valid location
                else
                    -- Set hit to 0
                    internal_hit <= '0';
                    -- Set x value of bullet to x value of tank
                    curr_bullet_x <= curr_tank_x;
                    -- Set y value of bullet to y value of tank
							if (unsigned(curr_tank_y) < to_unsigned(SCREEN_WIDTH/2, 10)) then
								curr_bullet_y <= std_logic_vector(unsigned(curr_tank_y) + to_unsigned(TANK_HEIGHT/2, 10));
							else
								curr_bullet_y <= std_logic_vector(unsigned(curr_tank_y) - to_unsigned(TANK_HEIGHT/2, 10));
							end if;
                    -- Bullet is no longer valid
                    internal_bullet_valid <= '0';
                end if; 
            end if;
        end if;

    end process;

    bullet_x <= curr_bullet_x;
    bullet_y <= curr_bullet_y;
    hit <= internal_hit;

end architecture behavioral;