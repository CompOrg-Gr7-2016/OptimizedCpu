-- This file is a CPU skeleton
--
-- entity name: cpu


library ieee;

use ieee.std_logic_1164.all; -- allows use of the std_logic_vector type
use ieee.numeric_std.all; -- allows use of the unsigned type
use STD.textio.all;


--Basic CPU interface.
--You may add your own signals, but do not remove the ones that are already there.
ENTITY cpu IS

   GENERIC (
      File_Address_Read    : STRING    := "../asm/output.txt";
      File_Address_Write   : STRING    := "MemCon.dat";
      Mem_Size_in_Word     : INTEGER   := 1024;
      IC_Size_in_Word      : INTEGER   := 256;
      Read_Delay           : INTEGER   := 0;
      Write_Delay          : INTEGER   := 0
   );
   PORT (
      clk:      	      IN    STD_LOGIC;
      reset:            IN    STD_LOGIC := '0';

      --Signals required by the MIKA testing suite
      finished_prog:    OUT   STD_LOGIC; --Set this to '1' when program execution is over
      assertion:        OUT   STD_LOGIC; --Set this to '1' when an assertion occurs
      assertion_pc:     OUT   NATURAL;   --Set the assertion's program counter location

      mem_dump:         IN    STD_LOGIC := '0'
   );

END cpu;

