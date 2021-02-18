

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity test_env_lab6 is
   Port ( clk : in STD_LOGIC;
          btn : in STD_LOGIC_VECTOR (4 downto 0);
          sw : in STD_LOGIC_VECTOR (15 downto 0);
          led : out STD_LOGIC_VECTOR (15 downto 0);
          an : out STD_LOGIC_VECTOR (3 downto 0);
          cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env_lab6;

architecture a_test_env_lab6 of test_env_lab6 is

component MonoPulseGenerator is
    port(
		btn, clk: in std_logic;
		en: out std_logic
	);
end component;

component SevenSegmentDisplays is
    port(
        input: in std_logic_vector(15 downto 0);
        clk: in std_logic;
        an: out std_logic_vector(3 downto 0);
        cat: out std_logic_vector(6 downto 0)
        );
end component;

component InstructionFetch is
    port(
	en: in std_logic;	
	clk: in std_logic;
	rst: in std_logic; 
	ja: in std_logic_vector(15 downto 0);
	ba: in std_logic_vector(15 downto 0);  
	PCSrc, PCJmp: in std_logic;
	PCnext: out std_logic_vector(15 downto 0);
	instr: out std_logic_vector(15 downto 0)
	);
end component;

component ControlUnit is
    port(  opcode : in STD_LOGIC_VECTOR (2 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           AluOp : out STD_LOGIC_VECTOR (2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC;
           hiLo: out std_logic
           );
end component;

component InstructionDecoder is
      port(
        regWrite: in std_logic;
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
end component;

signal enable: std_logic;
signal reset: std_logic;
signal instruction : STD_LOGIC_VECTOR (15 downto 0);
signal PCplusone : STD_LOGIC_VECTOR (15 downto 0);
signal jmp: std_logic;
signal pcsrc: std_logic;
signal regdst: std_logic;
signal extop: std_logic;
signal alusrc: std_logic;
signal aluop:  STD_LOGIC_VECTOR (2 downto 0);
signal memwrite: std_logic;
signal memtoreg: std_logic;
signal regwrite: std_logic;
signal rd1:std_logic_vector(15 downto 0);
signal rd2:std_logic_vector(15 downto 0);
signal extimm:std_logic_vector(15 downto 0);
signal func: std_logic_vector(2 downto 0);
signal hilo: std_logic:='0';
signal sa: std_logic;
signal RegWR: std_logic;
signal writedata: std_logic_vector(15 downto 0);
signal output: std_logic_vector(15 downto 0);
begin

RegWR <= enable and regwrite;
writedata <= rd1+rd2;


process(sw(7 downto 5))
begin
case sw(7 downto 5) is
when "000" => output <= instruction;
when "001" => output <= PCplusone;
when "010" => output <= rd1;
when "011" => output <= rd2;
when "100" => output <= writedata;
when "101" => output <= extimm;
when "110" => output <= "0000000000000000";
when "111" => output <= "0000000000000000";
end case;
end process;

led(0) <= alusrc;
led(3 downto 1) <= aluop;
led(4) <= memwrite;
led(5) <= memtoreg;
led(15 downto 6) <= "0000000000";

C1: MonoPulseGenerator port map(btn(0), clk, enable);
C2: MonoPulseGenerator port map(btn(1), clk, reset);
C3: InstructionFetch port map(enable, clk, reset, "0000000000000000", "0000000000000000", jmp, pcsrc, PCplusone, instruction);
C4: ControlUnit port map(instruction(15 downto 13), regdst, extop, alusrc, pcsrc, jmp, aluop, memwrite, memtoreg, regwrite, hilo);
C5: InstructionDecoder port map(RegWR, instruction, regdst, extop, writedata, rd1, rd2, extimm, func, sa, clk);
C6: SevenSegmentDisplays port map(output, clk, an, cat);
end a_test_env_lab6;










