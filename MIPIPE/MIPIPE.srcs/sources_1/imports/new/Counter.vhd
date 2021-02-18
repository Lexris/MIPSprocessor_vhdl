library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity Counter is
    generic(
	   data_stream: natural := 0
	);
	port(
	   sd: in std_logic_vector(data_stream downto 0);
	   cnt: out std_logic_vector(data_stream downto 0);
	   en, rst, set, clk, dir: in std_logic
    );
end Counter;

architecture A_Counter of Counter is
signal sum: std_logic_vector(data_stream downto 0);
begin
	process(en, rst, set, clk) 
	begin 
        if rst='1' then
    	    sum <= (others => '0');
        elsif set='1' then
    	    sum <= sd;
        elsif en='1' and rising_edge(clk) then
	        if dir = '0' then
		       sum <= sum + 1;
		    elsif dir='1' then
			   sum <= sum - 1;
		    end if;
	    end if; 
	end process; 
	cnt <= sum;
end A_Counter;