ARCHITECTURE rtl OF cpu IS
-- SIGNAL DEFINITIONS

    signal clock_cycles : integer := 0;

   -- INSTRUCTION FETCH STAGE
      signal program_counter_IF : std_logic_vector(31 downto 0) := x"00000000";
      signal instruction_IF : std_logic_vector(31 downto 0) := x"00000000";
      
   -- DECODE STAGE
      -- from register
         signal stall_D : std_logic := '0';
         signal valid_D : std_logic := '1';

         signal program_counter_D : std_logic_vector(31 downto 0) := x"00000000";
         signal program_counter_plus4_D : std_logic_vector(31 downto 0) := x"00000000";
         signal instruction_D :std_logic_vector(31 downto 0) := x"00000000";

      -- created in stage
         -- from instruction decoder
         signal opcode_D : std_logic_vector(5 downto 0) := "000000";
         signal reg_s_D : std_logic_vector(4 downto 0) := "00000";
         signal reg_t_D : std_logic_vector(4 downto 0) := "00000";
         signal reg_d_D : std_logic_vector(4 downto 0) := "00000";
         signal funct_D : std_logic_vector(5 downto 0) := "000000";
         signal shamt_D : std_logic_vector(4 downto 0) := "00000";
         signal immediate_raw_D : std_logic_vector (15 downto 0) := x"0000";
         signal address_D : std_logic_vector(25 downto 0) := (others => '0');

         -- from cpu controller
         signal reg_write_D : std_logic := '0';
         signal mem_write_D : std_logic := '0';
         signal mem_read_D : std_logic := '0';
         signal alu_imm_D : std_logic := '0';
         signal reg_d_dest_D : std_logic := '0';
         signal jump_D : std_logic := '0';
         signal branch_eq_D : std_logic := '0';
         signal branch_neq_D : std_logic := '0';
         signal mem_byte_D : std_logic := '0';
         signal halt_D : std_logic := '0';

         -- from register file
         signal r_31_in_D : std_logic := '0';
         signal reg_1_data_D : std_logic_vector (31 downto 0) := (others => '0');
         signal reg_2_data_D : std_logic_vector (31 downto 0) := (others => '0');

         -- from branch hazard unit
         signal forward_s_D : std_logic_vector(1 downto 0) := "00";
         signal forward_t_D : std_logic_vector(1 downto 0) := "00";
         signal forward_jr_D : std_logic_vector(1 downto 0) := "00";
         signal branch_hazard_stall : std_logic := '0';
         signal reset_stall : std_logic := '0';
         signal forward_branch_s_D : std_logic_vector(31 downto 0);
         signal forward_branch_t_D : std_logic_vector(31 downto 0);
         signal forward_jump_jr_D : std_logic_vector(31 downto 0);

      -- modified signals
         signal immediate_sign_ex_D : std_logic_vector (31 downto 0) := (others => '0');
         signal jump_target_D : std_logic_vector (31 downto 0) := (others => '0');
         signal branch_target_D : std_logic_vector (31 downto 0) := (others => '0');
         signal registers_equal_D : std_logic := '0';
         signal branch_taken_D : std_logic := '0';

   -- EXECUTION STAGE
      -- from register
         signal stall_EX : std_logic := '0';
         signal valid_EX : std_logic := '1';

         signal reg_write_EX : std_logic := '0';
         signal mem_write_EX : std_logic := '0';
         signal mem_read_EX : std_logic := '0';
         signal alu_imm_EX : std_logic := '0';
         signal reg_d_dest_EX : std_logic := '0';
         signal mem_byte_EX : std_logic := '0';
         signal halt_EX : std_logic := '0';

         signal opcode_EX : std_logic_vector(5 downto 0) := "000000";
         signal reg_s_EX : std_logic_vector(4 downto 0) := "00000";
         signal reg_t_EX : std_logic_vector(4 downto 0) := "00000";
         signal reg_d_EX : std_logic_vector(4 downto 0) := "00000";
         signal funct_EX : std_logic_vector(5 downto 0) := "000000";
         signal shamt_EX : std_logic_vector(4 downto 0) := "00000";
         signal immediate_EX : std_logic_vector(31 downto 0) := (others => '0');
         signal reg_1_data_EX : std_logic_vector (31 downto 0) := (others => '0');
         signal reg_2_data_EX : std_logic_vector (31 downto 0) := (others => '0');

      -- created in stage
         signal alu_port_1_EX : std_logic_vector(31 downto 0);
         signal alu_port_2_EX : std_logic_vector(31 downto 0);
         signal alu_reg_2_forward_EX : std_logic_vector(31 downto 0);
         signal reg_dest_EX : std_logic_vector(4 downto 0) := "00000";
         signal alu_result_EX : std_logic_vector (31 downto 0) := (others => '0');
         signal write_data_EX : std_logic_vector(31 downto 0) := (others => '0');

         -- forwarding controller
         signal forward_1_EX : std_logic_vector(1 downto 0) := "00";
         signal forward_2_EX : std_logic_vector(1 downto 0) := "00";

   -- MEMORY STAGE
      -- from register
         signal stall_M : std_logic := '0';
         signal valid_M : std_logic := '1';

         signal reg_write_M : std_logic := '0';
         signal mem_write_M : std_logic := '0';
         signal mem_read_M : std_logic := '0';
         signal mem_byte_M : std_logic := '0';
         signal halt_M : std_logic := '0';
         signal alu_result_M : std_logic_vector(31 downto 0) := (others => '0');
         signal reg_dest_M : std_logic_vector(4 downto 0) := (others => '0');
         signal write_data_M : std_logic_vector(31 downto 0) := (others => '0');

      -- created in stage
         signal read_data_M : std_logic_vector(31 downto 0) := (others => '0');

      --Main memory signals
         SIGNAL mm_address_M : NATURAL := 0;
         SIGNAL mm_word_byte_M : std_logic := '0';
         SIGNAL mm_we_M : STD_LOGIC := '0';
         SIGNAL mm_wr_done_M : STD_LOGIC := '0';
         SIGNAL mm_re_M : STD_LOGIC := '0';
         SIGNAL mm_rd_ready_M : STD_LOGIC := '0';
         SIGNAL mm_data_M : STD_LOGIC_VECTOR(31 downto 0) := (others => 'Z');
         SIGNAL mm_initialize_M : STD_LOGIC := '0';

   -- WRITE BACK STAGE
      -- from register
         signal stall_WB : std_logic := '0';
         signal valid_WB : std_logic := '1';

         signal reg_write_WB : std_logic := '0';
         signal mem_read_WB : std_logic := '0';
         signal alu_result_WB : std_logic_vector(31 downto 0) := (others => '0');
         signal reg_dest_WB : std_logic_vector(4 downto 0) := (others => '0');
         signal read_data_WB : std_logic_vector(31 downto 0) := (others => '0');

      -- created in stage
         signal reg_writeback_data_WB : std_logic_vector(31 downto 0) := (others => '0');


