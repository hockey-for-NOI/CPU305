library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pipe2_id is
	port(
		input_instruction: in std_logic_vector(15 downto 0);
		input_pc_addr: in std_logic_vector(15 downto 0);
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
		output_bubble: out std_logic;
	);
end pipe2_id;

architecture bhv of pipe2_id is

begin

	process (input_instruction, input_reg_rval1, input_reg_rval2,
				input_forward_exe_reg_wr_flag, input_forward_exe_res_reg_addr, input_forward_exe_res)
	variable rx, ry, rz: std_logic_vector(3 downto 0);
	begin
		--Default Values
		output_reg_rd1 <= (others => '1');
		output_reg_rd2 <= (others => '1');
		output_val1 <= (others => '0');
		output_val2 <= (others => '0');
		output_val3 <= (others => '0');
		output_res_reg_addr <= (others => '1');
		output_alu_op <= (others => '1');
		output_mem_rd_flag <= '0';
		output_mem_wr_flag <= '0';
		output_reg_wr_flag <= '0';
		output_jump_flag <= '0';
		output_jump_addr <= (others => '0');
		output_bubble <= '0';

		rx := '0' & input_instruction(10 downto 8);
		ry := '0' & input_instruction(7 downto 5);
		rz := '0' & input_instruction(4 downto 2);

		case input_instruction(15 downto 11) is
			when "01001"=> -- ADDIU
				output_reg_rd1 <= rx;
				output_val1 <= input_reg_rval1;
				if (input_forward_exe_reg_wr_flag) then
					if (rx == input_forwardexe_reg_addr) then
						output_val1 <= input_forward_exe_res;
					end if;
				end if;
				output_val2 <= (others => input_instruction(7);
				output_val2(7 downto 0) <= input_instruction(7 downto 0);
				output_res_reg_addr <= rx;
				output_alu_op <= x"0";
				output_reg_wr_flag <= '1';
			when "01000"=> -- ADDIU3
				null;
			when "01100"=>
				case input_instruction(10 downto 8) is
					when "011"=> -- ADDSP
						null;
					when "000"=> -- BTEQZ
						null;
					when "001"=> -- BTNEZ
						null;
					when "100"=> -- MTSP
						null;
					when others=>
						null;
				end case;
			when "11100"=>
				case input_instruction(1 downto 0) is
					case "01"=> -- ADDU
						null;
					case "11"=> -- SUBU
						null;
					when others=>
						null;
				end case;
			when "00010"=> -- B
				null;
			when "00100"=> -- BEQZ
				null;
			when "00101"=> -- BNEZ
				null;
			when "11101"=>
				case input_instruction(4 downto 0) is
					when "01010"=> -- CMP
						null;
					when "01100"=> -- AND
						null;
					when "01101"=> -- OR
						null;
					when "00000"=>
						case input_instruction(7 downto 5) is
							when "110"=> -- JALR
								null;
							when "000"=> -- JR
								null;
							when "001"=> -- JRRA
								null;
							when "010"=> -- MFPC
							when others=>
								null;
						end case;
					when "00011"=> -- SLTU
						null;
					when others=>
						null;
				end case;
			when "01101"=> -- LI
				null;
			when "10011"=> -- LW
				null;
			when "10010"=> -- LW_SP
				null;
			when "11110"=> 
				case input_instruction(7 downto 0) is
					when "00000000"=> -- MFIH
						null;
					when "00000001"=> -- MTIH
						null;
					when others=>
						null;
				end case;
			when "00110"=>
				case input_instruction(1 downto 0) is
					when "00"=> -- SLL
						null;
					when "11"=> -- SRA
						null;
					when others=>
						null;
				end case;
			when "01011"=> -- SLTUI
				null;
			when "11011"=> -- SW
				null;
			when "11010"=> -- SW_SP
				null;
			when others=>
				null;
		end case;
	end process;

end bhv;