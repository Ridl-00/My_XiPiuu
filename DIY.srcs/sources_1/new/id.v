`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/06 16:53:13
// Design Name: 
// Module Name: id
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module id(
    input wire rst,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus] inst_i,

    //处于EX阶段的指令要写入目的寄存器的信息
    input wire ex_wreg_i,
    input wire[`RegBus] ex_wdata_i,
    input wire[`RegAddrBus] ex_wd_i,

    //WB阶段的指令要写入目的寄存器的信息
    input wire mem_wreg_i,
    input wire[`RegBus] mem_wdata_i,
    input wire[`RegAddrBus] mem_wd_i,

    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,

    input wire[`AluOpBus] ex_aluop_i, //处于EX阶段指令的运算子类型，在发生load冒险 暂停时使用

    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,
    
    output reg[`AluOpBus] aluop_o,
    output reg[`AluSelBus] alusel_o,
    output reg[`RegBus] reg1_o,
    output reg[`RegBus] reg2_o,
    output reg[`RegAddrBus] wd_o, //译码阶段的指令要写入的目的寄存器地址
    output reg wreg_o, //译码阶段的指令是否有要写入的目的寄存器
    output wire[`RegBus] inst_o, //当前处于译码阶段的指令

    output reg next_inst_in_delayslot_o, //下一条进入译码阶段的指令是否位于延迟槽
    output reg is_in_delayslot_o, //当前处于译码阶段的指令是否位于延迟槽

    output reg branch_flag_o,
    output reg[`RegBus] branch_target_address_o,
    output reg[`RegBus] link_addr_o, //转移指令要保存的返回地址

    output wire stallreq //译码阶段请求流水线暂停

);

    //取得指令的指令码，功能码
    wire[5:0] op=inst_i[31:26]; //操作码
    wire[4:0] rs=inst_i[25:21]; //第一源操作数寄存器
    wire[4:0] rt=inst_i[20:16]; //第二源操作数寄存器（原op4）
    wire[4:0] rd=inst_i[15:11]; //目的寄存器
    wire[4:0] shamt=inst_i[10:6]; //位移量（原op2）
    wire[5:0] funct=inst_i[5:0]; //功能码（原op3)

    //保存指令执行需要的立即数
    reg[`RegBus] imm;

    //指令是否有效
    reg instvalid;
    wire[`RegAddrBus] pc_plus_4; //当前译码阶段指令后面第1条指令的地址
    wire[`RegAddrBus] pc_plus_8; //当前译码阶段指令后面第2条指令的地址
    wire[`RegBus] imm_sll2_signedext; //分支指令中的offset左移两位，再符号扩展至32位的值
    
    //load冒险所需
    reg stallreq_for_reg1_loadrelate;
    reg stallreq_for_reg2_loadrelate;
    wire pre_inst_is_load;

    assign pc_plus_4=pc_i+4;
    assign pc_plus_8=pc_i+8;
    assign imm_sll2_signedext={{14{inst_i[15]}}, inst_i[15:0], 2'b00};
    assign stallreq=stallreq_for_reg1_loadrelate|stallreq_for_reg2_loadrelate;
    assign pre_inst_is_load=((ex_aluop_i==`EXE_LB_OP)||(ex_aluop_i==`EXE_LW_OP))?1'b1:1'b0;


    assign inst_o=inst_i;

    //对指令译码
    always @(*) begin
        if(rst==`RstEnable)begin
            aluop_o <=`EXE_NOP_OP;
            alusel_o<=`EXE_RES_NOP;
            wd_o<=`NOPRegAddr;
            wreg_o<=`WriteDisable;
            instvalid<=`InstValid;
            reg1_read_o<=1'b0;
            reg2_read_o<=1'b0;
            reg1_addr_o<=`NOPRegAddr;
            reg2_addr_o<=`NOPRegAddr;
            imm<=`ZeroWord;
            link_addr_o<=`ZeroWord;
            branch_target_address_o<=`ZeroWord;
            branch_flag_o<=`NotBranch;
            next_inst_in_delayslot_o<=`NotInDelaySlot;
        end else begin
            aluop_o<=`EXE_NOP_OP;
            alusel_o<=`EXE_RES_NOP;
            wd_o <=rd;
            wreg_o<=`WriteDisable;
            instvalid<=`InstInvalid;
            reg1_read_o<=1'b0;
            reg2_read_o<=1'b0;
            reg1_addr_o<=rs;
            reg2_addr_o<=rt;
            imm<=`ZeroWord;
            link_addr_o<=`ZeroWord;
            branch_target_address_o<=`ZeroWord;
            branch_flag_o<=`NotBranch;
            next_inst_in_delayslot_o<=`NotInDelaySlot;
            case(op)
                `EXE_SPECIAL_INST:begin
                    case (funct)
                        `EXE_ADDU:begin
                            wreg_o<=`WriteEnable;
                            aluop_o<=`EXE_ADDU_OP;
                            alusel_o<=`EXE_RES_ARITHMETIC;
                            reg1_read_o<=1'b1;
                            reg2_read_o<=1'b1;
                            instvalid<=`InstValid;
                        end
                        `EXE_SUB:begin
                            wreg_o<=`WriteEnable;
                            aluop_o<=`EXE_SUB_OP;
                            alusel_o<=`EXE_RES_ARITHMETIC;
                            reg1_read_o<=1'b1;
                            reg2_read_o<=1'b1;
                            instvalid<=`InstValid;
                        end
                        `EXE_SLL:begin
                            wreg_o<=`WriteEnable;
                            aluop_o<=`EXE_SLL_OP;
                            alusel_o<=`EXE_RES_SHIFT;
                            reg1_read_o<=1'b0;
                            reg2_read_o<=1'b1;
                            imm[4:0]<=shamt;
                            wd_o<=rd;
                            instvalid<=`InstValid;
                        end
                        `EXE_SRL:begin
                            wreg_o<=`WriteEnable;
                            aluop_o<=`EXE_SRL_OP;
                            alusel_o<=`EXE_RES_SHIFT;
                            reg1_read_o<=1'b0;
                            reg2_read_o<=1'b1;
                            imm[4:0]<=shamt;
                            wd_o<=rd;
                            instvalid<=`InstValid;
                        end
                        `EXE_SRLV:begin
                            wreg_o<=`WriteEnable;
                            aluop_o<=`EXE_SRLV_OP;
                            alusel_o<=`EXE_RES_SHIFT;
                            reg1_read_o<=1'b1;
                            reg2_read_o<=1'b1;
                            valid<=`InstValid;
                        end
                        `EXE_OR:begin
                            wreg_o<=`WriteEnable;
                            aluop_o<=`EXE_OR_OP;
                            alusel_o<=`EXE_RES_LOGIC;
                            reg1_read_o<=1'b1;
                            reg2_read_o<=1'b1;
                            valid<=`InstValid;
                        end
                        `EXE_XOR:begin
                            wreg_o<=`WriteEnable;
                            aluop_o<=`EXE_XOR_OP;
                            alusel_o<=`EXE_RES_LOGIC;
                            reg1_read_o<=1'b1;
                            reg2_read_o<=1'b1;
                            valid<=`InstValid;
                        end
                        `EXE_AND:begin
                            wreg_o<=`WriteEnable;
                            aluop_o<=`EXE_AND_OP;
                            alusel_o<=`EXE_RES_LOGIC;
                            reg1_read_o<=1'b1;
                            reg2_read_o<=1'b1;
                            valid<=`InstValid;
                        end

                        `EXE_JR:begin
                            wreg_o<=`WriteDisable;
                            aluop_o<=`EXE_JR_OP;
                            alusel_o<=`EXE_RES_JUMP_BRANCH;
                            reg1_read_o<=1'b1;
                            reg2_read_o<=1'b0;
                            // link_addr_o<=`ZeroWord;
                            branch_target_address_o<=reg1_o;
                            branch_flag_o<=`Branch;
                            next_inst_in_delayslot_o<=`InDelaySlot;
                            instvalid<=`InstValid;
                        end
                        default:begin
                            
                        end
                    endcase
                end
                `EXE_ORI:begin
                    wreg_o<=`WriteEnable; //需要将结果写入目的寄存器
                    aluop_o<=`EXE_OR_OP; //运算子类型为or
                    alusel_o<=`EXE_RES_LOGIC; //运算类型是逻辑运算
                    reg1_read_o<=1'b1; //需要通过Regfile的读端口1读取寄存器
                    reg2_read_o<=1'b0; //不需要读2
                    imm<={16'h0, inst_i[15:0]}; //指令执行需要的立即数
                    wd_o<=rd; //指令执行要写的目的寄存器地址
                    instvalid<=`InstValid; //ori指令是有效指令
                end
                `EXE_ANDI:begin
                    wreg_o<=`WriteEnable;
                    aluop_o<=`EXE_AND_OP;
                    alusel_o<=`EXE_RES_LOGIC;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b0;
                    imm<={16'h0, inst_i[15:0]};
                    wd_o<=rd;
                    instvalid<=`InstValid;
                end
                `EXE_LUI:begin
                    wreg_o<=`WriteEnable;
                    aluop_o<=`EXE_LUI_OP;
                    alusel_o<=`EXE_RES_LOGIC;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b0;
                    imm<={inst_i[15:0], 16'h0};
                    wd_o<=rt; //存回寄存器2
                    instvalid<=`InstValid;
                end
                `EXE_ADDI:begin
                    wreg_o<=`WriteEnable;
                    sluop_o<=`EXE_ADDI_OP;
                    alusel_o<=`EXE_RES_ARITHMETIC;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b0;
                    imm<={{16{inst_i[15]}}, inst[15:0]};
                    wd_o<=rt;
                    instvalid<=`InstValid;
                end
                //分支
                `EXE_BNE:begin
                    wreg_o<=`WriteDisable;
                    aluop_o<=`EXE_BNE_OP;
                    alusel_o<=`EXE_RES_JUMP_BRANCH;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b1;
                    instvalid<=`InstValid;
                    if(reg1_o!=reg2_o)begin
                        branch_target_address_o<=pc_plus_4+imm_sll2_signedext;
                        branch_flag_o<=`Branch;
                        next_inst_in_delayslot_o<=`InDelaySlot;
                    end
                end
                `EXE_BEQ:begin
                    wreg_o<=`WriteDisable;
                    aluop_o<=`EXE_BEQ_OP;
                    alusel_o<=`EXE_RES_JUMP_BRANCH;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b1;
                    instvalid<=`InstValid;
                    if(reg1_o==reg2_o)begin
                        branch_target_address_o<=pc_plus_4+imm_sll2_signedext;
                        branch_flag_o<=`Branch;
                        next_inst_in_delayslot_o<=`InDelaySlot;
                    end
                end
                `EXE_BLEZ:begin
                    wreg_o<=`WriteDisable;
                    aluop_o<=`EXE_BLEZ_OP;
                    alusel_o<=`EXE_RES_JUMP_BRANCH;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b0;
                    instvalid<=`InstValid;
                    if((reg1_o[31]==1'b1)||(reg1_o==`ZeroWord))begin //<=0
                        branch_target_address_o<=pc_plus_4+imm_sll2_signedext;
                        branch_flag_o<=`Branch;
                        next_inst_in_delayslot_o<=`InDelaySlot;
                    end
                end
                `EXE_BGTZ:begin
                    wreg_o<=`WriteDisable;
                    aluop_o<=`EXE_BGTZ_OP;
                    alusel_o<=`EXE_RES_JUMP_BRANCH;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b0;
                    instvalid<=`InstValid;
                    if((reg1_o[31]==1'b0)||(reg1_o!=`ZeroWord))begin //>0
                        branch_target_address_o<=pc_plus_4+imm_sll2_signedext;
                        branch_flag_o<=`Branch;
                        next_inst_in_delayslot_o<=`InDelaySlot;
                    end
                end
                //装载
                `EXE_LW:begin
                    wreg_o<=`WriteEnable;
                    aluop_o<=`EXE_LW_OP;
                    alusel_o<=`EXE_RES_LOAD_STORE;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b0;
                    wd_o<=rt;
                    instvalid<=`InstValid;
                end
                `EXE_SW:begin
                    wreg_o<=`WriteDisable;
                    aluop_o<=`EXE_SW_OP;
                    alusel_o<=`EXE_RES_LOAD_STORE;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b1;
                    instvalid<=`InstValid;
                end
                `EXE_LB:begin
                    wreg_o<=`WriteEnable;
                    aluop_o<=`EXE_LB_OP;
                    alusel_o<=`EXE_RES_LOAD_STORE;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b0;
                    wd_o<=rt;
                    instvalid<=`InstValid;
                end
                `EXE_SB:begin
                    wreg_o<=`WriteDisable;
                    aluop_o<=`EXE_SB_OP;
                    alusel_o<=`EXE_RES_LOAD_STORE;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b1;
                    instvalid<=`InstValid;
                end
                //跳转
                `EXE_J:begin
                    wreg_o<=`WriteDisable;
                    aluop_o<=`EXE_J_OP;
                    alusel_o<=`EXE_RES_JUMP_BRANCH;
                    reg1_read_o<=1'b0;
                    reg2_read_o<=1'b0;
                    link_addr_o<=`ZeroWord;
                    branch_flag_o<=`Branch;
                    next_inst_in_delayslot_o<=`InDelaySlot;
                    instvalid<=`InstValid;
                    branch_target_address_o<={pc_plus_4[31:28], inst_i[25:0], 2'b00};
                end
                `EXE_JAL:begin
                    wreg_o<=`WriteEnable;
                    aluop_o<=`EXE_JAL_OP;
                    alusel_o<=`EXE_RES_JUMP_BRANCH;
                    reg1_read_o<=1'b0;
                    reg2_read_o<=1'b0;
                    wd_o<=5'b11111; //将返回地址链接到通用寄存器31，即跳转指令后的第二条指令的地址
                    link_addr_o<=pc_plus_8; //执行完跳转指令的指令和跳转指令紧跟的（延迟槽里的）指令之后回来的位置
                    branch_flag_o<=`Branch;
                    next_inst_in_delayslot_o<=`InDelaySlot;
                    instvalid<=`InstValid;
                end

                default:begin
                    
                end
            endcase
        end //if
    end //always


    always @(*) begin
        if(rst==`RstEnable)begin
            reg1_o<=`ZeroWord;
        //前一条是装载 && 上条要写的就是这条要读的 && reg1要读
        end else if(pre_inst_is_load==`'b1 && ex_wd_i==reg1_addr_o && reg1_read_o==1'b1)begin
            stallreq_for_reg1_loadrelate<=`Stop;
        //reg1要读&&EX要写&&reg1要读的寄存器就是EX阶段要写的寄存器
        end else if((reg1_read_o==1'b1)&&(ex_wreg_i==1'b1)&&(ex_wd_i==reg1_addr_o))begin
            reg1_o<=ex_wdata_i;
        end else if((reg1_read_o==1'b1)&&(mem_wreg_i==1'b1)&&(mem_wd_i==reg1_addr_o))begin
            reg1_o<=mem_wdata_i;
        end else if(reg1_read_o==1'b1)begin
            reg1_o<=reg1_data_i; //Regfile读端口1的输出值
        end else if(reg1_read_o==1'b0)begin
            reg1_o<=imm;
        end else begin
            reg1_o<=`ZeroWord;
        end
    end

    always @(*) begin
        if(rst==`RstEnable)begin
            reg2_o<=`ZeroWord;
        end else if(pre_inst_is_load==`'b1 && ex_wd_i==reg2_addr_o && reg2_read_o==1'b1)begin
            stallreq_for_reg2_loadrelate<=`Stop;
        end else if((reg2_read_o==1'b1)&&(ex_wreg_i==1'b1)&&(ex_wd_i==reg2_addr_o))begin
            reg2_o<=ex_wdata_i;
        end else if((reg2_read_o==1'b1)&&(mem_wreg_i==1'b1)&&(mem_wd_i==reg2_addr_o))begin
            reg2_o<=mem_wdata_i;
        end else if(reg2_read_o==1'b1)begin
            reg2_o<=reg2_data_i;
        end else if(reg2_read_o==1'b0)begin
            reg2_o<=imm;
        end else begin
            reg2_o<=`ZeroWord;
        end 
    end
endmodule
