library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pipe2_id is
	port(
		input_instruction: in std_logic_vector(15 downto 0);
		output_reg_rd1, output_reg_rd2: out std_logic_vector(3 downto 0);
		input_reg_rval1, input_reg_rval2: in std_logic_vector(15 downto 0);
		input_forward_exe_reg_wr_flag: in std_logic;
		input_forward_exe_res_reg_addr: in std_logic_vector(15 downto 0);
		input_forward_exe_res: in std_logic_vector(15 downto 0);
		output_val1, output_val2, output_val3: out std_logic_vector(15 downto 0);
		output_res_reg_addr: out std_logic_vector(3 downto 0);
		output_alu_op: out std_logic_vector(3 downto 0);
		output_mem_rd_flag: out std_logic;
		output_mem_wr_flag: out std_logic;
		output_reg_wr_flag: out std_logic;
		output_jump_flag: out std_logic;
		output_jump_addr: out std_logic_vector(15 downto 0);
		output_stalls: out std_logic_vector(4 downto 0);
	);
end pipe2_id;

architecture bhv of pipe2_id is

begin

	process (input_instruction, input_reg_rval1, input_reg_rval2,
				input_forward_exe_reg_wr_flag, input_forward_exe_res_reg_addr, input_forward_exe_res)
	begin
	end process;

end bhv;
