library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RegisterFile is
    generic(
		adressLength: natural:=2;
		wordLength: natural:=15
	);
	port( 
		ra1, ra2, wa: in std_logic_vector(adressLength downto 0);
		wd: in std_logic_vector(wordLength downto 0);
		regWr, clk: in std_logic;
		rd1, rd2: out std_logic_vector(wordLength downto 0)
	);
end RegisterFile;

architecture A_RegisterFile of RegisterFile is
    type arr_type is array (0 to 7) of std_logic_vector(wordLength downto 0);----------modif aici la 15
    signal registers: arr_type:=(
        B"0000_0000_0000_0000",
        B"0000_0000_0000_0011",
        B"0000_0000_0000_0010",
        B"0000_0000_0000_0011",
        B"0000_0000_0000_0100",
        B"0000_0000_0000_0101",
        B"0000_0000_0000_0110",
        B"0000_0000_0000_0111"
        );
    begin
	rd1 <= registers(conv_integer(ra1));
	rd2 <= registers(conv_integer(ra2));
	
	WRITE_REGISTER: process(clk)
	begin
	   if rising_edge(clk) then
	       if regWr='1' then
                registers(conv_integer(wa)) <= wd;
           end if;
       end if;
	end process;
end A_RegisterFile;
