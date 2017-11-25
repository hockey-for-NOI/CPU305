library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CPU is
	port(
		start, clk_press, clk_50m, rst: in std_logic;
		sram1_en, sram1_oe, sram1_we: out std_logic;
		sram2_en, sram2_oe, sram2_we: out std_logic;
		sram1_data, sram2_data: inout std_logic_vector(15 downto 0);
		sram1_addr, sram2_addr: out std_logic_vector(17 downto 0);
		data_ready, tsre, tbre: in std_logic;
		rdn, wrn: out std_logic;
		debug0: out std_logic_vector(15 downto 0);
		debug1, debug2: out std_logic_vector(6 downto 0)
	);
end CPU;

architecture bhv of CPU is

signal	clk, clk_wr: std_logic;
signal	reg_rd1, reg_rd2, reg_wr: std_logic_vector(3 downto 0);
signal	reg_rval1, reg_rval2, reg_wval: std_logic_vector(15 downto 0);
signal	reg_we: std_logic;
signal	mem1_rd_flag, mem1_wr_flag, mem2_rd_flag, mem2_wr_flag: std_logic;
signal	mem1_rd_addr, mem1_wr_addr, mem2_rd_addr, mem2_wr_addr: std_logic_vector(15 downto 0);
signal	mem1_rd_val, mem1_wr_val, mem2_rd_val, mem2_wr_val: std_logic_vector(15 downto 0);
signal	pc_jump_flag, pc_stall: std_logic;
signal	pc_jump_addr, pc_addr: std_logic_vector(15 downto 0);
signal	if_instruction: std_logic_vector(15 downto 0);
signal	config_pc_mask: std_logic_vector(15 downto 0);
signal	gate1_stall, gate2_stall, gate3_stall, gate4_stall: std_logic;
signal	id_instruction: std_logic_vector(15 downto 0);
signal	id_val1, id_val2, id_val3: std_logic_vector(15 downto 0);
signal	id_res_reg_addr: std_logic_vector(15 downto 0);
signal	id_alu_op: std_logic_vector(3 downto 0);
signal	id_mem_rd_flag, id_mem_wr_flag, id_reg_wr_flag: std_logic;
signal	exe_val1, exe_val2, exe_val3: std_logic_vector(15 downto 0);
signal	exe_res_reg_addr: std_logic_vector(15 downto 0);
signal	exe_alu_op: std_logic_vector(3 downto 0);
signal	exe_mem_rd_flag, exe_mem_wr_flag, exe_reg_wr_flag: std_logic;
signal	exe_res: std_logic_vector(15 downto 0);
signal	mem_addr: std_logic_vector(15 downto 0);
signal	mem_res_reg_addr: std_logic_vector(15 downto 0);
signal	mem_mem_rd_flag, mem_mem_wr_flag, mem_reg_wr_flag: std_logic;
signal	mem_input_val, mem_output_val: std_logic_vector(15 downto 0);
signal	wb_reg_wr_flag: std_logic;
signal	wb_val: std_logic_vector(15 downto 0);

begin

