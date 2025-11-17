library ieee;
use ieee.std_logic_1164.all;

entity decoder_2_4 is
  port(
        i_A : in std_logic_vector(1 downto 0);
        i_E : in std_logic;
        o_Y : out std_logic_vector(3 downto 0)
  );
end decoder_2_4;

architecture arch of decoder_2_4
is
-- Temporary signal used to hold decoder output before enable control
  signal y_tmp : std_logic_vector(3 downto 0);
begin
  with i_A select
    y_tmp <= "0001" when "00",
             "0010" when "01",
             "0100" when "10",
             "1000" when others;
  o_Y <= y_tmp when i_E = '1' else "0000";
end arch;
