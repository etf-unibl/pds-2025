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
--   several test vectors to the eight_bit_divider and checks quotient
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

  signal A_i : std_logic_vector(7 downto 0);
  signal B_i : std_logic_vector(7 downto 0);
  signal Q_o : std_logic_vector(7 downto 0);
  signal R_o : std_logic_vector(7 downto 0);

begin


  uut : entity work.eight_bit_divider
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
    -- 1) 100 / 7
    wait for 1 ns;
    A_int := 100;
    B_int := 7;
    A_i   <= std_logic_vector(to_unsigned(A_int, 8));
    B_i   <= std_logic_vector(to_unsigned(B_int, 8));
    wait for 100 ns;

    Q_exp := A_int / B_int;
    R_exp := A_int mod B_int;

    assert (Q_o = std_logic_vector(to_unsigned(Q_exp, 8)) and
            R_o = std_logic_vector(to_unsigned(R_exp, 8)))
      severity error;

    -- 2) 25 / 5
    A_int := 25;
    B_int := 5;
    A_i   <= std_logic_vector(to_unsigned(A_int, 8));
    B_i   <= std_logic_vector(to_unsigned(B_int, 8));
    wait for 100 ns;

    Q_exp := A_int / B_int;
    R_exp := A_int mod B_int;

    assert (Q_o = std_logic_vector(to_unsigned(Q_exp, 8)) and
            R_o = std_logic_vector(to_unsigned(R_exp, 8)))
      severity error;

    -- 3) 5 / 15
    A_int := 5;
    B_int := 15;
    A_i   <= std_logic_vector(to_unsigned(A_int, 8));
    B_i   <= std_logic_vector(to_unsigned(B_int, 8));
    wait for 100 ns;

    Q_exp := A_int / B_int;
    R_exp := A_int mod B_int;

    assert (Q_o = std_logic_vector(to_unsigned(Q_exp, 8)) and
            R_o = std_logic_vector(to_unsigned(R_exp, 8)))
      severity error;

    -- 4) 15 / 0  (dijeljenje sa nulom)
    A_int := 15;
    B_int := 0;
    A_i   <= std_logic_vector(to_unsigned(A_int, 8));
    B_i   <= std_logic_vector(to_unsigned(B_int, 8));
    wait for 100 ns;

    assert (Q_o = std_logic_vector(to_unsigned(0, 8)) and
            R_o = std_logic_vector(to_unsigned(A_int, 8)))
      severity error;

    wait;
  end process stim_p;

end arch;
