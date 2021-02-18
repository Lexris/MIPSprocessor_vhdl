library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity Decoder is
	port(
	   input: in std_logic_vector(3 downto 0);
	   output: out std_logic_vector(3 downto 0)
    );
end Decoder;

architecture A_Decoder of Decoder is
begin
	process(input)
	begin
		case input is
			when "000" => output <= "00000001";
			when "001" => output <= "00000010";
			when "010" => output <= "00000100";
			when "011" => output <= "00001000";
			when "100" => output <= "00010000";
			when "101" => output <= "00100000";
			when "110" => output <= "01000000";
			when "111" => output <= "10000000";
		end case;
	end process;
end A_Decoder;
