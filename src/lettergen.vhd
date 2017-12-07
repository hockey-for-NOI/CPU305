library ieee;   
use ieee.std_logic_1164.all;  
use ieee.std_logic_unsigned.all;  
use ieee.std_logic_arith.all;
entity lettergen is   
	port(    		    
		--25hz
		clkr: in std_logic;
		clkw: in std_logic;
		rst: in std_logic;
		disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
		--write data
		char_we: in std_logic;
		char_value: in std_logic_vector(7 downto 0);
	--	char_addr: in std_logic_vector(11 downto 0);
		row      :  IN   INTEGER;    --row pixel coordinate
	    column   :  IN   INTEGER;    --column pixel coordinate
		red      :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    	green    :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    	blue     :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0') --blue magnitude output to DAC
		);
end lettergen; 


ARCHITECTURE a OF lettergen IS   
	component font_rom 
		port(
			clock: in std_logic;
			addr: in std_logic_vector(10 downto 0);
			data: out std_logic_vector(0 to 7)
		);
	end component;

	component char_mem 
		port(
	      clkr, clkw: in std_logic;
	      char_read_addr : in std_logic_vector(11 downto 0);
	      char_write_addr: in std_logic_vector(11 downto 0);
	      char_we : in std_logic;
	      char_write_value : in std_logic_vector(7 downto 0);
	      char_read_value : out std_logic_vector(7 downto 0)
	   );
	end component;


	-- For Text Generator 
	SIGNAL font_bit : STD_LOGIC;
	SIGNAL char_ascii : STD_LOGIC_VECTOR(6 downto 0);
	signal rom_addr: std_logic_vector(10 downto 0);
	signal row_addr: std_logic_vector(3 downto 0);
	signal font_word: std_logic_vector(0 to 7);
	signal pixel_x, pixel_y, addr_x, addr_y: std_logic_vector(9 downto 0);
	SIGNAL readR : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL readC : STD_LOGIC_VECTOR(6 downto 0);
  	signal read_addr: std_logic_vector(11 downto 0);
  	signal ascii_out: std_logic_vector(7 downto 0);
	SIGNAL nowR,nxtR : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL nowC,nxtC : STD_LOGIC_VECTOR(6 downto 0);
	SIGNAL nowAddr, nxtAddr : STD_LOGIC_VECTOR(11 downto 0);
	SIGNAL writeR : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL writeC : STD_LOGIC_VECTOR(6 downto 0);
	
	SIGNAL writeAddr : STD_LOGIC_VECTOR(11 downto 0);
	
BEGIN
    font_unit: font_rom
	 port map(
		 clock => clkr, 
		 addr => rom_addr,
		 data => font_word
	 );  

	 character_ram: char_mem
	 port map(
	 	clkr => clkr,
	 	clkw => clkw,
	    char_read_addr => read_addr,
	      char_write_addr => writeAddr,
	      char_we => char_we,
			char_write_value => char_value,
	      char_read_value => ascii_out
	 
	 	);


	 process(row, column)
	  begin
		pixel_y(9 downto 0) <= conv_std_logic_vector(row, 10);
		pixel_x(9 downto 0) <= conv_std_logic_vector(column, 10);
		addr_x <= pixel_x + "0000000010";--	why?
		addr_y <= pixel_y;
		--addr_x <= pixel_x;
		readR <= addr_y(8 downto 4);
		readC <= addr_x(9 downto 3);
		read_addr <= readR & readC;
	  end process;
	 --char_ascii <= "0110010";
	 char_ascii <= ascii_out(6 downto 0);

	 row_addr <= pixel_y(3 downto 0);
	 rom_addr <= char_ascii & row_addr;
	 font_bit <= font_word(conv_integer(pixel_x(2 downto 0)));

	 process(disp_ena, font_bit)
	 begin
	    if disp_ena = '0' then 
			red <= (OTHERS => '0');
         	green <= (OTHERS => '0');
         	blue <= (OTHERS => '0');
		 elsif font_bit = '1' then
			red <= (OTHERS => '1');
         	green <= (OTHERS => '1');
         	blue <= (OTHERS => '1');
		 else
			red <= (OTHERS => '0');
         	green <= (OTHERS => '0');
         	blue <= (OTHERS => '0');
		 end if;
	 end process;

	 --	position
	 process (clkw, rst) 
	 begin 
		if (rst = '0') then 
			nowC <= "0000000";
			nowR <= "00000";
			nowAddr <= nowR & nowC;
		else
			if (rising_edge(clkw)) then 
				nowR <= nxtR;
				nowC <= nxtC;
				nxtAddr <= nxtAddr;
			end if;
		end if;
	 end process;


	process(char_we, nowR, nowC, char_value)
	variable temp: std_logic_vector(7 downto 0);
	begin 
		nxtR <= nowR ;
		nxtC <= nowC ;
		nxtAddr <= nxtR & nxtC;
		writeR <= "00000";
		writeC <= "0000000";
		writeAddr <= writeR & writeC;
		
		if (char_we = '1') then 
			writeR <= nowR;
			writeC <= nowC;
			writeAddr <= writeR & writeC;
			
			if (char_value(7 downto 0) = "00001000") then  -- backspace
				if (nowC = "0000000") then  -- start of line
					nxtC <= "0000000";
				else 
					nxtC <= nowC - "0000001";
				end if;
			elsif (char_value(7 downto 0) = "00001101") then -- \r
				if (nowR = "11101") then  -- end of screen   ATTENTION !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					nxtC <= "0000000";
					nxtR <= "00000";
				else
					nxtC <= "0000000";
					nxtR <= nowR + "00001";
				end if;

			elsif (char_value(7 downto 0) = "00001010") then -- \n
				if (nowR = "11101") then  -- end of screen   ATTENTION !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					nxtC <= "0000000";
					nxtR <= "00000";
				else
					nxtC <= "0000000";
					nxtR <= nowR + "00001";
				end if;
			elsif (nowC = "1000000") then 
				nxtC <= "1000000";
			else 
				nxtC <= nowC + "0000001";
			end if;	
						
			nxtAddr <= nxtR & nxtC;
		else
		end if;
	end process;


END a;