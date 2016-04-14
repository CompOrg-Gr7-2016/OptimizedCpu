library IEEE;
use ieee.std_logic_1164.all; -- allows use of the std_logic_vector type
use ieee.numeric_std.all; -- allows use of the unsigned type
use STD.textio.all;

ENTITY INSTRUCTION_CACHE IS

   GENERIC (
      instruction_file    : STRING    := "C:\\Users\\Francis\\Dropbox\\School\\2016 - Winter\\Computer Architecture\\Project Folder\\Instruction Cache\\Init.dat";
      instr_c_size_in_bytes     : INTEGER   := 256
   );
   PORT (
      clk : IN STD_LOGIC;
      address : IN std_logic_vector(31 downto 0);
      instruction : out std_logic_vector(31 downto 0)
   );

END INSTRUCTION_CACHE;

ARCHITECTURE behaviour OF INSTRUCTION_CACHE IS

    type instruction_mem_t is array (0 to instr_c_size_in_bytes-1) of std_logic_vector(7 downto 0);
    type b_in_line_t is array(1 to 4) of string(1 to 8);

    impure function init_instuction_memory(file_name : string) return instruction_mem_t is
            file file_pointer : text;
            variable line_content : string(1 to 32);
            variable bytes_in_line : b_in_line_t;
            variable line_num : line;
            variable i,j : integer := 0;
            variable char : character:='0';
            variable Mem_Address : integer:=0;
            variable  bin_value : std_logic_vector(7 downto 0);
            variable delay_cnt : integer :=0;
            variable result : instruction_mem_t := (others => (others => '0'));
        begin
              --Open the file read.txt from the specified location for reading(READ_MODE).
            file_open(file_pointer,file_name,READ_MODE);
            while not endfile(file_pointer) loop --till the end of file is reached continue.
                readline (file_pointer,line_num);  --Read the whole line from the file
              --Read the contents of the line from  the file into a variable.
                READ (line_num,line_content);
              --For each character in the line convert it to binary value.
              --And then store it in a signal named 'bin_value'.
                bytes_in_line(1) := line_content(1 to 8);
                bytes_in_line(2) := line_content(9 to 16);
                bytes_in_line(3) := line_content(17 to 24);
                bytes_in_line(4) := line_content(25 to 32);

                for i in 1 to 4 loop
                    for j in 1 to 8 loop
                        char := bytes_in_line(i)(j);
                        if(char = '0') then
                             bin_value(8-j) := '0';
                        else
                             bin_value(8-j) := '1';
                        end if;
                    end loop;
                    result(Mem_Address) := bin_value;
                    Mem_Address := Mem_Address +1;
                end loop;
            end loop;

            file_close(file_pointer);  --after reading all the lines close the file.
            return result;
    end function;

    signal instr_mem : instruction_mem_t := init_instuction_memory(instruction_file);

begin

    instr_c_clk_tick : process(address)
    begin
        instruction(31 downto 24) <= instr_mem(to_integer(unsigned(address)));
        instruction(23 downto 16) <= instr_mem(to_integer(unsigned(address)) + 1);
        instruction(15 downto 8) <= instr_mem(to_integer(unsigned(address)) + 2);
        instruction(7 downto 0) <= instr_mem(to_integer(unsigned(address)) + 3);
    end process;
end architecture;
