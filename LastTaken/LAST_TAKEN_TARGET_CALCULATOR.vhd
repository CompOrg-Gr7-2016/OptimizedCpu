library ieee;
use ieee.std_logic_1164.all;        -- standard unresolved logic UX01ZWLH-
use ieee.numeric_std.all;

entity LAST_TAKEN_TARGET_CALCULATOR is
    port (
        clk : in std_logic;
        predict_taken : in std_logic;
        instruction : in std_logic_vector(31 downto 0);
        program_counter : in std_logic_vector(31 downto 0);

        prediction_made : out std_logic := '0';
        predicted_taken : out std_logic := '0';
        branch_target : out std_logic_vector(31 downto 0) := (others => '0')
    ) ;
end entity ; -- LAST_TAKEN_TARGET_CALCULATOR

architecture arch of LAST_TAKEN_TARGET_CALCULATOR is

    signal program_counter_mem : std_logic_vector(31 downto 0);  
    signal instruction_mem : std_logic_vector(31 downto 0);  
    
    signal opcode : std_logic_vector (5 downto 0) := (others => '0');
    signal immediate : std_logic_vector (15 downto 0) := (others => '0');
    signal immediate_sign_ex : std_logic_vector (31 downto 0) := (others => '0');
    signal program_counter_plus4 : std_logic_vector (31 downto 0) := (others => '0');  
    
begin

    opcode <= instruction_mem(31 downto 26);
    immediate <= instruction (15 downto 0);

    program_counter_plus4 <= std_logic_vector(to_signed(to_integer(signed(program_counter)) + 4, 32));
    immediate_sign_ex <= std_logic_vector(to_signed(to_integer(signed(immediate)), 32));

    prediction_made <= '1' when (opcode = "000100" or opcode = "000101") else '0';

    predicted_taken <= predict_taken;
        
    branch_target <= std_logic_vector(to_unsigned(to_integer(shift_left(signed(immediate_sign_ex), 2)) + to_integer(unsigned(program_counter_plus4)), 32));

    process (clk)
    begin 
        if falling_edge(clk) then
            program_counter_mem <= program_counter;
            instruction_mem <= instruction;
        end if;
    end process;
end architecture ; -- arch