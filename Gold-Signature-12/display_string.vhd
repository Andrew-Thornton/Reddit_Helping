library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_string is 
  generic(
    MESSAGE : string := "TEST"
  );
  port( 
    MAX10_CLK1_50:    in  std_logic;    -- 50MHz clock on the board 
    LEDR:             out std_logic_vector(9 downto 0); 
    GPIO:             out std_logic_vector(35 downto 0)
  ); 
end entity DisplayN;

architecture main of DisplayN is 
    constant NUMBER_CHARS : integer := MESSAGE'length;

    component DisplayN is 
    port( 
        MAX10_CLK1_50:    in  std_logic;    -- 50MHz clock on the board 
        CHAR:             in  integer;
        LEDR:             out std_logic_vector(9 downto 0); 
        GPIO:             out std_logic_vector(35 downto 0)
    ); 
    end component DisplayN;

    signal counter: unsigned(30 downto 0); 
    signal char_counter: integer range 0 to NUMBER_CHARS-1 := 0;  -- Index for cycling through columns  
    
begin 

    count_proc : process(MAX10_CLK1_50)
    begin
        if rising_edge(MAX10_CLK1_50) then
            if counter < 25000000 then
                counter <= counter + 1; 
            else
                counter <= 0;
                if char_counter >= NUMBER_CHARS-1 then
                    char_counter <= 0;
                else
                    char_counter <= char_counter+1;
                end if;
            end if;
        end if;
    end process count_proc;
    
    displayer : DisplayN
    port map( 
        MAX10_CLK1_50 => MAX10_CLK1_50,
        CHAR          => charachter'pos(MESSAGE(char_counter)),
        LEDR          => LEDR,
        GPIO          => GPIO
    ); 

end architecture main;