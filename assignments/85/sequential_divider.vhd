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
--   This unit implements an 8-bit unsigned sequential divider using the
--   long-division algorithm. The division is performed bit-by-bit,
--   starting from the MSB of the dividend and progressing to the LSB.
--
--   Operation:
--     - When start_i = '1' (in idle state), inputs a_i and b_i are sampled.
--     - The divider runs for 8 iterations(one per clock cycle in state divide).
--     - During computation ready_o = '0'. When done, FSM returns to idle and
--       ready_o = '1'. Final outputs are valid when ready_o = '1'.
--
--   Special cases:
--     - Division by zero (b_i = 0):
--         q_o = 255 (0xFF), r_o = 255 (0xFF)
--     - Dividend smaller than divisor (a_i < b_i):
--         q_o = 0, r_o = a_i
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

--! @file sequential_divider.vhd
--! @brief Sequential 8-bit unsigned divider (long-division algorithm)
--! @details
--! Implements a sequential divider using a long-division algorithm.
--! One quotient bit is produced per clock cycle. Outputs are considered valid
--! when ready_o = '1' (idle state).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Entity definition of sequential_divider
entity sequential_divider is
  port (
    clk_i   : in  std_logic; --! System clock
    rst_i   : in  std_logic; --! Active-high reset
    start_i : in  std_logic; --! Start pulse to begin division
    a_i     : in  std_logic_vector(7 downto 0); --! Unsigned dividend input
    b_i     : in  std_logic_vector(7 downto 0); --! Unsigned divisor input
    q_o     : out std_logic_vector(7 downto 0); --! Unsigned quotient output
    r_o     : out std_logic_vector(7 downto 0); --! Unsigned remainder outpu
    ready_o : out std_logic
);
end sequential_divider;

--! @brief Architecture implementation of the sequential divider
--! @details
--! FSM states:
--! - idle  : waiting for start_i (ready_o='1')
--! - load  : latches inputs and initializes datapath
--! - divide: performs one long-division iteration per clock cycle (8 cycles)
--! - done  : handles special cases and then returns to idle

architecture arch of sequential_divider is

  --! @brief Divider FSM states
  type t_state is (idle, load, divide, done);

  signal state_reg, state_next                         : t_state; --! Current and next FSM state
  signal a_reg, a_next                                 : unsigned(7 downto 0); --! dividend
  signal b_reg, b_next                                 : unsigned(7 downto 0); --! divisor
  signal q_reg, q_next                                 : unsigned(7 downto 0); --! quotient
  signal r_reg, r_next                                 : unsigned(8 downto 0); --! remainder register (9-bit for shift-in)
  signal iteration_reg, iteration_next                 : unsigned(3 downto 0); --! Bit index counter (7 downto 0)
  signal divisor_is_0                                  : std_logic; --! Flag: b_i == 0
  signal count_is_0                                    : std_logic; --! Flag: iteration_reg == 0
  signal dividend_lt_divisor                           : std_logic; --! Flag: a_i < b_i
begin

-----------------------------------------------------------------------------
  -- CONTROL PATH
-----------------------------------------------------------------------------

  --! @brief State register
  --! @details
  --! - On rst_i='1' the FSM is initialized to state idle
  --! - On rising edge of clk_i the FSM state updates to state_next
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process;

  --! @brief Next-state logic
  --! @details
  --! - idle  -> load  when start_i='1'
  --! - load  -> done  for special cases (b=0 or a<b), else -> divide
  --! - divide-> done  after last iteration (bit 0 processed)
  --! - done  -> idle
  process(state_reg, start_i, a_i, b_i, count_is_0, divisor_is_0, dividend_lt_divisor)
  begin
    case state_reg is
      when idle =>
        if start_i = '1' then
          state_next <= load;
        else
          state_next <= idle;
        end if;
      when load =>
        if divisor_is_0 = '1' or dividend_lt_divisor = '1' then -- divide by 0
          state_next <= done;
        else
          state_next <= divide;
        end if;
      when divide =>
        if count_is_0 = '1' then
          state_next <= done;
        else
          state_next <= divide;
        end if;
      when done =>
        state_next <= idle;
    end case;
  end process;

  --! @brief Ready output
  --! @details Divider is ready when in idle state.
  ready_o <= '1' when state_reg = idle else '0';

