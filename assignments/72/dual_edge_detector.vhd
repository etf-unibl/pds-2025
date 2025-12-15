-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     multi_function_aritmetic_unit
--
-- description:
--
--   This unit implements a dual-edge detector for the input signal strobe_i.
--   The circuit generates a single-clock-cycle pulse on
--   output p_o whenever a transition on strobe_i is detected:
--     - rising edge  (0 -> 1)
--     - falling edge (1 -> 0)
--   The design is modeled as a two-state finite state machine (Mealy-type).
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

--! @file dual_edge_detector.vhd
--! @brief Dual-edge detector entity
--! @details
--! Defines the interface for detecting rising and falling edges on strobe_i.

library ieee;
use ieee.std_logic_1164.all;

--! @brief Entity definition of dual_edge_detector
entity dual_edge_detector is
  port (
  clk_i    : in  std_logic; --! System clock.
  rst_i    : in  std_logic; --! Active-high reset
  strobe_i : in  std_logic; --! Input signal whose edges are detected
  p_o      : out std_logic  --! Output signal asserted on any edge of input signal
);
end dual_edge_detector;

--! @brief Architecture implementation of the dual-edge detector
--! @details
--! Implements a two-state Mealy FSM:
--! - state "zero" represents strobe_i = '0'
--! - state "one"  represents strobe_i = '1'
architecture arch of dual_edge_detector is
  type t_state is
    (zero, one);
  signal state_reg, state_next : t_state;
begin
  --! @brief State register
  --! @details
  --! - On rst_i='1' the FSM is initialized to state "zero"
  --! - On rising edge of clk_i the FSM state updates to state_next
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= zero;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process;

  --! @brief Next-state logic
  --! @details
  --! Combinational transition logic:
  --! - from "zero" go to "one" when strobe_i becomes '1'
  --! - from "one"  go to "zero" when strobe_i becomes '0'
  process(state_reg, strobe_i)
  begin
    case state_reg is
      when zero =>
        if strobe_i = '1' then
          state_next <= one;
        else
          state_next <= zero;
        end if;
      when one =>
        if strobe_i = '0' then
          state_next <= zero;
        else
          state_next <= one;
        end if;
    end case;
  end process;

  --! @brief Mealy output logic.
  --! @details
  --! Output pulse generation (Mealy FSM):
  --! - p_o='1' when state_reg indicates previous level and strobe_i indicates
  --!   opposite level (an edge is present)
  --! - otherwise p_o='0'
  process(state_reg, strobe_i)
  begin
    if state_reg = zero and strobe_i = '1' then
      p_o <= '1';
    elsif state_reg = one and strobe_i = '0' then
      p_o <= '1';
    else
      p_o <= '0';
    end if;
  end process;
end arch;
