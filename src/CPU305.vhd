library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CPU is
	port(
		clk_press, clk_50m, rst_press: in std_logic;
		sram1_en, sram1_oe, sram1_we: out std_logic;
		sram2_en, sram2_oe, sram2_we: out std_logic;
		sram1_data, sram2_data: inout std_logic_vector(15 downto 0);
		sram1_addr, sram2_addr: out std_logic_vector(17 downto 0);
		data_ready, tsre, tbre: in std_logic;
		rdn, wrn: out std_logic;
		debug0: out std_logic_vector(15 downto 0);
		debug1, debug2: out std_logic_vector(6 downto 0);
		flash_addr : out std_logic_vector(22 downto 0);
		flash_data : inout std_logic_vector(15 downto 0);
		flash_byte : out std_logic;
		flash_vpen : out std_logic;
		flash_rp : out std_logic;
		flash_ce : out std_logic;
		flash_oe : out std_logic;
		flash_we : out std_logic;
		rst_flash : in std_logic
	);
end CPU;

architecture bhv of CPU is

signal	clk, clk_wr, rst, clk_dcm: std_logic;
signal	reg_rd1, reg_rd2, reg_wr: std_logic_vector(3 downto 0);
signal	reg_rval1, reg_rval2, reg_wval: std_logic_vector(15 downto 0);
signal	reg_we: std_logic;
signal	mem1_rd_flag, mem1_wr_flag, mem2_rd_flag, mem2_wr_flag: std_logic;
signal	mem1_rd_addr, mem1_wr_addr, mem2_rd_addr, mem2_wr_addr: std_logic_vector(15 downto 0);
signal	mem1_rd_val, mem1_wr_val, mem2_rd_val, mem2_wr_val: std_logic_vector(15 downto 0);
signal	pc_jump_flag, pc_stall: std_logic;
signal	pc_jump_addr: std_logic_vector(15 downto 0);
signal	if_instruction: std_logic_vector(15 downto 0);
signal	if_pc_addr, id_pc_addr: std_logic_vector(15 downto 0);
signal	gate1_stall, gate2_stall, gate3_stall, gate4_stall: std_logic;
signal	id_instruction: std_logic_vector(15 downto 0);
signal	id_val1, id_val2, id_val3: std_logic_vector(15 downto 0);
signal	id_res_reg_addr: std_logic_vector(3 downto 0);
signal	id_alu_op: std_logic_vector(3 downto 0);
signal	id_mem_rd_flag, id_mem_wr_flag, id_reg_wr_flag: std_logic;
signal	exe_val1, exe_val2, exe_val3: std_logic_vector(15 downto 0);
signal	exe_res_reg_addr: std_logic_vector(3 downto 0);
signal	exe_alu_op: std_logic_vector(3 downto 0);
signal	exe_mem_rd_flag, exe_mem_wr_flag, exe_reg_wr_flag: std_logic;
signal	exe_res: std_logic_vector(15 downto 0);
signal	mem_addr: std_logic_vector(15 downto 0);
signal	mem_res_reg_addr: std_logic_vector(3 downto 0);
signal	mem_mem_rd_flag, mem_mem_wr_flag, mem_reg_wr_flag: std_logic;
signal	delayed_data_ready, delayed_tsre, delayed_tbre: std_logic;
signal	mem_input_val, mem_output_val: std_logic_vector(15 downto 0);
signal	wb_reg_wr_flag: std_logic;
signal	wb_val: std_logic_vector(15 downto 0);
signal	wb_res_reg_addr: std_logic_vector(3 downto 0);
signal	sram1_corrupt, id_bubble, sram2_serial_busy: std_logic;
signal	forwarder_rd1, forwarder_rd2: std_logic_vector(3 downto 0);
signal	forwarder_rval1, forwarder_rval2: std_logic_vector(15 downto 0);
signal	forwarder_bubble: std_logic;
signal  mem1_sram1_en, mem1_sram1_oe, mem1_sram1_we : std_logic;
signal  flash_sram1_en, flash_sram1_oe, flash_sram1_we : std_logic;
signal  mem1_sram1_data_in, mem1_sram1_data_out, flash_sram1_data : std_logic_vector(15 downto 0);
signal  mem1_sram1_addr, flash_sram1_addr : std_logic_vector(17 downto 0);
signal  flash_finished : std_logic;

--signal clk_origin, rst_neg, clk_fixed, rst_shift, rst_shift_neg : std_logic;

begin
	--debug0 <= forwarder_rval2;
	debug0 <= if_pc_addr;
	debug1 <= exe_val2(6 downto 0);
	--debug1 <= (others => '0');
	debug2(4 downto 0) <= (others => '0');
	debug2(5) <= rst;
	debug2(6) <= flash_finished;
	rst <= rst_press and flash_finished;
	with flash_finished select
		sram1_addr <= mem1_sram1_addr when '1', flash_sram1_addr when others;
