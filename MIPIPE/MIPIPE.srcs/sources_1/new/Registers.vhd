library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity Registers is
    generic(
        dataStream: natural
    );
    port(
        clk, rst: in std_logic;
        buffIn: in std_logic_vector(dataStream downto 0);
        buffOut: out std_logic_vector(dataStream downto 0)
    );
end Registers;

architecture A_Registers of Registers is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if(rst='1') then
                buffOut<=(others=>'0');
            else buffOut <= buffIn;
            end if;
        end if;
    end process;
end A_Registers;
