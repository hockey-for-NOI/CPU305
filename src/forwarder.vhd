library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity forwarder is
	port(
		rd1, rd2: in std_logic_vector(3 downto 0);
		rval1, rval2: out std_logic_vector(15 downto 0);
		reg_rd1, reg_rd2: out std_logic_vector(3 downto 0);
		reg_rval1, reg_rval2: in std_logic_vector(15 downto 0);
		exe_forward_flag, exe_forward_nflag: in std_logic;
		exe_forward_addr: in std_logic_vector(3 downto 0);
		exe_forward_val: in std_logic_vector(15 downto 0);
		mem_forward_flag: in std_logic;
		mem_forward_addr: in std_logic_vector(3 downto 0);
		mem_forward_val: in std_logic_vector(15 downto 0)
	);
end forwarder;

architecture bhv of forwarder is
begin

	reg_rd1 <= rd1;
	reg_rd2 <= rd2;

	process(rd1, reg_rval1, exe_forward_flag, exe_forward_addr, exe_forward_val,
				mem_forward_flag, mem_forward_addr, mem_forward_val)
	begin
		rval1 <= reg_rval1;
		if (mem_forward_flag = '1') then
			if (mem_forward_addr = rd1) then
				rval1 <= mem_forward_val;
			end if;
		end if;
		if (exe_forward_flag & exe_forward_nflag = "10") then
			if (exe_forward_addr = rd1) then
				rval1 <= exe_forward_val;
			end if;
		end if;
	end process;

	process(rd2, reg_rval2, exe_forward_flag, exe_forward_addr, exe_forward_val,
				mem_forward_flag, mem_forward_addr, mem_forward_val)
	begin
		rval2 <= reg_rval2;
		if (mem_forward_flag = '1') then
			if (mem_forward_addr = rd2) then
				rval2 <= mem_forward_val;
			end if;
		end if;
		if (exe_forward_flag & exe_forward_nflag = "10") then
			if (exe_forward_addr = rd2) then
				rval2 <= exe_forward_val;
			end if;
		end if;
	end process;

end bhv;
