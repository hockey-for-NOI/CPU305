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
		output_val1, output_val2, output_val3: out std_logic_vector(15 downto 0);
		output_res_reg_addr: out std_logic_vector(3 downto 0);
		output_alu_op: out std_logic_vector(3 downto 0);
		output_mem_rd_flag: out std_logic;
		output_mem_wr_flag: out std_logic;
		output_reg_wr_flag: out std_logic;
		output_jump_flag: out std_logic;
		output_jump_addr: out std_logic_vector(15 downto 0)
	);
end pipe2_id;

architecture bhv of pipe2_id is

begin

	process (input_instruction, input_reg_rval1, input_reg_rval2, input_pc_addr)
	variable rx, ry, rz: std_logic_vector(3 downto 0);
	variable jump_dist: std_logic_vector(15 downto 0);
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

		rx := '0' & input_instruction(10 downto 8);
		ry := '0' & input_instruction(7 downto 5);
		rz := '0' & input_instruction(4 downto 2);

		case input_instruction(15 downto 11) is
			when "00001"=> -- NOP
				null;
			when "01001"=> -- ADDIU
				output_reg_rd1 <= rx;
				output_val1 <= input_reg_rval1;	
				output_val2 <= (others => input_instruction(7));
				output_val2(7 downto 0) <= input_instruction(7 downto 0);
				output_res_reg_addr <= rx;
				output_alu_op <= x"0";
				output_reg_wr_flag <= '1';
			when "01000"=> -- ADDIU3
				output_reg_rd1 <= rx;
				output_val1 <= input_reg_rval1;
				output_val2 <= (others => input_instruction(3));
				output_val2(3 downto 0) <= input_instruction(3 downto 0);
				output_res_reg_addr <= ry;
				output_alu_op <= "0000";
				output_reg_wr_flag <= '1';
			when "01100"=>
				case input_instruction(10 downto 8) is
					when "011"=> -- ADDSP
						rx := "1010"; --A: SP
						output_reg_rd1 <= rx; --SP
						output_val1 <= input_reg_rval1;
						output_val2 <= (others => input_instruction(7));
						output_val2(7 downto 0) <= input_instruction(7 downto 0);
						output_res_reg_addr <= rx;
						output_alu_op <= "0000";
						output_reg_wr_flag <= '1';
					when "000"=> -- BTEQZ
						output_reg_rd1 <= "1000"; --8: T
						if input_reg_rval1 = "0000000000000000" then
							jump_dist <= (others => input_instruction(7));
							jump_dist(7 downto 0) <= input_instruction(7 downto 0);
							output_jump_addr <= jump_dist + input_pc_addr;
							output_jump_flag = '1';
						end if;
					when "001"=> -- BTNEZ
						output_reg_rd1 <= "1000"; --8: T
						if input_reg_rval1 /= "0000000000000000" then
							jump_dist <= (others => input_instruction(7));
							jump_dist(7 downto 0) <= input_instruction(7 downto 0);
							output_jump_addr <= jump_dist + input_pc_addr;
							output_jump_flag = '1';
						end if;
					when "100"=> -- MTSP
						rx := '0' & input_instruction(7 downto 5);
						rz := "1010"; --A: SP
						output_reg_rd1 <= rx;
						output_val1 <= input_reg_rval1;
						output_res_reg_addr <= rz; --SP
						output_alu_op <= "1000"; --8: val1
						output_reg_wr_flag <= '1';
					when others=>
						null;
				end case;
			when "11100"=>
				case input_instruction(1 downto 0) is
					when "01"=> -- ADDU
						output_reg_rd1 <= rx;
						output_reg_rd2 <= ry;
						output_val1 <= input_reg_rval1;
						output_val2 <= input_reg_rval2;
						output_res_reg_addr <= rz;
						output_alu_op <= "0000";
						output_reg_wr_flag <= '1';
					when "11"=> -- SUBU
						output_reg_rd1 <= rx;
						output_reg_rd2 <= ry;
						output_val1 <= input_reg_rval1;
						output_val2 <= input_reg_rval2;
						output_res_reg_addr <= rz;
						output_alu_op <= "0001";
						output_reg_wr_flag <= '1';
					when others=>
						null;
				end case;
			when "00010"=> -- B
				jump_dist <= (others => input_instruction(10));
				jump_dist(10 downto 0) <= input_instruction(10 downto 0);
				output_jump_addr <= jump_dist + input_pc_addr;
				output_jump_flag = '1';
			when "00100"=> -- BEQZ
				output_reg_rd1 <= rx;
				if input_reg_rval1 = "0000000000000000" then
					jump_dist <= (others => input_instruction(7));
					jump_dist(7 downto 0) <= input_instruction(7 downto 0);
					output_jump_addr <= jump_dist + input_pc_addr;
					output_jump_flag = '1';
				end if;
			when "00101"=> -- BNEZ
				output_reg_rd1 <= rx;
				if input_reg_rval1 /= "0000000000000000" then
					jump_dist <= (others => input_instruction(7));
					jump_dist(7 downto 0) <= input_instruction(7 downto 0);
					output_jump_addr <= jump_dist + input_pc_addr;
					output_jump_flag = '1';
				end if;
			when "11101"=>
				case input_instruction(4 downto 0) is
					when "01010"=> -- CMP
						rz := "1000"; --8: T
						output_reg_rd1 <= rx;
						output_reg_rd2 <= ry;
						output_val1 <= input_reg_rval1;
						output_val2 <= input_reg_rval2;
						output_res_reg_addr <= rz;
						output_alu_op <= "0110";
						output_reg_wr_flag <= '1';
					when "01100"=> -- AND
						output_reg_rd1 <= rx;
						output_reg_rd2 <= ry;
						output_val1 <= input_reg_rval1;
						output_val2 <= input_reg_rval2;
						output_res_reg_addr <= rx;
						output_alu_op <= "0010";
						output_reg_wr_flag <= '1';
					when "01101"=> -- OR
						output_reg_rd1 <= rx;
						output_reg_rd2 <= ry;
						output_val1 <= input_reg_rval1;
						output_val2 <= input_reg_rval2;
						output_res_reg_addr <= rx;
						output_alu_op <= "0011";
						output_reg_wr_flag <= '1';
					when "00000"=>
						case input_instruction(7 downto 5) is
							when "110"=> -- JALR
								output_reg_rd1 <= rx;
								output_jump_addr <= input_reg_rval1;
								output_jump_flag = '1';
								output_val1 <= input_reg_rval1 + 2；--RPC
								output_res_reg_addr <= "1011"; --B: RA
								output_alu_op <= "1000"; --8: val1
								output_reg_wr_flag = '1';
							when "000"=> -- JR
								output_reg_rd1 <= rx;
								output_jump_addr <= input_reg_rval1;
								output_jump_flag = '1';
							when "001"=> -- JRRA
								output_reg_rd1 <= "1011"; --B: RA
								output_jump_addr <= input_reg_rval1;
								output_jump_flag = '1';
							when "010"=> -- MFPC
								output_val1 <= input_pc_addr;
								output_res_reg_addr <= rx;
								output_alu_op <= "1000"; --8: val1
								output_reg_wr_flag <= '1';
							when others=>
								null;
						end case;
					when others=>
						null;
				end case;
			when "01101"=> -- LI
				output_val1(7 downto 0) <= input_instruction(7 downto 0); --zero extend
				output_alu_op <= "1000"; --8: val1
				output_res_reg_addr <= rx;
				output_reg_wr_flag = '1';
			when "10011"=> -- LW
				output_reg_rd1 <= rx;
				output_val1 <= input_reg_rval1;
				output_val2 <= (others => input_instruction(4));
				output_val2(4 downto 0) <= input_instruction(4 downto 0);
				output_alu_op <= "0000";
				output_res_reg_addr <= ry;
				output_reg_wr_flag <= '1';
				output_mem_rd_flag <= '1';				
			when "10010"=> -- LW_SP
				output_reg_rd1 <= "1010"; --A: SP
				output_val1 <= input_reg_rval1;
				output_val2 <= (others => input_instruction(7));
				output_val2(7 downto 0) <= input_instruction(7 downto 0);
				output_alu_op <= "0000";
				output_res_reg_addr <= rx;
				output_reg_wr_flag <= '1';
				output_mem_rd_flag <= '1';
			when "11110"=> 
				case input_instruction(7 downto 0) is
					when "00000000"=> -- MFIH
						rz := "1001"; --9: IH
						output_reg_rd1 <= rz;
						output_val1 <= input_reg_rval1;
						output_res_reg_addr <= rx;
						output_alu_op <= "1000"; --8: val1
						output_reg_wr_flag <= '1';
					when "00000001"=> -- MTIH
						rz := "1001"; --9: IH
						output_reg_rd1 <= rx;
						output_val1 <= input_reg_rval1;
						output_res_reg_addr <= rz; --IH
						output_alu_op <= "1000"; --8: val1
						output_reg_wr_flag <= '1';
					when others=>
						null;
				end case;
			when "00110"=>
				case input_instruction(1 downto 0) is
					when "00"=> -- SLL
						output_reg_rd1 <= ry;
						output_val1 <= input_reg_rval1;
						output_val2(2 downto 0) <= input_instruction(4 downto 2);
						output_res_reg_addr <= rx;
						output_alu_op <= "0100";
						output_reg_wr_flag <= '1';
					when "11"=> -- SRA
						output_reg_rd1 <= ry;
						output_val1 <= input_reg_rval1;
						output_val2(2 downto 0) <= input_instruction(4 downto 2);
						output_res_reg_addr <= rx;
						output_alu_op <= "0101";
						output_reg_wr_flag <= '1';
					when others=>
						null;
				end case;
			when "01010"=> --SLTI
				output_reg_rd1 <= rx;
				output_val1 <= input_reg_rval1;
				output_val2 <= (others => input_instruction(7);
				output_val2(7 downto 0) <= input_instruction(7 downto 0);
				output_alu_op <= "1010";
				output_res_reg_addr <= "1000"; --8: T
				output_reg_wr_flag <= '1';
			when "01011"=> -- SLTUI
				output_reg_rd1 <= rx;
				output_val1 <= input_reg_rval1;
				output_val2(7 downto 0) <= input_instruction(7 downto 0);
				output_alu_op <= "0111";
				output_res_reg_addr <= "1000"; --8: T
				output_reg_wr_flag <= '1';
			when "11011"=> -- SW
				output_reg_rd1 <= rx;
				output_reg_rd2 <= ry;
				output_val1 <= input_reg_rval1;
				output_val2 <= (others => input_instruction(4));
				output_val2(4 downto 0) <= input_instruction(4 downto 0);
				output_val3 <= input_reg_rval2;
				output_alu_op <= "0000";
				output_mem_wr_flag <= '1';
			when "11010"=> -- SW_SP
				output_reg_rd1 <= "1010"; --A: SP
				output_reg_rd2 <= rx;
				output_val1 <= input_reg_rval1;
				output_val2 <= (others => input_instruction(7));
				output_val2(7 downto 0) <= input_instruction(7 downto 0);
				output_val3 <= input_reg_rval2;
				output_alu_op <= "0000";
				output_mem_wr_flag <= '1';
			when others=>
				null;
		end case;
	end process;

end bhv;
