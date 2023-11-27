library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity move_object is

    port (
        clk : in std_logic;
        rst : in std_logic;
        pulse : out std_logic
    );

end entity move_object;

architecture behavioral of move_object is

    signal counter : std_logic_vector (20 downto 0); 
      
begin

    process (clk, rst) 

        constant ZEROS : std_logic_vector(counter'range) := (others => '0');
	 
    begin

        if (rst = '1') then
            counter <= (others => '0');
        elsif (rising_edge(clk)) then
            counter <= std_logic_vector(unsigned(counter) + to_unsigned(1,counter'length));
            if ( counter = ZEROS ) then
                pulse <= '1';
            else
                pulse <= '0';
            end if;
        end if;

    end process;

    tank_move <= internal_tank_move;

end architecture behavioral;
