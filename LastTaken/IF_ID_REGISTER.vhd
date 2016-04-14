library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_ID_REGISTER is
  port (
	clk : in std_logic;

	-- REGISTER CONTROL
	stall : in std_logic;

	-- DATA STORED
		-- IN
		instruction_IN : in std_logic_vector(31 downto 0);
		pc_IN : in std_logic_vector(31 downto 0);
        
        prediction_made_IN : in std_logic;
        predicted_taken_IN : in std_logic;
        branch_target_IN : in std_logic_vector (31 downto 0);

		-- OUT
		instruction_OUT : out std_logic_vector(31 downto 0);
		pc_plus_4_OUT : out std_logic_vector(31 downto 0);
		pc_OUT : out std_logic_vector(31 downto 0) := x"00000000";
        
        prediction_made_OUT : out std_logic := '0';
        predicted_taken_OUT : out std_logic := '0';
        branch_target_OUT : out std_logic_vector (31 downto 0) := (others => '0');

	-- CPU CONTROLL
	valid : out std_logic
  ) ;
end entity ; -- IF_ID_REGISTER

architecture arch of IF_ID_REGISTER is
begin

	register_behaviour : process( clk )
	begin
		if rising_edge(clk) then
			pc_OUT <= pc_IN;
			instruction_OUT <= instruction_IN;
			pc_plus_4_OUT <= std_logic_vector(to_signed(to_integer(signed(pc_IN)) + 4, 32));
			
            prediction_made_OUT <= prediction_made_IN;
            predicted_taken_OUT <= predicted_taken_IN;
            branch_target_OUT <= branch_target_IN;
            
			if stall = '0' then
				valid <= '1';
			else
				valid <= '0';
				instruction_OUT <= (others => '0');
				pc_plus_4_OUT <= pc_IN;
                prediction_made_OUT <= '0';
			end if;
		end if;		
	end process ; -- register_behaviour
end architecture ; -- arch