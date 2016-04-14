library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity REGISTER_FILE is
  port (
	clk : in std_logic;
	reg_1_select : in std_logic_vector(4 downto 0);
	reg_2_select : in std_logic_vector(4 downto 0);
	write_en : in std_logic;
	write_select : in std_logic_vector(4 downto 0);
	write_data : in std_logic_vector(31 downto 0);
	reg_1_data : out std_logic_vector(31 downto 0);
	reg_2_data : out std_logic_vector(31 downto 0);
	r_31_in : in std_logic_vector(31 downto 0);
	r_31_write_en : in std_logic
  );
end entity ; -- REGISTER_FILE

architecture arch of REGISTER_FILE is
	type register_file_t is array(0 to 31) of std_logic_vector(31 downto 0);
	signal register_file : register_file_t := ((others=> (others=>'0')));
begin

	register_pro : process( reg_1_select, reg_2_select, clk )
	begin

		reg_1_data <= register_file(to_integer(unsigned(reg_1_select)));
		reg_2_data <= register_file(to_integer(unsigned(reg_2_select)));
		
		if falling_edge(clk) then
			if write_en = '1' then
				if write_select /= "00000" then
					register_file(to_integer(unsigned(write_select))) <= write_data;

					if write_select = reg_1_select then
						reg_1_data <= write_data;
					end if;

					if write_select = reg_2_select then
						reg_2_data <= write_data;
					end if;
				end if;
			end if ;

			if r_31_write_en = '1' then
				register_file(31) <= r_31_in;
			end if;
		end if;

	end process ; -- write_back_pro

end architecture ; -- arch