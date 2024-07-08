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
    wire[5:0] op=inst_i[31:26];
    wire[4:0] op2=inst_i[10:6];
    wire[5:0] op3=inst_i[5:0];
    wire[4:0] op4=inst_i[20:16];

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
            wd_o <=inst_i[15:11];
            wreg_o<=`WriteDisable;
            instvalid<=`InstInvalid;
            reg1_read_o<=1'b0;
            reg2_read_o<=1'b0;
            reg1_addr_o<=inst_i[25:21];
            reg2_addr_o<=inst_i[20:16];
            imm<=`ZeroWord;
            case(op)
                `EXE_ORI:begin
                    wreg_o<=`WriteEnable; //需要将结果写入目的寄存器
                    aluop_o<=`EXE_OR_OP; //运算子类型为or
                    alusel_o<=`EXE_RES_LOGIC; //运算类型是逻辑运算
                    reg1_read_o<=1'b1; //需要通过Regfile的读端口1读取寄存器
                    reg2_read_o<=1'b0; //不需要读2
                    imm<={16'h0, inst_i[15:0]}; //指令执行需要的立即数
                    wd_o<=inst_i[20:16]; //指令执行要写的目的寄存器地址
                    instvalid<=`InstValid; //ori指令是有效指令
                end
                default:begin
                    
                end
            endcase
        end //if
    end //always


    always @(*) begin
        if(rst==`RstEnable)begin
            reg1_o<=`ZeroWord;
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
        end else if(reg2_read_o==1'b1)begin
            reg2_o<=reg2_data_i;
        end else if(reg2_read_o==1'b0)begin
            reg2_o<=imm;
        end else begin
            reg2_o<=`ZeroWord;
        end 
    end
endmodule
