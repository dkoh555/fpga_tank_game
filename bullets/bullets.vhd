-- Import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Bullet entities
entity bullet is

    port (
        bullet_move : in std_logic;
        shoot : in std_logic;
        curr_tank_x : in std_logic_vector (9 downto 0);
        curr_tank_y : in std_logic_vector (9 downto 0);
        other_tank_x : in std_logic_vector (9 downto 0);
        other_tank_y : in std_logic_vector (9 downto 0);
        rst : in std_logic;
        bullet_x : out std_logic_vector (9 downto 0);
        bullet_y: out std_logic_vector (9 downto 0);
        hit : out std_logic;
    );
    generic (
        screen_width : natural := 640;
        screen_height : natural := 480;
        tank_width: natural := 20;
        tank_height: natural := 10;
    );

end entity bullet;

architecture behavioral of bullet is
    internal_shoot_status, internal_bullet_status : std_logic;

    function get_collision (signal other_tank_x, other_tank_y, tank_width, tank_height, bullet_x, bullet_y: std_logic_vector) return std_logic is
		variable collision : std_logic;
		
	begin
        -- If within tank boundaries
        if (unsigned(other_tank_x) - to_unsigned(tank_width/2) <= bullet_x and 
            unsigned(other_tank_x) + to_unsigned(tank_width/2) >= bullet_x and
            unsigned(other_tank_y) - to_unsigned(tank_height/2) <= bullet_y and
            unsigned(other_tank_y) + to_unsigned(tank_height/2) >= bullet_y) then
                collision <= '1';
        else 
                collision <= '0';
        end if;
        return collision;
	end function get_collision;

begin

    process (shoot, bullet_move, rst) begin
        if (rst = '1') then
            internal_bullet_status <= '0';
            internal_shoot_status <= '0';
            hit <= '0';
            bullet_x <= curr_tank_x;
            bullet_y <= curr_tank_y;
        -- If bullet is shot
        elsif (rising_edge(shoot)) then
            -- If bullet is currently not valid, shoot
            if (internal_shoot_status = '0' and internal_bullet_status) then
                internal_shoot_status <= '1';
            end if;
        -- If bullet is called to move
        elsif (rising_edge(bullet_move)) then
            -- If bullet has been shot
            if (internal_shoot_status = '1') then
                -- If bullet has collided with other tank
                if (get_collision(other_tank_x, other_tank_y, tank_width, tank_height, bullet_x, bullet_y) = '1') then 
                    -- Set internal_bullet_status to 0 since it is no longer valid
                    internal_bullet_status <= '0';
                    -- Set hit to 1
                    hit <= '1';
                -- If bullet is still in a valid location
                elsif (bullet_x <= screen_width and bullet_x >= 0 and bullet_y <= screen_height and bullet_y >= 0)
                    if (curr_tank_y < screen_height/2) then
                        -- Move bullet by 1
                        bullet_y <= std_logic_vector(unsigned(bullet_y) + 1);
                    else
                        -- Move bullet by -1
                        bullet_y <= std_logic_vector(unsigned(bullet_y) - 1);
                    end if;
                    -- Set internal_bullet_status to 1 since it is still valid
                    internal_bullet_status <= '1';
                    -- Set hit to 0
                    hit <= '0';
                -- If bullet is not in a valid location
                else
                    -- Set internal_bullet_status to 0 since it is no longer valid
                    internal_bullet_status <= '0';
                    -- Set hit to 1
                    hit <= '0';
                end if;
            end if;
        end if;

    end process;

end architecture behavioral;