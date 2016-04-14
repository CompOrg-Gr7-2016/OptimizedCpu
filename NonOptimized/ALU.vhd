library ieee;
use ieee.std_logic_1164.all;        -- standard unresolved logic UX01ZWLH-
use ieee.numeric_std.all;

entity ALU is
  port (
	opcode : in std_logic_vector(5 downto 0);
	funct : in std_logic_vector(5 downto 0);
	shamt : in std_logic_vector(4 downto 0);
	port_1 : in std_logic_vector(31 downto 0);
	port_2 : in std_logic_vector(31 downto 0);
	result : out std_logic_vector(31 downto 0) := x"00000000"
  ) ;
end entity ; -- ALU

architecture arch of ALU is

signal mult_hi : std_logic_vector(31 downto 0);
signal mult_lo : std_logic_vector(31 downto 0);

begin

alu_execution : process(opcode, funct, shamt, port_1, port_2)

	variable mult_temp : std_logic_vector(63 downto 0);
	variable div_a : integer;
	variable div_b : integer;
	variable div_temp : integer;

begin
		case( opcode ) is
			when "000000" => -- R type
				case( funct ) is
					when "000000" => --sll 0x00
						result <= std_logic_vector(shift_left(unsigned(port_2), to_integer(unsigned(shamt))));
					when "000010" => --srl 0x02
						result <= std_logic_vector(shift_right(unsigned(port_2), to_integer(unsigned(shamt))));
					when "001000" => --jr 0x08
						-- no operation
					when "010000" => --mfhi 0x10
						result <= mult_hi;
					when "010010" => --mflo 0x12
						result <= mult_lo;
					when "011000" => --mult 0x18
						mult_temp := std_logic_vector(to_signed(to_integer(signed(port_1)) * to_integer(signed(port_2)), 64));
						mult_hi <= mult_temp(63 downto 32);
						mult_lo <= mult_temp(31 downto 0);
					when "011010" => --div 0x1A
						div_a := to_integer(signed(port_1));
						div_b := to_integer(signed(port_2));
						if div_b /= 0 then
							div_temp := div_a / div_b;
							mult_lo <= std_logic_vector(to_signed(div_temp, 32));
							mult_hi <= std_logic_vector(to_signed(to_integer(signed(port_1)) rem to_integer(signed(port_2)), 32));
						end if;
					when "100000" => --add 0x20
						result <= std_logic_vector(to_signed(to_integer(signed(port_1)) + to_integer(signed(port_2)), 32));
					when "100010" => --sub 0x22
						result <= std_logic_vector(to_signed(to_integer(signed(port_1)) - to_integer(signed(port_2)), 32));
					when "100100" => --and bit 0x24
						result <= port_1 and port_2;
					when "100101" => --or bit 0x25
						result <= port_1 or port_2;
					when "100110" => --xor bit 0x26
						result <= port_1 xor port_2;
					when "100111" => --nor bit 0x27
						result <= port_1 nor port_2;
					when "101010" => --slt 0x2A
						if to_integer(signed(port_1)) < to_integer(signed(port_2)) then
							result <= x"00000001";
						else
							result <= x"00000000";
						end if ;
					when others => -- should not happen
						result <= (others => 'X');
				end case;	
				
			when "001000" => --addi 0x08
				result <= std_logic_vector(to_signed(to_integer(signed(port_1)) + to_integer(signed(port_2)), 32));
			when "001100" => --andi 0x0C
				result <= port_1 and port_2;
			when "001101" => --ori 0x0D
				result <= port_1 or port_2;
			when "001110" => --xori 0x0E
				result <= port_1 xor port_2;
			when "001010" => --slti
				if to_integer(signed(port_1)) < to_integer(signed(port_2)) then
					result <= x"00000001";
				else
					result <= x"00000000";
				end if ;
            when "100000" => -- load byte
                result <= std_logic_vector(to_signed(to_integer(signed(port_1)) + to_integer(signed(port_2)), 32));
            when "100011" => -- load word
                result <= std_logic_vector(to_signed(to_integer(signed(port_1)) + to_integer(signed(port_2)), 32));
            when "101000" => -- store byte
                result <= std_logic_vector(to_signed(to_integer(signed(port_1)) + to_integer(signed(port_2)), 32));
            when "101011" => -- store word
                result <= std_logic_vector(to_signed(to_integer(signed(port_1)) + to_integer(signed(port_2)), 32));
            when "001111" => -- lui
                result <= port_2; 
            when "010101" => -- asrti
                result <= (others => '0');
            when "100100" => -- halt
                result <= (others => '0');
            when others => -- should not happen
                result <= (others => '0');
		end case ;
end process ; -- alu_execution

end architecture ; -- arch
