library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        imm_signed : out std_logic;
        sel_b      : out std_logic;
        op_alu     : out std_logic_vector(5 downto 0);
        read       : out std_logic;
        write      : out std_logic;
        sel_pc     : out std_logic;
        branch_op  : out std_logic;
        sel_mem    : out std_logic;
        rf_wren    : out std_logic;
        pc_sel_imm : out std_logic;
        pc_sel_a   : out std_logic;
        sel_ra     : out std_logic;
        rf_retaddr : out std_logic_vector(4 downto 0);
        sel_rC     : out std_logic
    );
end controller;

architecture synth of controller is

    constant op_lsb_branch : std_logic_vector(2 downto 0) := "110";
    constant op_br : std_logic_vector(5 downto 0) := "000110";
    constant op_ble : std_logic_vector(5 downto 0) := "001110";
    constant op_bgt : std_logic_vector(5 downto 0) := "010110";
    constant op_bne : std_logic_vector(5 downto 0) := "011110";
    constant op_beq : std_logic_vector(5 downto 0) := "100110";
    constant op_bleu : std_logic_vector(5 downto 0) := "101110";
    constant op_bgtu : std_logic_vector(5 downto 0) := "110110";

    constant op_call : std_logic_vector(5 downto 0) := "000000";

    constant op_jmpi : std_logic_vector(5 downto 0) := "000001";

    constant op_andi : std_logic_vector(5 downto 0) :=    "001100";
    constant op_ori : std_logic_vector(5 downto 0) :=     "010100";
    constant op_xnori : std_logic_vector(5 downto 0) :=   "011100";
    constant op_cmpleui : std_logic_vector(5 downto 0) := "101000";
    constant op_cmpgtui : std_logic_vector(5 downto 0) := "110000";

    constant op_addi : std_logic_vector(5 downto 0) :=   "000100";
    constant op_cmplei : std_logic_vector(5 downto 0) := "001000";
    constant op_cmpgti : std_logic_vector(5 downto 0) := "010000";
    constant op_cmpnei : std_logic_vector(5 downto 0) := "011000";
    constant op_cmpeqi : std_logic_vector(5 downto 0) := "100000";

    constant op_ldw : std_logic_vector(5 downto 0) := "010111";

    constant op_stw : std_logic_vector(5 downto 0) := "010101";

    constant op_r_type : std_logic_vector(5 downto 0) := "111010";


    constant opx_lsb_jmp : std_logic_vector(2 downto 0) := "101";
    constant opx_callr : std_logic_vector(5 downto 0) := "011101";
    constant opx_jmp : std_logic_vector(5 downto 0) := "001101";
    constant opx_ret : std_logic_vector(5 downto 0) := "000101";

    constant opx_lsb_ri_op : std_logic_vector(2 downto 0) := "010";
    constant opx_slli : std_logic_vector(5 downto 0) := "010010";
    constant opx_srli : std_logic_vector(5 downto 0) := "011010";
    constant opx_srai : std_logic_vector(5 downto 0) := "111010";
    constant opx_roli : std_logic_vector(5 downto 0) := "000010";

    constant opx_add : std_logic_vector(5 downto 0) := "110001";
    constant opx_sub : std_logic_vector(5 downto 0) := "111001";
    constant opx_cmple : std_logic_vector(5 downto 0) := "001000";
    constant opx_cmpgt : std_logic_vector(5 downto 0) := "010000";
    constant opx_nor : std_logic_vector(5 downto 0) := "000110";
    constant opx_and : std_logic_vector(5 downto 0) := "001110";
    constant opx_or : std_logic_vector(5 downto 0) := "010110";
    constant opx_xnor : std_logic_vector(5 downto 0) := "011110";
    constant opx_sll : std_logic_vector(5 downto 0) := "010011";
    constant opx_srl : std_logic_vector(5 downto 0) := "011011";
    constant opx_sra : std_logic_vector(5 downto 0) := "111011";
    constant opx_cmpne : std_logic_vector(5 downto 0) := "011000";
    constant opx_cmpeq : std_logic_vector(5 downto 0) := "100000";
    constant opx_cmpleu : std_logic_vector(5 downto 0) := "101000";
    constant opx_cmpgtu : std_logic_vector(5 downto 0) := "110000";
    constant opx_rol : std_logic_vector(5 downto 0) := "000011";
    constant opx_ror : std_logic_vector(5 downto 0) := "001011";

    constant opx_break : std_logic_vector(5 downto 0) := "110100";


    constant op_alu_add : std_logic_vector(5 downto 0) := "000---";
    constant op_alu_sub : std_logic_vector(5 downto 0) := "001---";

    constant op_alu_le : std_logic_vector(5 downto 0) := "011001";
    constant op_alu_gt : std_logic_vector(5 downto 0) := "011010";
    constant op_alu_ne : std_logic_vector(5 downto 0) := "011011";
    constant op_alu_eq : std_logic_vector(5 downto 0) := "011100";
    constant op_alu_leu : std_logic_vector(5 downto 0) := "011101";
    constant op_alu_gtu : std_logic_vector(5 downto 0) := "011110";

    constant op_alu_nor : std_logic_vector(5 downto 0) := "10--00";
    constant op_alu_and : std_logic_vector(5 downto 0) := "10--01";
    constant op_alu_or : std_logic_vector(5 downto 0) := "10--10";
    constant op_alu_xnor : std_logic_vector(5 downto 0) := "10--11";

    constant op_alu_rol : std_logic_vector(5 downto 0) := "11-000";
    constant op_alu_ror : std_logic_vector(5 downto 0) := "11-001";
    constant op_alu_sll : std_logic_vector(5 downto 0) := "11-010";
    constant op_alu_srl : std_logic_vector(5 downto 0) := "11-011";
    constant op_alu_sra : std_logic_vector(5 downto 0) := "11-111";

