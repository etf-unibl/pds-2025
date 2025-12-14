-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     sequential_divider
--
-- description:
--
--   This file implements an 8-bit sequential divider using the Repeated
--   Subtraction algorithm. Dividing by zero results in NaN value for
--   both the quotient and the remainder.
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
--! @file sequential_divider.vhd
--! @brief Implements an 8-bit sequential divider using the Repeated
--  Subtraction algorithm.
--! @details Dividing by zero results in NaN value for both the quotient and
--  the remainder. The NaN value equals 255.
-----------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
--! Use numeric types (signed/unsigned) and arithmetic operators (+, -, <, >=)
use ieee.numeric_std.all;

--! @brief Entity definition of sequential_divider.
entity sequential_divider is
  port (
    clk_i   : in  std_logic; --! Clock input
    rst_i   : in  std_logic; --! Reset input (active when '1')
    start_i : in  std_logic; --! Start algorithm input (active when '1')
    a_i     : in  std_logic_vector(7 downto 0); --! Dividend input
    b_i     : in  std_logic_vector(7 downto 0); --! Divisor input
    q_o     : out std_logic_vector(7 downto 0); --! Quotient output
    r_o     : out std_logic_vector(7 downto 0); --! Remainder output
    ready_o : out std_logic  --! Output ready signal (output stable when '1')
);
end sequential_divider;

--! @brief Architecture implementing the sequential divider logic.
architecture arch of sequential_divider is
  --! @brief Constant representing number of bits in input and output data.
  constant c_WIDTH       : integer := 8;
  --! @brief Constant representing Not a Number value in case of dividing by zero.
  --! @details It has 255 value for unsigned 8-bit data.
  constant c_NAN         : unsigned(c_WIDTH-1 downto 0) := to_unsigned(255, c_WIDTH);
  --! @brief Type that represents possible states of sequential divider (based on FSM).
  type t_state_type is (idle, check_and_load, op);
  --! @brief Registers for current and next states of the FSM.
  signal state_reg, state_next : t_state_type;
  --! @brief Flag indicating if divisor is zero.
  signal b_is_0                : std_logic;
  --! @brief Flag indicating if subtraction should stop.
  signal count_0               : std_logic;
  --! @brief Registers for divisor, remainder and quotient, respectively.
  signal b_reg, b_next         : unsigned(c_WIDTH-1 downto 0);
  signal rm_reg, rm_next       : unsigned(c_WIDTH-1 downto 0);
  signal q_reg, q_next         : unsigned(c_WIDTH-1 downto 0);
  --! @brief Connections for functional units outputs.
  signal inc_out               : unsigned(c_WIDTH-1 downto 0);
  signal sub_out               : unsigned(c_WIDTH-1 downto 0);
begin
  --! @brief FSM state register process (control path).
  --! @details Updates current state on rising clock edge or resets to idle.
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process;
  --! @brief FSM next-state and output logic (control path).
  --! @details Determines next state based on current state, start signal and flags.
  process (state_reg, b_is_0, start_i, count_0)
  begin
    case state_reg is
      when idle =>
        if start_i = '1' then
          state_next <= check_and_load;
        else
          state_next <= idle;
        end if;
      when check_and_load =>
        if b_is_0 = '1' then
          state_next <= idle;
        else
          state_next <= op;
        end if;
      when op =>
        if count_0 = '1' then
          state_next <= idle;
        else
          state_next <= op;
        end if;
    end case;
  end process;
  --! @brief Output logic (control path).
  --! @details Indicates when output is stable (FSM in idle state).
  ready_o <= '1' when state_reg = idle else '0';
  --! @brief Data register process (data path).
  --! @details Updates divisor, remainder and quotient registers on rising clock edge.
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      b_reg <= (others => '0');
      rm_reg <= (others => '0');
      q_reg <= (others => '0');
    elsif rising_edge(clk_i) then
      b_reg <= b_next;
      rm_reg <= rm_next;
      q_reg <= q_next;
    end if;
  end process;
  --! @brief Data path routing multiplexer process.
  --! @details Determines next values for registers based on FSM state.
  process(state_reg, b_reg, rm_reg, q_reg,
              a_i, b_i, inc_out, sub_out, b_is_0)
  begin
    --! Defaults: hold values.
    b_next <= b_reg;
    rm_next <= rm_reg;
    q_next <= q_reg;
    case state_reg is
      when idle =>
        b_next <= b_reg;
        rm_next <= rm_reg;
        q_next <= q_reg;
      when check_and_load =>
        if unsigned(b_i) = 0 then
          q_next  <= c_NAN;
          rm_next <= c_NAN;
        else
          b_next <= unsigned(b_i);
          rm_next <= unsigned(a_i);
          q_next <= (others => '0');
        end if;
      when op =>
        b_next <= b_reg;
        if count_0 = '1' then
          rm_next <= rm_reg;
          q_next <= q_reg;
        else
          rm_next <= sub_out;
          q_next <= inc_out;
        end if;
    end case;
  end process;
  --! @brief Functional units (data path).
  --! @details Performs subtraction (remainder - divisor) and quotient increment.
  sub_out  <= rm_reg - b_reg;
  inc_out  <= q_reg + 1;
  --! @brief Status signals.
  --! @details Flags for divisor zero check and operation completion.
  b_is_0   <= '1' when unsigned(b_i) = 0 else '0';
  count_0  <= '1' when rm_reg < b_reg else '0';
  --! @brief Output logic (data path).
  --! @details Converts internal unsigned registers to std_logic_vector outputs.
  q_o <= std_logic_vector(q_reg);
  r_o <= std_logic_vector (rm_reg);
end arch;
