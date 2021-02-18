library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity ALU is
    generic(
        aluSelLength: natural := 2;
        dataStream: natural := 0
    );
    port(
        en: in std_logic;
        aluIn1, aluIn2: in std_logic_vector(dataStream downto 0);
        aluSel: in std_logic_vector(2 downto 0);
        aluOut: out std_logic_vector(dataStream downto 0);
        high: out std_logic_vector(2*dataStream+1 downto 0);
        zero: out std_logic
        );
end ALU;

architecture A_ALU of ALU is
signal aluOutTemp: std_logic_vector(dataStream downto 0);
begin

selectOperation: process(aluSel, aluIn1, aluIn2)
begin
    case aluSel is
        when "000" => aluOutTemp <= aluIn1 + aluIn2;
        when "001" => aluOutTemp <= aluIn1 - aluIn2;
        when "011" => aluOutTemp <= aluIn1(dataStream-1 downto 0) & "0";
        when "010" => aluOutTemp <= "0" & aluIn1(dataStream downto 1);
        when "110" => aluOutTemp <= aluIn1 and aluIn2;
        when "111" => aluOutTemp <= aluIn1 or aluIn2;
        when "101" => aluOutTemp <= aluIn1 xor aluIn2;
        when "100" => aluOutTemp <= not(aluIn1 xor aluIn2);
        when others => null;
    end case;
end process;
	
aluOut <= aluOutTemp;
zero <= '1' when aluOutTemp = 0 else '0';
end A_ALU;
