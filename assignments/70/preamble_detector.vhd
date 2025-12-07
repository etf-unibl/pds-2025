-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     preamble_detector
--
-- description:   Preamble detector for a serial bit stream.
--                Implements a Moore state machine that monitors the
--                serial input data_i and generates a one clock cycle
--                pulse on match_o whenever the bit sequence "10101010"
--                is detected.
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
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
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
-- OTHER DEALINGS IN THE SOFTWARE.
-----------------------------------------------------------------------------
--! @file preamble_detector.vhd
--! @brief Preamble detector for a serial bit stream.
--! @details
--!   Implements a Moore state machine that monitors the serial input
--!   data_i and generates a one clock cycle pulse on match_o whenever
--!   the bit sequence "10101010" is detected.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Entity of the preamble detector.
--! @details
--!   The entity defines a synchronous clock input, asynchronous reset,
--!   serial data input and an output pulse that indicates successful
--!   preamble detection.
entity preamble_detector is
  port (
    clk_i   : in  std_logic;  --! Clock input. The rising edge is used to sample data_i and update the FSM state.
    rst_i   : in  std_logic;  --! Asynchronous active-high reset that returns the FSM to the initial state S0.
    data_i  : in  std_logic;  --! Serial input bit stream that is monitored for the preamble "10101010".
    match_o : out std_logic   --! Output pulse that is '1' for exactly one clock cycle after the preamble has been received.
  );
end preamble_detector;

--! @brief Implementation of the Moore state machine.
--! @details
--!   The architecture uses nine states (S0 to S8) to track partial matches
--!   of the preamble "10101010". State S8 represents a complete match and
--!   is the only state in which match_o is asserted.
architecture arch of preamble_detector is

  --! @brief FSM state type.
  --! @details
  --!   Each state encodes how many of the most recent input bits match
  --!   the prefix of the preamble "10101010".
  type t_state is
    (S0, S1, S2, S3, S4, S5, S6, S7, S8);

  --! Registers holding the current and next FSM state.
  signal state_reg  : t_state;
  signal state_next : t_state;
  signal match_int : std_logic;
  signal match_reg : std_logic;

begin

  --! @brief State register.
  --! @details
  --!   On the rising edge of clk_i the current state is updated with
  --!   state_next. When rst_i is '1', the FSM is reset to S0.
  state_register : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= S0;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process state_register;

  --! @brief Combinational next-state and output logic.
  --! @details
  --!   Computes state_next and match_o based on the current state
  --!   and the input bit data_i. The output match_o is asserted
  --!   only in state S8.
  next_state_logic : process (state_reg, data_i)
  begin
    -- default values
    state_next <= state_reg;
    match_int    <= '0';

    case state_reg is

      when S0 =>
        if data_i = '1' then
          state_next <= S1;
        else
          state_next <= S0;
        end if;

      when S1 =>
        if data_i = '0' then
          state_next <= S2;
        else
          state_next <= S1;
        end if;

      when S2 =>
        if data_i = '1' then
          state_next <= S3;
        else
          state_next <= S0;
        end if;

      when S3 =>
        if data_i = '0' then
          state_next <= S4;
        else
          state_next <= S1;
        end if;

      when S4 =>
        if data_i = '1' then
          state_next <= S5;
        else
          state_next <= S0;
        end if;

      when S5 =>
        if data_i = '0' then
          state_next <= S6;
        else
          state_next <= S1;
        end if;

      when S6 =>
        if data_i = '1' then
          state_next <= S7;
        else
          state_next <= S0;
        end if;

      when S7 =>
        if data_i = '0' then
          state_next <= S8;
          match_int  <= '1';
        else
          state_next <= S1;
        end if;

      when S8 =>
        if data_i = '1' then
          state_next <= S7;
        else
          state_next <= S0;
        end if;

      when others =>
        state_next <= S0;

    end case;
  end process next_state_logic;
  output_reg : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      match_reg <= '0';
    elsif rising_edge(clk_i) then
      match_reg <= match_int;
    end if;
  end process output_reg;
  match_o <= match_reg;

end arch;
