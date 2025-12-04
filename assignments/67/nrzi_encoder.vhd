-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     nrzi_encoder
--
-- description:
--
--   This file implements a NRZI(Non-return-to-zero) encoding.
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
library ieee;
use ieee.std_logic_1164.all;

 --! @file nrzi_encoder.vhd
 --! @brief NRZI (Non-Return-to-Zero Inverted) encoder
 --! @details Implements a Moore FSM NRZI encoder. Output changes only on input '1'.
 --! The encoder has two states (S0, S1) representing the current output logic level.

entity nrzi_encoder is
  port (
    clk_i  : in  std_logic;  --! Input clock signal
    rst_i  : in  std_logic;  --! Active-high synchronous reset
    data_i : in  std_logic;  --! Input data signal
    data_o : out std_logic   --! NRZI encoded output
  );
end nrzi_encoder;

--! @brief Architecture arch for NRZI encoder
--! @details Includes next-state logic, output logic, and state register updates
architecture arch of nrzi_encoder is
  --! @brief Internal signal declarations
  type t_state is (S0, S1);               --! @brief FSM states
  signal state_reg, state_next : t_state; --! @brief Current and next state signals of Moore machine
  signal data_o_next : std_logic;         --! @brief Next output value

begin

  --! @brief Next-state logic
  --! @details Determines the next FSM state based on current state and input
  process(state_reg, data_i)
  begin
    case state_reg is
      when S0 =>
        if data_i = '1' then
          state_next <= S1;
        else
          state_next <= S0;
        end if;
      when S1 =>
        if data_i = '1' then
          state_next <= S0;
        else
          state_next <= S1;
        end if;
    end case;
  end process;

  --! @brief Moore output logic
  --! @details Output is a function of next state (look-ahead Moore)
  process(state_next)
  begin
    case state_next is
      when S0 => data_o_next <= '0';
      when S1 => data_o_next <= '1';
    end case;
  end process;

  --! @brief State register and output update
  --! @details Registers are updated on rising clock edge or reset
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= S0;
      data_o   <= '0';
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
      data_o   <= data_o_next;
    end if;
  end process;

end architecture arch;
