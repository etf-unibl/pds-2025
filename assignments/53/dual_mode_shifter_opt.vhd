-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     dual_mode_shifter_opt
--
-- description:
--
--   This file implements an optimized dual-mode shifting circuit logic.
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

entity dual_mode_shifter_opt is
  port (
  SH_IN_i  : in  std_logic_vector (15 downto 0);
  MODE_i   : in  std_logic;
  SH_OUT_o : out std_logic_vector (15 downto 0 )
);
end dual_mode_shifter_opt;

architecture arch of dual_mode_shifter_opt is
  component right_shifter is
    port (
    SH_IN_i  : in  std_logic_vector (15 downto 0);
    SH_OUT_o : out std_logic_vector (15 downto 0)
    );
  end component;
  component bit_reverser is
    port (
    REV_IN_i  : in  std_logic_vector  (15 downto 0);
    MODE_i    : in  std_logic;
    REV_OUT_o : out std_logic_vector  (15 downto 0)
    );
  end component;
  signal rev_input, shifted : std_logic_vector (15 downto 0);
begin
  u_rev_pre : bit_reverser
    port map (
    REV_IN_i  => SH_IN_i,
    MODE_i    => MODE_i,
    REV_OUT_o => rev_input
    );
  u_r : right_shifter
    port map (
    SH_IN_i  => rev_input,
    SH_OUT_o => shifted
  );
  u_rev_post : bit_reverser
    port map (
    REV_IN_i  => shifted,
    MODE_i    => MODE_i,
    REV_OUT_o => SH_OUT_o
    );
end arch;
