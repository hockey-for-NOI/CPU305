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
		debug1, debug2: out std_logic_vector(6 downto 0);
	);
end CPU;

architecture bhv of CPU is

signal	clk, clk_neg, clk_2x, clk_2x_neg, clk_4x, clk_4x_neg: std_logic;
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
signal	gate1_stall: std_logic;
signal	id_instruction: std_logic_vector(15 downto 0);

begin

--	clkman_inst: entity clkman_50m port map(
--	clkman_inst: entity clkman_25m port map(
	clkman_inst: entity clkman_hand port map(
		clk_press => clk_press, clk_50m => clk_50m,
		clk => clk, clk_neg => clk_neg,
		clk_2x => clk_2x, clk_2x_neg => clk_2x_neg,
		clk_4x => clk_4x, clk_4x_neg => clk_4x_neg
	);

	reg_inst: entity reg port map(
		clk => clk, rst => rst,
		rd1 => reg_rd1, rval1 => reg_rval1,
		rd2 => reg_rd2, rval2 => reg_rval2,
		wr => reg_wr, we => reg_we, wval => reg_wval
	);

	mem1_inst: entity mem1 port map(
		clk => clk, rst => rst,
		rd_flag => mem1_rd_flag, rd_addr => mem1_rd_addr, rd_val => mem1_rd_val,
		wr_flag => mem1_wr_flag, wr_addr => mem1_wr_addr, wr_val => mem1_wr_val,
		sram1_en => sram1_en, sram1_oe => sram1_oe, sram1_we => sram1_we,
		sram1_data => sram1_data, sram1_addr => sram1_addr
	);

	mem2_inst: entity mem2 port map(
		clk => clk, rst => rst,
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
		input_prev_mem_rd_addr => prev_mem_rd_addr,
		output_succ_mem_rd_addr => succ_mem_rd_addr,
		output_reg_rd1 => reg_rd1,
		output_reg_rd2 => reg_rd2,
		input_reg_rval1 => reg_rval1,
		input_reg_rval2 => reg_rval2,
		output_val1_reg_addr => id_val1_reg_addr,
		output_val1 => id_val1,
		output_val2_reg_addr => id_val2_reg_addr,
		output_val2 => id_val2,
		output_res_reg_addr => id_res_reg_addr,
		output_alu_op => id_alu_op,
		output_mem_rd_flag => id_mem_rd_flag,
		output_mem_wr_flag => id_mem_wr_flag,
		output_reg_wr_flag => id_reg_wr_flag,
		output_jump_flag => pc_jump_flag,
		output_jump_addr => pc_jump_addr,
		output_pc_stall => pc_stall,
	);

	pipe2_fwd_inst: entity pipe2_fwd port map(
		clk => clk, rst => rst,
		input_mem_rd_addr => succ_mem_rd_addr,
		output_mem_rd_addr => prev_mem_rd_addr
	);

	gate2_id_exe_inst: entity gate2_id_exe port map(
		input_val1 => id_val1,
		input_val1_reg_addr => id_val1_reg_addr,
		input_val2 => id_val2,
		input_val2_reg_addr => id_val2_reg_addr,
		input_res_reg_addr => id_res_reg_addr,
		input_alu_op => id_alu_op,
		input_mem_rd_flag => id_mem_rd_flag,
		input_mem_wr_flag => id_mem_wr_flag,
		input_reg_wr_flag => id_reg_wr_flag,
		output_val1 => exe_val1,
		output_val1_reg_addr => exe_val1_reg_addr,
		output_val2 => exe_val2,
		output_val2_reg_addr => exe_val2_reg_addr,
		output_res_reg_addr => exe_res_reg_addr,
		output_alu_op => exe_alu_op,
		output_mem_rd_flag => exe_mem_rd_flag,
		output_mem_wr_flag => exe_mem_wr_flag,
		output_reg_wr_flag => exe_reg_wr_flag
	);

	pipe3_exe_inst: entity pipe3_exe port map(
	);

end bhv;
