-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     bcd_to_binary_tb
--
-- description:
--
--   This file implements a simple bcd_to_binary logic.
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
--! @brief Empty entity for testbench
--! @brief Testbench architecture for bcd_to_binary
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_to_binary_tb is
end bcd_to_binary_tb;

architecture arch of bcd_to_binary_tb is
  constant c_CLK_PERIOD : time := 20 ns;

  component bcd_to_binary is
    port (
      clk_i    : in std_logic;
      rst_i    : in std_logic;
      start_i  : in std_logic;
      bcd1_i   : in std_logic_vector(3 downto 0);
      bcd2_i   : in std_logic_vector(3 downto 0);
      binary_o : out std_logic_vector(6 downto 0);
      ready_o  : out std_logic
    );
  end component;

  signal clk_s    : std_logic := '0';
  signal rst_s    : std_logic := '1';
  signal start_s  : std_logic := '0';
  signal bcd1_s   : std_logic_vector(3 downto 0) := (others => '0');
  signal bcd2_s   : std_logic_vector(3 downto 0) := (others => '0');
  signal binary_s : std_logic_vector(6 downto 0);
  signal ready_s  : std_logic;
  signal stop_clk : std_logic := '0';

begin

  DUT : bcd_to_binary
    port map(
      clk_i    => clk_s,
      rst_i    => rst_s,
      start_i  => start_s,
      bcd1_i   => bcd1_s,
      bcd2_i   => bcd2_s,
      binary_o => binary_s,
      ready_o  => ready_s
    );

  clk : process
  begin
    while stop_clk = '0' loop
      clk_s <= '0';
      wait for c_CLK_PERIOD / 2;
      clk_s <= '1';
      wait for c_CLK_PERIOD / 2;
    end loop;
    wait;
  end process clk;

  stim_proc : process
    variable v         : integer;
    variable exp_bin   : unsigned(6 downto 0);
    variable got_bin   : unsigned(6 downto 0);
    variable error_cnt : integer := 0;
    variable test_cnt  : integer := 0;
  begin
    rst_s   <= '1';
    start_s <= '0';
    bcd1_s  <= (others => '0');
    bcd2_s  <= (others => '0');

    wait for 3 * c_CLK_PERIOD;
    rst_s <= '0';
    wait for c_CLK_PERIOD;

    for v in 0 to 99 loop
      wait until rising_edge(clk_s) and ready_s = '1';

      bcd1_s <= std_logic_vector(to_unsigned(v / 10, 4));
      bcd2_s <= std_logic_vector(to_unsigned(v mod 10, 4));

      start_s <= '1';
      wait until rising_edge(clk_s);
      start_s <= '0';

      wait until rising_edge(clk_s) and ready_s = '1';

      exp_bin := to_unsigned(v, 7);
      got_bin := unsigned(binary_s);

      test_cnt := test_cnt + 1;

      if got_bin /= exp_bin then
        error_cnt := error_cnt + 1;
      end if;
    end loop;

    stop_clk <= '1';
    wait for c_CLK_PERIOD;

    if error_cnt > 0 then
      assert false report "Simulation failed: " & integer'image(error_cnt) &
               " errors out of " & integer'image(test_cnt) & " tests."
        severity failure;
    end if;

    wait;
  end process stim_proc;

end arch;
