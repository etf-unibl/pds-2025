-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     nrzi_decoder
--
-- description:
--
--   This file implements a NRZI decoding circuit.
--
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
--! @file nrzi_decoder.vhd
--! @brief NRZI (Non-Return to Zero Invert to ones) decoder
--! @details Implements a Moore FSM for NRZI decoding with four states,
--!          distinguishing between input transition and no-transition conditions
-----------------------------------------------------------------------------


--! Use standard library
library IEEE;
--! Use logic elements
use IEEE.STD_LOGIC_1164.all;

--! @brief Entity definition of nrzi_decoder
entity nrzi_decoder is
  port (
    clk_i  : in  std_logic; --! Input clock
    rst_i  : in  std_logic; --! Active-high reset
    data_i : in  std_logic; --! NRZI encoded input
    data_o : out std_logic  --! Decoded output
  );
end nrzi_decoder;

--! @brief Architecture implementing the nrzi_decoder logic
--! @details Defines states and registers, applies clk signal.
--!          Implements register-state, next-state logic and output-logic
architecture arch of nrzi_decoder is

  --! @brief Type that represents possible states of nrzi_decoder
  --! @details FSM states: S_<line_level>_<change_flag>
  --!          S0_NC: Input level '0', no change detected -> output '0'
  --!          S1_NC: Input level '1', no change detected -> output '0'
  --!          S0_C : Input level '0', change detected -> output '1'
  --!          S1_C : Input level '1', change detected -> output '1'
  type t_state is (S0_NC, S1_NC, S0_C, S1_C);

  --! @brief Registers for current and next states of the FSM
  signal current_state, next_state : t_state;

begin

  --! @brief State register
  --! @details Updates current state on rising edge of clk signal or resets to default state
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      current_state <= S0_NC;
    elsif rising_edge(clk_i) then
      current_state <= next_state;
    end if;
  end process;

  --! @brief Next-state logic
  --! @details Determines next FSM state based on current state and input data
  process(current_state, data_i)
  begin
    next_state <= current_state;

    case current_state is

      when S0_NC | S0_C =>
        if data_i = '0' then
          next_state <= S0_NC;
        else
          next_state <= S1_C;
        end if;

      when S1_NC | S1_C =>
        if data_i = '1' then
          next_state <= S1_NC;
        else
          next_state <= S0_C;
        end if;

    end case;
  end process;

  --! @brief Moore output logic
  --! @details For states with change occurred output is '1' and in other cases output is '0'
  process(current_state)
  begin
    data_o <= '0';

    case current_state is
      when S0_C =>
        data_o <= '1';
      when S1_C =>
        data_o <= '1';
      when others =>
        data_o <= '0';
    end case;
  end process;

end arch;
