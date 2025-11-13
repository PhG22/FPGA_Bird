LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY bird_logic IS
    PORT (
        i_clk       : IN  STD_LOGIC; 
        i_reset     : IN  STD_LOGIC; 
        i_game_tick : IN  STD_LOGIC; 
        i_flap      : IN  STD_LOGIC; 
        o_bird_y    : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END bird_logic;

ARCHITECTURE rtl OF bird_logic IS
    SIGNAL r_bird_y_pos : INTEGER RANGE 0 TO 479 := 240;
    
    CONSTANT C_GRAVITY_AMOUNT : INTEGER := 5;
    CONSTANT C_FLAP_AMOUNT    : INTEGER := 10;
    CONSTANT C_TOP_LIMIT      : INTEGER := 10;
    CONSTANT C_BOTTOM_LIMIT   : INTEGER := 460;
    
BEGIN

    PROCESS (i_clk, i_reset)
        VARIABLE v_next_y : INTEGER RANGE 0 TO 479; 
        
    BEGIN
        
        IF (i_reset = '1') THEN
            r_bird_y_pos <= 240;
            
        ELSIF (rising_edge(i_clk)) THEN
            
            IF (i_game_tick = '1') THEN
            
                -- Carrega o valor ATUAL do sinal na variável
                v_next_y := r_bird_y_pos;
                
                -- Executa a lógica usando a variável
                IF (i_flap = '1') THEN
                    v_next_y := r_bird_y_pos - C_FLAP_AMOUNT; -- Sobe
                ELSE
                    v_next_y := r_bird_y_pos + C_GRAVITY_AMOUNT; -- Cai
                END IF;

                -- --- Checagem de Limites ---
                IF (v_next_y < C_TOP_LIMIT) THEN
                    r_bird_y_pos <= C_TOP_LIMIT;
                ELSIF (v_next_y > C_BOTTOM_LIMIT) THEN
                    r_bird_y_pos <= C_BOTTOM_LIMIT;
                ELSE
                    r_bird_y_pos <= v_next_y;
                END IF;
                
            END IF; 
            
        END IF; 
    END PROCESS;

    o_bird_y <= std_logic_vector(to_unsigned(r_bird_y_pos, 10));
    
END rtl;