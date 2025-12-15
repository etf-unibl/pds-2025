-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     bcd_to_bindary
--
-- description:
--
--   bcd_to_binary unit implements conversion of two digit BCD number to
--   seven bit binary number.
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
--! @file bcd_to_binary.vhd
--! @brief Implements two digit BCD to seven bit binary conversion
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Entity definition of bcd_to_binary.
--! Unit implements conversion of two digit BCD number to seven digit binary
--! number. When the start_i input is high bcd1_i and bcd2_i inputs are
--! loaded and used to calculate the output binary_o. When the output
--! ready_o changes it's value to high, our output binary_o is ready and
--! the conversion is done.
--! While the rst_i state is high the unit is halted and stays in idle state.
entity bcd_to_binary is
  port (
  clk_i    : in  std_logic;                    --! Clock input of the unit.
  rst_i    : in  std_logic;                    --! Reset input of the unit.
  start_i  : in  std_logic;                    --! Start input which brings state from idle to load, starting the conversion.
  bcd1_i   : in  std_logic_vector(3 downto 0); --! First bcd digit (in decimal number 72, bcd1_i would represent '7').
  bcd2_i   : in  std_logic_vector(3 downto 0); --! Second bcd digit (in decimal number 72, bcd2_i would represent '2').
  binary_o : out std_logic_vector(6 downto 0); --! Binary output of the conversion.
  ready_o  : out std_logic                     --! Output used to signal that conversion is done.
);
end bcd_to_binary;

--! @brief Architecture definition of bcd_to_binary.
--! This architecture uses Moore's finite state machine and
--! Register-Transfer method.
--! States of the machine are: idle, load, bcd0 and op.
--! Machine starts in the idle state nad stays in it until input
--! start_i is high and input rst_i is low.
--! From idle state machine goes to load state where inputs are loaded.
--! If both of the input bcd digits are equal to zero, machine goes to
--! bcd0 state where the output is set to zero. Otherwise it goes
--! to op state in which the conversion is done.
--! Conversion is realised using the "Reverse Double Dabble" method:
--! (https://en.wikipedia.org/wiki/Double_dabble#Reverse_double_dabble).
architecture arch of bcd_to_binary is

  type t_state_type is (idle, bcd0, load, op);
  constant c_WIDTH                    : integer := 4;
  constant c_WIDTH_RES                : integer := 7;
  signal state_reg, state_next        : t_state_type;
  signal bcd1_is_0, bcd2_is_0, done_0 : std_logic;

  --! Input bcd register and it's next state.
  signal bcd1_reg, bcd1_next          : unsigned(c_WIDTH-1 downto 0);
  --! Input bcd register and it's next state.
  signal bcd2_reg, bcd2_next          : unsigned(c_WIDTH-1 downto 0);

  --! Result register and it's next state.
  signal r_reg, r_next                : unsigned(c_WIDTH_RES-1 downto 0);

  --! This will be helper signal in which lowest bit will be shifted
  --! from the bcd number. In every op iteration it will be added to result (r_reg).
  signal shifter_out                  : unsigned(c_WIDTH_RES-1 downto 0);

  --! Initial value of n will be 7 since we will need to do 7 shifts to the shifter_out.
  signal n_reg, n_next                : unsigned(2 downto 0);

  -- All of the below signals are used as helper and temporary signals.
  --! helper signal.
  signal sub_out                      : unsigned(2 downto 0);
  --! helper signal.
  signal bcd1_pom                     : unsigned(c_WIDTH-1 downto 0);
  --! helper signal.
  signal bcd2_pom                     : unsigned(c_WIDTH-1 downto 0);
  --! helper signal.
  signal bcd1_shr                     : unsigned(c_WIDTH-1 downto 0);
  --! helper signal.
  signal bcd2_shr                     : unsigned(c_WIDTH-1 downto 0);
  --! helper signal.
  signal bcd1_thr                     : unsigned(c_WIDTH-1 downto 0);
  --! helper signal.
  signal bcd2_thr                     : unsigned(c_WIDTH-1 downto 0);
  --! helper signal.
  signal seven                        : unsigned(2 downto 0) := "111";
begin
  --! control path: state register
  state_register : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process state_register;

  --! control path: next-state / output logic
  next_state : process(state_reg, start_i, bcd1_is_0, bcd2_is_0, done_0)
  begin
    case state_reg is
      when idle =>
        if start_i = '1' then
          if bcd1_is_0 = '1' and bcd2_is_0 = '1' then
            state_next <= bcd0;
          else
            state_next <= load;
          end if;
        else
          state_next <= idle;
        end if;
      when bcd0 =>
        state_next <= idle;
      when load =>
        state_next <= op;
      when op =>
        if done_0 = '1' then
          state_next <= idle;
        else
          state_next <= op;
        end if;
    end case;
  end process next_state;

  --! control path: output logic
  ready_o <= '1' when state_reg = idle else '0';

  --! data path: data register
  data_reg : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      bcd1_reg    <= (others => '0');
      bcd2_reg    <= (others => '0');
      n_reg       <= (others => '0');
      r_reg       <= (others => '0');
    elsif rising_edge(clk_i) then
      bcd1_reg    <= bcd1_next;
      bcd2_reg    <= bcd2_next;
      n_reg       <= n_next;
      r_reg       <= r_next;
    end if;
  end process data_reg;

  --! data path: routing multipexer
  routing_mux : process(state_reg, bcd1_reg, bcd2_reg, r_reg,
                        bcd1_i, bcd2_i, shifter_out, sub_out, n_reg, n_next, bcd1_pom, bcd2_pom)
  begin
    case state_reg is
      when idle =>
        bcd1_next      <= bcd1_reg;
        bcd2_next      <= bcd2_reg;
        n_next         <= n_reg;
        r_next         <= r_reg;
      when bcd0 =>
        bcd1_next      <= unsigned(bcd1_i);
        bcd2_next      <= unsigned(bcd2_i);
        n_next         <= unsigned(seven);
        r_next         <= (others => '0');
      when load =>
        bcd1_next      <= unsigned(bcd1_i);
        bcd2_next      <= unsigned(bcd2_i);
        n_next         <= unsigned(seven);
        r_next         <= (others => '0');
      when op =>
        bcd1_next      <= bcd1_pom;
        bcd2_next      <= bcd2_pom;
        n_next         <= sub_out;
        r_next         <= shifter_out;
    end case;
  end process routing_mux;

  --! data path: functional units
  shifter_out <= bcd2_reg(0) & r_reg(6 downto 1);
  bcd1_shr <= '0' & bcd1_reg(3 downto 1);
  bcd2_shr <= bcd1_reg(0) & bcd2_reg(3 downto 1);
  bcd1_thr <= bcd1_shr when bcd1_shr < 8 else bcd1_shr - 3;
  bcd2_thr <= bcd2_shr when bcd2_shr < 8 else bcd2_shr - 3;
  bcd1_pom <= bcd1_thr;
  bcd2_pom <= bcd2_thr;
  sub_out  <= n_reg - 1;
  --! data path: status
  bcd1_is_0 <= '1' when bcd1_i = "0000" else '0';
  bcd2_is_0 <= '1' when bcd2_i = "0000" else '0';
  done_0    <= '1' when n_next = "000" else '0';
  --! data path: output
  binary_o <= std_logic_vector(r_reg);
end arch;
