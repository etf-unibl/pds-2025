-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     dual_edge_detector
--
-- description:
--
--   This file implements detector of both edges meaning
--                           changes 0->1 and 1->0
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

entity dual_edge_detector is
  port (
    clk_i    : in  std_logic;
    rst_i    : in  std_logic;
    strobe_i : in  std_logic;
    p_o      : out std_logic
);
end dual_edge_detector;

architecture arch of bcd_adder is
  type mc_sm_type is
    (zero, edge, one);
  signal state_reg, state_next : mc_sm_type;

begin
  --! state register
  process(clk_i, rst_i)
  begin
    if rst_i = '1'  then
      state_reg <= zero;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process

  --! next-state logic
  process(state_reg, strobe_i)
  begin
    case state_reg is
      when zero =>
        if strobe_i = '1' then
          state_next <= edge;
        else
          state_next <= zero;
        end if;
      when edge =>
        if strobe_i = '1' then
          state_next <= one;
        else
          state_next <= zero;
        end if;
      when one =>
        if strobe_i = '0' then
          state_next <= edge;
        else
          state_next <= zero;
        end if;
    end case;
  end process;

  --! Output logic
  process(state_reg)
  begin
    p_o <= '0';
    case state_reg is
      when zero =>
      when one =>
      when edge =>
        p_o <= '1';
    end case;
  end process;
end arch;
