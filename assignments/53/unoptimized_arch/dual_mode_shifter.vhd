-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     dual_mode_shifter
--
-- description:
--
--   This file implements a 16-bit dual-mode shifter:
--   circular left or right based on mode.
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

entity dual_mode_shifter is
  port (
  SH_IN_i  : in  std_logic_vector (15 downto 0);
  MODE_i   : in  std_logic;
  SH_OUT_o : out std_logic_vector (15 downto 0 )
);
end dual_mode_shifter;

architecture arch of dual_mode_shifter is
  component left_shifter is
    port (
    SH_IN_i  : in std_logic_vector (15 downto 0);
    SH_OUT_o : out std_logic_vector (15 downto 0)
    );
  end component;
  component right_shifter is
    port (
    SH_IN_i  : in std_logic_vector (15 downto 0);
    SH_OUT_o : out std_logic_vector (15 downto 0)
  );
  end component;
  signal left_o, right_o : std_logic_vector (15 downto 0);
begin
  u_l : left_shifter
  port map (
  SH_IN_i  => SH_IN_i,
  SH_OUT_o => left_o
  );
  u_r : right_shifter
  port map (
  SH_IN_i  => SH_IN_i,
  SH_OUT_o => right_o
  );
  SH_OUT_o <= left_o when MODE_i = '0' else right_o;
end arch;
