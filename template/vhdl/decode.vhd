library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;
use work.regfile;

entity decode is
    port (
        clk, reset : in  std_logic;
        stall      : in  std_logic;
        flush      : in  std_logic;

        -- from fetch
        pc_in      : in  pc_type;
        instr      : in  instr_type;

        -- from writeback
        reg_write  : in reg_write_type;

        -- towards next stages
        pc_out     : out pc_type;
        exec_op    : out exec_op_type;
        mem_op     : out mem_op_type;
        wb_op      : out wb_op_type;

        -- exceptions
        exc_dec    : out std_logic
    );
end entity;

architecture rtl of decode is
 
 component regfile is
    port (
        clk              : in  std_logic;
        reset            : in  std_logic;
        stall            : in  std_logic;
        rdaddr1, rdaddr2 : in  reg_adr_type := (others => '0');
        rddata1, rddata2 : out data_type;
        wraddr           : in  reg_adr_type;
        wrdata           : in  data_type;
        regwrite         : in  std_logic
    );
 end component;
 
 signal int_instr : instr_type := (others => '0');
 signal int_pc : pc_type := (others => '0');
 signal int_readdata1, int_readdata2 : data_type;
 signal reg_readdata1, reg_readdata2 : data_type; 
 signal help_rdaddr1, help_rdaddr2 : reg_adr_type; 
 signal wraddr : reg_adr_type;
 signal wrdata : data_type;
 signal regwrite : std_logic;
 signal int_pc_in : pc_type; 
 signal int_pc_out : pc_type;  
 signal int_rdaddr1 : reg_adr_type; 
 signal int_rdaddr2 : reg_adr_type; 
 signal int_reg_write : reg_write_type; 
 --signal int_rdaddr1, int_rdaddr2 : reg_adr_type; 

 constant fct7_zeros : std_logic_vector(6 downto 0) := (others => '0');
 constant OPC_LOAD : std_logic_vector(6 downto 0) := "0000011";
 constant OPC_STORE : std_logic_vector(6 downto 0) := "0100011";
 constant OPC_BRANCH : std_logic_vector(6 downto 0) := "1100011";
 constant OPC_JALR : std_logic_vector(6 downto 0) := "1100111";
 constant OPC_JAL : std_logic_vector(6 downto 0) := "1101111";
 constant OPC_OP_IMM : std_logic_vector(6 downto 0) := "0010011";
 constant OPC_OP : std_logic_vector(6 downto 0) := "0110011";
 constant OPC_AUIPC : std_logic_vector(6 downto 0) := "0010111";
 constant OPC_LUI : std_logic_vector(6 downto 0) := "0110111";
 
 alias pre_opcode : std_logic_vector(6 downto 0) is instr(6 downto 0);
 alias opcode : std_logic_vector(6 downto 0) is int_instr(6 downto 0);
 alias rd : std_logic_vector(4 downto 0) is int_instr(11 downto 7);
 alias rs1 : std_logic_vector(4 downto 0) is int_instr(19 downto 15);
 alias rs2 : std_logic_vector(4 downto 0) is int_instr(24 downto 20);
 alias fct3 : std_logic_vector(2 downto 0) is int_instr(14 downto 12);
 alias fct7 : std_logic_vector(6 downto 0) is int_instr(31 downto 25);
 alias shamt : std_logic_vector(4 downto 0) is int_instr(11 downto 7);

