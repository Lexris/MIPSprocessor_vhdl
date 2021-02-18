library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity Basys3Env1 is
    port( 
        clk : in STD_LOGIC;
        btn : in STD_LOGIC_VECTOR (4 downto 0);
        sw : in STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (15 downto 0);
        an : out STD_LOGIC_VECTOR (3 downto 0);
        cat : out STD_LOGIC_VECTOR (6 downto 0)
    );
end Basys3Env1;

architecture A_Basys3Env1 of Basys3Env1 is
component MonoPulseGenerator is
    port(
		btn, clk: in std_logic;
		en: out std_logic
	);
end component;
component InstructionFetch is
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
end component;
component ControlUnit is
    port(  
        opCode: in std_logic_vector(2 downto 0);
        regDst: out std_logic;
        regWrite: out std_logic;
        aluSrc: out std_logic;
        extOp: out std_logic;
        aluOp: out std_logic_vector(2 downto 0);
        regToMem: out std_logic;
        memToReg: out std_logic;
        branch: out std_logic;
        jmp: out std_logic
        );
end component;
component ALUControl is
    generic(
        aluOpLength: natural := 2;
        funcLength: natural := 2;
        aluSelLength: natural := 2
    );
    port(
        aluOp: in std_logic_vector(aluOpLength downto 0);
        func: in std_logic_vector(funcLength downto 0);
        aluSel: out std_logic_vector(aluSelLength downto 0)
    );
end component;
component InstructionDecoder is
    port(
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
end component;
component ALU is
    generic(
        aluSelLength: natural := 2;
        dataStream: natural := 0
    );
    port(  
        en: in std_logic;
        aluIn1, aluIn2: in std_logic_vector(dataStream downto 0);
        aluSel: in std_logic_vector(aluSelLength downto 0);
        aluOut: out std_logic_vector(dataStream downto 0);
        high: out std_logic_vector(2*dataStream+1 downto 0);
        zero: out std_logic
        );
end component;
component RAM is
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
end component;
component SevenSegmentDisplays is
    port(
        input: in std_logic_vector(15 downto 0);
        clk: in std_logic;
        an: out std_logic_vector(3 downto 0);
        cat: out std_logic_vector(6 downto 0)
        );
end component;

signal enIF, rstIF: std_logic;
signal jmpA_temp, brcA_temp: std_logic_vector(15 downto 0);
signal PCSrc_temp, PCJmp_temp: std_logic;
signal PCnext, instr: std_logic_vector(15 downto 0);  
signal an_temp: std_logic_vector(3 downto 0);
signal cat_temp: std_logic_vector(6 downto 0);

signal regDst_temp: std_logic;
signal regWrite_temp: std_logic;
signal aluSrc_temp: std_logic;
signal extOp_temp: std_logic;
signal aluOp_temp: std_logic_vector(2 downto 0);
signal regToMem_temp: std_logic;
signal memToReg_temp: std_logic;
signal branch_temp: std_logic;
signal jmp_temp: std_logic;
signal aluSel_temp: std_logic_vector(2 downto 0);

signal wd_temp: std_logic_vector(15 downto 0);
signal rd1_temp, rd2_temp: std_logic_vector(15 downto 0);
signal extImm_temp: std_logic_vector(15 downto 0);
signal func_temp: std_logic_vector(2 downto 0);
signal sa_temp: std_logic;

signal aluIn2: std_logic_vector(15 downto 0);
signal aluOut_temp: std_logic_vector(15 downto 0);
signal high_temp: std_logic_vector(31 downto 0);
signal zero_temp: std_logic:='0';

signal memWrEn: std_logic:='0';
signal RAMout: std_logic_vector(15 downto 0);

signal regWrite_temp2: std_logic;

signal asdf: std_logic_vector(15 downto 0);
begin
    --Button debounce
    MonoPulseGenerator_C1: MonoPulseGenerator port map(btn=>btn(0), clk=>clk, en=>enIF);
    MonoPulseGenerator_C2: MonoPulseGenerator port map(btn=>btn(1), clk=>clk, en=>rstIF);
    
    --Instruction fetch(Compute next instruction)
    brcA_temp <= PCnext + extImm_temp;
    jmpA_temp <= "000" & instr(12 downto 0);
    PCSrc_temp <= branch_temp and zero_temp;
    PCJmp_temp <= jmp_temp;
    InstructionFetch_C1: InstructionFetch port map(en=>enIF, clk=>clk, rst=>rstIF, jmpA=>jmpA_temp, brcA=>brcA_temp, PCSrc=>PCSrc_temp, PCJmp=>PCJmp_temp, PCnext=>PCnext, instr=>instr);
    
    --Control units(Compute enable signals)
    ControlUnit_C1: ControlUnit port map(opCode=>instr(15 downto 13), regDst=>regDst_temp, regWrite=>regWrite_temp, aluSrc=>aluSrc_temp, extOp=>extOp_temp, aluOp=>aluOp_temp, regToMem=>regToMem_temp, memToReg=>memToReg_temp, branch=>branch_temp, jmp=>jmp_temp);
    ALUControl_C1: ALUControl generic map(aluOpLength=>2, funcLength=>2, aluSelLength=>2) port map(aluOp=>aluOp_temp, func=>func_temp, aluSel=>aluSel_temp);
    
    --Decode current instruction into components(registers, addresses, etc)
    wd_temp <= aluOut_temp when memToReg_temp='0' else RAMout when memToReg_temp='1';
    regWrite_temp2 <= regWrite_temp and enIF;
    InstructionDecoder_C1: InstructionDecoder port map(regWr=>regWrite_temp2, instr=>instr, regDst=>regDst_temp, extOp=>extOp_temp, wd=>wd_temp, rd1=>rd1_temp, rd2=>rd2_temp, extImm=>extImm_temp, func=>func_temp, sa=>sa_temp, clk=>clk);

    --ALU
    aluIn2 <= rd2_temp when aluSrc_temp='0' else extImm_temp when aluSrc_temp='1';
    ALU_C1: ALU generic map(aluSelLength=>2, dataStream=>15) port map(en=>enIF, aluIn1=>rd1_temp, aluIn2=>aluIn2, aluSel=>aluSel_temp, aluOut=>aluOut_temp, high=>high_temp, zero=>zero_temp);
    
    --RAM
    memWrEn<=regToMem_temp;
    RAM_C1: RAM generic map(adressLength => 15, wordLength =>15) port map(en=>enIF, clk=>clk, memWr=>memWrEn, addr=>aluOut_temp, wd=>rd2_temp, rd=>RAMout);
    
	--Display
	led(15)<=regDst_temp;
	led(14)<=regWrite_temp;
	led(13)<=aluSrc_temp;
	led(12)<=extOp_temp;
	led(11)<=memWrEn;
	led(10)<=regToMem_temp;
	led(9)<=branch_temp;
	led(8)<=zero_temp;
	led(7)<=PCSrc_temp;
	led(6)<=jmp_temp;
	asdf <= rd1_temp(3 downto 0) & aluIn2(3 downto 0) & "0000" & aluOut_temp(3 downto 0) when sw(8) = '1' else instr;
	SevenSegmentDisplays_C1: SevenSegmentDisplays port map(input=>asdf, clk=>clk, an=>an, cat=>cat);	
end A_Basys3Env1;
