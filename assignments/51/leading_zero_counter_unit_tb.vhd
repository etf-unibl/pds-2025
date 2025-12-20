-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     leading_zero_counter_unit_tb
--
-- description:
--
--   This file implements a testbench for the 16-bit leading zero counter unit.
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

entity leading_zero_counter_unit_tb is
end leading_zero_counter_unit_tb;

architecture arch of leading_zero_counter_unit_tb is

  signal INPUT_DATA_i_tb  : std_logic_vector(15 downto 0);
  signal OUTPUT_DATA_o_tb : std_logic_vector(4 downto 0);

  component leading_zero_counter_unit
    port (
      INPUT_DATA_i  : in std_logic_vector(15 downto 0);
      OUTPUT_DATA_o : out std_logic_vector(4 downto 0)
    );
  end component;

begin

  DUT : leading_zero_counter_unit
    port map (
      INPUT_DATA_i  => INPUT_DATA_i_tb,
      OUTPUT_DATA_o => OUTPUT_DATA_o_tb
    );

  stim_proc : process
  begin

    INPUT_DATA_i_tb <= "1000000000000000";
    wait for 10 ns;

    INPUT_DATA_i_tb <= "0100000000000000";
    wait for 10 ns;

    INPUT_DATA_i_tb <= "0001000000000000";
    wait for 10 ns;

    INPUT_DATA_i_tb <= "0000000100000000";
    wait for 10 ns;

    INPUT_DATA_i_tb <= "0000000000000001";
    wait for 10 ns;

    INPUT_DATA_i_tb <= "0000000000000000";
    wait for 10 ns;

    INPUT_DATA_i_tb <= "0010001000100010";
    wait for 10 ns;

    assert false report "=== SIMULATION COMPLETED ===" severity note;

    wait;
  end process stim_proc;

end arch;
