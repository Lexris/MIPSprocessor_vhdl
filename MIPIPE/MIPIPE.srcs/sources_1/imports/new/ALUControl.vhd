library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALUControl is
    generic(
        aluOpLength: natural := 2;
        funcLength: natural := 2;
        aluSelLength: natural := 2
    );
    port(
        aluOp: in std_logic_vector(2 downto 0);
        func: in std_logic_vector(2 downto 0);
        aluSel: out std_logic_vector(2 downto 0)
    );
end ALUControl;

architecture A_ALUControl of ALUControl is

begin
    selectOperation: process(aluOp)
    begin
        case aluOp is
            when "000" => 
                case func is
                    when "000" => aluSel <= "000";   --add
                    when "001" => aluSel <= "001";   --sub
                    when "011" => aluSel <= "011";   --sll
                    when "010" => aluSel <= "010";    --srl
                    when "110" => aluSel <= "110";   --and
                    when "111" => aluSel <= "111";   --or
                    when "101" => aluSel <= "101";   --xor
                    when "100" => aluSel <= "100";   --nxor 
                    when others => null;
                end case;
            when "001" => aluSel <= "000";          --addi
            when "011" => aluSel <= "001";          --subi
            when "010" => aluSel <= "000";          --lw
            when "110" => aluSel <= "000";          --sw
            when "111" => aluSel <= "001";          --beq
            when "101" => aluSel <= "001";          --bne
            when "100" => aluSel <= "001";          --jmp
            when others => null;
        end case;
    end process;
end A_ALUControl;
