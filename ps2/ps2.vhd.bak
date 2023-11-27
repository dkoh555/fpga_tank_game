LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ps2 is
	port( 	keyboard_clk, keyboard_data, clock_50MHz ,
			reset : in std_logic;--, read : in std_logic;
			key : out std_logic_vector(13 downto 0);
			speed1disp: out std_logic_vector(6 downto 0);
			speed2disp: out std_logic_vector(6 downto 0);
			speed1 : out std_logic_vector(1 downto 0);
			speed2 : out std_logic_vector(1 downto 0)
		);
end entity ps2;


architecture structural of ps2 is

component keyboard IS
	PORT( 	keyboard_clk, keyboard_data, clock_50MHz ,
			reset, read : IN STD_LOGIC;
			scan_code : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			scan_ready : OUT STD_LOGIC);
end component keyboard;

component oneshot is
port(
	pulse_out : out std_logic;
	trigger_in : in std_logic; 
	clk: in std_logic );
end component oneshot;

component leddcd is
	port(
		 data_in : in std_logic_vector(3 downto 0);
		 segments_out : out std_logic_vector(6 downto 0)
		);
end component leddcd;	

signal scan2 : std_logic;
signal scan_code2 : std_logic_vector( 7 downto 0 );
signal history3 : std_logic_vector(7 downto 0);
signal history2 : std_logic_vector(7 downto 0);
signal history1 : std_logic_vector(7 downto 0);
signal history0 : std_logic_vector(7 downto 0);
signal read : std_logic;
signal speed1inner : std_logic_vector(3 downto 0);
signal speed2inner : std_logic_vector(3 downto 0);
signal hist3 : std_logic_vector(7 downto 0);
signal hist2 : std_logic_vector(7 downto 0);
signal hist1 : std_logic_vector(7 downto 0);
signal hist0 : std_logic_vector(7 downto 0);
signal scan_code : std_logic_vector( 7 downto 0 );
signal scan_readyo : std_logic;

begin

u1: keyboard port map(	
				keyboard_clk => keyboard_clk,
				keyboard_data => keyboard_data,
				clock_50MHz => clock_50MHz,
				reset => reset,
				read => read,
				scan_code => scan_code2,
				scan_ready => scan2
			);

pulser: oneshot port map(
   pulse_out => read,
   trigger_in => scan2,
   clk => clock_50MHz
			);

scan_readyo <= scan2;
scan_code <= scan_code2;

hist0<=history0;
hist1<=history1;
hist2<=history2;
hist3<=history3;

a1 : process(scan2)
begin
	if(rising_edge(scan2)) then
	history3 <= history2;
	history2 <= history1;
	history1 <= history0;
	history0 <= scan_code2;
	end if;
end process a1;

speedp1 : process(clock_50MHz, reset)
begin
	if (reset = '0') then
		speed1inner <= "0001";
	elsif rising_edge(clock_50MHz) then
		if (history0 = x"69") then
			speed1inner <= "0001";
		elsif (history0 = x"72") then
			speed1inner <= "0010";
		elsif (history0 = x"7A") then
			speed1inner <= "0011";
		else
			speed1inner <= speed1inner;
		end if;		
	end if;
end process speedp1;

speed1 <= speed1inner(1 downto 0);

speedp2 : process(clock_50MHz, reset)
begin
	if (reset = '0') then
		speed2inner <= "0001";
	elsif rising_edge(clock_50MHz) then
		if (history0 = x"16") then
			speed2inner <= "0001";
		elsif (history0 = x"1E") then
			speed2inner <= "0010";
		elsif (history0 = x"26") then
			speed2inner <= "0011";
		else
			speed2inner <= speed2inner;
		end if;		
	end if;
end process speedp2;

speed2 <= speed2inner(1 downto 0);

speeddisp1: leddcd port map (data_in => speed1inner, segments_out => speed1disp);
speeddisp2: leddcd port map (data_in => speed2inner, segments_out => speed2disp);

decode1: for i in 0 to hist0'length / 4 - 1 generate begin
	disp_divider: leddcd port map (data_in => history0((i+1)*4-1 downto i * 4), segments_out => key((i+1)*7-1 downto i*7));
end generate;

end architecture structural;