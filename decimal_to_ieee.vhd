library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decimal_to_ieee is
  port(
    clk_i  : in  std_logic;
    in_i   : in  std_logic_vector(19 downto 0);
    out_o  : out std_logic_vector(31 downto 0)
  );
end decimal_to_ieee;

architecture rtl of decimal_to_ieee is

  --breaking up the input into the respective parts
  signal sign   : std_logic;
  signal mag    : unsigned(18 downto 0);

  -- 1st clock cycle signals
  signal max_one  : integer range -1 to 18 ;
  
  -- shift registers
  signal sign_sr : std_logic_vector(1 downto 0);
  signal mag_sr : unsigned(18 downto 0);
  
  -- 2nd clock cycle mand and exp
  signal res_mand : unsigned(23 downto 0);
  signal res_exp  : unsigned(7 downto 0);

begin

  -- input mapping
  sign <= in_i(19);
  mag  <= unsinged(in_i(18 downto 0));

  -- This process finds out where the largest one is in the magnitude vector 
  -- clock cycle 1
  find_max_one : process(clk_i)
  begin
    if rising_edge(clk_i) then
      -- default case is that there are no values of magnitude 
      max_one <= -1;
      for i in 0 to 18 loop
        if mag(i) = '1' then
          max_one <= i;
        end if;
      end loop
    end if;
  end process find_max_one;
  
  -- clock cycles 1 shift register
  shift_register_proc : process(clk_i)
  begin
    if rising_edge(clk_i) then
      sign_sr(0) <= sign;
      mag_sr <= mag;
    end if;
  end process shift_register_proc;
  
  -- this here then decides the mandissa and the exponent
  -- clock cycle 2
  mand_and_exp_proc : process(clk_i)
    variable mag_se : std_logic_vector(23 downto 0);
  begin
    if rising_edge(clk_i) then
      if max_one = -1 then
        --this is the rare case of 0
        res_mand <= to_unsigned(0,24);
        res_exp  <= to_unsigned(0,8);
      else
        --normal case
        mag_se := ("00000" & std_logic_vector(mag_sr));
        res_mand <= shift_left(unsigned(mag_se),5+(18-max_one));
        res_exp <= to_unsigned(127,8)+to_unsigned(max_one,8); --the 127 is here due to the ieee-754 offset
      end if;
    end if;
  end process mand_and_exp_proc;
  
  --clock cycle 2 shift register
  shift_register_proc2 : process(clk_i)
  begin
    if rising_edge(clk_i) then
      sign_sr(1) <= sign_sr(0);
    end if;
  end process shift_register_proc2;
  
  -- output mapping
  -- clock cycle 3
  output_process : process(clk_i)
  begin
    if rising_edge(clk_i) then
      out_o(31)           <= sign_sr(1);
      out_o(30 downto 23) <= std_logic_vector(res_exp);
      out_o(22 downto  0) <= std_logic_vector(res_mand(22 downto 0)); --chop off the 1 in 1.x or its 0
    end if;
  end process output_process;

end rtl;