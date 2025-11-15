-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     bit_reverser
--
-- description:
--
--   This file implements a .
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

entity bit_reverser is
  generic (
  g_WIDTH   : integer := 16
  );
  port(
  REV_IN_i  : in  std_logic_vector  (g_WIDTH - 1 downto 0);
  MODE_i    : in  std_logic;
  REV_OUT_o : out std_logic_vector (g_WIDTH - 1 downto 0)
  );
end bit_reverser;

architecture arch of bit_reverser is
begin
  with MODE_i select
    REV_OUT_o <= REV_IN_i when '1',
    ( REV_IN_i(0) & REV_IN_i(1) & REV_IN_i(2) & REV_IN_i(3) & REV_IN_i(4) &
    REV_IN_i(5) & REV_IN_i(6) & REV_IN_i(7) & REV_IN_i(8) &
    REV_IN_i(9) & REV_IN_i(10) & REV_IN_i(11) & REV_IN_i(12) &
    REV_IN_i(13) & REV_IN_i(14) & REV_IN_i(15) ) when others;
end arch;
