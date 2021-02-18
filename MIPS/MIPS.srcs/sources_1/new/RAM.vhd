library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAM is
    generic(
        adressLength: natural:=15;
		wordLength: natural:=15
    );
    port( 
        en: in std_logic;
        clk: in std_logic;
        memWr: in std_logic;
        addr: in std_logic_vector(adressLength downto 0);
        wd: in std_logic_vector(wordLength downto 0); 
        rd: out std_logic_vector(wordLength downto 0)
    );
end RAM;

architecture A_RAM of RAM is
type mem is array(0 to adressLength) of std_logic_vector(wordLength downto 0);
signal ram: mem;
signal address: std_logic_vector(3 downto 0);--AICI ERA 4
begin
    address <= addr(3 downto 0);
   
    process (clk)
    begin
        if rising_edge(clk) then
            if en = '1' and memWr = '1' then
                ram(conv_integer(address)) <= wd;
            end if;
        end if;
    end process;
    
    rd <= ram(conv_integer(address));

end A_RAM;
