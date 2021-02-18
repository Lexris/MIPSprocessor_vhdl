library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstructionFetch is
    port(
	en: in std_logic;	
	clk: in std_logic;
	rst: in std_logic; 
	jmpA: in std_logic_vector(15 downto 0);
	brcA: in std_logic_vector(15 downto 0);  
	PCSrc, PCJmp: in std_logic;
	PCnext: out std_logic_vector(15 downto 0);
	instr: out std_logic_vector(15 downto 0)
	);
end InstructionFetch;

architecture A_InstructionFetch of InstructionFetch is

component MonoPulseGenerator
	port(
		btn, clk: in std_logic;
		en: out std_logic
	);
end component;	 
type arr_type is array (0 to 255) of std_logic_vector(15 downto 0);
signal rom: arr_type:=(
--				B"000_000_000_000_0_001",       --0(reg[0] -= reg[0])
--                B"000_001_001_001_0_001",       --1(reg[1] -= reg[1])
--				B"010_001_001_000_0_000",        --2(reg[1] += mem[0])
--				B"000_010_010_010_0_001",        --3(reg[2] -= reg[2])
--				B"010_010_010_000_0_001",       --4(reg[2] += mem[1])
--				B"001_001_001_000_0_001",	   --5(reg[1] += 1)
--				B"101_001_010_111_1_111",	  --6(bne reg[1], reg[2])
--				B"100_000_000_000_0_101",	   --7(jump la 5)
--				B"110_010_001_000_0_000",       --8(store reg[2], reg[1], 0)
--                others => B"000_000_000_000_0_000" 

				--Program 1 care merge
--            B"000_000_000_000_0_001",
--            B"001_000_000_000_0_110",
--            B"000_001_001_001_0_001",
--            B"011_000_000_000_0_010",
--            B"111_000_001_000_0_001", --E081
            
--            B"100_000_000_000_0_011",
--            B"100_000_000_000_0_110",
--            others => B"000_000_000_000_0_000"	  
--				--Program 2 care merge
				B"000_000_000_000_0_001",   --0001 sub reg[0],reg[0]            1
	            
	            B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7         2
	            B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7         3   
	            B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7         4
                
                B"001_000_000_000_1_111",   --200f addi reg[0], 16              5   
                B"000_001_001_001_0_001",   --0491 sub reg[1],reg[1]            6
	            
	            B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7         7   
	            B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7         8
	            B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7         9
                
                B"110_001_000_000_0_000",   --c400 sw r[0] la r[1]+0            10
                
                B"000_000_000_000_0_010",   --0002 srl r[0] cu 1                11
	            B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7         12
	            B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7         13  
	            B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7         14

                B"111_000_001_000_0_101",   --e085 beq r[0], r[1], 5            15
                B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7          16
	            B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7         17
	            B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7         18

                B"100_000_000_000_1_010",   --800a jmp 10                       19
	            B"000_111_111_111_1_110",   --1FFE and reg7,reg7,reg7           20

                
				B"010_000_000_000_0_000",   --4000 lw r0 <-mem[0]               21
				
				B"100_000_000_001_0_101",   --8015 jmp 21(adica la el)          22
	            B"000_111_111_111_1_110",    --1FFE and reg7,reg7,reg7         23

                others => B"000_000_000_000_0_000"
                );	  
signal sum: std_logic_vector(15 downto 0) := (others=>'0');	
signal mux1: std_logic_vector(15 downto 0) := (others=>'0');	
signal mux2: std_logic_vector(15 downto 0) := (others=>'0');
begin
	ProgramCounter: process(en, rst, clk) 
	begin
	   if rst = '1' then
	       sum <= (others=>'0');
	   elsif en='1' and rising_edge(clk) then
		   sum <= mux2;
	   end if; 
	end process; 
	
	mux1 <= sum+1 when PCSrc='0'
		else brcA when PCSrc='1'; 
	mux2 <= mux1 when PCJmp='0' 
		else jmpA when PCJmp='1';
	instr<=rom(conv_integer(sum));
	PCnext<=sum+1;
end A_InstructionFetch;
