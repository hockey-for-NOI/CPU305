library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity stallman is
	port(
		input_sram2_serial_busy: in std_logic;
		input_sram1_corrupt: in std_logic;
		input_forwarder_bubble: in std_logic;
		output_stalls: out std_logic_vector(4 downto 0)
	);
end stallman;

architecture bhv of stallman is
begin

	process (input_sram2_serial_busy, input_sram1_corrupt, input_forwarder_bubble)
	begin
		if (input_sram2_serial_busy = '1') then
			output_stalls <= "11110";
		elsif (input_sram1_corrupt = '1') then
			output_stalls <= "11100";
		elsif (input_forwarder_bubble = '1') then
			output_stalls <= "11000";
		else
			output_stalls <= (others => '0');
		end if;
	end process;

end bhv;
