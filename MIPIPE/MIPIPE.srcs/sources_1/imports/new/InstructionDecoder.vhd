library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InstructionDecoder is
    port(
        wa: in std_logic_vector(2 downto 0);
        regWr: in std_logic;
        instr: in std_logic_vector(15 downto 0);
        regDst: in std_logic;
        extOp: in std_logic;
        wd: in std_logic_vector(15 downto 0);
        rd1, rd2: out std_logic_vector(15 downto 0);
        extImm: out std_logic_vector(15 downto 0);
        func: out std_logic_vector(2 downto 0);
        sa: out std_logic;
        clk: in std_logic
        );
end InstructionDecoder;

architecture A_InstructionDecoder of InstructionDecoder is
component RegisterFile is
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
end component;
begin
    --determine the write adress
    
    --extend immediate
    extImm <= (15 downto 7 => '0') & instr(6 downto 0) when extOp = '0' else (15 downto 7 => instr(6)) & instr(6 downto 0) when extOp = '1';
    
    func <= instr(2 downto 0);
    sa <= instr(3);
    
    RegisterFile_C1: RegisterFile generic map(adressLength=>2, wordLength=>15) port map(ra1=>instr(12 downto 10), ra2=>instr(9 downto 7), wa=>wa, wd=>wd, regWr=>regWr, clk=>clk, rd1=>rd1, rd2=>rd2);

end A_InstructionDecoder;
