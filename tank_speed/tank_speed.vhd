library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tank_speed is

    port (
        clk : in std_logic;
        rst : in std_logic;
        select_speed : in std_logic_vector (1 downto 0);
        tank_move : out std_logic
    );

end entity tank_speed;

architecture behavioral of tank_speed is

    signal counter : std_logic_vector (24 downto 0);
    signal internal_tank_move : std_logic;
    signal internal_speed : std_logic_vector (24 downto 0);
   
begin

    process (select_speed)
	 begin
        case select_speed is
            when "01" =>
                internal_speed <= "0000000011000000000000000";
            when "10" =>
                internal_speed <= "0000000010000000000000000";
            when others =>
                internal_speed <= "0000000001000000000000000";
        end case;
    end process;

    process (clk, rst) begin

        if (rst = '1') then
            counter <= (others => '0');
        elsif (rising_edge(clk)) then
            if unsigned(counter) >= unsigned(internal_speed) then
                counter <= (others => '0');
                internal_tank_move <= not internal_tank_move;
            else
                counter <= std_logic_vector(unsigned(counter) + 1);
            end if;
        end if;

    end process;

    tank_move <= internal_tank_move;


end architecture behavioral;