--	with flash_finished select --??
--		sram1_data <= mem1_sram1_data_in when '1', flash_sram1_data when others;
--	mem1_sram1_data_out <= sram1_data;
	process(mem1_sram1_data_out, mem1_wr_flag, flash_sram1_data)
	begin
		if (flash_finished = '0') then
			sram1_data <= flash_sram1_data;
		else
			if (mem1_wr_flag = '0') then
				sram1_data <= (others=>'Z');
				mem1_sram1_data_in <= sram1_data;
			else
				sram1_data <= mem1_sram1_data_out;
			end if;
		end if;
	end process;
	with flash_finished select
		sram1_en <= mem1_sram1_en when '1', flash_sram1_en when others;
	with flash_finished select
		sram1_oe <= mem1_sram1_oe when '1', flash_sram1_oe when others;
	with flash_finished select
		sram1_we <= mem1_sram1_we when '1', flash_sram1_we when others;
	--rst <= rst_press;
	--sram1_addr <= mem1_sram1_addr;
	--sram1_data <= mem1_sram1_data;
	--sram1_en <= mem1_sram1_en;
	--sram1_oe <= mem1_sram1_oe;
	--sram1_we <= mem1_sram1_we;

--	clk <= clk_50m;
--	clk_wr <= clk_50m;

--	rst_neg <= not rst;
--	rst_shift <= rst_neg;

	Inst_dcm_test: entity dcm_test PORT MAP(
		CLKIN_IN => clk_50m,
		RST_IN => '0',
		CLKFX_OUT => clk_dcm,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => open,
		LOCKED_OUT => open
	);
	clkman_inst: entity clkman port map(
		clk_in => clk_dcm,
		clk => clk,
		clk_wr => clk_wr
	);
	
--	clk_adv_inst: entity clk_adv port map(
--		CLKIN_IN => clk_50m,
--		RST_IN => rst_neg,
--		CLK0_OUT => clk_origin,
--		CLKFX_OUT => clk,
--		LOCKED_OUT => rst_shift_neg
--	);
	
--	clk <= clk_fixed;
--	clk_wr <= clk_fixed xor clk_origin;

--	rst_shift <= not rst_shift_neg;

