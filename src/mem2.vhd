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
		sram2_data: inout std_logic_vector(25 downto 0);
		sram2_addr: out std_logic_vector(27 downto 0);
		data_ready, tsre, tbre: in std_logic;
		rdn, wrn: out std_logic
	);
end mem2;

architecture bhv of mem2 is

begin

end bhv;
