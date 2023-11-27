--Import libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;
use WORK.score_const.all;

entity top is
    port (
        -- General Inputs
        clk : in std_logic;
        rst : in std_logic;
		-- Keyboard Inputs		  
        kb_clk : in std_logic;
		kb_data : in std_logic;
		
		-- Bullet Inputs
		shoot_bullet1 : in std_logic;
		shoot_bullet2 : in std_logic;
		-- VGA Inputs
		rst_n : in std_logic;
		
		inter_speed1disp, inter_speed2disp : out std_logic_vector (6 downto 0);
		
		-- VGA Outputs
		vga_red, vga_green, vga_blue : out std_logic_vector(7 downto 0); 
		horiz_sync, vert_sync, vga_blank, vga_clk : out std_logic;
		
		-- LCD Outputs
		lcd_rs, lcd_e, lcd_on, reset_led, sec_led : out std_logic;
		lcd_rw	: buffer std_logic;
		data_bus : inout std_logic_vector(7 DOWNTO 0);  
		  
		-- Score Outputs
        p1_score : out std_logic_vector (6 downto 0);
        p2_score : out std_logic_vector (6 downto 0)
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
            score2 : in std_logic_vector (SCORE_WIDTH - 1 downto 0);
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
	 
	 -- PS2 Keyboard component
	 component ps2 is
		port(
			keyboard_clk, keyboard_data, clock_50MHz, reset : in std_logic;
			key : out std_logic_vector(13 downto 0);
			speed1disp: out std_logic_vector(6 downto 0);
			speed2disp: out std_logic_vector(6 downto 0);
			speed1 : out std_logic_vector(1 downto 0);
			speed2 : out std_logic_vector(1 downto 0)
		);
	 end component ps2;
	 
	 -- Tank Speed component	 
	component tank_speed is
		port (
			clk : in std_logic;
			rst : in std_logic;
			select_speed : in std_logic_vector (1 downto 0);
			tank_move : out std_logic
		);	
	end component tank_speed;
	
	-- VGA component
	component VGA_top_level is
		port(
			WINNER : in std_logic_vector(1 downto 0);
			-- Clock and Reset signals
			CLOCK_50 : in std_logic;
			RESET_N : in std_logic;
			-- Inputs for tank and bullet positions
			TANK_A_POSX, TANK_A_POSY : in std_logic_vector(9 downto 0); 
			TANK_B_POSX, TANK_B_POSY : in std_logic_vector(9 downto 0); 
			BULL_A_POSX, BULL_A_POSY : in std_logic_vector(9 downto 0); 
			BULL_B_POSX, BULL_B_POSY : in std_logic_vector(9 downto 0);
			--VGA 
			VGA_RED, VGA_GREEN, VGA_BLUE : out std_logic_vector(7 downto 0); 
			HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK : out std_logic
		);
	end component VGA_top_level;
	
	-- Score Stop component
	component score_stop is 
		port (
			clk : in std_logic;
			rst : in std_logic;
			tank1_score : in std_logic_vector (1 downto 0);
			tank2_score : in std_logic_vector (1 downto 0);
			real_clk : out std_logic
		);
	end component score_stop;
	
	 
	-- Unused signals
	--signal inter_speed1disp, inter_speed2disp : std_logic_vector (6 downto 0);
	signal inter_key : std_logic_vector (13 downto 0);
	
	-- Clock signal
	signal t_clk : std_logic;
	
	-- Reset signal
	signal t_rst : std_logic;
	
	-- Tank speeds
	signal t_speed1, t_speed2 : std_logic_vector (1 downto 0);
	
	-- Tank move pulse
	signal t_tank1move, t_tank2move : std_logic;
	
	-- Tanks locations
	signal t_tank1y, t_tank1x, t_tank2y, t_tank2x : std_logic_vector (9 downto 0);
	
	-- Bullet move pulse
	signal t_bulletmove : std_logic;
	
	-- Bullet position
	signal t_bullet1y, t_bullet1x, t_bullet2y, t_bullet2x : std_logic_vector (9 downto 0);
	
	-- Tanks hit
	signal t_hit1, t_hit2 : std_logic;
	
	-- Scores
	signal t_score1, t_score2 : std_logic_vector (1 downto 0);
	
	-- Winner
	signal t_winner : std_logic_vector (1 downto 0);
	
	-- New clock
	signal n_clk, clk_lock : std_logic;

begin
	
	
	t_rst <= not rst;

	keyboard : ps2 
		port map ( 
			keyboard_clk => kb_clk,
			keyboard_data => kb_data,
			clock_50MHz => clk,
			reset => rst,
			key => inter_key, -- Not actually used
			speed1disp => inter_speed1disp,
			speed2disp => inter_speed2disp,
			speed1 => t_speed1,
			speed2 => t_speed2
		);
		
	move_tank1 : tank_speed
		port map (
			clk => t_clk,
			rst => t_rst,
			select_speed => t_speed1,
			tank_move => t_tank1move
		);
		
	move_tank2 : tank_speed
		port map (
			clk => t_clk,
         rst => t_rst,
         select_speed => t_speed2,
         tank_move => t_tank2move
		);

	tank1 : tank 
		port map (
			clk => t_clk,
			rst => t_rst,
			tank_in_y => std_logic_vector(to_unsigned(450, 10)),
			tank_move => t_tank1move,
			tank_out_y => t_tank1y,
			tank_out_x => t_tank1x	
		);

	tank2 : tank 
		port map (
			clk => t_clk,
			rst => t_rst,
			tank_in_y => std_logic_vector(to_unsigned(30, 10)),
			tank_move => t_tank2move,
			tank_out_y => t_tank2y,
			tank_out_x => t_tank2x	
		);
		
	move_bullet : tank_speed
		port map (
			clk => t_clk,
         rst => t_rst,
         select_speed => "01",
         tank_move => t_bulletmove
		);
	
	bullet1 : bullet
		port map (
			bullet_move => t_bulletmove,
			rst => t_rst,
			shoot => shoot_bullet1,
			curr_tank_x => t_tank1x,
			curr_tank_y => t_tank1y,
			other_tank_x => t_tank2x,
			other_tank_y => t_tank2y,
			bullet_x => t_bullet1x,
			bullet_y => t_bullet1y,
			hit => t_hit1
		);
	
	bullet2 : bullet
		port map (
			bullet_move => t_bulletmove,
			rst => t_rst,
			shoot => shoot_bullet2,
			curr_tank_x => t_tank2x,
			curr_tank_y => t_tank2y,
			other_tank_x => t_tank1x,
			other_tank_y => t_tank1y,
			bullet_x => t_bullet2x,
			bullet_y => t_bullet2y,
			hit => t_hit2
		);
		
	tank1score : score
		port map (
			rst => t_rst,
			other_tank_hit => t_hit1,
			curr_tank_score => t_score1
		);
	
	tank2score : score
		port map (
			rst => t_rst,
			other_tank_hit => t_hit2,
			curr_tank_score => t_score2
		);	
		
	state : gamestate
		port map (
			rst => t_rst,
			clk => clk,
			score1 => t_score1,
			score2 => t_score2,
			winner => t_winner		
		);
		
	stop : score_stop
		port map (
			clk => clk,
			rst => t_rst,
			tank1_score => t_score1,
			tank2_score => t_score2,
			real_clk => t_clk		
		);
		
	vga : VGA_top_level
		port map (
			WINNER => t_winner,
			CLOCK_50 => clk,
			RESET_N => rst_n,
			TANK_A_POSX => t_tank1x,
			TANK_A_POSY => t_tank1y,
			TANK_B_POSX => t_tank2x,
			TANK_B_POSY => t_tank2y,
			BULL_A_POSX => t_bullet1x,
			BULL_B_POSX => t_bullet2x,
			BULL_A_POSY => t_bullet1y,
			BULL_B_POSY => t_bullet2y,
			VGA_RED => vga_red,
			VGA_GREEN => vga_green,
			VGA_BLUE => vga_blue,
			HORIZ_SYNC => horiz_sync,
			VERT_SYNC => vert_sync,
			VGA_BLANK => vga_blank,
			VGA_CLK => vga_clk
		);
		
	lcd : de2lcd
		port map (
			reset => rst,
			clk_50Mhz => clk,
			winner => t_winner,
			LCD_RS => lcd_rs,
			LCD_E => lcd_e,
			LCD_ON => lcd_on,
			RESET_LED => reset_led,
			SEC_LED => sec_led,
			LCD_RW => lcd_rw,
			DATA_BUS => data_bus
		);
	 
	 dispscore1 : leddcd
		port map (
			data_in => "00" & t_score1,
			segments_out => p1_score
		);
		
	dispscore2 : leddcd
		port map (
			data_in => "00" & t_score2,
			segments_out => p2_score
		);
		
end architecture structural;