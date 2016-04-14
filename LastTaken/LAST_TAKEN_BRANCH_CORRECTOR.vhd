library ieee;
use ieee.std_logic_1164.all;        -- standard unresolved logic UX01ZWLH-
use ieee.numeric_std.all;

entity LAST_TAKEN_BRANCH_CORRECTOR is
    port (
        clk : in std_logic;
        opcode : in std_logic_vector(5 downto 0);
        -- Branch values
        prediction_made : in std_logic;
        predicted_taken : in std_logic;
        branch_target : in std_logic_vector(31 downto 0);
        pc_plus_4 : in std_logic_vector(31 downto 0);
        -- Verifying correctness of decision
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
        -- Outputs
        predict_taken : out std_logic := '0';
        wrong_prediction : out std_logic := '0';
        fix_target : out std_logic_vector(31 downto 0) := (others => '0')
    ) ;
end entity ; -- LAST_TAKEN_BRANCH_CORRECTOR

architecture arch of LAST_TAKEN_BRANCH_CORRECTOR is


begin

latch_pro : process( clk )
        variable equal : std_logic := '0';
        
        variable forward_s : std_logic_vector(1 downto 0) := "00";
        variable forward_t : std_logic_vector(1 downto 0) := "00";
        
        variable forward_value_s : std_logic_vector(31 downto 0) := (others => '0');
        variable forward_value_t : std_logic_vector(31 downto 0) := (others => '0');
    begin
        if (falling_edge(clk) and prediction_made = '1') then
            if (opcode = "000100") then --beq
                equal := '1';
            elsif (opcode = "000101") then -- bne
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
            
            if (forward_s = "01") then
                forward_value_s := alu_result_M;
            elsif (forward_s = "10") then
                forward_value_s := reg_writeback_data_WB;
            else
                forward_value_s := reg_s_data;
            end if;
            
            if (forward_t = "01") then
                forward_value_t := alu_result_M;
            elsif (forward_t = "10") then
                forward_value_t := reg_writeback_data_WB;
            else
                forward_value_t := reg_t_data;
            end if;
            
            if (equal = '1') then --beq
                if (forward_value_s = forward_value_t) then --branch should have been taken
                    predict_taken <= '1';
                    if (predicted_taken = '1') then -- OK
                        wrong_prediction <= '0';
                    else -- NOT OK
                        wrong_prediction <='1';
                        fix_target <= branch_target;
                    end if;
                else  --branch should not have been taken
                    predict_taken <= '0';
                    if (predicted_taken = '1') then -- NOT OK
                        wrong_prediction <='1';
                        fix_target <= pc_plus_4;
                    else -- OK
                        wrong_prediction <='0';
                    end if;
                end if;
            else --bne
                if (forward_value_s = forward_value_t) then -- SHOULD NOT HAVE BEEN TAKEN
                    predict_taken <= '0';
                    if (predicted_taken = '1') then -- NOT OK
                        wrong_prediction <= '1';
                        fix_target <= pc_plus_4;
                    else -- OK
                        wrong_prediction <= '0';
                    end if;
                else -- SHOULD HAVE BEEN TAKEN
                    predict_taken <= '1';
                    if (predicted_taken = '1') then -- OK
                        wrong_prediction <= '0';
                    else -- NOT OK
                        wrong_prediction <= '1';
                        fix_target <= branch_target;
                    end if;
                end if;
            end if;
        else 
            wrong_prediction <= '0';
        end if; 
	end process ; -- main_pro
end architecture ; -- arch