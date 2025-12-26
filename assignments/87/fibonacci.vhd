-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     fibonacci
--
-- description:
--
--   This file implements a sequential Fibonacci number generator
--   based on an RT-level design methodology.
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
--! @file fibonacci.vhd
--! @brief Sequential Fibonacci number generator
--! @details This module generates Fibonacci numbers using an iterative
--! register-transfer (RT) based architecture.
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Entity definition of fibonacci
entity fibonacci is
  port (
    clk_i   : in  std_logic;                      --! Input clock
    rst_i   : in  std_logic;                      --! Active-high reset
    start_i : in  std_logic;                      --! Start computation
    n_i     : in  std_logic_vector(5 downto 0);   --! Sequence length
    r_o     : out std_logic_vector(42 downto 0);  --! Fibonacci result
    ready_o : out std_logic                       --! Ready flag
  );
end fibonacci;

--! @brief Architecture implementing the fibonacci logic
architecture arch of fibonacci is

  --! @brief Internal data width
  constant c_WIDTH : integer := 21;

  --! @brief Type that represents possible states of fibonacci
  type t_state is (S_IDLE, S_INIT, S_CALC);

  --! @brief FSM registers
  signal cs_reg, ns_next : t_state := S_IDLE;

  --! @brief Datapath registers
  signal prev_reg, prev_next : unsigned(2*c_WIDTH downto 0);
  signal curr_reg, curr_next : unsigned(2*c_WIDTH downto 0);
  signal cnt_reg,  cnt_next  : unsigned(5 downto 0);

  --! @brief Datapath signals
  signal sum_val  : unsigned(2*c_WIDTH downto 0);
  signal dec_cnt  : unsigned(5 downto 0);

  --! @brief Status signals
  signal last_iter : std_logic;
  signal n_zero    : std_logic;

begin

  --! @brief State register
  --! @details Updates current state on rising edge of clk signal or resets to default state
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      cs_reg <= S_IDLE;
    elsif rising_edge(clk_i) then
      cs_reg <= ns_next;
    end if;
  end process;

  --! @brief Next-state logic
  --! @details Implements Moore-type finite state machine control.
  --! The next state is determined based on the current state and
  --! internal status signals, while outputs depend only on the current state
  process(cs_reg, start_i, last_iter, n_zero)
  begin
    case cs_reg is
      when S_IDLE =>
        if start_i = '1' and n_zero = '0' then
          ns_next <= S_INIT;
        else
          ns_next <= S_IDLE;
        end if;

      when S_INIT =>
        ns_next <= S_CALC;

      when S_CALC =>
        if last_iter = '1' then
          ns_next <= S_IDLE;
        else
          ns_next <= S_CALC;
        end if;

      when others =>
        ns_next <= S_IDLE;
    end case;
  end process;

  --! @brief Moore output logic
  --! @details Generates output signals based solely on the current FSM state.
  --! The ready_o signal is asserted when the FSM is in the idle state,
  --! indicating that the module is ready to accept a new start command
  ready_o <= '1' when cs_reg = S_IDLE else '0';

  --! @brief Datapath registers
  --! @details Determines next values for registers based on FSM state
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      prev_reg <= (others => '0');
      curr_reg <= (others => '0');
      cnt_reg  <= (others => '0');
    elsif rising_edge(clk_i) then
      prev_reg <= prev_next;
      curr_reg <= curr_next;
      cnt_reg  <= cnt_next;
    end if;
  end process;

  --! @brief Datapath routing logic
  --! @details Selects register update values depending on the current FSM state
  process(cs_reg, prev_reg, curr_reg, cnt_reg, sum_val, dec_cnt, n_i)
  begin
    prev_next <= prev_reg;
    curr_next <= curr_reg;
    cnt_next  <= cnt_reg;

    case cs_reg is
      when S_IDLE =>
        prev_next <= prev_reg;
        curr_next <= curr_reg;
        cnt_next  <= cnt_reg;

      when S_INIT =>
        prev_next <= (others => '0');
        curr_next <= (0 => '1', others => '0');
        cnt_next  <= unsigned(n_i);

      when S_CALC =>
        prev_next <= curr_reg;
        curr_next <= sum_val;
        cnt_next  <= dec_cnt;

      when others =>
        prev_next <= (others => '0');
        curr_next <= (others => '0');
        cnt_next  <= (others => '0');
    end case;
  end process;

  --! @brief Functional units
  --! The adder computes the next Fibonacci value, while the decrementer updates
  --! the iteration counter
  sum_val <= prev_reg + curr_reg;
  dec_cnt <= cnt_reg - 1;

  --! @brief Status logic
  --! @details Generates internal status flags for detection of special conditions
  --! such as zero input or last iteration
  n_zero    <= '1' when n_i = "000000" else '0';
  last_iter <= '1' when cnt_next = "000001" else '0';

  --! @brief Output assignment
  --! @details Connects the internal datapath result register to the module output.
  --! The output remains stable until a new computation is started
  r_o <= std_logic_vector(curr_reg);

end arch;
