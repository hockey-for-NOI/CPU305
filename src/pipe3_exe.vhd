library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pipe3_exe is
	port(
		input_val1, input_val2: in std_logic_vector(15 downto 0);
		input_alu_op: in std_logic_vector(3 downto 0);
		output_res: out std_logic_vector(15 downto 0)
	);		
end pipe3_exe;

architecture bhv of pipe3_exe is

begin
	process(input_val1, input_val2, input_alu_op)
	variable tmp_res: std_logic_vector(15 downto 0):=(others=>'0');
	begin
		case input_alu_op is
			when "0000" =>
				tmp_res := input_val1 + input_val2;
			when "0001" =>
				tmp_res := input_val1 - input_val2;
			when "0010" =>
				tmp_res := input_val1 and input_val2;
			when "0011" =>
				tmp_res := input_val1 or input_val2;
			when "0100" =>
				if input_val2 = "0000000000000000" then	--SLL: input_val1 << input_val2
					tmp_res := to_stdlogicvector(to_bitvector(input_val1) sll 8);
				else
					tmp_res := to_stdlogicvector(to_bitvector(input_val1) sll conv_integer(input_val2));
				end if;
			when "0101" =>
				if input_val2 = "0000000000000000" then	--SRA: input_val1 >> input_val2 ��������
					tmp_res := to_stdlogicvector(to_bitvector(input_val1) sra 8);
				else
					tmp_res := to_stdlogicvector(to_bitvector(input_val1) sra conv_integer(input_val2)); 
				end if;
			when "0110" =>
				if input_val1 = input_val2 then
					tmp_res := "0000000000000000";
				else
					tmp_res := "0000000000000001";
				end if;
			when "0111" => -- < (unsigned)
				if input_val1 < input_val2 then
					tmp_res := "0000000000000001";
				else
					tmp_res := "0000000000000000";
				end if;
			when "1000" =>
				tmp_res := input_val1;
			when "1001" =>
				tmp_res := input_val2;
			when "1010" => -- < (signed)
				if ((not input_val1(15)) & input_val1(14 downto 0)) < ((not input_val2(15)) & input_val2(14 downto 0)) then
					tmp_res := "0000000000000001";
				else
					tmp_res := "0000000000000000";
				end if;
			when "1111" =>	--NULL
				tmp_res := "0000000000000000";
			when others =>
				tmp_res := "0000000000000000";
		end case;
		output_res <= tmp_res;
	end process;

end bhv;