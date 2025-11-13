LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY pixel_drawer IS
    PORT (
        i_pixel_x   : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        i_pixel_y   : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        -- Posições dos elementos
        i_bird_y    : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        i_pipe_x    : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        i_pipe_gap_y : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        -- Flags de estado do game_manager
        i_game_over : IN STD_LOGIC;
        i_game_ready: IN STD_LOGIC; 

        -- Saídas de cor (4 bits por canal)
        o_red       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        o_green     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        o_blue      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END pixel_drawer;

ARCHITECTURE rtl OF pixel_drawer IS

    -- --- Constantes de Cor (RRRR GGGG BBBB) ---
    CONSTANT C_BIRD_COLOR_R : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111"; -- Amarelo
    CONSTANT C_BIRD_COLOR_G : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100";
    CONSTANT C_BIRD_COLOR_B : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";

    CONSTANT C_PIPE_COLOR_R : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010"; -- Verde
    CONSTANT C_PIPE_COLOR_G : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";
    CONSTANT C_PIPE_COLOR_B : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";

    CONSTANT C_BG_COLOR_R   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100"; -- Azul Claro
    CONSTANT C_BG_COLOR_G   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
    CONSTANT C_BG_COLOR_B   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    
    CONSTANT C_TEXT_COLOR_R : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111"; -- Branco
    CONSTANT C_TEXT_COLOR_G : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    CONSTANT C_TEXT_COLOR_B : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

    -- --- Constantes de Geometria ---
    CONSTANT C_BIRD_X_POS   : INTEGER := 100;
    CONSTANT C_BIRD_SIZE    : INTEGER := 20;
    CONSTANT C_PIPE_WIDTH   : INTEGER := 60;
    CONSTANT C_GAP_HEIGHT   : INTEGER := 120;
    
    -- Sinais internos para conversão
    SIGNAL s_x, s_y : INTEGER RANGE 0 TO 639;
    SIGNAL s_bird_y_int   : INTEGER RANGE 0 TO 479;
    SIGNAL s_pipe_x_int   : INTEGER;
    SIGNAL s_pipe_gap_int : INTEGER RANGE 0 TO 479;
    
BEGIN

    s_x <= to_integer(unsigned(i_pixel_x));
    s_y <= to_integer(unsigned(i_pixel_y));
    s_bird_y_int <= to_integer(unsigned(i_bird_y));
    s_pipe_x_int <= to_integer(unsigned(i_pipe_x));
    s_pipe_gap_int <= to_integer(unsigned(i_pipe_gap_y));

    PROCESS (s_x, s_y, s_bird_y_int, s_pipe_x_int, s_pipe_gap_int, i_game_over, i_game_ready)
    
        VARIABLE v_is_bird : BOOLEAN;
        VARIABLE v_is_pipe : BOOLEAN;
        VARIABLE v_is_text : BOOLEAN;
            
    BEGIN 
            
        v_is_bird := (s_x >= C_BIRD_X_POS AND s_x < (C_BIRD_X_POS + C_BIRD_SIZE) AND
                      s_y >= s_bird_y_int AND s_y < (s_bird_y_int + C_BIRD_SIZE));
    
        v_is_pipe := (s_x >= s_pipe_x_int AND s_x < (s_pipe_x_int + C_PIPE_WIDTH) AND
                     (s_y < (s_pipe_gap_int - C_GAP_HEIGHT/2) OR 
                      s_y > (s_pipe_gap_int + C_GAP_HEIGHT/2)));
                      
        -- Lógica de Texto (baseada no estado do jogo)
        
        IF (i_game_ready = '1') THEN
            -- --- TELA DE INÍCIO ---
            IF (s_y >= 150 AND s_y < 180) AND (s_x >= 260 AND s_x < 280) THEN -- F
                v_is_text := (s_x < 264 OR s_y < 154 OR (s_y > 163 AND s_y < 167));
            ELSIF (s_y >= 150 AND s_y < 180) AND (s_x >= 290 AND s_x < 310) THEN -- P
                v_is_text := (s_x < 294 OR s_y < 154 OR (s_y > 163 AND s_y < 167) OR (s_x > 306 AND s_y < 167));
            ELSIF (s_y >= 150 AND s_y < 180) AND (s_x >= 320 AND s_x < 340) THEN -- G
                v_is_text := (s_x < 324 OR s_y < 154 OR s_y > 176 OR (s_y > 163 AND s_x > 330));
            ELSIF (s_y >= 150 AND s_y < 180) AND (s_x >= 350 AND s_x < 370) THEN -- A
                v_is_text := (s_x < 354 OR s_x > 366 OR s_y < 154 OR (s_y > 163 AND s_y < 167));
                
            ELSIF (s_y >= 190 AND s_y < 220) AND (s_x >= 260 AND s_x < 280) THEN -- B
                v_is_text := (s_x < 264 OR s_y < 194 OR s_y > 216 OR (s_x > 276) OR (s_y > 203 AND s_y < 207));
            ELSIF (s_y >= 190 AND s_y < 220) AND (s_x >= 290 AND s_x < 310) THEN -- I
                v_is_text := (s_y < 194 OR s_y > 216 OR (s_x > 298 AND s_x < 302));
            ELSIF (s_y >= 190 AND s_y < 220) AND (s_x >= 320 AND s_x < 340) THEN -- R
                v_is_text := (s_x < 324 OR s_y < 194 OR (s_y > 203 AND s_y < 207) OR (s_x > 336 AND s_y < 205) OR (s_y >= 205 AND s_x >= 332));
            ELSIF (s_y >= 190 AND s_y < 220) AND (s_x >= 350 AND s_x < 370) THEN -- D
                v_is_text := (s_x < 354 OR s_y < 194 OR s_y > 216 OR (s_x > 366));

            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 190 AND s_x < 200) THEN -- P
                v_is_text := (s_x < 192 OR s_y < 352 OR (s_y > 357 AND s_y < 359) OR (s_x > 198 AND s_y < 358));
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 205 AND s_x < 215) THEN -- R
                v_is_text := (s_x < 207 OR s_y < 352 OR (s_y > 357 AND s_y < 359) OR (s_x > 213 AND s_y < 358) OR (s_y >= 358 AND s_x >= 211));
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 220 AND s_x < 230) THEN -- E
                v_is_text := (s_x < 222 OR s_y < 352 OR s_y > 363 OR (s_y > 357 AND s_y < 359));
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 235 AND s_x < 245) THEN -- S
                v_is_text := (s_y < 352 OR s_y > 363 OR (s_x < 237 AND s_y < 358) OR (s_x > 243 AND s_y > 358));
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 250 AND s_x < 260) THEN -- S
                v_is_text := (s_y < 352 OR s_y > 363 OR (s_x < 252 AND s_y < 358) OR (s_x > 258 AND s_y > 358));
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 270 AND s_x < 280) THEN -- F
                v_is_text := (s_x < 272 OR s_y < 352 OR (s_y > 357 AND s_y < 359));
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 285 AND s_x < 295) THEN -- L
                v_is_text := (s_x < 287 OR s_y > 363);
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 300 AND s_x < 310) THEN -- A
                v_is_text := (s_x < 302 OR s_x > 308 OR s_y < 352 OR (s_y > 357 AND s_y < 359));
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 315 AND s_x < 325) THEN -- P
                v_is_text := (s_x < 317 OR s_y < 352 OR (s_y > 357 AND s_y < 359) OR (s_x > 323 AND s_y < 358));
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 335 AND s_x < 345) THEN -- T
                v_is_text := (s_x < 343 AND s_x > 337) OR (s_y < 352);
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 350 AND s_x < 360) THEN -- O
                v_is_text := (s_x < 352 OR s_x > 358 OR s_y < 352 OR s_y > 363);
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 370 AND s_x < 380) THEN -- S
                v_is_text := (s_y < 352 OR s_y > 363 OR (s_x < 372 AND s_y < 358) OR (s_x > 378 AND s_y > 358));
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 385 AND s_x < 395) THEN -- T
                v_is_text := (s_x < 393 AND s_x > 387) OR (s_y < 352);
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 400 AND s_x < 410) THEN -- A
                v_is_text := (s_x < 402 OR s_x > 408 OR s_y < 352 OR (s_y > 357 AND s_y < 359));
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 415 AND s_x < 425) THEN -- R
                v_is_text := (s_x < 417 OR s_y < 352 OR (s_y > 357 AND s_y < 359) OR (s_x > 423 AND s_y < 358) OR (s_y >= 358 AND s_x >= 421));
            ELSIF (s_y >= 350 AND s_y < 365) AND (s_x >= 430 AND s_x < 440) THEN -- T
                v_is_text := (s_x < 438 AND s_x > 432) OR (s_y < 352);
            
            ELSE
                v_is_text := false;
            END IF;

        ELSIF (i_game_over = '1') THEN
            -- --- TELA DE FIM DE JOGO ---
            IF (s_y >= 220 AND s_y < 250) AND (s_x >= 260 AND s_x < 280) THEN
                v_is_text := (s_x < 264 OR s_y < 224 OR s_y > 246 OR (s_y > 233 AND s_x > 270)); -- "G"
            
            ELSIF (s_y >= 220 AND s_y < 250) AND (s_x >= 290 AND s_x < 310) THEN
                v_is_text := (s_x < 294 OR s_x > 306 OR s_y < 224 OR (s_y > 233 AND s_y < 237)); -- "A"
            
            ELSIF (s_y >= 220 AND s_y < 250) AND (s_x >= 320 AND s_x < 340) THEN
                v_is_text := (s_x < 324 OR s_x > 336 OR (s_y < 230 AND (s_x > 326 AND s_x < 334))); -- "M"
            
            ELSIF (s_y >= 220 AND s_y < 250) AND (s_x >= 350 AND s_x < 370) THEN
                v_is_text := (s_x < 354 OR s_y < 224 OR s_y > 246 OR (s_y > 233 AND s_y < 237)); -- "E"
            
            ELSIF (s_y >= 260 AND s_y < 290) AND (s_x >= 275 AND s_x < 295) THEN
                v_is_text := (s_x < 279 OR s_x > 291 OR s_y < 264 OR s_y > 286); -- "O"
            
            ELSIF (s_y >= 260 AND s_y < 290) AND (s_x >= 305 AND s_x < 325) THEN
                v_is_text := ((s_x < 309 OR s_x > 321) AND (s_y < 280)) OR 
                             (s_y >= 280 AND s_x >= 313 AND s_x < 317); -- "V"
    
            ELSIF (s_y >= 260 AND s_y < 290) AND (s_x >= 335 AND s_x < 355) THEN
                v_is_text := (s_x < 339 OR s_y < 264 OR s_y > 286 OR (s_y > 273 AND s_y < 277)); -- "E"
            
            ELSIF (s_y >= 260 AND s_y < 290) AND (s_x >= 365 AND s_x < 385) THEN
                v_is_text := (s_x < 369) OR (s_y < 264) OR (s_y > 273 AND s_y < 277) OR 
                             (s_x > 381 AND s_y < 275) OR (s_y >= 275 AND s_x >= 377); -- "R"
            
            ELSE
                v_is_text := false;
            END IF;
            
        ELSE
            -- Se NÃO for game over E NÃO for game ready (ou seja, estamos jogando)
            v_is_text := false;
        END IF;


        -- Lógica de Prioridade (Mux de Saída)
        IF (v_is_text) THEN
            o_red   <= C_TEXT_COLOR_R;
            o_green <= C_TEXT_COLOR_G;
            o_blue  <= C_TEXT_COLOR_B;
        ELSIF (v_is_bird) THEN
            o_red   <= C_BIRD_COLOR_R;
            o_green <= C_BIRD_COLOR_G;
            o_blue  <= C_BIRD_COLOR_B;
        ELSIF (v_is_pipe) THEN
            o_red   <= C_PIPE_COLOR_R;
            o_green <= C_PIPE_COLOR_G;
            o_blue  <= C_PIPE_COLOR_B;
        ELSE
            o_red   <= C_BG_COLOR_R;
            o_green <= C_BG_COLOR_G;
            o_blue  <= C_BG_COLOR_B;
        END IF;
            
    END PROCESS;
    
END rtl;