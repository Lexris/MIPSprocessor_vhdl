library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlUnit is
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
end ControlUnit;

architecture A_ControlUnit of ControlUnit is
begin
    process(opcode) 
    begin
        case opcode is
            when "000" => regDst<='1'; regWrite<='1'; aluSrc<='0'; extOp<='-'; aluOp<=opcode; regToMem<='0'; memToReg<='0'; branch<='0'; jmp<='0'; --rtype
            when "001" => regDst<='0'; regWrite<='1'; aluSrc<='1'; extOp<='1'; aluOp<=opcode; regToMem<='0'; memToReg<='0'; branch<='0'; jmp<='0'; --addi
            when "011" => regDst<='0'; regWrite<='1'; aluSrc<='1'; extOp<='1'; aluOp<=opcode; regToMem<='0'; memToReg<='0'; branch<='0'; jmp<='0'; --subi
            when "010" => regDst<='0'; regWrite<='1'; aluSrc<='1'; extOp<='1'; aluOp<=opcode; regToMem<='0'; memToReg<='1'; branch<='0'; jmp<='0'; --lw
            when "110" => regDst<='-'; regWrite<='0'; aluSrc<='1'; extOp<='1'; aluOp<=opcode; regToMem<='1'; memToReg<='-'; branch<='0'; jmp<='0'; --sw
            when "111" => regDst<='-'; regWrite<='0'; aluSrc<='0'; extOp<='1'; aluOp<=opcode; regToMem<='0'; memToReg<='-'; branch<='1'; jmp<='0'; --beq
            when "101" => regDst<='-'; regWrite<='0'; aluSrc<='0'; extOp<='1'; aluOp<=opcode; regToMem<='0'; memToReg<='-'; branch<='1'; jmp<='0'; --bne
            when "100" => regDst<='-'; regWrite<='0'; aluSrc<='-'; extOp<='-'; aluOp<=opcode; regToMem<='0'; memToReg<='-'; branch<='0'; jmp<='1'; --jmp
            when others => null;
        end case;
    end process;
end A_ControlUnit;
