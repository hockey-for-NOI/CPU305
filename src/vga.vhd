library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga is
  PORT(
    clk :  IN   STD_LOGIC;  --50M
    rst   :  IN   STD_LOGIC;  --rst
    h_sync    :  OUT  STD_LOGIC;  --horiztonal sync pulse
    v_sync    :  OUT  STD_LOGIC;  --vertical sync pulse
   r, g, b : out STD_LOGIC_VECTOR(2 downto 0);
	ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
    ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
  ); 
end vga;

architecture bhv of vga is
  signal  	ascii_new, ps2_data_ready : std_logic;
  signal   ps2_read_en : std_logic := '0';
  signal   ascii_code, read_ascii_code : std_logic_vector(7 downto 0);

  SIGNAL write_ena : STD_LOGIC := '0';
  SIGNAL clkw : std_logic := '0';
  SIGNAL pix_clk : STD_LOGIC;
  SIGNAL dis_ena : STD_LOGIC;
  SIGNAL column : INTEGER;
  SIGNAL row : INTEGER;
  SIGNAL n_blank : STD_LOGIC;
  SIGNAL n_sync : STD_LOGIC; 
  
  SIGNAL column_minus : INTEGER;
  SIGNAL state : std_logic_vector(1 downto 0);

  component fredivider_vga
  port(
    clkin:in STD_LOGIC;
    clkout:out STD_LOGIC
  );
  end component;
  
  COMPONENT vga_controller 
  GENERIC(
    h_pulse  :  INTEGER;   --horiztonal sync pulse width in pixels
    h_bp     :  INTEGER;   --horiztonal back porch width in pixels
    h_pixels :  INTEGER;  --horiztonal display width in pixels
    h_fp     :  INTEGER;   --horiztonal front porch width in pixels
    h_pol    :  STD_LOGIC;   --horizontal sync pulse polarity (1 = positive, 0 = negative)
    v_pulse  :  INTEGER;     --vertical sync pulse width in rows
    v_bp     :  INTEGER;    --vertical back porch width in rows
    v_pixels :  INTEGER;  --vertical display width in rows
    v_fp     :  INTEGER;     --vertical front porch width in rows
    v_pol    :  STD_LOGIC);  --vertical sync pulse polarity (1 = positive, 0 = negative)
  PORT(
    pixel_clk :  IN   STD_LOGIC;  --pixel clock at frequency of VGA mode being used
    reset_n   :  IN   STD_LOGIC;  --active low asycnchronous reset
    h_sync    :  OUT  STD_LOGIC;  --horiztonal sync pulse
    v_sync    :  OUT  STD_LOGIC;  --vertical sync pulse
    disp_ena  :  OUT  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    column    :  OUT  INTEGER;    --horizontal pixel coordinate
    row       :  OUT  INTEGER;    --vertical pixel coordinate
    n_blank   :  OUT  STD_LOGIC;  --direct blacking output to DAC
    n_sync    :  OUT  STD_LOGIC); --sync-on-green output to DAC
  END component;
  
  
  COMPONENT lettergen
  PORT(
    clkr, clkw      :  IN   STD_LOGIC;
	 rst : in std_logic;
    disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    row      :  IN   INTEGER;    --row pixel coordinate
    column   :  IN   INTEGER;    --column pixel coordinate
   char_we: in std_logic;
		char_value: in std_logic_vector(7 downto 0);
    red      :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
  END component;
  
  COMPONENT ps2
  GENERIC(
      clk_freq                  : INTEGER; --system clock frequency in Hz
      ps2_debounce_counter_size : INTEGER);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
  PORT(
	  rst:in std_logic;
	  read_en: in std_logic; -- read or not
      clk        : IN  STD_LOGIC;                     --system clock input
      ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
      ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
      ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
      ascii_code : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		can_read: out std_logic; -- can read?
		read_ascii_code: out std_logic_vector(7 downto 0) -- last ascii code
		); --ASCII value, from high bit to low bit 
		
END ps2;
  
begin

    ufredivider:
    fredivider_vga port map(
      clkin=>clk,clkout=>pix_clk
    );
   
   uController:
   vga_controller 
   generic map (
    h_pulse => 96,   --horiztonal sync pulse width in pixels
     h_bp => 48,   --horiztonal back porch width in pixels
     h_pixels=> 640,  --horiztonal display width in pixels
     h_fp=> 16,   --horiztonal front porch width in pixels
     h_pol=>'0',   --horizontal sync pulse polarity (1 = positive, 0 = negative)
     v_pulse =>2,     --vertical sync pulse width in rows
     v_bp =>33,    --vertical back porch width in rows
     v_pixels=>480,  --vertical display width in rows
     v_fp=>10,     --vertical front porch width in rows
     v_pol=>'0'  --vertical sync pulse polarity (1 = positive, 0 = negative)
   )
   port map(
    pixel_clk=>pix_clk, 
    reset_n=>rst, 
      h_sync=>h_sync, 
      v_sync=>v_sync, 
      disp_ena=>dis_ena, 
      column=>column, 
      row=>row, 
      n_blank=>n_blank, 
      n_sync=>n_sync
   );

   
   column_minus <= column - 1;
   

  uTextGen:
  lettergen
  port map (
    clkr=>pix_clk,
    clkw=>clkw,
	 rst=>rst,
    disp_ena=>dis_ena, 
    row=>row, 
    column=>column_minus, 
    char_we=>write_ena,
    char_value=>read_ascii_code,
    red=>r, 
    green=>g, 
    blue=>b
  );
  
  ps2_inst:
  ps2
  generic map (
    clk_freq => 50_000_000, --system clock frequency in Hz
      ps2_debounce_counter_size => 8
   )
   port map(
		clk => clk, rst => rst,
		read_en => ps2_read_en,
		ps2_clk => ps2_clk, ps2_data => ps2_data,
		ascii_new => ascii_new, ascii_code => ascii_code,
		can_read => ps2_data_ready, read_ascii_code => read_ascii_code
   );
   
   
	process(pix_clk, rst)
	begin
	
		if (rst = '0') then
			state <= "00";
			ps2_read_en <= '0';
			write_ena <= '0';
			clkw <= '0';
		elsif rising_edge(pix_clk) then 
			if (ps2_data_ready = '1') then
				state <= "01";
				ps2_read_en <= 1;
				write_ena <= '0';
				clkw <= '0';
			else
				case state is
					when "01" =>
						write_ena <= '1';
						state <= "10";
					when "10" =>
						clkw <= '1';
						state <= "11";
					when "11" =>
						ps2_read_en <= '0';
						clkw <= '0';
						write_ena <= '0';
						state <= "00";
					when others =>
						null;
				end case;
			end if;
		end if;
	end process;
end bhv;

