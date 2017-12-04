library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity flash is
	port(
		--ʱ��
		clk : in std_logic;
		rst : in std_logic;

		sram1_addr : out std_logic_vector(17 downto 0); 	--sram1��ַ����
		sram1_data : out std_logic_vector(15 downto 0);--sram1��������
				
		sram1_en : out std_logic;		--sram1ʹ�ܣ�='1'��ֹ����Զ����'0'
		sram1_oe : out std_logic;		--sram1��ʹ�ܣ�='1'��ֹ
		sram1_we : out std_logic;		--sram1дʹ�ܣ�='1'��ֹ
		
		flash_finished : out std_logic := '0';
		
		--Flash
		flash_addr : out std_logic_vector(22 downto 0);		--flash��ַ��
		flash_data : inout std_logic_vector(15 downto 0);	--flash������
		
		flash_byte : out std_logic := '1';	--flash����ģʽ������'1'
		flash_vpen : out std_logic := '1';	--flashд����������'1'
		flash_rp : out std_logic := '1';		--'1'��ʾflash����������'1'
		flash_ce : out std_logic := '0';		--flashʹ��
		flash_oe : out std_logic := '1';		--flash��ʹ�ܣ�'0'��Ч��ÿ�ζ���������'1'
		flash_we : out std_logic := '1'		--flashдʹ��
	);
end flash;

architecture bhv of flash is

	signal flash_finished_signal : std_logic := '0';
	signal flash_state : std_logic_vector(2 downto 0) := "001";
	signal current_addr : std_logic_vector(15 downto 0) := (others => '0');	--flash��ǰҪ���ĵ�ַ
	signal cnt : std_logic_vector(9 downto 0) := (others => '0');
	
begin
	
	--sram1��д�ڴ�
	--sram1_en <= '0';
	--sram1_addr(17 downto 16) <= "00";
	--flash����
	--flash_byte <= '1';
	--flash_vpen <= '1';
	--flash_rp <= '1';
	--flash_ce <= '0';
	
	process(clk, rst)
	begin
	
		if (rst = '0') then
			sram1_oe <= '1';
			sram1_we <= '1';
			sram1_addr <= (others => '0');
			flash_state <= "001";
			flash_finished_signal <= '0';
			current_addr <= (others => '0');
			cnt <= (others => '0');
			
		elsif rising_edge(clk) then 
			if (flash_finished_signal = '1') then			--��flash����kernelָ�sram1�����
				flash_byte <= '1';
				flash_vpen <= '1';
				flash_rp <= '1';
				flash_ce <= '1';	--��ֹflash
				sram1_en <= '0';
				sram1_addr(17 downto 16) <= "00";
				sram1_oe <= '1';
				sram1_we <= '1';
				
			else				--��flash����kernelָ�sram1��δ��ɣ����������
				if (cnt = "1000000000") then
					cnt <= (others => '0');
					
					case flash_state is
						when "001" =>		--WE��0
							sram1_en <= '0';
							sram1_we <= '0';
							sram1_oe <= '1';
							flash_we <= '0';
							flash_oe <= '1';
							
							flash_byte <= '1';
							flash_vpen <= '1';
							flash_rp <= '1';
							flash_ce <= '0';
							
							flash_state <= "010";
							
						when "010" =>
							flash_data <= x"00FF";
							flash_state <= "011";
							
						when "011" =>
							flash_we <= '1';
							flash_state <= "100";
							
						when "100" =>
							flash_addr <= "000000" & current_addr & '0';
							flash_data <= (others => 'Z');
							flash_oe <= '0';
							flash_state <= "101";
							
						when "101" =>
							flash_oe <= '1';
							sram1_we <= '0';
							sram1_addr <= "00" & current_addr;
							sram1_data <= flash_data;
							flash_state <= "110";
						
						when "110" =>
							sram1_we <= '1';
							current_addr <= current_addr + '1';
							flash_state <= "001";
						
						when others =>
							flash_state <= "001";
						
					end case;
					
					if (current_addr > x"0249") then
						flash_byte <= '1';
						flash_vpen <= '1';
						flash_rp <= '1';
						flash_ce <= '1';	--��ֹflash
						sram1_en <= '0';
						sram1_addr(17 downto 16) <= "00";
						sram1_oe <= '1';
						sram1_we <= '1';
						flash_finished_signal <= '1';
					end if;
				else 
					cnt <= cnt + 1;
				end if;	--cnt 
				
			end if;	--flash finished or not
			
		end if;	--rst/clk_raise
		
	end process;
	
	flash_finished <= flash_finished_signal;
	
	
end bhv;

