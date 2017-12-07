library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mem1 is
	port(
		clk_wr: in std_logic;
		if_addr: in std_logic_vector(15 downto 0);
		if_val: out std_logic_vector(15 downto 0);
		rd_flag: in std_logic;
		rd_addr: in std_logic_vector(15 downto 0);
		rd_val: out std_logic_vector(15 downto 0);
		wr_flag: in std_logic;
		wr_addr: in std_logic_vector(15 downto 0);
		wr_val: in std_logic_vector(15 downto 0);
		sram1_en, sram1_oe, sram1_we: out std_logic;
		--sram1_data: inout std_logic_vector(15 downto 0);
		sram1_data_in : in std_logic_vector(15 downto 0);
		sram1_data_out : out std_logic_vector(15 downto 0);
		sram1_addr: out std_logic_vector(17 downto 0);
		corrupt, virus: out std_logic;
		danger_addr1, danger_addr2: in std_logic_vector(15 downto 0)
	);
end mem1;

architecture bhv of mem1 is

begin

	sram1_en <= '0';
	sram1_oe <= wr_flag;
	sram1_we <= clk_wr or (not wr_flag);

	process(rd_flag, wr_flag, rd_addr, wr_addr, wr_val, sram1_data_in, if_addr)
	begin
		if (wr_flag = '1') then
			corrupt <= '1';
			virus <= '0';
			sram1_addr <= "00" & wr_addr;
			sram1_data_out <= wr_val;
			if_val <= (11 => '1', others => '0'); -- NOP
			rd_val <= (others => 'X');
		elsif (rd_flag = '1') then
			corrupt <= '1';
			virus <= '0';
			sram1_addr <= "00" & rd_addr;
			if_val <= (11 => '1', others => '0'); -- NOP
			rd_val <= sram1_data_in;
		else
			corrupt <= '0';
			sram1_addr <= "00" & if_addr;
			rd_val <= (others => 'X');
			if ((if_addr = danger_addr1) or (if_addr = danger_addr2)) then
				if_val <= (11 => '1', others => '0'); -- NOP
				virus <= '1';
			else
				if_val <= sram1_data_in;
				virus <= '0';
			end if;
		end if;
	end process;

end bhv;