-----------------------------------------------------------------------------
  -- DATA PATH
-----------------------------------------------------------------------------
  --! @brief Datapath registers
  process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      a_reg         <= (others => '0');
      b_reg         <= (others => '0');
      q_reg         <= (others => '0');
      r_reg         <= (others => '0');
      iteration_reg <= (others => '0');
    elsif rising_edge(clk_i) then
      a_reg         <= a_next;
      b_reg         <= b_next;
      q_reg         <= q_next;
      r_reg         <= r_next;
      iteration_reg <= iteration_next;
    end if;
  end process;

  --! @brief Datapath routing and long-division iteration logic
  --! @details
  --! One iteration performs:
  --! 1) Shift remainder left and bring in next dividend bit.
  --! 2) Compare shifted remainder with divisor:
  --!    - if remainder >= divisor: subtract divisor and set quotient bit to 1
  --!    - else: keep remainder and set quotient bit to 0

  p_next_state : process(state_reg, a_reg, b_reg, q_reg, r_reg, iteration_reg, a_i, b_i, divisor_is_0, dividend_lt_divisor)
    variable idx     : integer; --! Current bit index of dividend
    variable r_shift : unsigned(8 downto 0); --! Shifted remainder candidate
    variable b_ext   : unsigned(8 downto 0); --! 9-bit extended divisor
    variable qv      : unsigned(7 downto 0); --! Local quotient copy
  begin
    a_next         <= a_reg;
    b_next         <= b_reg;
    q_next         <= q_reg;
    r_next         <= r_reg;
    iteration_next <= iteration_reg;
    case state_reg is
      when idle =>
      when load =>
        --! Latch inputs and initialize working registers
        a_next         <= unsigned(a_i);
        b_next         <= unsigned(b_i);
        q_next         <= (others => '0');
        r_next         <= (others => '0');
        iteration_next <= "0111";
      when divide =>
        idx     := to_integer(iteration_reg); --! Current dividend bit index
        b_ext   := '0' & b_reg; --! Extend divisor to 9 bits
        r_shift := r_reg(7 downto 0) & a_reg(idx); --! Shift remainder left, bring in the current dividend bit
        qv      := q_reg; --! Start from current quotient value and update one bit

        --! Restoring step: compare and (optionally) subtract
        if r_shift >= b_ext then
          r_next  <= r_shift - b_ext;
          qv(idx) := '1';
        else
          r_next  <= r_shift;
          qv(idx) := '0';
        end if;

        q_next <= qv;

        --! Decrement iteration counter until reaching 0
        if iteration_reg > 0 then
          iteration_next <= iteration_reg - 1;
        end if;
      when done =>
        --! Handle special cases
        if divisor_is_0 = '1' then
          --! Division by zero => NaN encoding (255/255)
          q_next <= (others => '1');
          r_next <= (others => '1');
        elsif dividend_lt_divisor = '1' then
          --! a < b => quotient = 0, remainder = a
          q_next <= (others => '0');
          r_next <= '0' & a_reg;
        end if;
    end case;
  end process p_next_state;

  --! @brief Status flags
  --! @details
  --! - divisor_is_0: used to select NaN result
  --! - dividend_lt_divisor: used for early exit case q=0, r=a
  --! - count_is_0: indicates last iteration (bit 0)
  divisor_is_0        <= '1' when b_i = "00000000" else '0';
  dividend_lt_divisor <= '1' when unsigned(a_i) < unsigned(b_i) else '0';
  count_is_0          <= '1' when iteration_reg = 0 else '0';

  --! @brief Outputs
  --! @details
  --! q_o is the quotient register, r_o is the lower 8 bits of the remainder register.

  q_o <= std_logic_vector(q_reg);
  r_o <= std_logic_vector(r_reg(7 downto 0));

end arch;
