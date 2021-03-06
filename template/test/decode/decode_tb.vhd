library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pkg.all;
use work.op_pkg.all;
use work.regfile;

entity decode_tb is
end entity;

architecture bench of decode_tb is

    
	component decode is
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
	end component;
	
	 component regfile is
    port (
        clk              : in  std_logic;
        reset            : in  std_logic;
        stall            : in  std_logic;
        rdaddr1, rdaddr2 : in  reg_adr_type;
        rddata1, rddata2 : out data_type;
        wraddr           : in  reg_adr_type;
        wrdata           : in  data_type;
        regwrite         : in  std_logic
    );
 end component;
 
	signal int_readdata1, int_readdata2 : data_type;
	signal wraddr : reg_adr_type;
	signal wrdata : data_type;
	signal regwrite : std_logic;
	signal clk, reset, stall, flush, exc_dec : std_logic;
	signal reg_write : reg_write_type;
	signal pc_in, pc_out : pc_type;
	signal instr : instr_type;
	signal exec_op : exec_op_type;
	signal mem_op : mem_op_type;
	signal wb_op : wb_op_type;
	constant CLK_PERIOD : time := 40 ns;
	signal stop_clk : boolean := false;
begin

	uut : decode
	port map (
        clk => clk,
		  reset => reset,
        stall => stall,
        flush => flush,
        pc_in => pc_in,
        instr => instr,
        reg_write  => reg_write,
        pc_out => pc_out,
        exec_op => exec_op,
        mem_op => mem_op,
        wb_op => wb_op,
        exc_dec => exc_dec
		);
		
	uut1 : regfile
	port map(
        clk => clk,
        reset => reset,
        stall => stall,
        rdaddr1 => instr(19 downto 15),
		  rdaddr2 => instr(24 downto 20),
        rddata1 => int_readdata1,
		  rddata2 => int_readdata2,
        wraddr => wraddr,
        wrdata => wrdata,
        regwrite => regwrite
    );	

	stimulus : process
	begin
		reset <= '0';
		stall <= '0';
		flush <= '0';
		pc_in <= (others => '0');
		reg_write.write <= '0';
		reg_write.reg <= (others => '0');
		reg_write.data <= (others => '0');
		regwrite <= '0';
		wraddr <= (others => '0');
		wrdata <= (others => '0');
		instr <= (others => '0');
		wait for CLK_PERIOD;

		reset <= '1';
		regwrite <= '1';
		wraddr <= "00010";
		wrdata <= x"000000FF";
		wait until rising_edge(clk);
		wraddr <= "00001";
		wrdata <= x"000000AB";
		wait for CLK_PERIOD;
		--OPC_OP ADD
		instr <= "0000000" & "00010" & "00001" & "000" & wb_op.rd & "0110011";
		wait for CLK_PERIOD;
		--OPC_OP SUB
		instr <= "0100000" & "00010" & "00001" & "000" & wb_op.rd & "0110011";
		
		wait for CLK_PERIOD;
		--OPC_IMM XORI
		instr <= x"3a5" & "00010" & "100" & wb_op.rd & "0010011";
		
		wait for CLK_PERIOD;
		--OPC_BRANCH BLTU
		instr <= "1101111" & "00010" & "00001" & "110" & "11010" & "1100011";
		
		wait for CLK_PERIOD;
		--OPC_STORE SH
		instr <= "1100000" & "00010" & "00001" & "001" & "00010" & "0100011";
		
		wait for CLK_PERIOD;
		--OPC_LOAD LHU
		instr <= x"3a5" & "00010" & "101" & wb_op.rd & "0000011";
		
		wait for CLK_PERIOD;
		--OPC_JAL
		instr <= x"3a5f1" & wb_op.rd & "1101111";
		
		wait for CLK_PERIOD;
		--OPC_JALR
		instr <= x"7e1" & "00001" & "000" & wb_op.rd & "1100111";
		
		wait for CLK_PERIOD;
		--OPC_AUIPC
		instr <= x"b47f2" & wb_op.rd & "0010111";
		
		wait for CLK_PERIOD;
		--OPC_LUI
		instr <= x"12345" & wb_op.rd & "0110111";

		wait for 4*CLK_PERIOD;
		stop_clk <= true;		
		wait;
	end process;


	generate_clk : process
	begin
	    while not stop_clk loop
	    	clk <= '0', '1' after CLK_PERIOD/2;
		wait for CLK_PERIOD;
	    end loop;
	    wait;
	end process;

end architecture;

