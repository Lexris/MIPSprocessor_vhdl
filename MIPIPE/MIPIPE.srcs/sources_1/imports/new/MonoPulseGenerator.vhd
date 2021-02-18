library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity MonoPulseGenerator is
    port(
		btn, clk: in std_logic;
		en: out std_logic
	);
end MonoPulseGenerator;

architecture A_MonoPulseGenerator of MonoPulseGenerator is
signal q1: std_logic := '0';
signal q2: std_logic := '0';
signal q3: std_logic := '0';
signal sum: std_logic_vector(15 downto 0);
component Counter
	generic(
		data_stream: natural:=15
	);
	port(
	    sd: in std_logic_vector(data_stream downto 0);
		cnt: out std_logic_vector(data_stream downto 0);
		en, rst, set, clk, dir: in std_logic
	);
end component;

begin
	Counter_C1: Counter generic map(data_stream=>15) port map(sd=>(others=>'0'), cnt=>sum, en=>'1', rst=>'0', set=>'0', clk=>clk, dir=>'0'); 
	process(clk)
	begin
		if rising_edge(clk) then
			q3 <= q2;
			q2 <= q1;
			if sum="1111111111111111" then
				q1 <= btn;
		    end if;
		end if;
	end process;
	en <= q2 and not q3;
end A_MonoPulseGenerator;
