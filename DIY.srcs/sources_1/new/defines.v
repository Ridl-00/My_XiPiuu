`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/06 10:58:24
// Design Name: 
// Module Name: defines
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


// global
`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000 //32位的数值0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define AluOpBus 7:0 //译码阶段的输出aluop_o的宽度
`define AluSelBus 2:0 //译码阶段的输出alusel_o的宽度
`define InstValid 1'b0 //! 0 时指令有效
`define InstInvalid 1'b1 //! 1 时指令无效
`define True_v 1'b1 //逻辑真
`define False_v 1'b0
`define ChipEnable 1'b1 //芯片使能
`define ChipDisable 1'b0

//指令相关
`define EXE_ORI 6'b001101

`define EXE_NOP 6'b000000 //无操作

//AluOp  Alu操作
`define EXE_OR_OP 8'b00100101 //或操作

`define EXE_NOP_OP 8'b00000000 //无

//ALusel  Alu选择
`define EXE_RES_LOGIC 3'b001 //选择或 逻辑操作模式

`define EXE_RES_NOP 3'b00

//指令存储器inst_rom
`define InstAddrBus 31:0 //ROM的地址总线宽度
`define InstBus 31:0 //数据总线宽度
`define InstMemNum 131071 //ROM的实际大小为128KB
`define InstMemNumLog2 17 //ROM实际使用的地址宽度

//通用寄存器regfile
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32 //通用寄存器的宽度
`define DoubleRegWidth 64 //两倍的通用寄存器的宽度
`define DoubleRegBus 63:0
`define RegNum 32 //通用寄存器的数量
`define RegNumLog2 5 //寻址通用寄存器使用的地址位数
`define NOPRegAddr 5'b00000 //用于无操作指令的寄存器地址