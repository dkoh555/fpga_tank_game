library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tank_speed is

    port (
        clk : in std_logic;
        rst : in std_logic;
        select_speed : in std_logic_vector (1 downto 0);
        tank_move : out std_logic;
    );

end entity tank_speed;

architecture behavioral of tank_speed is

    signal counter : std_logic_vector (24 downto 0);
    signal internal_tank_move : std_logic;
    signal internal_speed : std_logic (24 downto 0);
   
begin

    process (select_speed) begin
        select select_speed
            when "01" =>
                internal_speed <= (others => '0') & "11110100001000111111";
            when "10" =>
                internal_speed <= (others => '0') & "1010001011000010101"
            when others =>
                internal_speed <= (others => '0') & "111101000010001111";
        end
    end process;

    process (clk, rst) begin

        if (rst = '1') then
            counter <= (others => '0');
        elsif (rising_edge(clk)) then
            if counter >= select_speed then
                counter <= (others => '0');
                internal_tank_move <= not internal_tank_move;
            else
                counter <= counter + 1;
            end if;
        end if;

    end process;

    tank_move <= internal_tank_move;


end architecture behavioral;
