library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mem2 is
	port(
		clk_wr: in std_logic;
		rd_flag: in std_logic;
		rd_addr: in std_logic_vector(15 downto 0);
		rd_val: out std_logic_vector(15 downto 0);
		wr_flag: in std_logic;
		wr_addr: in std_logic_vector(15 downto 0);
		wr_val: in std_logic_vector(15 downto 0);
		serial_busy: out std_logic;
		sram2_en, sram2_oe, sram2_we: out std_logic;
		sram2_data: inout std_logic_vector(15 downto 0);
		sram2_addr: out std_logic_vector(17 downto 0);
		data_ready, tsre, tbre: in std_logic;
		rdn, wrn: out std_logic
	);
end mem2;

architecture bhv of mem2 is

begin

	process (rd_flag, rd_addr, wr_flag, wr_addr, wr_val, sram2_data, data_ready, tsre, tbre, clk_wr)
	begin
		rdn <= '1';
		wrn <= '1';
		serial_busy <= '0';
		sram2_en <= '0';
		sram2_oe <= wr_flag;
		sram2_we <= clk_wr or (not wr_flag);
		if (wr_flag = '1') then
			sram2_addr <= "00" & wr_addr;
			sram2_data <= wr_val;
			rd_val <= (others => 'X');
			if (wr_addr = x"BF00") then
				if (tsre = '1' and tbre = '1') then
					wrn <= clk_wr;
					sram2_we <= '1';
				else
					serial_busy <= '1';
				end if;
			end if;
		elsif (rd_flag = '1') then
			sram2_addr <= "00" & rd_addr;
			sram2_data <= (others => 'Z');
			rd_val <= sram2_data;
			if (rd_addr = x"BF01") then
				rd_val <= (1 => data_ready, 0 => (tbre and tsre), others => '0');
			elsif (rd_addr = x"BF00") then
				sram2_en <= '1';
				sram2_oe <= '1';
				sram2_we <= '1';
				rdn <= '0';
				wrn <= '1';
			end if;
		else
			sram2_addr <= (others => 'X');
			sram2_data <= (others => 'Z');
			rd_val <= (others => 'X');
		end if;
	end process;

end bhv;
