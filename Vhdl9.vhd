LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
ENTITY proc IS
 PORT ( DIN : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
 Resetn, Clock, Run : IN STD_LOGIC;
 DOUT : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
 R0, R1, R2, R3, R4, R5, R6, R7, A, G : BUFFER STD_LOGIC_VECTOR(8 DOWNTO 0);
 ADDR : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
 W : OUT STD_LOGIC;
 Done : BUFFER STD_LOGIC);
END proc;

ARCHITECTURE Behavior OF proc IS
 COMPONENT upcount
 PORT ( Clear, Clock : IN STD_LOGIC;
 Q : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
 END COMPONENT;
 COMPONENT pc_count
 PORT ( R : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
 Resetn, Clock, E, L : IN STD_LOGIC;
 Q : OUT STD_LOGIC_VECTOR(8 DOWNTO 0));
 END COMPONENT;
 COMPONENT dec3to8
 PORT ( W : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
 En : IN STD_LOGIC;
 Y : OUT STD_LOGIC_VECTOR(0 TO 7));
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
 SIGNAL Rin, Rout : STD_LOGIC_VECTOR(0 TO 7);
 SIGNAL BusWires, Sum : STD_LOGIC_VECTOR(8 DOWNTO 0);
 SIGNAL Clear, IRin, ADDRin, DINout, DOUTin, Ain, Gin, Gout, AddSub : STD_LOGIC;
 SIGNAL Tstep_Q : STD_LOGIC_VECTOR(2 DOWNTO 0);
 SIGNAL I : STD_LOGIC_VECTOR(2 DOWNTO 0);
 SIGNAL Xreg, Yreg : STD_LOGIC_VECTOR(0 TO 7);
 SIGNAL IR : STD_LOGIC_VECTOR(1 TO 9);
 SIGNAL Sel : STD_LOGIC_VECTOR(1 to 10); -- bus selector
 SIGNAL pc_inc, W_D, Z, Z_D : STD_LOGIC;
BEGIN
 Clear <= NOT(Resetn) OR Done OR (NOT(Run) AND NOT(Tstep_Q(1)) AND NOT(Tstep_Q(0)));
 Tstep: upcount PORT MAP (Clear, Clock, Tstep_Q);
 I <= IR(1 TO 3);
 decX: dec3to8 PORT MAP (IR(4 TO 6), '1', Xreg);
 decY: dec3to8 PORT MAP (IR(7 TO 9), '1', Yreg);
 controlsignals: PROCESS (Tstep_Q, I, Xreg, Yreg, Z, Run)
 BEGIN
 Done <= '0'; 
 Ain <= '0'; 
 Gin <= '0'; 
 Gout <= '0'; 
 AddSub <= '0';
 IRin <= '0'; 
 DINout <= '0'; 
 DOUTin <= '0'; 
 ADDRin <= '0'; 
 W_D <= '0';
 Rin <= "00000000"; 
 Rout <= "00000000"; 
 pc_inc <= '0';
 CASE Tstep_Q IS
 WHEN "000" => -- fetch the instruction
 Rout <= "00000001"; -- R7 is program counter (pc)
 ADDRin <= '1';
 pc_inc <= Run; -- to increment pc
 WHEN "001" => -- wait cycle for synchronous memory
 -- in case the instruction turns out to be mvi, read memory
 Rout <= "00000001"; -- R7 is program counter (pc)
 ADDRin <= '1';
 WHEN "010" => -- store DIN in IR
 IRin <= '1';
 WHEN "011" => -- define signals in T3
 CASE I IS
 WHEN "000" => -- mv Rx,Ry
 Rout <= Yreg;
 Rin <= Xreg;
 Done <= '1';
 WHEN "001" => -- mvi Rx,#D
 -- data is available now on DIN
 DINout <= '1';
 Rin <= Xreg;
 pc_inc <= '1';
 Done <= '1';
 WHEN "010" => -- add
 Rout <= Xreg;
 Ain <= '1';
 WHEN "011" => -- sub
 Rout <= Xreg;
 Ain <= '1';
 WHEN "100" => -- ld Rx,[Ry]
 Rout <= Yreg;
 ADDRin <= '1';
 WHEN "101" => -- st [Ry],Rx
 Rout <= Yreg;
 ADDRin <= '1';
 WHEN OTHERS => -- mvnz Rx,Ry
 IF Z = '0' THEN
 Rout <= Yreg;
 Rin <= Xreg;
 ELSE
 Rout <= "00000000";
 Rin <= "00000000";
 END IF;
 Done <= '1';
 END CASE;
 WHEN "100" => -- define signals T4
 CASE I IS
 WHEN "010" => -- add
 Rout <= Yreg;
 Gin <= '1';
 WHEN "011" => -- sub
 Rout <= Yreg;
 AddSub <= '1';
 Gin <= '1';
 WHEN "100" => -- ld Rx,[Ry]
 W_D <= '0'; -- do nothing--wait cycle for synchronous memory
 WHEN OTHERS => -- st [Ry],Rx
 Rout <= Xreg;
 DOUTin <= '1';
 W_D <= '1';
 END CASE;
 WHEN OTHERS => -- define T5
 CASE I IS
 WHEN "010" => -- add
 Gout <= '1';
 Rin <= Xreg;
 Done <= '1';
 WHEN "011" => -- sub
 Gout <= '1';
 Rin <= Xreg;
 Done <= '1';
 WHEN "100" => -- ld Rx,[Ry]
 DINout <= '1';
 Rin <= Xreg;
 Done <= '1';
 WHEN OTHERS => -- st [Ry],Rx
 Done <= '1'; -- wait cycle for synhronous memory
 END CASE;
 END CASE;
 END PROCESS;

 reg_0: regn PORT MAP (BusWires, Rin(0), Clock, R0);
 reg_1: regn PORT MAP (BusWires, Rin(1), Clock, R1);
 reg_2: regn PORT MAP (BusWires, Rin(2), Clock, R2);
 reg_3: regn PORT MAP (BusWires, Rin(3), Clock, R3);
 reg_4: regn PORT MAP (BusWires, Rin(4), Clock, R4);
 reg_5: regn PORT MAP (BusWires, Rin(5), Clock, R5);
 reg_6: regn PORT MAP (BusWires, Rin(6), Clock, R6);
 -- R7 is program counter
 -- pc_count(R, Resetn, Clock, E, L, Q);
 pc: pc_count PORT MAP (BusWires, Resetn, Clock, pc_inc, Rin(7), R7);
 reg_A: regn PORT MAP (BusWires, Ain, Clock, A);
 reg_DOUT: regn PORT MAP (BusWires, DOUTin, Clock, DOUT);
 reg_ADDR: regn PORT MAP (BusWires, ADDRin, Clock, ADDR);
 reg_IR: regn GENERIC MAP (n => 9) PORT MAP (DIN, IRin, Clock, IR);
 reg_W: flipflop PORT MAP (W_D, Resetn, Clock, W);
 -- alu
 alu: PROCESS (AddSub, A, BusWires)
 BEGIN
 IF AddSub = '0' THEN
 Sum <= A + BusWires;
 ELSE
 Sum <= A - BusWires;
 END IF;
 END PROCESS;
 reg_G: regn PORT MAP (Sum, Gin, Clock, G);
 Z_D <= '1' WHEN (G = 0) ELSE '0';
 reg_Z: flipflop PORT MAP (Z_D, Resetn, Clock, Z);
 -- define the internal processor bus
 Sel <= Rout & Gout & DINout;
 busmux: PROCESS (Sel, R0, R1, R2, R3, R4, R5, R6, R7, G, DIN)
 BEGIN
 IF Sel = "1000000000" THEN
 BusWires <= R0;
 ELSIF Sel = "0100000000" THEN
 BusWires <= R1;
 ELSIF Sel = "0010000000" THEN
 BusWires <= R2;
 ELSIF Sel = "0001000000" THEN
 BusWires <= R3;
 ELSIF Sel = "0000100000" THEN
 BusWires <= R4;
 ELSIF Sel = "0000010000" THEN
 BusWires <= R5;
 ELSIF Sel = "0000001000" THEN
 BusWires <= R6;
 ELSIF Sel = "0000000100" THEN
 BusWires <= R7;
 ELSIF Sel = "0000000010" THEN
 BusWires <= G;
 ELSE
 BusWires <= DIN;
 END IF;
 END PROCESS;
END Behavior;