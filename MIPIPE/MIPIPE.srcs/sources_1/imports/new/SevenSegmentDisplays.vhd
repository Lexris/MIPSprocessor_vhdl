library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity SevenSegmentDisplays is
    port(
        input: in std_logic_vector(15 downto 0);
        clk: in std_logic;
        an: out std_logic_vector(3 downto 0);
        cat: out std_logic_vector(6 downto 0)
        );
end SevenSegmentDisplays;

architecture A_SevenSegmentDisplays of SevenSegmentDisplays is
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
signal cnt_temp: std_logic_vector(15 downto 0);
signal display: std_logic_vector(3 downto 0);

begin
    --Counter_C1: Counter generic map(data_stream=>15) port map(sd=>(others=>'0'), cnt=>cnt_temp, en=>'1', rst=>'0', set=>'0', clk=>clk,  dir=>'0'); 
    
    Count: process(clk)
    begin
        if rising_edge(clk) then
          cnt_temp <= cnt_temp +1;
        end if;
    end process;


    RefreshSSDs: process(cnt_temp(15 downto 14), input)
    begin
        case cnt_temp(15 downto 14) is
            when "00" => 
                display <= input(3 downto 0);
                an <= "1110";
            when "01" => 
                display <= input(7 downto 4);
                an <= "1101";
            when "10" => 
                display <= input(11 downto 8);
                an <= "1011";
            when "11" => 
                display <= input(15 downto 12);
                an <= "0111";
            when others => null;
        end case;
    end process;

    with display select cat<= 
        "1111001" when "0001",   --1
        "0100100" when "0010",   --2
        "0110000" when "0011",   --3
        "0011001" when "0100",   --4
        "0010010" when "0101",   --5
        "0000010" when "0110",   --6
        "1111000" when "0111",   --7
        "0000000" when "1000",   --8
        "0010000" when "1001",   --9
        "0001000" when "1010",   --A
        "0000011" when "1011",   --b
        "1000110" when "1100",   --C
        "0100001" when "1101",   --d
        "0000110" when "1110",   --E
        "0001110" when "1111",   --F
        "1000000" when others;   --0
end A_SevenSegmentDisplays;
