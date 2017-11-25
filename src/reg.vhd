entity reg is
	port(
		rd1, rd2, wr : in STD_LOGIC_VECTOR(3 DOWNTO 0);
		we : in STD_LOGIC;
		rval1, rval2, wval : out STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
end reg;

architecture bhv of reg is
type reg_array is array (integer range 0 to 15) of std_logic_vector(15 downto 0);
signal regs : reg_array;
begin
	rval1 <= regs(CONV_INTEGER(rd1));
	rval2 <= regs(CONV_INTEGER(rd2));
	
	process(we) --将使能当做clk
	begin
		if we'event and we = '0' then
			regs(CONV_INTEGER(wr)) <= wval;
		end if;
	end process;
end bhv;