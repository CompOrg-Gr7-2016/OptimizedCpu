library IEEE;
use ieee.std_logic_1164.all; -- allows use of the std_logic_vector type
use ieee.numeric_std.all; -- allows use of the unsigned type
use STD.textio.all;

entity cpu_tb is
  port (
	some : in std_logic
  ) ;
end entity ; -- cpu_tb

architecture bb of cpu_tb is

	component cpu IS
	   GENERIC (
	      File_Address_Read    : STRING    := "Init.dat";
	      File_Address_Write   : STRING    := "MemCon.dat";
	      Mem_Size_in_Word     : INTEGER   := 1024;
	      IC_Size_in_Word      : INTEGER   := 256;
	      Read_Delay           : INTEGER   := 0; 
	      Write_Delay          : INTEGER   := 0
	   );
	   PORT (
	      clk: IN STD_LOGIC;
	      reset: IN STD_LOGIC := '0';
	      
	      --Signals required by the MIKA testing suite
	      finished_prog:    OUT   STD_LOGIC; --Set this to '1' when program execution is over
	      assertion:        OUT   STD_LOGIC; --Set this to '1' when an assertion occurs 
	      assertion_pc:     OUT   NATURAL;   --Set the assertion's program counter location
	      
	      mem_dump:         IN    STD_LOGIC := '0'
	   );
	   
	END component;

	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal mem_dump : std_logic := '0';

begin

cpui1 : cpu 
	   GENERIC map(
	      File_Address_Read    => "C:/Users/Francis/GitProjects/vhdlcpu/Part 2/asm/output.txt",
	      File_Address_Write   => "MemCon.dat",
	      Mem_Size_in_Word     => 256,
	      IC_Size_in_Word      => 256,
	      Read_Delay           => 0, 
	      Write_Delay          => 0
	   )
	   PORT map (
	      clk => clk,
	      reset => reset,
	      mem_dump => mem_dump
	   );
	   
clk <= not clk after 10 ns;

end architecture ; -- bb