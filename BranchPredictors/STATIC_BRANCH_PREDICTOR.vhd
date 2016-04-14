library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity STATIC_BRANCH_PREDICTOR is
	port (
        clk : in std_logic;
		opcode : in std_logic_vector(5 downto 0);
		reg_s : in std_logic_vector(4 downto 0);
		reg_t : in std_logic_vector(4 downto 0);
        reg_s_data : in std_logic_vector(31 downto 0);
        reg_t_data : in std_logic_vector(31 downto 0);
		write_dest_M : in std_logic_vector(4 downto 0);
		reg_write_en_M : in std_logic;
        alu_result_M : in std_logic_vector(31 downto 0);
		write_dest_WB : in std_logic_vector(4 downto 0);
		reg_write_en_WB : in std_logic;
        reg_writeback_data_WB : in std_logic_vector(31 downto 0);

        branch_taken : out std_logic := '0'
	) ;
end entity ; -- STATIC_BRANCH_PREDICTOR

architecture behaviour of STATIC_BRANCH_PREDICTOR is
begin

    latch_pro : process( clk )
    
        variable equal : std_logic := '0';
        
        variable forward_s : std_logic_vector(1 downto 0) := "00";
        variable forward_t : std_logic_vector(1 downto 0) := "00";
        
        variable forward_value_s : std_logic_vector(31 downto 0) := (others => '0');
        variable forward_value_t : std_logic_vector(31 downto 0) := (others => '0');
        
    begin
        if falling_edge(clk) then
            if if (opcode = "000100") then --beq
                equal := '1';
            elsif opcode = "000101") then -- bne
                equal := '0';
            end if; 


            if (reg_s = write_dest_M and reg_write_en_M = '1') then
                forward_s := "01";
            elsif (reg_s = write_dest_WB and reg_write_en_WB = '1') then
                forward_s := "10";
            else
                forward_s := "00";
            end if ;

            -- t register
            if (reg_t = write_dest_M and reg_write_en_M = '1') then
                forward_t := "01";
            elsif (reg_t = write_dest_WB and reg_write_en_WB = '1') then
                forward_t := "10";
            else
                forward_t := "00";
            end if ;
            
            forward_value_s := alu_result_M when forward_s = "01"
                                else reg_writeback_data_WB when forward_s = "10"
                                else reg_s_data;
            forward_value_t := alu_result_M when forward_t = "01"
                                else reg_writeback_data_WB when forward_t = "10"
                                else reg_t_data;
            
            if (equal = '1') then
                if (forward_value_s = forward_value_t) then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;
            else
                if (forward_value_s = forward_value_t) then
                    branch_taken <= '0';
                else
                    branch_taken <= '1';
                end if;
            end if;
        
        end if; 
	end process ; -- main_pro

end architecture ; -- behaviour