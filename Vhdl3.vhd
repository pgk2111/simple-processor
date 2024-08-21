LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
ENTITY pc_count IS
 PORT ( R : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
 Resetn, Clock, E, L : IN STD_LOGIC;
 Q : OUT STD_LOGIC_VECTOR(8 DOWNTO 0));
END pc_count;
ARCHITECTURE Behavior OF pc_count IS
 SIGNAL Count : STD_LOGIC_VECTOR(8 DOWNTO 0);
BEGIN
 PROCESS (Clock)
 BEGIN
 IF (Clock'EVENT AND Clock = '1') THEN
 IF (Resetn = '0') THEN
 Count <= (OTHERS => '0');
 ELSIF (L = '1') THEN
 Count <= R;
 ELSIF (E = '1') THEN
 Count <= Count + 1;
 END IF;
 END IF;
 END PROCESS;
 Q <= Count;
END Behavior;