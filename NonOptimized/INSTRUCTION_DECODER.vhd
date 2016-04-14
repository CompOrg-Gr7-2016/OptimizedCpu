library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity INSTRUCTION_DECODER is
  port (
	instruction : in std_logic_vector(31 downto 0);
	opcode_31_26 : out std_logic_vector(5 downto 0);
	rs_25_21 : out std_logic_vector(4 downto 0);
	rt_20_16 : out std_logic_vector(4 downto 0);
	rd_15_11 : out std_logic_vector(4 downto 0);
	shamt_10_6 : out std_logic_vector(4 downto 0);
	funct_5_0 : out std_logic_vector(5 downto 0);
	immediate_15_0 : out std_logic_vector (15 downto 0);
	address_25_0 : out std_logic_vector(25 downto 0)
  ) ;
end entity ; -- INSTRUCTION_DECODER

architecture arch of INSTRUCTION_DECODER is
begin
	opcode_31_26 <= instruction(31 downto 26);
	rs_25_21 <= instruction(25 downto 21);
	rt_20_16 <= instruction(20 downto 16);
	rd_15_11 <= instruction(15 downto 11);
	shamt_10_6 <= instruction(10 downto 6);
	funct_5_0 <= instruction(5 downto 0);
	immediate_15_0 <= instruction (15 downto 0);
	address_25_0 <= instruction(25 downto 0);
end architecture ; -- arch