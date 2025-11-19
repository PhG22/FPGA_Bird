--------------------
--
-- game_clock_divider.vhd
-- Criado em: 11/11/25
-- Autor: Pedro Henrique Guimarães Gomes
--
-- Rev 1 - Documentação - 18/11/25
--
--------------------
--  Resumo
--
-- Divisor de clock para geração do "Game Tick".
--
-- Gera um pulso de habilitação (tick) de aproximadamente 60Hz a partir do clock
-- principal de 25MHz, usado para sincronizar a física do jogo independentemente
-- da taxa de atualização de pixels.
-- 
--------------------------
--- Detalhes 
--
-- Entradas:
--      i_clk: Clock de entrada (25 MHz).
--      i_reset: Reinicia o contador interno.
--
-- Saídas:
--      o_tick: Pulso de duração de 1 ciclo de clock, ativo 60 vezes por segundo.
--
-- Funcionamento:
--      Utiliza um contador de inteiros que conta de 0 até 419.582. Quando o
--      contador atinge o máximo, gera o pulso '1' e reinicia, criando a frequência
--      desejada (25MHz / 419583 ≈ 60Hz).
--
--------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY game_clock_divider IS
    PORT (
        i_clk   : IN  STD_LOGIC; -- Clock principal (25 MHz)
        i_reset : IN  STD_LOGIC; -- Reset (ativo-alto)
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
        IF (i_reset = '1') THEN -- Reinicia o contador no reset
            r_counter <= 0;
            o_tick    <= '0';
        ELSIF (rising_edge(i_clk)) THEN
            
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