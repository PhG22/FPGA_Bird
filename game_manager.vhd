LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY game_manager IS
    PORT (
        i_clk         : IN  STD_LOGIC; -- Clock principal (25 MHz)
        i_reset       : IN  STD_LOGIC; -- Reset (ativo-alto)
        i_flap        : IN  STD_LOGIC; -- Botão de pulo (para iniciar o jogo)
        i_game_tick   : IN  STD_LOGIC; -- Pulso de 60Hz (para placar)
        
        -- Posições para detecção de colisão
        i_bird_y    : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        i_pipe_x    : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        i_pipe_gap_y : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        -- Saídas de controle
        o_game_enable : OUT STD_LOGIC; -- '1' = Jogo rodando
        o_game_over   : OUT STD_LOGIC; -- '1' = Apenas em Game Over
        o_game_ready  : OUT STD_LOGIC; -- '1' = Apenas em Ready (tela inicial)
        o_led_out     : OUT STD_LOGIC_VECTOR(9 DOWNTO 0); -- Para os LEDs da placa
        
        -- Saídas para o placar 7-seg
        o_score_tens  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Dígito da dezena
        o_score_ones  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Dígito da unidade
        
        -- Saída para controle de velocidade (Placar 0-99 em binário)
        o_score       : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END game_manager;

ARCHITECTURE rtl OF game_manager IS

    -- --- Constantes de Geometria ---
    CONSTANT C_BIRD_X_POS   : INTEGER := 100;
    CONSTANT C_BIRD_SIZE    : INTEGER := 20;
    CONSTANT C_PIPE_WIDTH   : INTEGER := 60;
    CONSTANT C_GAP_HEIGHT   : INTEGER := 120;
    CONSTANT C_GROUND_Y     : INTEGER := 460;
    
    -- --- Sinais internos para Hitbox ---
    SIGNAL bird_x_start, bird_x_end : INTEGER;
    SIGNAL bird_y_start, bird_y_end : INTEGER;
    SIGNAL pipe_x_start, pipe_x_end : INTEGER;
    SIGNAL pipe_gap_top, pipe_gap_bottom : INTEGER;
    SIGNAL s_collision_flag : STD_LOGIC;
    
    -- --- Máquina de Estados ---
    TYPE state_type IS (s_ready, s_playing, s_game_over);
    SIGNAL current_state : state_type;

    -- --- Lógica de Blink (LEDs) ---
    CONSTANT C_BLINK_MAX_COUNT : INTEGER := 6250000;
    SIGNAL r_blink_counter : INTEGER RANGE 0 TO C_BLINK_MAX_COUNT := 0;
    SIGNAL r_blink_toggle  : STD_LOGIC := '0';

    -- --- Sinais para o Placar ---
    SIGNAL r_score         : INTEGER RANGE 0 TO 99 := 0;
    SIGNAL r_pipe_passed   : STD_LOGIC := '0';
    SIGNAL s_pipe_x_current: INTEGER;

BEGIN

    -- --- Lógica de "Hitbox" ---
    bird_y_start <= to_integer(unsigned(i_bird_y));
    pipe_x_start <= to_integer(unsigned(i_pipe_x));
    pipe_gap_top <= to_integer(unsigned(i_pipe_gap_y)) - (C_GAP_HEIGHT / 2);
    
    bird_x_start <= C_BIRD_X_POS;
    bird_x_end   <= C_BIRD_X_POS + C_BIRD_SIZE;
    bird_y_end   <= bird_y_start + C_BIRD_SIZE;
    pipe_x_end   <= pipe_x_start + C_PIPE_WIDTH;
    pipe_gap_bottom <= pipe_gap_top + C_GAP_HEIGHT;
    
    PROCESS(bird_x_start, bird_x_end, bird_y_start, bird_y_end,
            pipe_x_start, pipe_x_end, pipe_gap_top, pipe_gap_bottom)
            
        VARIABLE v_x_overlap : BOOLEAN;
        VARIABLE v_y_overlap : BOOLEAN;
        VARIABLE v_hit_pipe  : BOOLEAN;
        VARIABLE v_hit_ground: BOOLEAN;
    BEGIN
        v_x_overlap := (bird_x_end > pipe_x_start) AND (bird_x_start < pipe_x_end);
        v_y_overlap := (bird_y_start < pipe_gap_top) OR (bird_y_end > pipe_gap_bottom);
        v_hit_pipe := v_x_overlap AND v_y_overlap;
        v_hit_ground := (bird_y_end >= C_GROUND_Y);
        
        IF (v_hit_pipe OR v_hit_ground) THEN
            s_collision_flag <= '1';
        ELSE
            s_collision_flag <= '0';
        END IF;
    END PROCESS;

    -- --- Lógica de Estado, Blink e Placar ---
    s_pipe_x_current <= to_integer(unsigned(i_pipe_x));
    
    PROCESS(i_clk, i_reset)
    BEGIN
        IF (i_reset = '1') THEN
            current_state   <= s_ready;
            r_blink_counter <= 0;
            r_blink_toggle  <= '0';
            r_score         <= 0;
            r_pipe_passed   <= '0';
            
        ELSIF (rising_edge(i_clk)) THEN
        
            -- Lógica de Blink
            IF (r_blink_counter = C_BLINK_MAX_COUNT) THEN
                r_blink_counter <= 0;
                r_blink_toggle  <= NOT r_blink_toggle;
            ELSE
                r_blink_counter <= r_blink_counter + 1;
            END IF;

            -- Lógica da Estados
            CASE current_state IS
                WHEN s_ready =>
                    r_score <= 0;
                    r_pipe_passed <= '0';
                    IF (i_flap = '1') THEN
                        current_state <= s_playing;
                    END IF;
                    
                WHEN s_playing =>
                    -- Lógica de pontuação
                    IF (i_game_tick = '1') THEN 
                        IF (s_pipe_x_current < C_BIRD_X_POS AND r_pipe_passed = '0') THEN
                            IF (r_score < 99) THEN
                                r_score <= r_score + 1;
                            END IF;
                            r_pipe_passed <= '1';
                        ELSIF (s_pipe_x_current > (C_BIRD_X_POS + C_BIRD_SIZE)) THEN
                            r_pipe_passed <= '0';
                        END IF;
                    END IF;
                
                    -- Lógica de Game Over
                    IF (s_collision_flag = '1') THEN
                        current_state <= s_game_over;
                    END IF;
                    
                WHEN s_game_over =>
                    r_pipe_passed <= '0';
            END CASE;
        END IF;
    END PROCESS;
    
    -- --- Saídas de Controle ---
    o_game_enable <= '1' WHEN current_state = s_playing ELSE '0';
    o_game_over   <= '1' WHEN current_state = s_game_over ELSE '0';
    o_game_ready  <= '1' WHEN current_state = s_ready ELSE '0';
    o_led_out <= (OTHERS => r_blink_toggle) WHEN current_state = s_game_over ELSE (OTHERS => '0');

    -- Saídas BCD para o placar
    o_score_tens <= std_logic_vector(to_unsigned(r_score / 10, 4));
    o_score_ones <= std_logic_vector(to_unsigned(r_score MOD 10, 4));
    
    -- Saída binária do placar para controle de velocidade
    o_score <= std_logic_vector(to_unsigned(r_score, 7));

END rtl;