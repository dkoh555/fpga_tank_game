--Import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use WORK.tank_const.all;
use WORK.score_const.all;

entity top is
    port (
        -- Inputs
        clk : in std_logic;
        rst : in std_logic;
        keyboard_input : in std_logic;
        -- Outputs
        vga_output : out std_logic;
        p1_lcd : out std_logic_vector (6 downto 0);
        p2_lcd : out std_logic_vector (6 downto 0)
    );
end entity top;

architecture structural of top is

    -- Tank component
    component tank is
        port (
            -- Inputs
            clk : in std_logic;
            rst : in std_logic;
            tank_in_y : in std_logic_vector (9 downto 0);
            tank_move : in std_logic;
            tank_out_y : out std_logic_vector (9 downto 0);
            tank_out_x : out std_logic_vector (9 downto 0)
        );
    end component tank;

    -- Bullet component
    component bullet is
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
    end component bullet;

    -- Score component
    component score is 
        port (
            rst : in std_logic;
            other_tank_hit : in std_logic;
            curr_tank_score : out std_logic_vector (1 downto 0)
        );
    end component score;

    -- Gamestate component
    component gamestate is 
        port (
            rst : in std_logic;
            clk : in std_logic;
            score1 : in std_logic_vector (SCORE_WIDTH - 1 downto 0);
            score2 : in std_logic_vector (SCORE_WIDTH - 1 downto 0);
            winner : out std_logic_vector (SCORE_WIDTH - 1 downto 0)
        );
    end component gamestate;

    -- Display_score component
    component display_score is
        port (
            -- Inputs
            clk : in std_logic;
            score1 : in std_logic_vector (SCORE_WIDTH - 1 downto 0);
            score2 : in std_logic (SCORE_WIDTH - 1 downto 0);
            -- Outputs
            display1 : out std_logic_vector (7 downto 0);
            display2 : out std_logic_vector (7 downto 0)
        );
    end component display_score;
    
    -- LED decoder component
    component leddcd is
        port(
            data_in : in std_logic_vector(3 downto 0);
            segments_out : out std_logic_vector(6 downto 0)
        );
    end component leddcd;

    -- LCD component
    component de2lcd is
        PORT(reset, clk_50Mhz : in std_logic;
            winner : in std_logic_vector (1 downto 0);
            LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED : out std_logic;
            LCD_RW	: buffer std_logic;
            DATA_BUS : inout std_logic_vector(7 DOWNTO 0)
        );
    end component de2lcd;

begin

    p1_tank : tank 
        port map (
            clk => clk;
            rst => rst;
            tank_in_y => std_logic_vector(to_unsigned(450, 10))
            tank_move => 
        );


end architecture structural;