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
component Registers is
    generic(
        dataStream: natural
    );
    port(
        clk, rst: in std_logic;
        buffIn: in std_logic_vector(dataStream downto 0);
        buffOut: out std_logic_vector(dataStream downto 0)
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
signal wa_temp: std_logic_vector(2 downto 0);

--nivel 2
signal IFRegIn, IFRegOut: std_logic_vector(31 downto 0);
signal PCNextID, instrID: std_logic_vector(15 downto 0);

--nivel 3
signal IDRegIn, IDRegOut: std_logic_vector(77 downto 0);
signal memToReg_tempEX, regWrite_tempEX, regToMem_tempEX,  branch_tempEX, aluSrc_tempEX: std_logic;
signal wa_tempEX, aluOp_tempEX, func_tempEX: std_logic_vector(2 downto 0);
signal extImm_tempEX, PCNextEX, rd1_tempEX, rd2_tempEX: std_logic_vector(15 downto 0);

signal EXRegIn, EXRegOut: std_logic_vector(55 downto 0);

--nivel 4
signal brcA_tempMEM, rd2_tempMEM, aluOut_tempMEM: std_logic_vector(15 downto 0);
signal regToMem_tempMEM, branch_tempMEM, zero_tempMEM, memToReg_tempMEM, regWrite_tempMEM: std_logic;
signal wa_tempMEM: std_logic_vector(2 downto 0);

signal MEMRegIn, MEMRegOut: std_logic_vector(36 downto 0);

--nivel 1/5
signal regWrite_tempWB, memToReg_tempWB: std_logic;
signal wa_tempWB: std_logic_vector(2 downto 0);
signal RAMoutWB, aluOut_tempWB: std_logic_vector(15 downto 0);


begin
    --PART 1
    --Button debounce
    MonoPulseGenerator_C1: MonoPulseGenerator port map(btn=>btn(0), clk=>clk, en=>enIF);
    MonoPulseGenerator_C2: MonoPulseGenerator port map(btn=>btn(1), clk=>clk, en=>rstIF);
    --Instruction fetch(Compute next instruction)
    InstructionFetch_C1: InstructionFetch port map(en=>enIF, clk=>clk, rst=>rstIF, jmpA=>jmpA_temp, brcA=>brcA_tempMEM, PCSrc=>PCSrc_temp, PCJmp=>PCJmp_temp, PCnext=>PCnext, instr=>instr);
    IFRegIn <= instr & PCnext;
    Registers_C1: Registers generic map(dataStream=>31) port map(clk=>enIF, rst=>rstIF, buffIn=>IFRegIn, buffOut=>IFRegOut);
    --Semnale care trec la urmatorul nivel
    PCNextID<=IFRegOut(15 downto 0);
    instrID<=IFRegOut(31 downto 16);




    --PART 2
    jmpA_temp <= "000" & instrID(12 downto 0);  
    PCJmp_temp <= jmp_temp;                     
    --Control units(Compute enable signals)
    ControlUnit_C1: ControlUnit port map(opCode=>instrID(15 downto 13), regDst=>regDst_temp, regWrite=>regWrite_temp, aluSrc=>aluSrc_temp, extOp=>extOp_temp, aluOp=>aluOp_temp, regToMem=>regToMem_temp, memToReg=>memToReg_temp, branch=>branch_temp, jmp=>jmp_temp);
    --Decode current instruction into components(registers, addresses, etc)
    InstructionDecoder_C1: InstructionDecoder port map(wa=>wa_tempWB(2 downto 0), regWr=>regWrite_tempWB, instr=>instrID, regDst=>regDst_temp, extOp=>extOp_temp, wd=>wd_temp, rd1=>rd1_temp, rd2=>rd2_temp, extImm=>extImm_temp, func=>func_temp, sa=>sa_temp, clk=>clk);-- care reg write
    wa_temp <= instrID(9 downto 7) when regDst_temp = '0' else instrID(6 downto 4) when regDst_temp = '1';

    
    IDRegIn<=wa_temp & extImm_temp & memToReg_temp & regWrite_temp & regToMem_temp & branch_temp & aluOp_temp & aluSrc_temp & func_temp & PCNextID & rd1_temp & rd2_temp;
    Registers_C2: Registers generic map(dataStream=>77) port map(clk=>enIF, rst=>rstIF, buffIn=>IDRegIn, buffOut=>IDRegOut);
    wa_tempEX<=IDRegOut(77 downto 75);
    extImm_tempEX<=IDRegOut(74 downto 59);
    memToReg_tempEX<=IDRegOut(58);
    regWrite_tempEX<=IDRegOut(57);
    regToMem_tempEX<=IDRegOut(56);
    branch_tempEX<=IDRegOut(55);
    aluOp_tempEX<=IDRegOut(54 downto 52);
    aluSrc_tempEX<=IDRegOut(51);
    func_tempEX<=IDRegOut(50 downto 48);
    PCNextEX<=IDRegOut(47 downto 32);
    rd1_tempEX<=IDRegOut(31 downto 16);
    rd2_tempEX<=IDRegOut(15 downto 0);

    --Part3
    aluIn2 <= rd2_tempEX when aluSrc_tempEX='0' else extImm_tempEX when aluSrc_tempEX='1';
    ALUControl_C1: ALUControl generic map(aluOpLength=>2, funcLength=>2, aluSelLength=>2) port map(aluOp=>aluOp_tempEX, func=>func_tempEX, aluSel=>aluSel_temp);
    --ALU
    ALU_C1: ALU generic map(aluSelLength=>2, dataStream=>15) port map(en=>enIF, aluIn1=>rd1_tempEX, aluIn2=>aluIn2, aluSel=>aluSel_temp, aluOut=>aluOut_temp, high=>high_temp, zero=>zero_temp);
    brcA_temp <= PCNextEX + extImm_tempEX;         
    EXRegIn<= wa_tempEX & regToMem_tempEX & brcA_temp & rd2_tempEX & aluOut_temp & branch_tempEX & zero_temp & memToReg_tempEX & regWrite_tempEX;
    Registers_C3: Registers generic map(dataStream=>55) port map(clk=>enIF,rst=>rstIF, buffIn=>EXRegIn, buffOut=>EXRegOut);
    wa_tempMEM<=EXRegOut(55 downto 53);
    regToMem_tempMEM<=EXRegOut(52);
    brcA_tempMEM<=EXRegOut(51 downto 36);
    rd2_tempMEM<=EXRegOut(35 downto 20);
    aluOut_tempMEM<=EXRegOut(19 downto 4);
    branch_tempMEM<=EXRegOut(3);
    zero_tempMEM<=EXRegOut(2);
    memToReg_tempMEM<=EXRegOut(1);
    regWrite_tempMEM<=EXRegOut(0);

    --PARTEA 4
    PCSrc_temp <= branch_tempMEM and zero_tempMEM;
    regWrite_temp2 <= regWrite_tempMEM and enIF;
    
    --RAM
    memWrEn<=regToMem_tempMEM;
    RAM_C1: RAM generic map(adressLength => 15, wordLength =>15) port map(en=>enIF, clk=>clk, memWr=>memWrEn, addr=>aluOut_tempMEM, wd=>rd2_tempMEM, rd=>RAMout);
    ---HEREEEEEEEEEEEEEEEE
    MEMRegIn<=wa_tempMEM & regWrite_tempMEM & memToReg_tempMEM & RAMout & aluOut_tempMEM;
    Registers_C4: Registers generic map(dataStream=>36) port map(clk=>enIF,rst=>rstIF, buffIn=>MEMRegIn, buffOut=>MEMRegOut);
    wa_tempWB<=MEMRegOut(36 downto 34);
    regWrite_tempWB<=MEMRegOut(33);
    memToReg_tempWB<=MEMRegOut(32);
    RAMoutWB<=MEMRegOut(31 downto 16);
    aluOut_tempWB<=MEMRegOut(15 downto 0);

    wd_temp <= aluOut_tempWB when memToReg_tempWB='0' else RAMoutWB when memToReg_tempWB='1';
    
	--Display
	led(15)<=regDst_temp;
	led(14)<=regWrite_temp;
	led(13)<=aluSrc_temp;
	led(12)<=extOp_temp;
	led(11)<=memWrEn;
	led(10)<=regToMem_temp;
	led(9)<=branch_temp;
	led(8)<=zero_temp;
	led(6)<=jmp_temp;
	asdf <= rd1_tempEX(3 downto 0) & aluIn2(3 downto 0) & "0000" & aluOut_temp(3 downto 0) when sw(8) = '1' else instrID;
	SevenSegmentDisplays_C1: SevenSegmentDisplays port map(input=>asdf, clk=>clk, an=>an, cat=>cat);	
end A_Basys3Env1;
