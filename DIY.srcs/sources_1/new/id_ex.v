`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/06 19:51:44
// Design Name: 
// Module Name: id_ex
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

module id_ex(
    input wire rst,
    input wire clk,

    //从ID输入的
    input wire[`AluSelBus] id_alusel,
    input wire[`AluOpBus] id_aluop,

    input wire[`RegBus] id_reg1,
    input wire[`RegBus] id_reg2,
    input wire[`RegAddrBus] id_wd,
    input wire id_wreg,

    input wire id_is_in_delayslot,
    input wire next_inst_in_delayslot_i,
    input wire[`RegBus] id_link_address,

    input wire[`RegBus] id_inst, 

    //从ctrl输入的
    input wire[5:0] stall,

    //输出到EX的
    output reg[`AluSelBus] ex_alusel,
    output reg[`AluOpBus] ex_aluop,

    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg,

    output reg ex_is_in_delayslot,
    output reg is_in_delayslot_o,
    output reg[`RegBus] ex_link_address,

    output reg[`RegBus] ex_inst

    );

    always @(posedge clk) begin
        if(rst==`RstEnable)begin
            ex_aluop<=`EXE_NOP_OP;
            ex_alusel<=`EXE_RES_NOP;
            ex_reg1<=`ZeroWord;
            ex_reg2<=`ZeroWord;
            ex_wd<=`NOPRegAddr;
            ex_wreg<=`WriteDisable;
            ex_inst<=`ZeroWord;
        end else if(stall[2]==`Stop && stall[3]==`NoStop)begin
            ex_aluop<=`EXE_NOP_OP;
            ex_alusel<=`EXE_RES_NOP;
            ex_reg1<=`ZeroWord;
            ex_reg2<=`ZeroWord;
            ex_wd<=`NOPRegAddr;
            ex_wreg<=`WriteDisable;
        end else if(stall[2]==`NoStop)begin
            ex_aluop<=id_aluop;
            ex_alusel<=id_alusel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;		
        end       
    end

    //暂停什么的，还没写
    always @(posedge clk) begin
        //说是要在译码阶段没有暂停的情况下，直接将ID模块的输入通过接口ex_inst输出
        ex_inst<=id_inst;
    end

endmodule
