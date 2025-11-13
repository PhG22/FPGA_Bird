LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY pipe_logic IS
    PORT (
        i_clk         : IN  STD_LOGIC; -- Clock principal (25 MHz)
        i_reset       : IN  STD_LOGIC; -- Reset (ativo-alto)
        i_game_tick   : IN  STD_LOGIC; -- Pulso de 60Hz
        i_score       : IN  STD_LOGIC_VECTOR(6 DOWNTO 0); -- Placar (0-99)
        o_pipe_x      : OUT STD_LOGIC_VECTOR(9 DOWNTO 0); -- Posição X
        o_pipe_gap_y  : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)  -- Posição Y da abertura
    );
END pipe_logic;

ARCHITECTURE rtl OF pipe_logic IS

    -- --- Constantes do Cano ---
    CONSTANT C_PIPE_START_X    : INTEGER := 640; -- Posição inicial (direita)
    CONSTANT C_PIPE_END_X      : INTEGER := -60; -- Posição final (esquerda)
    CONSTANT C_GAP_Y_MIN       : INTEGER := 100; -- Abertura mais alta
    CONSTANT C_GAP_Y_MAX       : INTEGER := 380; -- Abertura mais baixa
    
    -- Sinais internos
    SIGNAL r_pipe_x_pos   : INTEGER RANGE C_PIPE_END_X TO C_PIPE_START_X := C_PIPE_START_X;
    SIGNAL r_pipe_gap_pos : INTEGER RANGE C_GAP_Y_MIN TO C_GAP_Y_MAX := 240;
    
    -- Gerador de números pseudo-aleatórios (LFSR)
    SIGNAL r_lfsr         : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10101010";

    -- Sinais para velocidade dinâmica
    SIGNAL s_current_pipe_speed : INTEGER RANGE 3 TO 10; -- Max velocidade = 10
    SIGNAL s_score_int          : INTEGER RANGE 0 TO 99;

BEGIN

    -- --- Lógica de Velocidade ---
    -- Converte o placar de entrada para um inteiro
    s_score_int <= to_integer(unsigned(i_score));
    
    -- Define a velocidade com base no placar
    PROCESS (s_score_int)
    BEGIN
        IF (s_score_int < 5) THEN
            s_current_pipe_speed <= 3; -- Nível 1
        ELSIF (s_score_int < 10) THEN
            s_current_pipe_speed <= 4; -- Nível 2
        ELSIF (s_score_int < 15) THEN
            s_current_pipe_speed <= 5; -- Nível 3
        ELSIF (s_score_int < 20) THEN
            s_current_pipe_speed <= 6; -- Nível 4
        ELSIF (s_score_int < 25) THEN
            s_current_pipe_speed <= 7; -- Nível 5
        ELSIF (s_score_int < 30) THEN
            s_current_pipe_speed <= 8; -- Nível 6
        ELSE
            s_current_pipe_speed <= 9; -- Nível Máximo
        END IF;
    END PROCESS;

    -- --- Movimento do Cano ---
    PROCESS (i_clk, i_reset)
        VARIABLE v_new_gap_y : INTEGER;
    BEGIN
        IF (i_reset = '1') THEN
            r_pipe_x_pos   <= C_PIPE_START_X;
            r_pipe_gap_pos <= 240;
            r_lfsr         <= "10101010";
            
        ELSIF (rising_edge(i_clk)) THEN
            -- A lógica do cano só roda no tick do jogo
            IF (i_game_tick = '1') THEN
            
                -- O cano saiu da tela?
                IF (r_pipe_x_pos < C_PIPE_END_X) THEN
                    -- Sim: Reinicia o cano na direita
                    r_pipe_x_pos <= C_PIPE_START_X;
                    
                    -- Calcula uma nova altura "aleatória" para a abertura
                    r_lfsr <= (r_lfsr(6 DOWNTO 0) & (r_lfsr(7) XOR r_lfsr(5) XOR r_lfsr(4) XOR r_lfsr(3)));
                    v_new_gap_y := C_GAP_Y_MIN + to_integer(unsigned(r_lfsr));
                    
                    IF (v_new_gap_y > C_GAP_Y_MAX) THEN
                        r_pipe_gap_pos <= C_GAP_Y_MAX;
                    ELSE
                        r_pipe_gap_pos <= v_new_gap_y;
                    END IF;
                    
                ELSE
                    -- Não: Continua movendo o cano para a esquerda
                    -- Usa a velocidade variável
                    r_pipe_x_pos <= r_pipe_x_pos - s_current_pipe_speed; 
                END IF;
                
            END IF; 
        END IF; 
    END PROCESS;

    -- --- Saídas ---
    o_pipe_x <= std_logic_vector(to_unsigned(r_pipe_x_pos, 10));
    o_pipe_gap_y <= std_logic_vector(to_unsigned(r_pipe_gap_pos, 10));
    
END rtl;