library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity serial_delayer is
	port(
		clk, rst: in std_logic;
		input_data_ready, input_tsre, input_tbre: in std_logic;
		output_data_ready, output_tsre, output_tbre: out std_logic
	);
end serial_delayer;

architecture bhv of serial_delayer is

begin

	process(clk, rst, input_data_ready, input_tsre, input_tbre)
	begin
		if (rst = '1') then
			output_data_ready <= '0';
			output_tsre <= '0';
			output_tbre <= '0';
		elsif rising_edge(clk) then
			output_data_ready <= input_data_ready;
			output_tsre <= input_tsre;
			output_tbre <= input_tbre;
		end if;
	end process;

end bhv;
