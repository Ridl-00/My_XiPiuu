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

    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,
    
    output reg[`AluOpBus] aluop_o,
    output reg[`AluSelBus] alusel_o,
    output reg[`RegBus] reg1_o,
    output reg[`RegBus] reg2_o,
    output reg[`RegAddrBus] wd_o, //译码阶段的指令要写入的目的寄存器地址
    output reg wreg_o //译码阶段的指令是否有要写入的目的寄存器
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
                default:begin
                    
                end
            endcase
        end //if
    end //always


    always @(*) begin
        if(rst==`RstEnable)begin
            reg1_o<=`ZeroWord;
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
