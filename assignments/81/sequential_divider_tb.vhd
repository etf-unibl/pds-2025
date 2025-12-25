-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     sequential_divider_tb
--
-- description:
--
--   Self-checking testbench for sequential_divider.
--   Uses a deterministic table of directed test vectors and compares
--   DUT outputs (q_o, r_o) against expected values.
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
--! @file sequential_divider_tb.vhd
--! @brief Self-checking testbench for sequential_divider.
--! @details
--! This testbench verifies the sequential_divider using a table of
--! test vectors with expected quotient and remainder.
--!
--! The testbench performs:
--! - clock generation (clk_gen)
--! - reset generation (rst_gen)
--! - directed stimulus and checking (stim)
--!
--! For each test case:
--! 1) wait for READY=1 (idle)
--! 2) apply inputs a_i and b_i
--! 3) wait 1 cycle (setup time)
--! 4) issue a 1-cycle START pulse
--! 5) require READY to drop (enter busy)
--! 6) wait for READY to return to 1 (done)
--! 7) sample outputs and compare with expected values
--!
--! Additionally, a control test checks that START asserted while busy is
--! ignored (and input changes during busy do not affect the result).
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Testbench entity
entity sequential_divider_tb is
end entity sequential_divider_tb;

--! @brief Testbench architecture
--! @details
--! Instantiates the DUT and contains clock/reset generation and self-checking
--! stimulus.
architecture arch of sequential_divider_tb is

  --! @brief DUT component declaration
  component sequential_divider
    port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      start_i : in  std_logic;
      a_i     : in  std_logic_vector(7 downto 0);
      b_i     : in  std_logic_vector(7 downto 0);
      q_o     : out std_logic_vector(7 downto 0);
      r_o     : out std_logic_vector(7 downto 0);
      ready_o : out std_logic
    );
  end component;

  --! @brief Clock period
  constant c_T : time := 20 ns;

  --! @brief Timeout limit (in clock cycles)
  --! @details
  --! Prevents infinite waiting in case the DUT never becomes ready, never
  --! leaves idle after start, or never finishes the operation.
  constant c_TIMEOUT_CYCLES : integer := 600;

  --! @brief Testbench clock
  signal clk_tb   : std_logic := '0';
  --! @brief Testbench reset (active-high)
  signal rst_tb   : std_logic := '1';
  --! @brief Testbench start pulse
  signal start_tb : std_logic := '0';
  --! @brief Dividend stimulus (a_i)
  signal a_tb     : std_logic_vector(7 downto 0) := (others => '0');
  --! @brief Divisor stimulus (b_i)
  signal b_tb     : std_logic_vector(7 downto 0) := (others => '0');
  --! @brief Quotient observed from DUT
  signal q_tb     : std_logic_vector(7 downto 0);
  --! @brief Remainder observed from DUT
  signal r_tb     : std_logic_vector(7 downto 0);
  --! @brief READY observed from DUT (idle/done indicator)
  signal ready_tb : std_logic;

  --! @brief Test vector record type (inputs and expected outputs)
  type t_case is record
    a   : integer;  --! Dividend as integer (0..255)
    b   : integer;  --! Divisor as integer (0..255)
    q_e : integer;  --! Expected quotient (0..255, NaN=255 for b=0)
    r_e : integer;  --! Expected remainder (0..255, NaN=255 for b=0)
  end record t_case;

  --! @brief Array type holding multiple test cases
  type t_case_array is array (natural range <>) of t_case;

  --! @brief Test case table
  --! @details Covers:
  --! - divide-by-zero behaviour (NaN=255)
  --! - a=0 and b!=0
  --! - a<b, a=b
  --! - exact division and division with remainder
  --! - worst-case in time (255/1)
  constant c_CASES : t_case_array := (
    -- Divide-by-zero (NaN=255)
    (0,    0, 255, 255),
    (28,   0, 255, 255),
    (255,  0, 255, 255),

    -- a=0, b!=0
    (0,    1,   0,   0),
    (0,    5,   0,   0),
    (0,  255,   0,   0),

    -- a<b  (q=0, r=a)
    (1,  255,   0,   1),
    (17,  39,   0,  17),
    (254, 255,  0, 254),

    -- a=b  (q=1, r=0)
    (1,    1,   1,   0),
    (97,  97,   1,   0),
    (255, 255,  1,   0),

    -- a>b exact division (r=0)
    (56,   2,  28,   0),
    (200,  5,  40,   0),
    (255,  3,  85,   0),

    -- a>b with remainder
    (56,  27,   2,   2),
    (200,  3,  66,   2),
    (255,  2, 127,   1),

    -- worst-case in time (255/1)
    (255,  1, 255,   0)
  );

