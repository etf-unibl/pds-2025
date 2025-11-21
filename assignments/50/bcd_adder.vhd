-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     bcd_adder
--
-- description:
--
--   This file implements three digit BCD adder using single_digit_bcd_adder unit
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

entity bcd_adder is
  port (
    A_i   : in  std_logic_vector(11 downto 0);
    B_i   : in  std_logic_vector(11 downto 0);
    SUM_o : out std_logic_vector(15 downto 0)
  );
end bcd_adder;

architecture bcd_adder_arch of bcd_adder is
  component single_digit_bcd_adder is
    port(
      A_i   : in  std_logic_vector(3 downto 0);
      B_i   : in  std_logic_vector(3 downto 0);
      CARRY_i : in std_logic;
      SUM_o : out std_logic_vector(3 downto 0);
      CARRY_o : out std_logic
    );
  end component;
  signal s_carry_out : std_logic_vector(3 downto 0) := "0000";
begin
  a0 : single_digit_bcd_adder port map(
    A_i     => A_i(3 downto 0),
    B_i     => B_i(3 downto 0),
    CARRY_i => '0',
    SUM_o   => SUM_o(3 downto 0),
    CARRY_o => s_carry_out(0)
  );
  a1 : single_digit_bcd_adder port map(
    A_i     => A_i(7 downto 4),
    B_i     => B_i(7 downto 4),
    CARRY_i => s_carry_out(0),
    SUM_o   => SUM_o(7 downto 4),
    CARRY_o => s_carry_out(1)
  );
  a2 : single_digit_bcd_adder port map(
    A_i     => A_i(11 downto 8),
    B_i     => B_i(11 downto 8),
    CARRY_i => s_carry_out(1),
    SUM_o   => SUM_o(11 downto 8),
    CARRY_o => s_carry_out(2)
  );
  a3 : single_digit_bcd_adder port map(
    A_i     => "0000",
    B_i     => "0000",
    CARRY_i => s_carry_out(2),
    SUM_o   => SUM_o(15 downto 12),
    CARRY_o => s_carry_out(3)
  );
end bcd_adder_arch;