begin

    branch_op <= '1' when op(2 downto 0) = op_lsb_branch else '0';

    imm_signed <= '0' when op = op_andi or op = op_ori or op = op_xnori or op = op_cmpleui or op = op_cmpgtui else '1';

    pc_sel_a <= '1' when op = op_r_type and (opx(2 downto 0) = opx_lsb_jmp) else '0';

    pc_sel_imm <= '1' when op = op_call or op = op_jmpi else '0';

    rf_wren <= '0' when op(2 downto 0) = op_lsb_branch or op = op_jmpi or (op = op_r_type and opx = opx_jmp) else '1';

    sel_b <= '1' when op(2 downto 0) = op_lsb_branch or (op = op_r_type and opx(2 downto 0) /= opx_lsb_jmp and opx(2 downto 0) /= opx_lsb_ri_op) else '0';

    sel_mem <= '1' when op = op_ldw else '0';

    sel_pc <= '1' when op = op_call or (op = op_r_type and opx = opx_callr) else '0';

    sel_ra <= '1' when op = op_call or (op = op_r_type and opx = opx_callr) else '0';

    sel_rC <= '1' when op = op_r_type and opx(2 downto 0) /= opx_lsb_jmp else '0';

    read <= '1' when op = op_ldw else '0';

    write <= '1' when op = op_stw else '0';

    p_op_alu : process(op, opx) is
    begin
        if (op = op_r_type) then
            if (opx = opx_add) then
                op_alu <= op_alu_add;
            elsif (opx = opx_sub) then
                op_alu <= op_alu_sub;
            elsif (opx = opx_cmple) then
                op_alu <= op_alu_le;
            elsif (opx = opx_cmpgt) then
                op_alu <= op_alu_gt;
            elsif (opx = opx_cmpne) then
                op_alu <= op_alu_ne;
            elsif (opx = opx_cmpeq) then
                op_alu <= op_alu_eq;
            elsif (opx = opx_cmpleu) then
                op_alu <= op_alu_leu;
            elsif (opx = opx_cmpgtu) then
                op_alu <= op_alu_gtu;
            elsif (opx = opx_nor) then
                op_alu <= op_alu_nor;
            elsif (opx = opx_and) then
                op_alu <= op_alu_and;
            elsif (opx = opx_or) then
                op_alu <= op_alu_or;
            elsif (opx = opx_xnor) then
                op_alu <= op_alu_xnor;
            elsif (opx = opx_rol or opx = opx_roli) then
                op_alu <= op_alu_rol;
            elsif (opx = opx_ror) then
                op_alu <= op_alu_ror;
            elsif (opx = opx_sll or opx = opx_slli) then
                op_alu <= op_alu_sll;
            elsif (opx = opx_srl or opx = opx_srli) then
                op_alu <= op_alu_srl;
            elsif (opx = opx_sra or opx = opx_srai) then
                op_alu <= op_alu_sra;
            end if;
        elsif (op = op_ble or op = op_cmplei) then
            op_alu <= op_alu_le;
        elsif (op = op_bgt or op = op_cmpgti) then
            op_alu <= op_alu_gt;
        elsif (op = op_bne or op = op_cmpnei) then
            op_alu <= op_alu_ne;
        elsif (op = op_beq or op = op_cmpeqi or op = op_br) then
            op_alu <= op_alu_eq;
        elsif (op = op_bleu or op = op_cmpleui) then
            op_alu <= op_alu_leu;
        elsif (op = op_bgtu or op = op_cmpgtui) then
            op_alu <= op_alu_gtu;
        elsif (op = op_addi or op = op_ldw or op = op_stw) then
            op_alu <= op_alu_add;
        elsif (op = op_andi) then
            op_alu <= op_alu_and;
        elsif (op = op_ori) then
            op_alu <= op_alu_or;
        elsif (op = op_xnori) then
            op_alu <= op_alu_xnor;
        end if;
    end process p_op_alu;

    rf_retaddr <= "11111";

end synth;
