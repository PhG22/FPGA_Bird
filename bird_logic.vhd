--------------------
--
-- bird_logic.vhd
-- Criado em: 11/11/25
-- Autor: Pedro Henrique Guimarães Gomes
--
-- Rev 1 - Documentação - 18/11/25
--
--------------------
--  Resumo
--
-- Controlador da física e posição vertical do pássaro.
--
-- Responsável por calcular a posição vertical (eixo Y) do pássaro a cada frame de jogo (tick),
-- aplicando as forças de gravidade (descida constante) e pulo (subida ao pressionar botão).
-- 
--------------------------
--- Detalhes 
--
-- Entradas:
--      i_clk: Clock do sistema (25 MHz).
--      i_reset: Reseta o pássaro para o centro da tela (Y=240).
--      i_game_tick: Pulso de 60Hz que dita o ritmo da física.
--      i_flap: Sinal do botão que aciona o pulo do pássaro.
--
-- Saídas:
--      o_bird_y: Vetor de 10 bits indicando a posição vertical atual.
--
-- Funcionamento:
--      A cada 'i_game_tick', incrementa a posição Y (gravidade) ou decrementa (pulo).
--      Inclui lógica de saturação (clamping) para impedir que o pássaro ultrapasse
--      os limites superior (teto) e inferior (chão) da tela (480 pixels).
--
--------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY bird_logic IS
    PORT (
        i_clk       : IN  STD_LOGIC; -- Clock principal (25 MHz)
        i_reset     : IN  STD_LOGIC; -- Reset (ativo-alto)
        i_game_tick : IN  STD_LOGIC; -- Pulso de 60Hz
        i_flap      : IN  STD_LOGIC; -- Botão de pulo
        o_bird_y    : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) -- Posição Y do pássaro
    );
END bird_logic;

ARCHITECTURE rtl OF bird_logic IS
    SIGNAL r_bird_y_pos : INTEGER RANGE 0 TO 479 := 240; -- Posição Y inicial do pássaro
    -- --- Constantes do Pássaro ---
    CONSTANT C_GRAVITY_AMOUNT : INTEGER := 5; -- Força da gravidade
    CONSTANT C_FLAP_AMOUNT    : INTEGER := 10; -- Força do "flap"
    CONSTANT C_TOP_LIMIT      : INTEGER := 10; -- Posição X do limite superior da tela
    CONSTANT C_BOTTOM_LIMIT   : INTEGER := 460; -- Posição X do limite inferior da tela
    
BEGIN

    PROCESS (i_clk, i_reset)
        VARIABLE v_next_y : INTEGER RANGE 0 TO 479; -- Define a variável que guardará a próxima Posição Y do pássaro
        
    BEGIN
        
        IF (i_reset = '1') THEN
            r_bird_y_pos <= 240; -- Retorna o pássaro a posição inicial quando reset está ativo
            
        ELSIF (rising_edge(i_clk)) THEN
            
            IF (i_game_tick = '1') THEN -- A lógica do pássaro só roda no tick do jogo
            
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

    -- --- Saída ---    
    o_bird_y <= std_logic_vector(to_unsigned(r_bird_y_pos, 10));
    
END rtl;