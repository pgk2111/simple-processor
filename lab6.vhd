LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
ENTITY lab6 IS
 PORT ( DIN : BUFFER STD_LOGIC_VECTOR(8 DOWNTO 0);
 Resetn, Clock, Run : IN STD_LOGIC;
 DOUT : BUFFER STD_LOGIC_VECTOR(8 DOWNTO 0);
 ADDR : BUFFER STD_LOGIC_VECTOR(8 DOWNTO 0);
 W : BUFFER STD_LOGIC;
 Done : BUFFER STD_LOGIC;
 R0, R1, R2, R3, R4, R5, R6, R7, A, G : BUFFER STD_LOGIC_VECTOR(8 DOWNTO 0);
 LEDR : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
 );
END lab6;

ARCHITECTURE Behavior OF lab6 is
COMPONENT proc
 PORT ( DIN : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
 Resetn, Clock, Run : IN STD_LOGIC;
 DOUT : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
 ADDR : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
 W : OUT STD_LOGIC;
 Done : BUFFER STD_LOGIC;
 R0, R1, R2, R3, R4, R5, R6, R7, A, G : BUFFER STD_LOGIC_VECTOR(8 DOWNTO 0));
 END COMPONENT;
 COMPONENT RAM
 generic(
        addr_width : integer := 128; 
        addr_bits  : integer := 7; 
        data_width : integer := 9 
        );
 PORT ( addr : in std_logic_vector(addr_bits-1 downto 0);
	 clk:in std_logic;
    data : in std_logic_vector(data_width-1 downto 0);
	 w: in std_logic;
	 q : out std_logic_vector(data_width-1 downto 0));
 END COMPONENT;
 COMPONENT regn
 GENERIC (n : INTEGER := 9);
 PORT ( R : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
 Rin, Clock : IN STD_LOGIC;
 Q : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0));
 END COMPONENT;
 COMPONENT flipflop
 PORT ( D, Resetn, Clock : IN STD_LOGIC;
 Q : OUT STD_LOGIC);
 END COMPONENT;
 signal add_dec : std_logic;
 signal LED_reg_cs: std_logic;
 signal LED_reg:STD_LOGIC_VECTOR(8 DOWNTO 0);
 begin
 U1: proc PORT MAP (DIN, resetn, Clock, Run, DOUT, ADDR, W, Done, R0, R1, R2, R3, R4, R5, R6, R7, A, G);
 add_dec <= '1' when (ADDR(8 downto 7) ="00") else '0';
 U2: RAM PORT MAP (ADDR(6 DOWNTO 0), Clock, DOUT, add_dec AND W, DIN);
 LED_reg_cs <= '1' WHEN (ADDR(8 DOWNTO 7) = "01") ELSE '0';
 U3: regn PORT MAP (DOUT, LED_reg_cs AND W, Clock, LED_reg);
 LEDR(8 DOWNTO 0) <= LED_reg(8 DOWNTO 0);

 END Behavior;