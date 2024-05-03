library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DisplayN is 
    port( 
        MAX10_CLK1_50:    in  std_logic;    -- 50MHz clock on the board 
        CHAR:             in  integer;
        LEDR:             out std_logic_vector(9 downto 0); 
        GPIO:             out std_logic_vector(35 downto 0)
    ); 
end entity DisplayN;

architecture main of DisplayN is 
    signal counter: unsigned(30 downto 0); 
    signal row_driver: std_logic_vector(0 to 7); 
    signal col_driver: std_logic_vector(0 to 7) := (others => '1');  -- Initialize to avoid inferred latches
    signal column_index: integer range 0 to 7 := 0;  -- Index for cycling through columns
begin 
    counter <= counter + 1 when rising_edge(MAX10_CLK1_50); 

    process(counter(5))  -- Using a lower bit for a faster update rate
    begin
        if rising_edge(counter(5)) then
            case CHAR is 
                when 65 => --A
                    case column_index is
                        when 0 => row_driver <= "00000000"; -- First column (off)
                        when 1 => row_driver <= "11111100"; -- Second column (part of 'A')
                        when 2 => row_driver <= "00100010"; -- Third column (part of 'A')
                        when 3 => row_driver <= "00100001"; -- Fourth column (part of 'A')
                        when 4 => row_driver <= "00100010"; -- Fifth column (part of 'A')
                        when 5 => row_driver <= "11111100"; -- Sixth column (part of 'A')
                        when 6 => row_driver <= "00000000"; -- Seventh column (off)
                        when 7 => row_driver <= "00000000"; -- Eighth column (off)
                        when others => row_driver <= (others => '0');
                    end case;
                when 78 => -- N
                    case column_index is
                        when 0 => row_driver <= "00000000"; -- First column (off)
                        when 1 => row_driver <= "11111110"; -- Second column (part of 'N')
                        when 2 => row_driver <= "00100000"; -- Third column (part of 'N')
                        when 3 => row_driver <= "00010000"; -- Fourth column (part of 'N')
                        when 4 => row_driver <= "00001000"; -- Fifth column (part of 'N')
                        when 5 => row_driver <= "11111110"; -- Sixth column (part of 'N')
                        when 6 => row_driver <= "00000000"; -- Seventh column (off)
                        when 7 => row_driver <= "00000000"; -- Eighth column (off)
                        when others => row_driver <= (others => '0');
                    end case;
                when others => -- random pattern for error
                    case column_index is
                        when 0 => row_driver <= "01010101";
                        when 1 => row_driver <= "10101010";
                        when 2 => row_driver <= "01010101";
                        when 3 => row_driver <= "10101010";
                        when 4 => row_driver <= "01010101";
                        when 5 => row_driver <= "10101010";
                        when 6 => row_driver <= "01010101";
                        when 7 => row_driver <= "10101010";
                        when others => row_driver <= (others => '0');
                    end case;
                end case;

            col_driver <= (others => '1');  -- Turns all columns off
            col_driver(column_index) <= '0';  -- Turns the current column on

            -- Cycle through columns
            if counter(6) = '1' then
                column_index <= (column_index + 1) mod 8;
            end if;
        end if;
    end process;

    -- Connect row and column drivers to the GPIO pins
    GPIO(0) <= row_driver(0);
    GPIO(2) <= row_driver(1);
    GPIO(4) <= row_driver(2);
    GPIO(6) <= row_driver(3);
    GPIO(8) <= row_driver(4);
    GPIO(10) <= row_driver(5);
    GPIO(12) <= row_driver(6);
    GPIO(14) <= '0'; --row_driver(7);

    GPIO(1) <= col_driver(0);
    GPIO(3) <= col_driver(1);
    GPIO(5) <= col_driver(2);
    GPIO(7) <= col_driver(3);
    GPIO(9) <= col_driver(4);
    GPIO(11) <= col_driver(5);
    GPIO(13) <= col_driver(6);
    GPIO(15) <= col_driver(7);
end architecture main;