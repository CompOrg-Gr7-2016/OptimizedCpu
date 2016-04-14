library ieee;
use ieee.std_logic_1164.all;        -- standard unresolved logic UX01ZWLH-
use ieee.numeric_std.all;

entity DYNAMIC_BRANCH_PREDICTOR is
  port (
	instruction : in std_logic_vector(31 downto 0);
    last_taken : in std_logic := '0';
    program_counter_plus4 : std_logic_vector(31 downto 0);
    
    predicted_last_taken : out std_logic := '0';
    branch_target : out std_logic_vector(31 downto 0) := (others => '0')
  ) ;
end entity ; -- DYNAMIC_BRANCH_PREDICTOR

architecture arch of DYNAMIC_BRANCH_PREDICTOR is

    signal opcode : std_logic_vector (5 downto 0) := (others => '0');
	signal immediate : std_logic_vector (15 downto 0) := (others => '0');
	signal immediate_sign_ex : std_logic_vector (31 downto 0) := (others => '0');

begin

    opcode <= instruction(31 downto 26);
	immediate <= instruction (15 downto 0);

    predicted <= '1' when (opcode = "000100" or opcode = "000101") else '0';
    immediate_sign_ex <= std_logic_vector(to_signed(to_integer(signed(immediate)), 32));
    branch_target <= std_logic_vector(to_unsigned(to_integer(shift_left(signed(immediate_sign_ex), 2)) + to_integer(unsigned(program_counter_plus4)), 32));

end architecture ; -- arch