BEGIN
-- COMPONENT INSTANTIATION

   -- INSTRUCTION FETCH STAGE
      INSTRUCTION_CACHE_i1 : ENTITY work.INSTRUCTION_CACHE
         GENERIC MAP (
            instruction_file => File_Address_Read,
            instr_c_size_in_bytes => IC_Size_in_Word * 4
         )
         PORT MAP (
            clk => clk,
            address => program_counter_IF,
            instruction => instruction_IF
         );

   -- IF -> D REGISTER
      IF_ID_PL_REGISTER_i1 : entity work.IF_ID_REGISTER
         port map (
            clk => clk,
            -- REGISTER CONTROL
            stall => stall_D,
            -- IN
            instruction_IN => instruction_IF,
            pc_IN => program_counter_IF,
            -- OUT
            instruction_OUT => instruction_D,
            pc_plus_4_OUT => program_counter_plus4_D,
            pc_OUT => program_counter_D,
            -- CPU CONTROLL
            valid => valid_D
      ) ;

   -- DECODE STAGE
      INSTRUCTION_DECODER_i1 : entity work.INSTRUCTION_DECODER
         port map (
            instruction => instruction_D,
            opcode_31_26 => opcode_D,
            rs_25_21 => reg_s_D,
            rt_20_16 => reg_t_D,
            rd_15_11 => reg_d_D,
            shamt_10_6 => shamt_D,
            funct_5_0 => funct_D,
            immediate_15_0 => immediate_raw_D,
            address_25_0 => address_D
         ) ;

      CPU_CONTROLLER_i1 : entity work.CPU_CONTROLLER
         port map (
            opcode => opcode_D,
            funct => funct_D,
            reg_write => reg_write_D,
            mem_write => mem_write_D,
            mem_read => mem_read_D,
            alu_imm => alu_imm_D,
            reg_d_dest => reg_d_dest_D,
            jump => jump_D,
            branch_eq => branch_eq_D,
            branch_neq => branch_neq_D,
            mem_byte => mem_byte_D,
            halt => halt_D
         );

      REGISTER_FILE_i1 : entity work.REGISTER_FILE
         port map (
            clk => clk,
            reg_1_select => reg_s_D,
            reg_2_select => reg_t_D,
            write_en => reg_write_WB,
            write_select => reg_dest_WB,
            write_data => reg_writeback_data_WB,
            reg_1_data => reg_1_data_D,
            reg_2_data => reg_2_data_D,
            r_31_in => program_counter_plus4_D,
            r_31_write_en => r_31_in_D
         );

      BRANCH_HAZARD_UNIT_i1 : entity work.BRANCH_HAZARD_UNIT
         port map (
            opcode => opcode_D,
            funct => funct_D,
            reg_s => reg_s_D,
            reg_t => reg_t_D,
            write_dest_EX => reg_dest_EX,
            write_dest_M => reg_dest_M,
            write_dest_WB => reg_dest_WB,
            reg_write_en_EX => reg_write_EX,
            reg_write_en_M => reg_write_M,
            reg_write_en_WB => reg_write_WB,
            forward_s => forward_s_D,
            forward_t => forward_t_D,
            forward_jr => forward_jr_D,
            stall => branch_hazard_stall
      ) ;

   -- D -> EX REGISTER
      D_EX_PL_REGISTER_i1: entity work.ID_EX_REGISTER
         port map (
            clk => clk,

            -- REGISTER CONTROL
            stall => stall_EX,
            -- DATA STORED
            -- IN
            reg_write_IN => reg_write_D,
            mem_write_IN => mem_write_D,
            mem_read_IN => mem_read_D,
            alu_imm_IN => alu_imm_D,
            reg_d_dest_IN => reg_d_dest_D,
            mem_byte_IN => mem_byte_D,
            halt_IN => halt_D,
            opcode_IN => opcode_D,
            reg_s_IN => reg_s_D,
            reg_t_IN => reg_t_D,
            reg_d_IN => reg_d_D,
            funct_IN => funct_D,
            shamt_IN => shamt_D,
            immediate_IN => immediate_sign_ex_D,
            reg_1_data_IN => reg_1_data_D,
            reg_2_data_IN => reg_2_data_D,
            -- OUT
            reg_write_OUT => reg_write_EX,
            mem_write_OUT => mem_write_EX,
            mem_read_OUT => mem_read_EX,
            alu_imm_OUT => alu_imm_EX,
            reg_d_dest_OUT => reg_d_dest_EX,
            mem_byte_OUT => mem_byte_EX,
            halt_OUT => halt_EX,
            opcode_OUT => opcode_EX,
            reg_s_OUT => reg_s_EX,
            reg_t_OUT => reg_t_EX,
            reg_d_OUT => reg_d_EX,
            funct_OUT => funct_EX,
            shamt_OUT => shamt_EX,
            immediate_OUT => immediate_EX,
            reg_1_data_OUT => reg_1_data_EX,
            reg_2_data_OUT => reg_2_data_EX,
            -- CPU CONTROLL
            valid => valid_EX
      ) ;

   -- EXECUTION STAGE
      ALU_i1 : entity work.ALU
         port map (
            opcode => opcode_EX,
            funct => funct_EX,
            shamt => shamt_EX,
            port_1 => alu_port_1_EX,
            port_2 => alu_port_2_EX,
            result => alu_result_EX
      ) ;

      FORWARDING_CONTROLLER_i1 : entity work.FORWARDING_CONTROLLER
         port map (
            write_reg_m => reg_dest_M,
            write_reg_w => reg_dest_WB,
            read_reg_1_x => reg_s_EX,
            read_reg_2_x => reg_t_EX,
            write_en_m => reg_write_M,
            write_en_w => reg_write_WB,
            forward_1 => forward_1_EX,
            forward_2 => forward_2_EX
      ) ;

   -- EX -> M REGISTER
      EX_MEM_REGISTER_i1 : entity work.EX_MEM_REGISTER
         port map (
            clk => clk,
            -- REGISTER CONTROL
            stall => stall_M,
            -- IN
            reg_write_IN => reg_write_EX,
            mem_write_IN => mem_write_EX,
            mem_read_IN => mem_read_EX,
            mem_byte_IN => mem_byte_EX,
            halt_IN => halt_EX,
            alu_result_IN => alu_result_EX,
            reg_dest_IN => reg_dest_EX,
            write_data_IN => alu_reg_2_forward_EX,
            -- OUT
            reg_write_OUT => reg_write_M,
            mem_write_OUT => mem_write_M,
            mem_read_OUT => mem_read_M,
            mem_byte_OUT => mem_byte_M,
            halt_OUT => halt_M,
            alu_result_OUT => alu_result_M,
            reg_dest_OUT => reg_dest_M,
            write_data_OUT => write_data_M,
            -- CPU CONTROLL
            valid => valid_M
      ) ;

   -- MEMORY STAGE
      --Instantiation of the main memory component
      main_memory : ENTITY work.Main_Memory
         GENERIC MAP (
            File_Address_Read   => File_Address_Read,
            File_Address_Write  => File_Address_Write,
            Mem_Size_in_Word    => Mem_Size_in_Word,
            Read_Delay          => Read_Delay,
            Write_Delay         => Write_Delay
         )
         PORT MAP (
            clk         => clk,
            address     => mm_address_M,
            Word_Byte   => mm_word_byte_M,
            we          => mm_we_M,
            wr_done     => mm_wr_done_M,
            re          => mm_re_M,
            rd_ready    => mm_rd_ready_M,
            data        => mm_data_M,
            initialize  => mm_initialize_M,
            dump        => mem_dump
      );

   -- M -> WB REGISTER
      MEM_WB_REGISTER_i1 : entity work.MEM_WB_REGISTER
         port map (
            clk => clk,
            -- REGISTER CONTROL
            stall => stall_WB,
            -- IN
            reg_write_IN => reg_write_M,
            mem_read_IN => mem_read_M,
            alu_result_IN => alu_result_M,
            read_data_IN => read_data_M,
            reg_dest_IN => reg_dest_M,
            -- OUT
            reg_write_OUT => reg_write_WB,
            mem_read_OUT => mem_read_WB,
            alu_result_OUT => alu_result_WB,
            read_data_OUT => read_data_WB,
            reg_dest_OUT => reg_dest_WB,
            -- CPU CONTROLL
            valid => valid_WB
      ) ;

   -- WRITE BACK STAGE (none)

