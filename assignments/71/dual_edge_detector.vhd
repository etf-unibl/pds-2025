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
--   This file implements detector of both edges, meaning
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

-----------------------------------------------------------------------------
--! @file dual_edge_detector.vhd
--! @brief implements detector of both edges, meaning changes 0->1 and 1->0
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Entity definition of dual_edge_detector.
--! Unit implements edge detector that i syncrhonous with the clock.
--! Whenever input(strobe_i) changes it's state, either from 0 to 1, or
--! 1 to 0, the output(p_o) should be high indicating that an edge has been
--! detected. Output(p_o) is low otherwise.
entity dual_edge_detector is
  port (
    clk_i    : in  std_logic; --! Clock input of the unit.
    rst_i    : in  std_logic; --! Reset input of the unit.
    strobe_i : in  std_logic; --! The input we are trying to detect edges from.
    p_o      : out std_logic  --! Output which signals that an edge is detected.
);
end dual_edge_detector;

--! @brief Architecture definition of dual_edge_detector.
--! This architecture uses Moore's finite state machine.
--! States of the machine are: zero, edge and one.
--! state zero is entered in when strobe_i has value of '0' and current state is either zero or edge.
--! state one is entered in when strobe_i has value of '1' and current state is either one or edge.
--! state edge is entered in when strobe_i the current state is one and the value '0' or when state is zero and the value is '1'
--! During the edge state output is high, meaning an edge is detected, otherwise it's low.
--! States of the machine have been coded with almost one-shot coding achieving
--! more efficient solution which uses two registers instead of three.
architecture arch of dual_edge_detector is

  type mc_sm_type is
    (zero, edge, one);
  attribute enum_encoding : string;
  attribute enum_encoding of mc_sm_type : type is "00 01 10";
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
  end process;

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
      when one =>
        if strobe_i = '0' then
          state_next <= edge;
        else
          state_next <= one;
        end if;
      when edge =>
        if strobe_i = '1' then
          state_next <= one;
        else
          state_next <= zero;
        end if;
    end case;
  end process;

  --! Output logic
  process(state_reg)
  begin
    case state_reg is
      when zero =>
        p_o <= '0';
      when one =>
        p_o <= '0';
      when edge =>
        p_o <= '1';
    end case;
  end process;
end arch;