--	clkman_inst: entity clkman_50m port map(
--	clkman_inst: entity clkman_25m port map(
	clkman_inst: entity clkman_hand port map(
		clk_press => clk_press, clk_50m => clk_50m,
		clk => clk, clk_wr => clk_wr, -- clk_wr: In each clk period, starts as '1', turn to '0' when the falling edge of clk, and return to '1' a.s.a.p.
	);

	reg_inst: entity reg port map(
		clk => clk, rst => rst,
		rd1 => reg_rd1, rval1 => reg_rval1,
		rd2 => reg_rd2, rval2 => reg_rval2,
		wr => reg_wr, we => reg_we, wval => reg_wval
	);

	mem1_inst: entity mem1 port map(
		clk => clk, rst => rst,
		clk_wr => clk_wr,
		rd_flag => mem1_rd_flag, rd_addr => mem1_rd_addr, rd_val => mem1_rd_val,
		wr_flag => mem1_wr_flag, wr_addr => mem1_wr_addr, wr_val => mem1_wr_val,
		sram1_en => sram1_en, sram1_oe => sram1_oe, sram1_we => sram1_we,
		sram1_data => sram1_data, sram1_addr => sram1_addr
	);

	mem2_inst: entity mem2 port map(
		clk => clk, rst => rst,
		clk_wr => clk_wr,
		rd_addr => mem2_rd_addr, rd_addr => mem2_rd_addr, rd_val => mem2_rd_val,
		wr_addr => mem2_wr_addr, wr_addr => mem2_wr_addr, wr_val => mem2_wr_val,
		sram2_en => sram2_en, sram2_oe => sram2_oe, sram2_we => sram2_we,
		sram2_data => sram2_data, sram2_addr => sram2_addr,
		data_ready => data_ready, tsre => tsre, tbre => tbre
	);

	pc_inst: entity PC port map(
		clk => clk, rst => rst,
		jump_flag => pc_jump_flag, jump_addr => pc_jump_addr,
		stall => pc_stall, pc_addr => pc_addr
	);

	pipe1_if_inst: entity pipe1_if port map(
		input_pc_addr => pc_addr,
		output_instruction => if_instruction
	);

	gate1_if_id_inst: entity gate1_if_id port map(
		clk => clk, rst => rst,
		stall => gate1_stall,
		input_instruction => if_instruction,
		output_instruction => id_instruction
	);

	pipe2_id_inst: entity pipe2_id port map(
		input_instruction => id_instruction,
		output_reg_rd1 => reg_rd1,
		output_reg_rd2 => reg_rd2,
		input_reg_rval1 => reg_rval1,
		input_reg_rval2 => reg_rval2,
		input_forward_exe_reg_wr_flag => exe_reg_wr_flag,
		input_forward_exe_res_reg_addr => exe_res_reg_addr,
		input_forward_exe_res => exe_res,
		output_val1 => id_val1,
		output_val2 => id_val2,
		output_val3 => id_val3,
		output_res_reg_addr => id_res_reg_addr,
		output_alu_op => id_alu_op,
		output_mem_rd_flag => id_mem_rd_flag,
		output_mem_wr_flag => id_mem_wr_flag,
		output_reg_wr_flag => id_reg_wr_flag,
		output_jump_flag => pc_jump_flag,
		output_jump_addr => pc_jump_addr,
		output_stalls => pc_stall & gate1_stall & gate2_stall & gate3_stall & gate4_stall
	);

	gate2_id_exe_inst: entity gate2_id_exe port map(
		clk => clk, rst => rst,
		stall => gate2_stall,
		input_val1 => id_val1,
		input_val2 => id_val2,
		input_val3 => id_val3,
		input_res_reg_addr => id_res_reg_addr,
		input_alu_op => id_alu_op,
		input_mem_rd_flag => id_mem_rd_flag,
		input_mem_wr_flag => id_mem_wr_flag,
		input_reg_wr_flag => id_reg_wr_flag,
		output_val1 => exe_val1,
		output_val2 => exe_val2,
		output_val3 => exe_val3,
		output_res_reg_addr => exe_res_reg_addr,
		output_alu_op => exe_alu_op,
		output_mem_rd_flag => exe_mem_rd_flag,
		output_mem_wr_flag => exe_mem_wr_flag,
		output_reg_wr_flag => exe_reg_wr_flag
	);

	pipe3_exe_inst: entity pipe3_exe port map(
		input_val1 => exe_val1,
		input_val2 => exe_val2,
		input_alu_op => exe_alu_op,
		output_res => exe_res
	);

	gate3_exe_mem_inst: entity gate3_exe_mem port map(
		clk => clk, rst => rst,
		stall => gate3_stall,
		input_res => exe_res,
		input_val => exe_val3,
		input_res_reg_addr => exe_res_reg_addr,
		input_mem_rd_flag => exe_mem_rd_flag,
		input_mem_wr_flag => exe_mem_wr_flag,
		input_reg_wr_flag => exe_reg_wr_flag,
		output_res => mem_addr,
		output_val => mem_input_val,
		output_res_reg_addr => mem_res_reg_addr,
		output_mem_rd_flag => mem_mem_rd_flag,
		output_mem_wr_flag => mem_mem_wr_flag,
		output_reg_wr_flag => mem_reg_wr_flag
	);

	pipe4_mem_inst: entity pipe4_mem port map(
		input_addr => mem_addr,
		input_val => mem_input_val,
		input_mem_rd_flag => mem_mem_rd_flag,
		input_mem_wr_flag => mem_mem_wr_flag,
		mem1_rd_flag => mem1_rd_flag, mem1_rd_addr => mem1_rd_addr, mem1_rd_val => mem1_rd_val,
		mem1_wr_flag => mem1_wr_flag, mem1_wr_addr => mem1_wr_addr, mem1_wr_val => mem1_wr_val,
		mem2_rd_addr => mem2_rd_addr, mem2_rd_addr => mem2_rd_addr, mem2_rd_val => mem2_rd_val,
		mem2_wr_addr => mem2_wr_addr, mem2_wr_addr => mem2_wr_addr, mem2_wr_val => mem2_wr_val,
		output_val => mem_output_val
	);

	gate4_mem_wb_inst: entity gate4_mem_wb port map(
		clk => clk, rst => rst,
		stall => gate4_stall,
		input_reg_wr_flag => mem_reg_wr_flag,
		input_mem_val => mem_output_val,
		output_reg_wr_flag => wb_reg_wr_flag,
		output_val => wb_val
	);

	pipe5_wb_inst: entity pipe5_wb port map(
		clk_wr => clk_wr,
		input_reg_wr_flag => wb_reg_wr_flag,
		input_val => wb_val,
		reg_wr => reg_wr, reg_we => reg_we, reg_wval => reg_wval
	);

end bhv;
