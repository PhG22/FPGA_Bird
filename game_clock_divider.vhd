LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY game_clock_divider IS
    PORT (
        i_clk   : IN  STD_LOGIC; -- Clock de entrada
        i_reset : IN  STD_LOGIC; -- Reset assíncrono
        o_tick  : OUT STD_LOGIC  -- Pulso de saída (60 Hz)
    );
END game_clock_divider;

ARCHITECTURE rtl OF game_clock_divider IS

    -- Valor calculado: 25.175.000 / 60 - 1 = 419.582,33
    -- Vamos usar 419.582
    CONSTANT MAX_COUNT : INTEGER := 419582;
    
    -- O contador precisa de 19 bits (2^19 = 524288)
    SIGNAL r_counter : INTEGER RANGE 0 TO MAX_COUNT;

BEGIN

    PROCESS (i_clk, i_reset)
    BEGIN
        IF (i_reset = '1') THEN
            r_counter <= 0;
            o_tick    <= '0';
        ELSIF (rising_edge(i_clk)) THEN
            
            -- O contador atingiu o máximo?
            IF (r_counter = MAX_COUNT) THEN
                r_counter <= 0;      -- Reinicia o contador
                o_tick    <= '1';  -- Gera o pulso de '1'
            ELSE
                r_counter <= r_counter + 1; -- Continua contando
                o_tick    <= '0'; -- Mantém o pulso em '0'
            END IF;
            
        END IF;
    END PROCESS;

END rtl;