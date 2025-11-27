-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025
-----------------------------------------------------------------------------
--
-- unit name:     multi_function_aritmetic_unit_tb
--
-- description:
--
--   This file implements testbench for multi_function_aritmetic_unit logic.
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

entity multi_function_aritmetic_unit_tb is
end multi_function_aritmetic_unit_tb;

architecture arch of multi_function_aritmetic_unit_tb is

  -- DUT signals
  signal A_i    : std_logic_vector(15 downto 0);
  signal B_i    : std_logic_vector(15 downto 0);
  signal CTRL_i : std_logic_vector(1 downto 0);
  signal RES_o  : std_logic_vector(15 downto 0);

  -- DUT component
  component multi_function_aritmetic_unit is
    port (
      A_i    : in  std_logic_vector(15 downto 0);
      B_i    : in  std_logic_vector(15 downto 0);
      CTRL_i : in  std_logic_vector(1 downto 0);
      RES_o  : out std_logic_vector(15 downto 0)
    );
  end component;

  -- test vectors for A_i and B_i
  type t_test_vector_array is array (natural range <>) of std_logic_vector(15 downto 0);
  constant c_TEST_VECTORS : t_test_vector_array := (
    x"0000",
    x"0001",
    x"0002",
    x"000A",
    x"00FF",
    x"0F0F",
    x"1234",
    x"7FFF",
    x"8000",
    x"FFFF"
  );

begin

  -- DUT instance
  i_dut : multi_function_aritmetic_unit
    port map (
      A_i    => A_i,
      B_i    => B_i,
      CTRL_i => CTRL_i,
      RES_o  => RES_o
    );

  -- init process
  init : process
  begin
    wait;
  end process init;

  -- main test process
  always : process
    variable expected    : std_logic_vector(15 downto 0);
    variable error_count : integer := 0;
  begin

    ---------------------------------------------------------------------------
    -- Test 1: A_i + B_i (CTRL_i = "00")
    ---------------------------------------------------------------------------
    CTRL_i <= "00";
    for i in c_TEST_VECTORS'range loop
      for j in c_TEST_VECTORS'range loop
        A_i <= c_TEST_VECTORS(i);
        B_i <= c_TEST_VECTORS(j);
        wait for 10 ns;

        expected := std_logic_vector(unsigned(A_i) + unsigned(B_i));

        if RES_o /= expected then
          assert false
            report "ADD failed: A="  & integer'image(to_integer(unsigned(A_i))) &
                   "; B="            & integer'image(to_integer(unsigned(B_i))) &
                   "; expected="     & integer'image(to_integer(unsigned(expected))) &
                   "; actual="       & integer'image(to_integer(unsigned(RES_o)))
            severity error;
          error_count := error_count + 1;
        end if;
      end loop;
    end loop;
    assert false report "A + B tests finished." severity note;

    ---------------------------------------------------------------------------
    -- Test 2: A_i - B_i (CTRL_i = "01")
    ---------------------------------------------------------------------------
    CTRL_i <= "01";
    for i in c_TEST_VECTORS'range loop
      for j in c_TEST_VECTORS'range loop
        A_i <= c_TEST_VECTORS(i);
        B_i <= c_TEST_VECTORS(j);
        wait for 10 ns;

        expected := std_logic_vector(unsigned(A_i) - unsigned(B_i));

        if RES_o /= expected then
          assert false
            report "SUB failed: A=" & integer'image(to_integer(unsigned(A_i))) &
                   "; B="           & integer'image(to_integer(unsigned(B_i))) &
                   "; expected="    & integer'image(to_integer(unsigned(expected))) &
                   "; actual="      & integer'image(to_integer(unsigned(RES_o)))
            severity error;
          error_count := error_count + 1;
        end if;
      end loop;
    end loop;
    assert false report "A - B tests finished." severity note;

    ---------------------------------------------------------------------------
    -- Test 3: A_i + 1 (CTRL_i = "10")
    ---------------------------------------------------------------------------
    CTRL_i <= "10";
    for i in c_TEST_VECTORS'range loop
      A_i <= c_TEST_VECTORS(i);
      B_i <= (others => '0');
      wait for 10 ns;

      expected := std_logic_vector(unsigned(A_i) + 1);

      if RES_o /= expected then
        assert false
          report "INC failed: A=" & integer'image(to_integer(unsigned(A_i))) &
                 "; expected="    & integer'image(to_integer(unsigned(expected))) &
                 "; actual="      & integer'image(to_integer(unsigned(RES_o)))
          severity error;
        error_count := error_count + 1;
      end if;
    end loop;
    assert false report "A + 1 tests finished." severity note;

    ---------------------------------------------------------------------------
    -- Test 4: A_i - 1 (CTRL_i = "11")
    ---------------------------------------------------------------------------
    CTRL_i <= "11";
    for i in c_TEST_VECTORS'range loop
      A_i <= c_TEST_VECTORS(i);
      B_i <= (others => '0');
      wait for 10 ns;

      expected := std_logic_vector(unsigned(A_i) - 1);

      if RES_o /= expected then
        assert false
          report "DEC failed: A=" & integer'image(to_integer(unsigned(A_i))) &
                 "; expected="    & integer'image(to_integer(unsigned(expected))) &
                 "; actual="      & integer'image(to_integer(unsigned(RES_o)))
          severity error;
        error_count := error_count + 1;
      end if;
    end loop;
    assert false report "A - 1 tests finished." severity note;

    ---------------------------------------------------------------------------
    -- Summary
    ---------------------------------------------------------------------------
    wait for 10 ns;
    if error_count = 0 then
      assert false report "Test completed successfully." severity note;
    else
      assert false report "Test finished with errors." severity error;
    end if;

    wait;
  end process always;

end arch;