--	clk_shift_inst: entity clk_shift port map(
--		CLKIN_IN => clk_fixed,
--		RST_IN => rst_neg,
--		CLKIN_IBUFG_OUT => open,
--		CLK0_OUT => clk,
--		CLK270_OUT => clk_wr,
--		LOCKED_OUT => open
--	);

	reg_inst: entity reg port map(
		clk => clk,
		rd1 => reg_rd1, rval1 => reg_rval1,
		rd2 => reg_rd2, rval2 => reg_rval2,
		wr => reg_wr, we => reg_we, wval => reg_wval
	);

	mem1_inst: entity mem1 port map(
		clk_wr => clk_wr,
		if_addr => if_pc_addr, if_val => if_instruction,
		rd_flag => mem1_rd_flag, rd_addr => mem1_rd_addr, rd_val => mem1_rd_val,
		wr_flag => mem1_wr_flag, wr_addr => mem1_wr_addr, wr_val => mem1_wr_val,
		sram1_en => mem1_sram1_en, sram1_oe => mem1_sram1_oe, sram1_we => mem1_sram1_we,
		--sram1_data => mem1_sram1_data, 
		sram1_data_in => mem1_sram1_data_in,
		sram1_data_out => mem1_sram1_data_out,
		sram1_addr => mem1_sram1_addr,
		corrupt => sram1_corrupt
	);
	flash_inst: entity flash port map(
		clk => clk, rst => rst_flash, --clk??
		sram1_addr => flash_sram1_addr,	sram1_data => flash_sram1_data,				
		sram1_en => flash_sram1_en, sram1_oe => flash_sram1_oe, sram1_we =>flash_sram1_we,
		flash_finished =>flash_finished,
		flash_addr => flash_addr, flash_data => flash_data,		
		flash_byte => flash_byte, flash_vpen => flash_vpen,
		flash_rp => flash_rp, flash_ce => flash_ce,
		flash_oe => flash_oe, flash_we => flash_we
	);

	serial_delayer_inst: entity serial_delayer port map(
		clk => clk, rst => rst,
		input_data_ready => data_ready,
		input_tsre => tsre,
		input_tbre => tbre,
		output_data_ready => delayed_data_ready,
		output_tsre => delayed_tsre,
		output_tbre => delayed_tbre
	);

	mem2_inst: entity mem2 port map(
		clk_wr => clk_wr,
		rd_flag => mem2_rd_flag, rd_addr => mem2_rd_addr, rd_val => mem2_rd_val,
		wr_flag => mem2_wr_flag, wr_addr => mem2_wr_addr, wr_val => mem2_wr_val,
		serial_busy => sram2_serial_busy,
		sram2_en => sram2_en, sram2_oe => sram2_oe, sram2_we => sram2_we,
		sram2_data => sram2_data, sram2_addr => sram2_addr,
		data_ready => delayed_data_ready, tsre => delayed_tsre, tbre => delayed_tbre,
		rdn => rdn, wrn => wrn
	);

	stallman_inst: entity stallman port map(
		input_sram2_serial_busy => sram2_serial_busy,
		input_sram1_corrupt => sram1_corrupt,
		input_forwarder_bubble => forwarder_bubble,
		output_stalls(4) => pc_stall,
		output_stalls(3) => gate1_stall,
		output_stalls(2) => gate2_stall,
		output_stalls(1) => gate3_stall,
		output_stalls(0) => gate4_stall
	);

	forwarder_inst: entity forwarder port map(
		rd1 => forwarder_rd1,
		rd2 => forwarder_rd2,
		rval1 => forwarder_rval1,
		rval2 => forwarder_rval2,
		reg_rd1 => reg_rd1, reg_rval1 => reg_rval1,
		reg_rd2 => reg_rd2, reg_rval2 => reg_rval2,
		exe_reg_wr_flag => exe_reg_wr_flag,
		exe_mem_rd_flag => exe_mem_rd_flag,
		exe_forward_addr => exe_res_reg_addr,
		exe_forward_val => exe_res,
		mem_forward_flag => mem_reg_wr_flag,
		mem_forward_addr => mem_res_reg_addr,
		mem_forward_val => mem_output_val,
		forwarder_bubble => forwarder_bubble
	);

	pc_inst: entity PC port map(
		clk => clk, rst => rst,
		jump_flag => pc_jump_flag, jump_addr => pc_jump_addr,
		stall => pc_stall, pc_addr => if_pc_addr
	);

	gate1_if_id_inst: entity gate1_if_id port map(
		clk => clk, rst => rst,
		stall => gate1_stall,
		bubble => '0',
		input_instruction => if_instruction,
		input_pc_addr => if_pc_addr,
		output_instruction => id_instruction,
		output_pc_addr => id_pc_addr
	);

	pipe2_id_inst: entity pipe2_id port map(
		input_instruction => id_instruction,
		input_pc_addr => id_pc_addr,
		output_reg_rd1 => forwarder_rd1,
		output_reg_rd2 => forwarder_rd2,
		input_reg_rval1 => forwarder_rval1,
		input_reg_rval2 => forwarder_rval2,
		output_val1 => id_val1,
		output_val2 => id_val2,
		output_val3 => id_val3,
		output_res_reg_addr => id_res_reg_addr,
		output_alu_op => id_alu_op,
		output_mem_rd_flag => id_mem_rd_flag,
		output_mem_wr_flag => id_mem_wr_flag,
		output_reg_wr_flag => id_reg_wr_flag,
		output_jump_flag => pc_jump_flag,
		output_jump_addr => pc_jump_addr
	);

	gate2_id_exe_inst: entity gate2_id_exe port map(
		clk => clk, rst => rst,
		stall => gate2_stall,
		bubble => forwarder_bubble,
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
		bubble => sram1_corrupt,
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
		mem2_rd_flag => mem2_rd_flag, mem2_rd_addr => mem2_rd_addr, mem2_rd_val => mem2_rd_val,
		mem2_wr_flag => mem2_wr_flag, mem2_wr_addr => mem2_wr_addr, mem2_wr_val => mem2_wr_val,
		output_val => mem_output_val
	);

	gate4_mem_wb_inst: entity gate4_mem_wb port map(
		clk => clk, rst => rst,
		stall => gate4_stall,
		bubble => sram2_serial_busy,
		input_reg_wr_flag => mem_reg_wr_flag,
		input_res_reg_addr => mem_res_reg_addr,
		input_mem_val => mem_output_val,
		output_reg_wr_flag => wb_reg_wr_flag,
		output_val => wb_val,
		output_res_reg_addr => wb_res_reg_addr
	);

	pipe5_wb_inst: entity pipe5_wb port map(
		input_reg_wr_flag => wb_reg_wr_flag,
		input_val => wb_val,
		input_res_reg_addr => wb_res_reg_addr,
		reg_wr => reg_wr, reg_we => reg_we, reg_wval => reg_wval
	);

end bhv;
