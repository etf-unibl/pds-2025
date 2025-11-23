-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     eight_bit_divider_tb
--
-- description:   Self-checking testbench for eight_bit_divider
--
--   This file implements a simple self-checking testbench that applies
--   test vectors to the eight_bit_divider and checks quotient
--   and remainder against expected values.
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

entity eight_bit_divider_tb is
end eight_bit_divider_tb;

architecture arch of eight_bit_divider_tb is

  component eight_bit_divider is
    port (
      A_i : in  std_logic_vector(7 downto 0);
      B_i : in  std_logic_vector(7 downto 0);
      Q_o : out std_logic_vector(7 downto 0);
      R_o : out std_logic_vector(7 downto 0)
    );
  end component;

  signal A_i : std_logic_vector(7 downto 0) := (others => '0');
  signal B_i : std_logic_vector(7 downto 0) := (others => '0');
  signal Q_o : std_logic_vector(7 downto 0);
  signal R_o : std_logic_vector(7 downto 0);

begin

  uut : eight_bit_divider
    port map (
      A_i => A_i,
      B_i => B_i,
      Q_o => Q_o,
      R_o => R_o
    );

  stim_p : process
    variable A_int : integer;
    variable B_int : integer;
    variable Q_exp : integer;
    variable R_exp : integer;
  begin
    wait for 1 ns;

    -- sve kombinacije A=0..255, B=0..255
    for A_int in 0 to 255 loop
      for B_int in 0 to 255 loop
        A_i <= std_logic_vector(to_unsigned(A_int, 8));
        B_i <= std_logic_vector(to_unsigned(B_int, 8));
        wait for 100 ns;

        if B_int = 0 then
          Q_exp := 255;
          R_exp := 255;
        else
          Q_exp := A_int / B_int;
          R_exp := A_int mod B_int;
        end if;

        assert (Q_o = std_logic_vector(to_unsigned(Q_exp, 8)) and
                R_o = std_logic_vector(to_unsigned(R_exp, 8)))
          report "Test failed"
          severity error;
      end loop;
    end loop;

    wait;
  end process stim_p;

end arch;