-- COMBINATIONAL LOGIC
   -- INSTRUCTION FETCH STAGE
      program_counter_IF <= program_counter_D when branch_hazard_stall = '1'
                              else branch_target_D when branch_taken_D = '1' -- branch (TODO: clear registers)
                              else jump_target_D when jump_D = '1' -- jump
                              else program_counter_plus4_D;

   -- DECODE STAGE
      immediate_sign_ex_D <= std_logic_vector(shift_left(to_signed(to_integer(signed(immediate_raw_D)), 32), 16)) when opcode_D = "001111"
                              else std_logic_vector(to_signed(to_integer(signed(immediate_raw_D)), 32));
      branch_target_D <= std_logic_vector(to_unsigned(to_integer(shift_left(signed(immediate_sign_ex_D), 2)) + to_integer(unsigned(program_counter_plus4_D)), 32));

      forward_branch_s_D <= alu_result_M when forward_s_D = "01"
                              else reg_writeback_data_WB when forward_s_D = "10"
                              else reg_1_data_D;

      forward_branch_t_D <= alu_result_M when forward_t_D = "01"
                              else reg_writeback_data_WB when forward_t_D = "10"
                              else reg_2_data_D;

      forward_jump_jr_D <= alu_result_M when forward_jr_D = "01"
                              else reg_writeback_data_WB when forward_jr_D = "10"
                              else reg_1_data_D;

      jump_target_D(31 downto 28) <=  forward_jump_jr_D(31 downto 28) when (funct_D = "001000" and opcode_D = "000000") -- jump register
                                       else program_counter_plus4_D(31 downto 28); -- jump immediate
      jump_target_D(27 downto 2) <= forward_jump_jr_D(27 downto 2) when (funct_D = "001000" and opcode_D = "000000") -- jump register
                                       else address_D; -- jump immediate
      jump_target_D(1 downto 0) <= forward_jump_jr_D(1 downto 0) when (funct_D = "001000" and opcode_D = "000000") -- jump register
                                       else "00";

      registers_equal_D <= '1' when forward_branch_s_D = forward_branch_t_D
                           else '0';
      branch_taken_D <= (branch_eq_D and registers_equal_D) or (branch_neq_D and (not registers_equal_D));

      r_31_in_D <= '1' when opcode_D = "000011" else '0'; -- jal


   -- EXECUTION STAGE
      reg_dest_EX <= reg_d_EX when reg_d_dest_EX = '1' else reg_t_EX;
      alu_port_1_EX <= reg_1_data_EX when forward_1_EX = "00"
                        else alu_result_M when forward_1_EX = "01"
                        else reg_writeback_data_WB when forward_1_EX = "10"
                        else reg_1_data_EX;
      alu_reg_2_forward_EX <= reg_2_data_EX when forward_2_EX = "00"
                        else alu_result_M when forward_2_EX = "01"
                        else reg_writeback_data_WB when forward_2_EX = "10"
                        else reg_2_data_EX;
      alu_port_2_EX <= immediate_EX when alu_imm_EX = '1'
                        else alu_reg_2_forward_EX;

      stall_EX <= branch_hazard_stall when reset = '0'
                    else '1';

   -- MEMORY STAGE
      mm_address_M <= to_integer(unsigned(alu_result_M));
      mm_word_byte_M <= (not mem_byte_M);
      mm_we_M <= mem_write_M;
      mm_re_M <= mem_read_M;

      mem_data_pro : process (mem_write_M, mem_read_M)
      begin
         if mem_write_M = '1' then
            mm_data_M <= write_data_M;
         end if;

         if mem_read_M = '1' then
            read_data_M <= mm_data_M;
         end if;
      end process;


   -- WRITE BACK STAGE
      reg_writeback_data_WB <= read_data_WB when mem_read_WB = '1'
                                 else alu_result_WB;

   process (reset)
   begin
      if reset = '1' then
         stall_D <= '1';
         stall_M <= '1';
         stall_WB <= '1';
         mm_initialize_M <= '1';
      else
         stall_D <= '0';
         stall_M <= '0';
         stall_WB <= '0';
         mm_initialize_M <= '0';
      end if ;
   end process;

   process(clk)
   begin
    if rising_edge(clk) then
        clock_cycles <= clock_cycles + 1;
    end if;
   end process;

END rtl;
