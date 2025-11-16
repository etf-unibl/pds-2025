-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     dual_mode_comparator_tb
--
-- description:
--
--   This file implements a simple sign-magnitude dual mode comparator
--   test bench.
--
-----------------------------------------------------------------------------
-- Copyright (c) 2025 Faculty of Electrical Engineering
-----------------------------------------------------------------------------
-- The MIT License
-----------------------------------------------------------------------------
-- Copyright 2025 Faculty of Electrical Engineering
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom
-- the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dual_mode_comparator_tb is
end dual_mode_comparator_tb;

architecture arch of dual_mode_comparator_tb is

  component dual_mode_comparator
    port (
      A_i    : in  std_logic_vector(7 downto 0);
      B_i    : in  std_logic_vector(7 downto 0);
      MODE_i : in  std_logic;
      AGTB_o : out std_logic
    );
  end component;

  signal A_i, B_i : std_logic_vector(7 downto 0);
  signal MODE_i   : std_logic;
  signal AGTB_o   : std_logic;

begin

  uut : dual_mode_comparator
    port map (
      A_i    => A_i,
      B_i    => B_i,
      MODE_i => MODE_i,
      AGTB_o => AGTB_o
    );

  tb : process
    variable error_count    : integer := 0;
    variable total_tests    : integer := 0;
    variable a_sign, b_sign : std_logic;
    variable a_mag, b_mag   : integer;
    variable expected       : std_logic;
  begin
    A_i  <= "00000000";
    B_i  <= "00000000";

    assert false report "--- TESTING UNSIGNED MODE (MODE=0) ---" severity note;
    MODE_i <= '0';

    for a_val in 0 to 255 loop
      for b_val in 0 to 255 loop
        A_i <= std_logic_vector(to_unsigned(a_val, 8));
        B_i <= std_logic_vector(to_unsigned(b_val, 8));
        wait for 1 ns;
        total_tests := total_tests + 1;

        a_sign := A_i(7);
        b_sign := B_i(7);
        a_mag  := to_integer(unsigned(A_i(6 downto 0)));
        b_mag  := to_integer(unsigned(B_i(6 downto 0)));

        if MODE_i = '0' then
          if (a_sign = b_sign and a_mag > b_mag) or
             (a_sign = '1' and b_sign = '0') then
            expected := '1';
          else
            expected := '0';
          end if;
        else
          if a_sign = '0' and b_sign = '1' then
            expected := '1';
          elsif a_sign = '1' and b_sign = '0' then
            expected := '0';
          elsif a_mag = b_mag then
            expected := '0';
          elsif a_sign = '0' then
            if a_mag > b_mag then
              expected := '1';
            else
              expected := '0';
            end if;
          else
            if a_mag < b_mag then
              expected := '1';
            else
              expected := '0';
            end if;
          end if;
        end if;

        if AGTB_o /= expected then
          assert false report "ERROR: A=" & integer'image(a_val) &
                        ", B=" & integer'image(b_val) &
                        ", Got: " & std_logic'image(AGTB_o) &
                        ", Expected: " & std_logic'image(expected)
          severity error;
        end if;
      end loop;
    end loop;

    A_i <= "00000000";
    B_i <= "00000000";

    assert false report "--- TESTING SIGNED MODE (MODE=1) ---" severity note;
    MODE_i <= '1';

    for a_val in 0 to 255 loop
      for b_val in 0 to 255 loop
        A_i <= std_logic_vector(to_unsigned(a_val, 8));
        B_i <= std_logic_vector(to_unsigned(b_val, 8));
        wait for 1 ns;
        total_tests := total_tests + 1;

        a_sign := A_i(7);
        b_sign := B_i(7);
        a_mag  := to_integer(unsigned(A_i(6 downto 0)));
        b_mag  := to_integer(unsigned(B_i(6 downto 0)));

        if a_mag = 0 and b_mag = 0 then
          expected := '0';
        elsif a_sign = '0' and b_sign = '1' then
          expected := '1';
        elsif a_sign = '1' and b_sign = '0' then
          expected := '0';
        elsif a_mag = b_mag then
          expected := '0';
        elsif a_sign = '0' then
          if a_mag > b_mag then
            expected := '1';
          else
            expected := '0';
          end if;
        else
          if a_mag < b_mag then
            expected := '1';
          else
            expected := '0';
          end if;
        end if;

        if AGTB_o /= expected then
          assert false report "ERROR: A=" & integer'image(a_val) &
                        ", B=" & integer'image(b_val) &
                        ", Got: " & std_logic'image(AGTB_o) &
                        ", Expected: " & std_logic'image(expected)
          severity error;
          error_count := error_count + 1;
        end if;
      end loop;
    end loop;

    assert false report "=== TEST COMPLETE! ===" severity note;
    assert false report "Total tests: "  & integer'image(total_tests) severity note;
    assert false report "Total errors: " & integer'image(error_count) severity note;

    if error_count = 0 then
      report "All tests passed!";
    else
      report "=== TESTS FAILED! ===";
    end if;

    wait;
  end process tb;

end arch;
