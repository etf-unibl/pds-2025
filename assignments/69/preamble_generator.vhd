-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     preamble_generator
--
-- description:
--
--   This file implements a preamble generation e.g. generation of the
--   following sequence: "10101010" on 1bit output.
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
--! @file preamble_generator.vhd
--! @brief implements the generation of the following sequence: 10101010
--! on rising edge of start_i

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--! @brief Entity definition of preamble_generator.
--! @details Unit implements preamble_generator that is synchronous with the clock.
--! Whenever start_i changes from low to high, the output will generate the following sequence
--! in the next 8 cycles: 10101010
--! When rst_i is invoked, the system asynchronously goes to the idle state
entity preamble_generator is
  port (
     clk_i   : in  std_logic; --! @brief Clock input of the unit.
     rst_i   : in  std_logic; --! @brief Reset input of the unit.
     start_i : in  std_logic; --! @brief The input which starts the sequence generation.
     data_o  : out std_logic  --! @brief Single bit output which generates one symbol per clock cycle
  );
end preamble_generator;
--! @brief Look-ahead buffer architecture for the preamble_generator.
--! @details Implements a Moore-type finite state machine (FSM) that outputs an
--! alternating 1/0 preamble sequence ("10101010"). The architecture uses:
--! - A state register (state_reg)
--! - A next-state FSM (state_next)
--! - A one-cycle look-ahead output buffer (buf_reg)
--! The FSM transitions through a fixed sequence of states once start_i is
--! asserted. Each state corresponds to a specific output bit.
architecture arch of preamble_generator is
  type t_mc_sm_type is
    (idle, state_00, state_10, state_01, state_02, state_03, state_11, state_12, state_13);
  signal state_reg, state_next : t_mc_sm_type;
  signal buffered_data, buf_reg : std_logic;
begin
  --! @brief state register
  state : process(clk_i,rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process state;
  --! buffer register
  output_buffer : process(clk_i,rst_i)
  begin
    if rst_i = '1' then
      buf_reg <= '0';
    elsif rising_edge(clk_i) then
      buf_reg <= buffered_data;
    end if;
  end process output_buffer;
  --! @brief next-state logic
  next_state : process(state_reg,start_i)
  begin
    case state_reg is
      when idle =>
        if start_i = '1' then
          state_next <= state_10;
        else
          state_next <= idle;
        end if;
      when state_10 =>
        state_next <= state_00;
      when state_00 =>
        state_next <= state_11;
      when state_11 =>
        state_next <= state_01;
      when state_01 =>
        state_next <= state_12;
      when state_12 =>
        state_next <= state_02;
      when state_02 =>
        state_next <= state_13;
      when state_13 =>
        state_next <= state_03;
      when state_03 =>
        state_next <= idle;
    end case;
  end process next_state;
  --! @brief look-ahead output logic
  look_ahead : process(state_next)
  begin
    buffered_data <= '0';
    case state_next is
      when idle =>
        buffered_data <= '0';
      when state_10 =>
        buffered_data <= '1';
      when state_00 =>
        buffered_data <= '0';
      when state_11 =>
        buffered_data <= '1';
      when state_01 =>
        buffered_data <= '0';
      when state_12 =>
        buffered_data <= '1';
      when state_02 =>
        buffered_data <= '0';
      when state_13 =>
        buffered_data <= '1';
      when state_03 =>
        buffered_data <= '0';
    end case;
  end process look_ahead;
  --! @brief output logic
  data_o <= buf_reg;
end arch;