begin

  --! @brief Device Under Test (DUT) instantiation
  dut : sequential_divider
    port map (
      clk_i   => clk_tb,
      rst_i   => rst_tb,
      start_i => start_tb,
      a_i     => a_tb,
      b_i     => b_tb,
      q_o     => q_tb,
      r_o     => r_tb,
      ready_o => ready_tb
    );

  --! @brief Clock generator
  --! @details Generates a clock with period c_T.
  clk_gen : process
  begin
    clk_tb <= '0';
    wait for c_T/2;
    clk_tb <= '1';
    wait for c_T/2;
  end process clk_gen;

  --! @brief Reset generator
  --! @details Holds reset high at start, then releases it once.
  rst_gen : process
  begin
    rst_tb <= '1';
    wait for 60 ns;
    rst_tb <= '0';
    wait;
  end process rst_gen;

  --! @brief Stimulus and checking
  --! @details
  --! Applies each test case, checks READY transitions and outputs,
  --! then runs an additional START-while-busy test.
  stim : process

    variable errors : integer := 0; --! Testbench error counter
    variable i      : integer; --! Test-case index for iterating through c_CASES
    variable a_in   : integer; --! Current test input a as an integer
    variable b_in   : integer; --! Current test input b as an integer
    variable q_exp  : integer; --! Expected quotient for the current test-case
    variable r_exp  : integer; --! Expected remainder for the current test-case

    variable cycles : integer; --! Cycle counter for while loops
  begin

    wait until rst_tb = '0'; --! Wait for reset release, then align to clock.
    wait until rising_edge(clk_tb);

    -------------------------------------------------------------------------
    -- Tests
    -------------------------------------------------------------------------
    for i in c_CASES'range loop --! Load the current test vector from c_CASES.
      a_in  := c_CASES(i).a;
      b_in  := c_CASES(i).b;
      q_exp := c_CASES(i).q_e;
      r_exp := c_CASES(i).r_e;

      --! Wait until DUT ready (idle) with timeout.
      cycles := 0;
      while ready_tb /= '1' loop
        wait until rising_edge(clk_tb);
        cycles := cycles + 1;
        if cycles >= c_TIMEOUT_CYCLES then
          errors := errors + 1;
          report "TIMEOUT waiting for READY=1 (idle) before test idx=" &
                 integer'image(i)
            severity error;
          exit;
        end if;
      end loop;

      --! Apply inputs.
      a_tb <= std_logic_vector(to_unsigned(a_in, 8));
      b_tb <= std_logic_vector(to_unsigned(b_in, 8));

      wait until rising_edge(clk_tb); --! 1-cycle setup (inputs stable before start)

      --! Start pulse = 1 clock
      start_tb <= '1';
      wait until rising_edge(clk_tb);
      start_tb <= '0';

      --! READY must drop (operation must start).
      cycles := 0;
      while ready_tb = '1' loop
        wait until rising_edge(clk_tb);
        cycles := cycles + 1;
        if cycles >= c_TIMEOUT_CYCLES then
          errors := errors + 1;
          report "TIMEOUT: READY did not drop after START for idx=" &
                 integer'image(i) &
                 " (A=" & integer'image(a_in) &
                 ", B=" & integer'image(b_in) & ")"
            severity error;
          exit;
        end if;
      end loop;

      --! Wait until done (READY returns to 1) with timeout.
      cycles := 0;
      while ready_tb /= '1' loop
        wait until rising_edge(clk_tb);
        cycles := cycles + 1;
        if cycles >= c_TIMEOUT_CYCLES then
          errors := errors + 1;
          report "TIMEOUT: operation did not finish for idx=" &
                 integer'image(i) &
                 " (A=" & integer'image(a_in) &
                 ", B=" & integer'image(b_in) & ")"
            severity error;
          exit;
        end if;
      end loop;

      wait until rising_edge(clk_tb); --! Sample outputs one clock after ready rises.

      --! Check.
      if (q_tb /= std_logic_vector(to_unsigned(q_exp, 8))) or (r_tb /= std_logic_vector(to_unsigned(r_exp, 8))) then
        errors := errors + 1;
        report "ERROR: idx=" & integer'image(i) &
               " A=" & integer'image(a_in) &
               " B=" & integer'image(b_in) &
               " got Q=" & integer'image(to_integer(unsigned(q_tb))) &
               " R=" & integer'image(to_integer(unsigned(r_tb))) &
               " exp Q=" & integer'image(q_exp) &
               " R=" & integer'image(r_exp)
          severity error;
      else
        report "OK:    idx=" & integer'image(i) &
               " A=" & integer'image(a_in) &
               " B=" & integer'image(b_in) &
               " -> Q=" & integer'image(to_integer(unsigned(q_tb))) &
               " R=" & integer'image(to_integer(unsigned(r_tb)))
          severity note;
      end if;
    end loop;

   -------------------------------------------------------------------------
    --! @brief Control test: START must be ignored while DUT is busy.
    --! @details
    --! This test verifies correct behaviour of the DUT:
    --! - A START pulse must be accepted only when READY=1 (idle state).
    --! - While READY=0 (busy), any additional START pulse must be ignored.
    --! - Input changes (a_i, b_i) applied while busy must not affect the
    --!   already-running operation (inputs shall be effectively latched on start).
    --!
    --! Test sequence:
    --! 1) Wait for READY=1 (idle) with timeout protection.
    --! 2) Apply inputs A=200 and B=3, wait one setup cycle.
    --! 3) Issue a single-cycle START pulse to launch the operation.
    --! 4) Confirm READY drops to 0 (enter busy).
    --! 5) While busy, change inputs to A=42 and B=7 and pulse START again.
    --!    Expected: DUT ignores this pulse and continues the original operation.
    --! 6) Wait for READY to return to 1 (done) with timeout protection.
    --! 7) Check that the final outputs correspond to the first operation
    --!    (200/3 => Q=66, R=2). Any other result indicates error.
    -------------------------------------------------------------------------
    cycles := 0;
    while ready_tb /= '1' loop
      wait until rising_edge(clk_tb);
      cycles := cycles + 1;
      if cycles >= c_TIMEOUT_CYCLES then
        errors := errors + 1;
        report "TIMEOUT waiting idle before control test (start while busy)."
          severity error;
        exit;
      end if;
    end loop;

    -- Apply first op inputs.
    a_tb <= std_logic_vector(to_unsigned(200, 8));
    b_tb <= std_logic_vector(to_unsigned(3, 8));
    wait until rising_edge(clk_tb);

    -- Start first op.
    start_tb <= '1';
    wait until rising_edge(clk_tb);
    start_tb <= '0';

    -- Ensure busy (ready drops).
    cycles := 0;
    while ready_tb = '1' loop
      wait until rising_edge(clk_tb);
      cycles := cycles + 1;
      if cycles >= c_TIMEOUT_CYCLES then
        errors := errors + 1;
        report "TIMEOUT: control test did not enter busy (READY never dropped)."
          severity error;
        exit;
      end if;
    end loop;

    -- While busy: change inputs + pulse start again (should be ignored).
    a_tb <= std_logic_vector(to_unsigned(42, 8));
    b_tb <= std_logic_vector(to_unsigned(7, 8));
    start_tb <= '1';
    wait until rising_edge(clk_tb);
    start_tb <= '0';

    -- Wait finish.
    cycles := 0;
    while ready_tb /= '1' loop
      wait until rising_edge(clk_tb);
      cycles := cycles + 1;
      if cycles >= c_TIMEOUT_CYCLES then
        errors := errors + 1;
        report "TIMEOUT: control test did not finish."
          severity error;
        exit;
      end if;
    end loop;

    wait until rising_edge(clk_tb);

    if (q_tb /= std_logic_vector(to_unsigned(66, 8))) or (r_tb /= std_logic_vector(to_unsigned(2, 8))) then
      errors := errors + 1;
      report "ERROR: start-while-busy control test failed. " &
             "Expected Q=66 R=2, got Q=" &
             integer'image(to_integer(unsigned(q_tb))) &
             " R=" & integer'image(to_integer(unsigned(r_tb)))
        severity error;
    else
      report "OK:    start-while-busy ignored (expected Q=66 R=2)"
        severity note;
    end if;

    -------------------------------------------------------------------------
    -- Final result
    -------------------------------------------------------------------------
    if errors = 0 then
      report "ALL TESTS PASSED (no errors)." severity note;
    else
      report "TESTS FAILED: errors=" & integer'image(errors) severity failure;
    end if;

    wait;
  end process stim;

end architecture arch;
