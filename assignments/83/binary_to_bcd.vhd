-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     binary_to_bcd
--
-- description:   Sequential converter from a 13-bit binary number to a
--                4-digit BCD representation. Implements the classic
--                shift-add-3 (double dabble) algorithm using RT design
--                methodology with a separated control and data path.
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
--! @file    binary_to_bcd.vhd
--! @brief   Binary-to-BCD converter (13-bit to 4-digit BCD).
--! @details
--!  This unit converts a 13-bit unsigned binary input value into a
--!  4-digit BCD representation using the shift-add-3 (double dabble)
--!  algorithm. The design follows RT methodology with a control FSM and a separate data path.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief   Entity for binary-to-BCD conversion.
entity binary_to_bcd is
  port(
    --! System clock (rising-edge active).
    clk_i    : in  std_logic;
    --! Asynchronous reset, active high.
    rst_i    : in  std_logic;
    --! Start pulse to begin conversion.
    start_i  : in  std_logic;
    --! 13-bit unsigned binary input value.
    binary_i : in  std_logic_vector(12 downto 0);
    --! BCD digit: ones (least significant decimal digit).
    bcd1_o   : out std_logic_vector(3 downto 0);
    --! BCD digit: tens.
    bcd2_o   : out std_logic_vector(3 downto 0);
    --! BCD digit: hundreds.
    bcd3_o   : out std_logic_vector(3 downto 0);
    --! BCD digit: thousands (most significant decimal digit).
    bcd4_o   : out std_logic_vector(3 downto 0);
    --! Ready: '1' when the unit is idle and result is valid.
    ready_o  : out std_logic
);
end binary_to_bcd;

--! @brief RT implementation of the shift-add-3 algorithm.
--! @details
--!  The architecture is split into:
--!   - control path: FSM t_state with states idle, init, add3, shift, done
--!   - data path: registers for the binary value, four BCD digits and
--!     an iteration counter, plus combinational logic for the add-3 and
--!     shift operations.

architecture arch of binary_to_bcd is

  --! Number of binary input bits to process.
  constant c_N_BITS : integer := 13;

  --! State type for the control logic
  type t_state is (idle, init, add3, shift, done);
  --! Current and next state of the FSM
  signal state_reg, state_next : t_state;

  --! Binary input register.
  signal bin_reg, bin_next : unsigned(12 downto 0);
  --! BCD digit registers and their next-state values.
  signal bcd1_reg, bcd1_next : unsigned(3 downto 0);
  signal bcd2_reg, bcd2_next : unsigned(3 downto 0);
  signal bcd3_reg, bcd3_next : unsigned(3 downto 0);
  signal bcd4_reg, bcd4_next : unsigned(3 downto 0);
  --! Iteration counter (counts processed bits 0..12).
  signal cnt_reg, cnt_next : unsigned(3 downto 0);
  --! Status : asserted when all bits have been processed.
  signal cnt_done : std_logic;

begin
  --control path: state register
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process;

  --control path: next-state logic
  process(state_reg, start_i, cnt_done)
  begin
    case state_reg is
      when idle =>
        if start_i = '1' then
          state_next <= init;
        else
          state_next <= idle;
        end if;

      when init =>
        state_next <= add3;

      when add3 =>
        state_next <= shift;

      when shift =>
        if cnt_done = '1' then
          state_next <= done;
        else
          state_next <= add3;
        end if;

      when done =>
        state_next <= idle;

    end case;
  end process;

  ready_o <= '1' when state_reg = idle else '0';

  --data path: registers
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      bin_reg  <= (others => '0');
      bcd1_reg <= (others => '0');
      bcd2_reg <= (others => '0');
      bcd3_reg <= (others => '0');
      bcd4_reg <= (others => '0');
      cnt_reg  <= (others => '0');
    elsif rising_edge(clk_i) then
      bin_reg  <= bin_next;
      bcd1_reg <= bcd1_next;
      bcd2_reg <= bcd2_next;
      bcd3_reg <= bcd3_next;
      bcd4_reg <= bcd4_next;
      cnt_reg  <= cnt_next;
    end if;
  end process;

  --data path: combinational logic (routing and functional units)
  process(state_reg, binary_i, bin_reg, bcd1_reg, bcd2_reg, bcd3_reg, bcd4_reg, cnt_reg)
    --! Temporary BCD digit values for the add-3 step.
    variable tmp_bcd1, tmp_bcd2, tmp_bcd3, tmp_bcd4 : unsigned(3 downto 0);
    --! Packed register for BCD digits and binary bits during shift.
    variable tmp_all : unsigned(28 downto 0); --4*4+13-1

  begin
      -- default: hold current values
    bin_next  <= bin_reg;
    bcd1_next <= bcd1_reg;
    bcd2_next <= bcd2_reg;
    bcd3_next <= bcd3_reg;
    bcd4_next <= bcd4_reg;
    cnt_next  <= cnt_reg;

    case state_reg is
      when idle =>
        null;   -- no data-path activity in idle

         -- load input and clear BCD digits and counter
      when init =>
        bin_next  <= unsigned(binary_i);
        bcd1_next <= (others => '0');
        bcd2_next <= (others => '0');
        bcd3_next <= (others => '0');
        bcd4_next <= (others => '0');
        cnt_next  <= (others => '0');

         -- add-3 correction for each BCD digit >= 5
      when add3 =>
        tmp_bcd1 := bcd1_reg;
        tmp_bcd2 := bcd2_reg;
        tmp_bcd3 := bcd3_reg;
        tmp_bcd4 := bcd4_reg;

        if tmp_bcd1 >= to_unsigned(5, tmp_bcd1'length) then
          tmp_bcd1 := tmp_bcd1 + 3;
        end if;

        if tmp_bcd2 >= to_unsigned(5, tmp_bcd2'length) then
          tmp_bcd2 := tmp_bcd2 + 3;
        end if;

        if tmp_bcd3 >= to_unsigned(5, tmp_bcd3'length) then
          tmp_bcd3 := tmp_bcd3 + 3;
        end if;

        if tmp_bcd4 >= to_unsigned(5, tmp_bcd4'length) then
          tmp_bcd4 := tmp_bcd4 + 3;
        end if;

        bcd1_next <= tmp_bcd1;
        bcd2_next <= tmp_bcd2;
        bcd3_next <= tmp_bcd3;
        bcd4_next <= tmp_bcd4;

      when shift =>
        tmp_all := bcd4_reg & bcd3_reg & bcd2_reg & bcd1_reg & bin_reg;
        tmp_all := shift_left(tmp_all, 1);

             -- unpack BCD digits and binary remainder
        bcd4_next <= tmp_all(28 downto 25);
        bcd3_next <= tmp_all(24 downto 21);
        bcd2_next <= tmp_all(20 downto 17);
        bcd1_next <= tmp_all(16 downto 13);
        bin_next  <= tmp_all(12 downto 0);

        cnt_next <= cnt_reg + 1;

      when done =>
        null; -- hold result until next start
    end case;
  end process;
  -- status and outputs
  --! Asserted when all c_N_BITS bits have been processed.
  cnt_done <= '1' when cnt_reg = to_unsigned(c_N_BITS-1, cnt_reg'length) else '0';

  bcd1_o <= std_logic_vector(bcd1_reg);
  bcd2_o <= std_logic_vector(bcd2_reg);
  bcd3_o <= std_logic_vector(bcd3_reg);
  bcd4_o <= std_logic_vector(bcd4_reg);

end arch;
