library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BRANCH_HAZARD_UNIT is
	port (
		opcode : in std_logic_vector(5 downto 0);
		funct : in std_logic_vector(5 downto 0);
		reg_s : in std_logic_vector(4 downto 0);
		reg_t : in std_logic_vector(4 downto 0);
		write_dest_EX : in std_logic_vector(4 downto 0);
		write_dest_M : in std_logic_vector(4 downto 0);
		write_dest_WB : in std_logic_vector(4 downto 0);
		reg_write_en_EX : in std_logic;
		reg_write_en_M : in std_logic;
		reg_write_en_WB : in std_logic;
		forward_s : out std_logic_vector(1 downto 0) := "00";
		forward_t : out std_logic_vector(1 downto 0) := "00";
		forward_jr : out std_logic_vector (1 downto 0) := "00";
		stall : out std_logic := '0';
        test : out std_logic := '0'
	) ;
end entity ; -- BRANCH_HAZARD_UNIT

architecture behaviour of BRANCH_HAZARD_UNIT is
begin

	main_pro : process( opcode, funct, reg_s, reg_t, write_dest_EX, write_dest_M, write_dest_WB, reg_write_en_EX, reg_write_en_M, reg_write_en_WB )
	begin
        stall <= '0';
		if (opcode = "000100" or opcode = "000101") then --beq or bne
			if (((reg_s = write_dest_EX) or (reg_t = write_dest_EX)) and reg_write_en_EX = '1') then
				stall <= '1';
                test <= '1';
			else
				stall <= '0';
                test <= '0';

				-- s register
				if (reg_s = write_dest_M and reg_write_en_M = '1') then
					forward_s <= "01";
				elsif (reg_s = write_dest_WB and reg_write_en_WB = '1') then
					forward_s <= "10";
				else
					forward_s <= "00";
				end if ;

				-- t register
				if (reg_t = write_dest_M and reg_write_en_M = '1') then
					forward_t <= "01";
				elsif (reg_t = write_dest_WB and reg_write_en_WB = '1') then
					forward_t <= "10";
				else
					forward_t <= "00";
				end if ;
			end if ;
		elsif (opcode = "000000" and funct = "001000") then -- jr
			if (reg_s = write_dest_EX and reg_write_en_EX = '1') then
				stall <= '1';
                test <= '1';
			else
				stall <= '0';
                test <= '0';

				if (reg_s = write_dest_M and reg_write_en_M = '1') then
					forward_jr <= "01";
				elsif (reg_s = write_dest_WB and reg_write_en_WB = '1') then
					forward_jr <= "10";
				else
					forward_jr <= "00";
				end if ;
			end if ;
		end if ;
	end process ; -- main_pro

end architecture ; -- behaviour