begin
	
	reg_inst : regfile
	port map(
        clk => clk,
        reset => reset,
        stall => stall,
        --rdaddr1 => instr(19 downto 15),
	--rdaddr2 => instr(24 downto 20),
	rdaddr1 => int_rdaddr1,
	rdaddr2 => int_rdaddr2,
        rddata1 => reg_readdata1,
	rddata2 => reg_readdata2,
        wraddr => reg_write.reg,
        wrdata => reg_write.data,
        regwrite => reg_write.write
    );
	
	sync : process(reset, clk, flush, stall, reg_readdata1, reg_readdata2)
	begin
		if reset = '0' then
			int_instr <= (others => '0');
			int_pc <= (others => '0');
			int_rdaddr1 <= (others => '0'); 
			int_rdaddr2 <= (others => '0'); 

		elsif flush = '1' then 
			int_instr <= (others => '0'); 
			int_pc <= (others => '0'); 
			int_reg_write <= reg_write_nop; 
			int_rdaddr1 <= (others => '0'); 
			int_rdaddr2 <= (others => '0'); 

		elsif rising_edge(clk) and stall = '0' and flush = '0' then
			int_instr <= instr;	
			int_pc <= pc_in; 
			int_reg_write <= reg_write; 
			int_rdaddr1 <= instr(19 downto 15); 
			int_rdaddr2 <= instr(24 downto 20); 

			int_readdata1 <= reg_readdata1; 
			int_readdata2 <= reg_readdata2; 

			--branch, op, store
			if reg_write.write = '1' and (pre_opcode = OPC_BRANCH or pre_opcode = OPC_OP or  pre_opcode = OPC_STORE) then 
				--replace rs1
				if reg_write.reg = instr(19 downto 15) then
					int_readdata1 <= reg_write.data;
				
				elsif help_rdaddr1 /= instr(19 downto 15) then
						--don't get result of older read access to regfile 
						int_readdata1 <= (others => '0'); 
				end if; 

				
				--replace rs2 
				if reg_write.reg = instr(24 downto 20) then
					int_readdata2 <= reg_write.data;	
			
				elsif help_rdaddr2 /= instr(24 downto 20) then 
						--don't get result of older read access to regfile
						int_readdata2 <= (others => '0'); 
				end if; 	
				--maybe both

				if reg_write.reg = instr(19 downto 15) and instr(19 downto 15) = instr(24 downto 0) then
				
					int_readdata1 <= reg_write.data;	
					int_readdata2 <= reg_write.data;
				
				end if;
			
			else  
				/*
				if help_rdaddr1 /= instr(19 downto 15) then 
						int_readdata1 <= (others => '0'); 
				end if; 
			
				if help_rdaddr2 /= instr(24 downto 20) then 
						int_readdata2 <= (others => '0'); 
				end if; */ 
			
			end if; 
		end if;
	end process;
	
	output : process(all)
	begin		
		exec_op <= EXEC_NOP;
		mem_op <= MEM_NOP;
		wb_op <= WB_NOP;
		exc_dec <= '0';
		pc_out <= int_pc;

		help_rdaddr1 <= int_rdaddr1; 
		help_rdaddr2 <= int_rdaddr2; 

		case opcode is
			when OPC_OP =>
		            exec_op.imm_flag <= '0';
            		    exec_op.store_flag <= '0';
			    exec_op.pc_flag <= '0';
				case fct3 is
					when "000" =>
						case fct7 is
							when fct7_zeros => -- R ADD rd, rs1, rs2
								exec_op.aluop <= ALU_ADD;
								exec_op.rs1 <= rs1;
								exec_op.rs2 <= rs2;

								exec_op.readdata1 <= int_readdata1;
								exec_op.readdata2 <= int_readdata2;

								wb_op.src <= WBS_ALU;
								wb_op.write <= '1'; 
                        wb_op.rd <= rd;
							when "0100000" => -- R SUB rd, rs1, rs2
								exec_op.aluop <= ALU_SUB;
								exec_op.rs1 <= rs1;
								exec_op.rs2 <= rs2;
								if int_reg_write.reg = rs1 then
									exec_op.readdata1 <= int_reg_write.data;
									exec_op.readdata2 <= int_readdata2;
								elsif int_reg_write.reg = rs2 then
									exec_op.readdata2 <= int_reg_write.data;
									exec_op.readdata1 <= int_readdata1;
								elsif int_reg_write.reg = rs1 and rs1 = rs2 then
									exec_op.readdata1 <= int_reg_write.data;
									exec_op.readdata2 <= int_reg_write.data;
								else	
									exec_op.readdata1 <= int_readdata1;
									exec_op.readdata2 <= int_readdata2;
								end if;
								wb_op.src <= WBS_ALU;
								wb_op.write <= '1';
								wb_op.rd <= rd;
							when others => exc_dec <= '1';
						end case;	
				   when "001" =>
						if fct7 = fct7_zeros then -- R SLL rd = rs1 << rs2(4:0)
							exec_op.aluop <= ALU_SLL;
							exec_op.rs1 <= rs1;
							exec_op.rs2 <= rs2;
							if int_reg_write.reg = rs1 then
								exec_op.readdata1 <= int_reg_write.data;
								exec_op.readdata2 <= int_readdata2;
							elsif int_reg_write.reg = rs2 then
								exec_op.readdata2 <= int_reg_write.data;
								exec_op.readdata1 <= int_readdata1;
							elsif int_reg_write.reg = rs1 and rs1 = rs2 then
								exec_op.readdata1 <= int_reg_write.data;
								exec_op.readdata2 <= int_reg_write.data;
							else	
								exec_op.readdata1 <= int_readdata1;
								exec_op.readdata2 <= int_readdata2;
							end if;
							wb_op.src <= WBS_ALU;
							wb_op.write <= '1';
							wb_op.rd <= rd;
						else
							exc_dec <= '1';
						end if;
				   when "010" => 
						if fct7 = fct7_zeros then -- R SLT rd = (rs1\+- < rs2\+-) ? 1:0
							exec_op.aluop <= ALU_SLT;
							exec_op.rs1 <= rs1;
							exec_op.rs2 <= rs2;
							if int_reg_write.reg = rs1 then
								exec_op.readdata1 <= int_reg_write.data;
								exec_op.readdata2 <= int_readdata2;
							elsif int_reg_write.reg = rs2 then
								exec_op.readdata2 <= int_reg_write.data;
								exec_op.readdata1 <= int_readdata1;
							elsif int_reg_write.reg = rs1 and rs1 = rs2 then
								exec_op.readdata1 <= int_reg_write.data;
								exec_op.readdata2 <= int_reg_write.data;
							else	
								exec_op.readdata1 <= int_readdata1;
								exec_op.readdata2 <= int_readdata2;
							end if;
                     					wb_op.src <= WBS_ALU;
							wb_op.write <= '1';
							wb_op.rd <= rd;
						else
							exc_dec <= '1';
						end if;
					when "011" =>
						if fct7 = fct7_zeros then -- R SLTU rd = (rs1\0 < rs\0) ? 1:0
							exec_op.aluop <= ALU_SLTU;
							exec_op.rs1 <= rs1;
							exec_op.rs2 <= rs2;
							if int_reg_write.reg = rs1 then
								exec_op.readdata1 <= int_reg_write.data;
								exec_op.readdata2 <= int_readdata2;
							elsif int_reg_write.reg = rs2 then
								exec_op.readdata2 <= int_reg_write.data;
								exec_op.readdata1 <= int_readdata1;
							elsif int_reg_write.reg = rs1 and rs1 = rs2 then
								exec_op.readdata1 <= int_reg_write.data;
								exec_op.readdata2 <= int_reg_write.data;
							else	
								exec_op.readdata1 <= int_readdata1;
								exec_op.readdata2 <= int_readdata2;
							end if;
							wb_op.src <= WBS_ALU;
							wb_op.write <= '1';
							wb_op.rd <= rd;
						end if;
					when "100" =>
						if fct7 = fct7_zeros then -- R XOR rd = rs1^rs2
							exec_op.aluop <= ALU_XOR;
							exec_op.rs1 <= rs1;
							exec_op.rs2 <= rs2;
							if int_reg_write.reg = rs1 then
								exec_op.readdata1 <= int_reg_write.data;
								exec_op.readdata2 <= int_readdata2;
							elsif int_reg_write.reg = rs2 then
								exec_op.readdata2 <= int_reg_write.data;
								exec_op.readdata1 <= int_readdata1;
							elsif int_reg_write.reg = rs1 and rs1 = rs2 then
								exec_op.readdata1 <= int_reg_write.data;
								exec_op.readdata2 <= int_reg_write.data;
							else	
								exec_op.readdata1 <= int_readdata1;
								exec_op.readdata2 <= int_readdata2;
							end if;
							wb_op.src <= WBS_ALU;
							wb_op.write <= '1';
							wb_op.rd <= rd;
						else
							exc_dec <= '1';
						end if;	
					when "101" =>
						case fct7 is
							when fct7_zeros =>  -- R SRL rd = rs1\0 >> rs2(4:0)
								exec_op.aluop <= ALU_SRL;
								exec_op.rs1 <= rs1;
								exec_op.rs2 <= rs2;
								if int_reg_write.reg = rs1 then
									exec_op.readdata1 <= int_reg_write.data;
									exec_op.readdata2 <= int_readdata2;
								elsif int_reg_write.reg = rs2 then
									exec_op.readdata2 <= int_reg_write.data;
									exec_op.readdata1 <= int_readdata1;
								elsif int_reg_write.reg = rs1 and rs1 = rs2 then
									exec_op.readdata1 <= int_reg_write.data;
									exec_op.readdata2 <= int_reg_write.data;
								else	
									exec_op.readdata1 <= int_readdata1;
									exec_op.readdata2 <= int_readdata2;
								end if;
								wb_op.src <= WBS_ALU;
								wb_op.write <= '1';
								wb_op.rd <= rd;
							when "0100000" =>  -- R SRA rd = rs1\+- >> rs2(4:0)
								exec_op.aluop <= ALU_SRA;
								exec_op.rs1 <= rs1;
								exec_op.rs2 <= rs2;
								if int_reg_write.reg = rs1 then
									exec_op.readdata1 <= int_reg_write.data;
									exec_op.readdata2 <= int_readdata2;
								elsif int_reg_write.reg = rs2 then
									exec_op.readdata2 <= int_reg_write.data;
									exec_op.readdata1 <= int_readdata1;
								elsif int_reg_write.reg = rs1 and rs1 = rs2 then
									exec_op.readdata1 <= int_reg_write.data;
									exec_op.readdata2 <= int_reg_write.data;
								else	
									exec_op.readdata1 <= int_readdata1;
									exec_op.readdata2 <= int_readdata2;
								end if;
								wb_op.src <= WBS_ALU;	
								wb_op.write <= '1';
								wb_op.rd <= rd;
							when others => exc_dec <= '1';
						end case;	
					when "110" =>
						if fct7 = fct7_zeros then -- R OR rd = rs1 | rs2
							exec_op.aluop <= ALU_OR;
							exec_op.rs1 <= rs1;
							exec_op.rs2 <= rs2;
							if int_reg_write.reg = rs1 then
								exec_op.readdata1 <= int_reg_write.data;
								exec_op.readdata2 <= int_readdata2;
							elsif int_reg_write.reg = rs2 then
								exec_op.readdata2 <= int_reg_write.data;
								exec_op.readdata1 <= int_readdata1;
							elsif int_reg_write.reg = rs1 and rs1 = rs2 then
								exec_op.readdata1 <= int_reg_write.data;
								exec_op.readdata2 <= int_reg_write.data;
							else	
								exec_op.readdata1 <= int_readdata1;
								exec_op.readdata2 <= int_readdata2;
							end if;
							wb_op.src <= WBS_ALU;
							wb_op.write <= '1';
							wb_op.rd <= rd;
						else 
							exc_dec <= '1';
						end if;	
					when "111" =>
						if fct7 = fct7_zeros then -- R AND rd = rs1 & rs2
							exec_op.aluop <= ALU_AND;
							exec_op.rs1 <= rs1;
							exec_op.rs2 <= rs2;
							if int_reg_write.reg = rs1 then
								exec_op.readdata1 <= int_reg_write.data;
								exec_op.readdata2 <= int_readdata2;
							elsif int_reg_write.reg = rs2 then
								exec_op.readdata2 <= int_reg_write.data;
								exec_op.readdata1 <= int_readdata1;
							elsif int_reg_write.reg = rs1 and rs1 = rs2 then
								exec_op.readdata1 <= int_reg_write.data;
								exec_op.readdata2 <= int_reg_write.data;
							else	
								exec_op.readdata1 <= int_readdata1;
								exec_op.readdata2 <= int_readdata2;
							end if;
							wb_op.src <= WBS_ALU;
							wb_op.write <= '1';
							wb_op.rd <= rd;
						else 
							exc_dec <= '1';
						end if;	
					when others =>	exc_dec <= '1';
				end case;	
			when OPC_OP_IMM =>
                exec_op.imm_flag <= '1';
                exec_op.store_flag <= '0';
					 exec_op.pc_flag <= '0';
					 exec_op.imm(31 downto 11) <= (others => int_instr(31));
					 exec_op.imm(10 downto 5) <= int_instr(30 downto 25);
					 exec_op.imm(4 downto 1) <= int_instr(24 downto 21);
					 exec_op.imm(0) <= int_instr(20);
				case fct3 is
					when "000" =>    -- I ADDI rd = rs1 + imm\+-
						exec_op.aluop <= ALU_ADD;
						exec_op.rs1 <= rs1;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
						else
							exec_op.readdata1 <= int_readdata1;
						end if;
						wb_op.src <= WBS_ALU;
						wb_op.write <= '1';
						wb_op.rd <= rd;
					when "010" =>    -- I SLTI rd = (rs1\+- < imm\+-) ? 1 : 0
						exec_op.aluop <= ALU_SLT;
						exec_op.rs1 <= rs1;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
						else
							exec_op.readdata1 <= int_readdata1;
						end if;
						wb_op.src <= WBS_ALU;
						wb_op.write <= '1';
						wb_op.rd <= rd;
					when "011" =>    -- I SLTIU rd = (rs1\0 < (imm\+-)\0) ? 1 : 0
						exec_op.aluop <= ALU_SLTU;
						exec_op.rs1 <= rs1;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
						else
							exec_op.readdata1 <= int_readdata1;
						end if;
						wb_op.src <= WBS_ALU;
						wb_op.write <= '1';
						wb_op.rd <= rd;
					when "100" =>    -- I XORI rd = rs1 ^ imm\+-
						exec_op.aluop <= ALU_XOR;
						exec_op.rs1 <= rs1;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
						else
							exec_op.readdata1 <= int_readdata1;
						end if;
						wb_op.src <= WBS_ALU;
						wb_op.write <= '1';
						wb_op.rd <= rd;
					when "110" =>   -- I ORI rd = rs1 | imm\+-
						exec_op.aluop <= ALU_OR;
						exec_op.rs1 <= rs1;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
						else
							exec_op.readdata1 <= int_readdata1;
						end if;
						wb_op.src <= WBS_ALU;
						wb_op.write <= '1';
						wb_op.rd <= rd;	
					when "111" =>   -- I ANDI rd = rs1 & imm\+-
						exec_op.aluop <= ALU_AND;
						exec_op.rs1 <= rs1;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
						else
							exec_op.readdata1 <= int_readdata1;
						end if;
						wb_op.src <= WBS_ALU;
						wb_op.write <= '1';
						wb_op.rd <= rd;	
					when "001" =>     -- I SLLI rd = rs1 << shamt
						exec_op.aluop <= ALU_SLL;
						exec_op.rs1 <= rs1;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
						else
							exec_op.readdata1 <= int_readdata1;
						end if;
						exec_op.imm(4 downto 0) <= shamt;
						wb_op.src <= WBS_ALU;
						wb_op.write <= '1';
						wb_op.rd <= rd;	
					when "101" =>    
                        case exec_op.imm(10) is
                            when '0' =>    -- I SRLI rd = rs1\0 >> shamt
                                exec_op.aluop <= ALU_SRL;
										  exec_op.rs1 <= rs1;
                                if int_reg_write.reg = rs1 then
												exec_op.readdata1 <= int_reg_write.data;
										  else
												exec_op.readdata1 <= int_readdata1;
										  end if;
                                exec_op.imm(4 downto 0) <= shamt;
                                wb_op.src <= WBS_ALU;
                                wb_op.write <= '1';
                                wb_op.rd <= rd;
                            when '1' =>   -- I SRAI rd = rs1\+- >> shamt...imm[4:0]=shamt
                                exec_op.aluop <= ALU_SRA;
										  exec_op.rs1 <= rs1;
                                if int_reg_write.reg = rs1 then
												exec_op.readdata1 <= int_reg_write.data;
										  else
												exec_op.readdata1 <= int_readdata1;
										  end if;
                                exec_op.imm(4 downto 0) <= shamt;
                                wb_op.src <= WBS_ALU;
                                wb_op.write <= '1';
                                wb_op.rd <= rd;	
                            when others => exc_dec <= '1';
                        end case;
					when others => exc_dec <= '1';
				end case;
			when OPC_STORE =>
						exec_op.imm_flag <= '0';
						exec_op.store_flag <= '1';
						exec_op.pc_flag <= '0';
						exec_op.imm(31 downto 11) <= (others => int_instr(31));
						exec_op.imm(10 downto 5) <= int_instr(30 downto 25);
						exec_op.imm(4 downto 1) <= int_instr(11 downto 8);
						exec_op.imm(0) <= int_instr(7);
				case fct3 is
					when "000" =>    -- S SB DMEM[rs1 + imm\+-] = rs2(7 : 0)
						exec_op.aluop <= ALU_ADD;
						exec_op.rs1 <= rs1;
						exec_op.rs2 <= rs2;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= (others => '0');
							exec_op.readdata2(7 downto 0) <= int_readdata2(7 downto 0); 
						elsif int_reg_write.reg = rs2 then
							exec_op.readdata2 <= (others => '0');
							exec_op.readdata2(7 downto 0) <= int_reg_write.data(7 downto 0);
							exec_op.readdata1 <= int_readdata1;
						elsif int_reg_write.reg = rs1 and rs1 = rs2 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= (others => '0');
							exec_op.readdata2(7 downto 0) <= int_reg_write.data(7 downto 0);
						else	
							exec_op.readdata1 <= int_readdata1;
							exec_op.readdata2 <= (others => '0');
							exec_op.readdata2(7 downto 0) <= int_readdata2(7 downto 0); 
						end if;
						wb_op.src <= WBS_MEM;
						wb_op.write <= '0';
						mem_op.mem.memtype <= MEM_B;
						mem_op.mem.memread <= '0';
						mem_op.mem.memwrite <= '1';
					when "001" =>    -- S SH DMEM[rs1 + imm\+-] = rs2(15 : 0)
						exec_op.aluop <= ALU_ADD;
						exec_op.rs1 <= rs1;
					   exec_op.rs2 <= rs2;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= (others => '0');
							exec_op.readdata2(15 downto 0) <= int_readdata2(15 downto 0);
						elsif int_reg_write.reg = rs2 then
							exec_op.readdata2 <= (others => '0');
							exec_op.readdata2(15 downto 0) <= int_reg_write.data(15 downto 0);
							exec_op.readdata1 <= int_readdata1;
						elsif int_reg_write.reg = rs1 and rs1 = rs2 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= (others => '0');
							exec_op.readdata2(15 downto 0) <= int_reg_write.data(15 downto 0);
						else	
							exec_op.readdata1 <= int_readdata1;
							exec_op.readdata2 <= (others => '0');
							exec_op.readdata2(15 downto 0) <= int_readdata2(15 downto 0);
						end if;						
						wb_op.src <= WBS_MEM;
						wb_op.write <= '0';
						mem_op.mem.memtype <= MEM_H;
						mem_op.mem.memread <= '0';
						mem_op.mem.memwrite <= '1';
					when "010" =>    -- S SW DMEM[rs1 + imm\+-] = rs2
						exec_op.aluop <= ALU_ADD;
						exec_op.rs1 <= rs1;
						exec_op.rs2 <= rs2;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_readdata2;
						elsif int_reg_write.reg = rs2 then
							exec_op.readdata2 <= int_reg_write.data;
							exec_op.readdata1 <= int_readdata1;
						elsif int_reg_write.reg = rs1 and rs1 = rs2 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_reg_write.data;
						else	
							exec_op.readdata1 <= int_readdata1;
							exec_op.readdata2 <= int_readdata2;
						end if;				
						wb_op.src <= WBS_MEM;
						wb_op.write <= '0';
						mem_op.mem.memtype <= MEM_W;
						mem_op.mem.memread <= '0';
						mem_op.mem.memwrite <= '1';
					when others => exc_dec <= '1';
				end case;
			when OPC_LOAD =>
                exec_op.imm_flag <= '1';
                exec_op.store_flag <= '0';
					 exec_op.pc_flag <= '0';
					 exec_op.imm(31 downto 11) <= (others => int_instr(31));
					 exec_op.imm(10 downto 5) <= int_instr(30 downto 25);
					 exec_op.imm(4 downto 1) <= int_instr(24 downto 21);
				    exec_op.imm(0) <= int_instr(20);
				case fct3 is
					when "000" =>    -- I LB rd = (int8_t) DMEM[rs1 + imm\+-]
						exec_op.aluop <= ALU_ADD;
						exec_op.rs1 <= rs1;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
						else
							exec_op.readdata1 <= int_readdata1;
						end if;
						wb_op.src <= WBS_MEM;
						wb_op.write <= '1';
						wb_op.rd <= rd;
						mem_op.mem.memtype <= MEM_B;
						mem_op.mem.memread <= '1';
						mem_op.mem.memwrite <= '0';
					when "001" =>    -- I LH rd = (int16_t) DMEM[rs1 + imm\+-]
						exec_op.aluop <= ALU_ADD;
						exec_op.rs1 <= rs1;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
						else
							exec_op.readdata1 <= int_readdata1;
						end if;
						wb_op.src <= WBS_MEM;
						wb_op.write <= '1';
						wb_op.rd <= rd;
						mem_op.mem.memtype <= MEM_H;
						mem_op.mem.memread <= '1';
						mem_op.mem.memwrite <= '0';
					when "010" =>    -- I LW rd = (int32_t) DMEM[rs1 + imm\+-]
						exec_op.aluop <= ALU_ADD;
						exec_op.rs1 <= rs1;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
						else
							exec_op.readdata1 <= int_readdata1;
						end if;
						wb_op.src <= WBS_MEM;
						wb_op.write <= '1';
						wb_op.rd <= rd;
						mem_op.mem.memtype <= MEM_W;
						mem_op.mem.memread <= '1';
						mem_op.mem.memwrite <= '0';
					when "100" =>    -- I LBU rd = (uint8_t) DMEM[rs1 + imm\+-]
						exec_op.aluop <= ALU_ADD;
						exec_op.rs1 <= rs1;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
						else
							exec_op.readdata1 <= int_readdata1;
						end if;
						wb_op.src <= WBS_MEM;
						wb_op.write <= '1';
						wb_op.rd <= rd;
						mem_op.mem.memtype <= MEM_BU;
						mem_op.mem.memread <= '1';
						mem_op.mem.memwrite <= '0';
					when "101" =>    -- I LHU rd = (uint16_t) DMEM[rs1 + imm\+-]
						wb_op.src <= WBS_MEM;
						exec_op.aluop <= ALU_ADD;
						exec_op.rs1 <= rs1;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
						else
							exec_op.readdata1 <= int_readdata1;
						end if;
						wb_op.write <= '1';
						wb_op.rd <= rd;
						mem_op.mem.memtype <= MEM_HU;
						mem_op.mem.memread <= '1';	
						mem_op.mem.memwrite <= '0';
					when others => exc_dec <= '1';
				end case;
			when OPC_BRANCH =>
                			 exec_op.imm_flag <= '0';
                			 exec_op.store_flag <= '0';
					 exec_op.pc_flag <= '1';
					 exec_op.imm(31 downto 12) <= (others => int_instr(31));
					 exec_op.imm(11) <= int_instr(7);
					 exec_op.imm(10 downto 5) <= int_instr(30 downto 25);
					 exec_op.imm(4 downto 1) <= int_instr(11 downto 8);
					 exec_op.imm(0) <= '0';
				case fct3 is
					when "000" =>    -- B BEQ if(rs1 == rs2) pc = pc + (imm\+- << 1)
						exec_op.aluop <= ALU_SUB;
						exec_op.rs1 <= rs1;
						exec_op.rs2 <= rs2;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_readdata2;
						elsif int_reg_write.reg = rs2 then
							exec_op.readdata2 <= int_reg_write.data;
							exec_op.readdata1 <= int_readdata1;
						elsif int_reg_write.reg = rs1 and rs1 = rs2 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_reg_write.data;
						else	
							exec_op.readdata1 <= int_readdata1;
							exec_op.readdata2 <= int_readdata2;
						end if;		
						mem_op.branch <= BR_CND;
					when "001" =>    -- B BNE if(rs1 != rs2) pc = pc + (imm\+- << 1)
						exec_op.aluop <= ALU_SUB;
						exec_op.rs1 <= rs1;
						exec_op.rs2 <= rs2;
							if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_readdata2;
						elsif int_reg_write.reg = rs2 then
							exec_op.readdata2 <= int_reg_write.data;
							exec_op.readdata1 <= int_readdata1;
						elsif int_reg_write.reg = rs1 and rs1 = rs2 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_reg_write.data;
						else	
							exec_op.readdata1 <= int_readdata1;
							exec_op.readdata2 <= int_readdata2;
						end if;		
						mem_op.branch <= BR_CND;
					when "100" =>    -- B BLT if(rs1\+- < rs2\+-) pc = pc + (imm\+- << 1)
						exec_op.aluop <= ALU_NOP;
						exec_op.rs1 <= rs1;
					   exec_op.rs2 <= rs2;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_readdata2;
						elsif int_reg_write.reg = rs2 then
							exec_op.readdata2 <= int_reg_write.data;
							exec_op.readdata1 <= int_readdata1;
						elsif int_reg_write.reg = rs1 and rs1 = rs2 then
							exec_op.readdata1 <= reg_write.data;
							exec_op.readdata2 <= reg_write.data;
						else	
							exec_op.readdata1 <= int_readdata1;
							exec_op.readdata2 <= int_readdata2;
						end if;		
						mem_op.branch <= BR_CND;
					when "101" =>    -- B BGE if(rs1\+- >= rs2\+- pc = pc + (imm\+- << 1)
						exec_op.aluop <= ALU_NOP;
						exec_op.rs1 <= rs1;
						exec_op.rs2 <= rs2;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_readdata2;
						elsif int_reg_write.reg = rs2 then
							exec_op.readdata2 <= int_reg_write.data;
							exec_op.readdata1 <= int_readdata1;
						elsif int_reg_write.reg = rs1 and rs1 = rs2 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_reg_write.data;
						else	
							exec_op.readdata1 <= int_readdata1;
							exec_op.readdata2 <= int_readdata2;
						end if;		
						mem_op.branch <= BR_CND;
					when "110" =>    -- B BLTU if(rs1\0 < rs2\0) pc = pc + (imm\+- << 1)
						exec_op.aluop <= ALU_NOP;
						exec_op.rs1 <= rs1;
						exec_op.rs2 <= rs2;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_readdata2;
						elsif int_reg_write.reg = rs2 then
							exec_op.readdata2 <= int_reg_write.data;
							exec_op.readdata1 <= int_readdata1;
						elsif int_reg_write.reg = rs1 and rs1 = rs2 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_reg_write.data;
						else	
							exec_op.readdata1 <= int_readdata1;
							exec_op.readdata2 <= int_readdata2;
						end if;		
						mem_op.branch <= BR_CND;
					when "111" =>    -- B BGEU if(rs1\0 >= rs2\0) pc = pc + (imm\+- << 1)
						exec_op.aluop <= ALU_NOP;
						exec_op.rs1 <= rs1;
						exec_op.rs2 <= rs2;
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_readdata2;
						elsif int_reg_write.reg = rs2 then
							exec_op.readdata2 <= int_reg_write.data;
							exec_op.readdata1 <= int_readdata1;
						elsif int_reg_write.reg = rs1 and rs1 = rs2 then
							exec_op.readdata1 <= int_reg_write.data;
							exec_op.readdata2 <= int_reg_write.data;
						else	
							exec_op.readdata1 <= int_readdata1;
							exec_op.readdata2 <= int_readdata2;
						end if;		
						mem_op.branch <= BR_CND;
					when others => exc_dec <= '1';
				end case;	
			when OPC_JALR =>
				if fct3 = "000" then  --I JALR rd = pc + 4; pc = imm\+- + rs1; pc[0] = '0'
                  exec_op.imm_flag <= '0';
                  exec_op.store_flag <= '1';
                  exec_op.pc_flag <= '1';
                  exec_op.aluop <= ALU_ADD;
						exec_op.imm(31 downto 11) <= (others => int_instr(31));
						exec_op.imm(10 downto 5) <= int_instr(30 downto 25);
						exec_op.imm(4 downto 1) <= int_instr(24 downto 21);
						exec_op.imm(0) <= int_instr(20);
						if int_reg_write.reg = rs1 then
							exec_op.readdata1 <= int_reg_write.data;
					   else
							exec_op.readdata1 <= int_readdata1;
						end if;	
						wb_op.src <= WBS_ALU;
						wb_op.write <= '1';
                  wb_op.rd <= rd;
				else
					exc_dec <= '1';
				end if;
			when OPC_JAL =>   --J JAL rd = pc + 4; pc = pc + (imm\+- << 1)
                exec_op.imm_flag <= '1';
                exec_op.store_flag <= '0';
                exec_op.pc_flag <= '1';
			            exec_op.imm(31 downto 20) <= (others => int_instr(31));
				    exec_op.imm(19 downto 12) <= int_instr(19 downto 12);
				    exec_op.imm(11) <= int_instr(20);
				    exec_op.imm(10 downto 5) <= int_instr(30 downto 25);
				    exec_op.imm(4 downto 1) <= int_instr(24 downto 21);
				    exec_op.imm(0) <= '0';
				    exec_op.aluop <= ALU_ADD;
				    wb_op.src <= WBS_OPC;
				    wb_op.write <= '1';
				    wb_op.rd <= rd;
				    mem_op.branch <= BR_BR; 
			
			when OPC_AUIPC =>   --U AUIPC rd = pc + (imm\+- << 12)
                exec_op.imm_flag <= '0';
                exec_op.store_flag <= '0';
                exec_op.pc_flag <= '0';
                exec_op.imm(31 downto 24) <= int_instr(19 downto 12);
				    exec_op.imm(23 downto 0) <= (others => '0');
                exec_op.aluop <= ALU_ADD;
					 exec_op.readdata1 <= (others => '0');
                exec_op.readdata1(15 downto 0) <= int_pc;
					 exec_op.readdata2 <= exec_op.imm;
				    wb_op.src <= WBS_ALU;
			       wb_op.write <= '1';
				    wb_op.rd <= rd;
			when OPC_LUI =>    --U LUI rd = imm\+- << 12
                exec_op.imm_flag <= '0';
                exec_op.store_flag <= '0';
                exec_op.pc_flag <= '0';
					 exec_op.imm(31 downto 24) <= int_instr(19 downto 12);
					 exec_op.imm(23 downto 0) <= (others => '0');
				    exec_op.aluop <= ALU_NOP;
					 exec_op.readdata1 <= (others => '0');
					 exec_op.readdata2 <= exec_op.imm;
					 wb_op.src <= WBS_ALU;
					 wb_op.write <= '1';
					 wb_op.rd <= rd;
			when "0001111" =>
				if fct3 = "000" then -- I FENCE nop
					exec_op <= EXEC_NOP;
					mem_op <= MEM_NOP;
					wb_op <= WB_NOP;					
				else	
					exc_dec <= '1';
				end if;
			when others => exc_dec <= '1';
		end case;


	end process;

end architecture;
