library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FORWARDING_CONTROLLER is
  port (
	write_reg_m : in std_logic_vector (4 downto 0);
	write_reg_w : in std_logic_vector (4 downto 0);
	read_reg_1_x : in std_logic_vector (4 downto 0);
	read_reg_2_x : in std_logic_vector (4 downto 0);
	write_en_m : in std_logic;
	write_en_w : in std_logic;
	forward_1 : out std_logic_vector(1 downto 0);
	forward_2 : out std_logic_vector(1 downto 0)
  ) ;
end entity ; -- FORWARDING_CONTROLLER

architecture arch of FORWARDING_CONTROLLER is
begin

	forward_1 <= "00" when read_reg_1_x = "00000" else 
				"01" when ((write_reg_m = read_reg_1_x) and write_en_m = '1') else
				"10" when ((write_reg_w = read_reg_1_x) and (write_reg_m /= read_reg_1_x) and write_en_w = '1') else
				"00";

                
	forward_2 <= "00" when read_reg_2_x = "00000" else 
				"01" when ((write_reg_m = read_reg_2_x) and write_en_m = '1') else
				"10" when ((write_reg_w = read_reg_2_x) and (write_reg_m /= read_reg_2_x) and write_en_w = '1') else
				"00";

end architecture ; -- arch
