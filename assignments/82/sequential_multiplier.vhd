-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     sequential_multiplier
--
-- description:
--
--   This file implements a sequential multiplier with add-shift method.
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
use ieee.numeric_std.all;

--! @file sequential_multiplier.vhd
--! @brief 8-bit sequential multiplier
--! @details Implements a sequential multiplier using a simple FSM with three states (idle, compute, shift).
--!          The design uses registers for operands and product, and a counter to track shifts.


entity sequential_multiplier is
  --! @brief Entity port definitions
  port (
    clk_i   : in  std_logic;                     --! Input clock signal
    rst_i   : in  std_logic;                     --! Active-high synchronous reset
    start_i : in  std_logic;                     --! Start signal for multiplication
    a_i     : in  std_logic_vector(7 downto 0);  --! Multiplicand
    b_i     : in  std_logic_vector(7 downto 0);  --! Multiplier
    c_o     : out std_logic_vector(15 downto 0); --! Product output
    ready_o : out std_logic                      --! High when multiplication is done
  );
end entity sequential_multiplier;

--! @brief Architecture arch for sequential multiplier
--! @details Includes FSM control logic, datapath registers, routing multiplexer, functional units, and output logic
architecture arch of sequential_multiplier is

  --! @brief Constant definitions
  constant c_WIDTH : integer := 8; --! Width of operands
  constant c_CNT_W : integer := 4; --! Width of shift counter

  --! @brief FSM state type
  type t_state is (idle, compute, shift); --! FSM states
  signal state_reg, state_next : t_state; --! Current and next FSM states

  --! @brief Datapath registers
  signal a_reg, a_next : unsigned(15 downto 0);            --! Multiplicand register
  signal b_reg, b_next : unsigned(7 downto 0);             --! Multiplier register
  signal p_reg, p_next : unsigned(15 downto 0);            --! Product register
  signal cnt_reg, cnt_next : unsigned(c_CNT_W-1 downto 0); --! Shift counter

  --! @brief Functional unit signals
  signal p_add   : unsigned(15 downto 0);        --! Adder output for partial product
  signal a_shift : unsigned(15 downto 0);        --! Shifted multiplicand
  signal b_shift : unsigned(7 downto 0);         --! Shifted multiplier
  signal cnt_dec : unsigned(c_CNT_W-1 downto 0); --! Decremented counter

begin

  --! @brief Control path : state registers
  state_registers : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process state_registers;

  --! @brief Control path : next state logic
  next_state_logic : process(state_reg, start_i, cnt_reg)
  begin
    state_next <= state_reg;
    case state_reg is
      when idle =>
        if start_i = '1' then
          state_next <= compute;
        end if;
      when compute =>
        state_next <= shift;
      when shift =>
        if cnt_reg = 0 then
          state_next <= idle;
        else
          state_next <= compute;
        end if;
    end case;
  end process next_state_logic;

  --! @brief Control path : output logic
  ready_o <= '1' when state_reg = idle else '0';

  --! @brief Data path : routing network
  routing_multiplexer : process(state_reg, start_i, a_reg, b_reg, p_reg, cnt_reg,
                           a_i, b_i, p_add, a_shift, b_shift, cnt_dec)
  begin
    a_next   <= a_reg;
    b_next   <= b_reg;
    p_next   <= p_reg;
    cnt_next <= cnt_reg;

    case state_reg is
      when idle =>
        if start_i = '1' then
          if a_i = "00000000" or b_i = "00000000" then
            p_next   <= (others => '0');
            cnt_next <= (others => '0');
          else
            a_next   <= "00000000" & unsigned(a_i);
            b_next   <= unsigned(b_i);
            p_next   <= (others => '0');
            cnt_next <= to_unsigned(c_WIDTH-1, c_CNT_W);
          end if;
        end if;
      when compute =>
        if b_reg(0) = '1' then
          p_next <= p_add;
        end if;
      when shift =>
        a_next   <= a_shift;
        b_next   <= b_shift;
        cnt_next <= cnt_dec;
    end case;
  end process routing_multiplexer;

  --! @brief Data path : data registers
  data_registers : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      a_reg   <= (others => '0');
      b_reg   <= (others => '0');
      p_reg   <= (others => '0');
      cnt_reg <= (others => '0');
    elsif rising_edge(clk_i) then
      a_reg   <= a_next;
      b_reg   <= b_next;
      p_reg   <= p_next;
      cnt_reg <= cnt_next;
    end if;
  end process data_registers;

  --! @brief Data path : funtional units
  p_add   <= p_reg + a_reg;
  a_shift <= a_reg(14 downto 0) & '0';
  b_shift <= '0' & b_reg(7 downto 1);
  cnt_dec <= cnt_reg - 1;

  --! @brief Data path : data output
  c_o     <= std_logic_vector(p_reg);

end architecture arch;
