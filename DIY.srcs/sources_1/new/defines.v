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
`define Stop 1'b1
`define NoStop 1'b0
`define InDelaySlot 1'b1 //指令延迟槽
`define NotInDelaySlot 1'b0
`define Branch 1'b1 //是分支
`define NotBranch 1'b0
`define InterruptAssert 1'b1 //中断
`define InterruptNotAssert 1'b0 //不中断
`define TrapAssert 1'b1 //陷阱
`define TrapNotAssert 1'b0

`define True_v 1'b1 //逻辑真
`define False_v 1'b0
`define ChipEnable 1'b1 //芯片使能
`define ChipDisable 1'b0

//指令相关(op字段)

//I型
//逻辑
`define EXE_ANDI 6'b001100
`define EXE_ORI  6'b001101
`define EXE_LUI  6'b001111
//算数
`define EXE_ADDI 6'b001000
//装载
`define EXE_LW   6'b100011
`define EXE_SW   6'b101011
`define EXE_LB   6'b100000
`define EXE_SB   6'b101000
//转移
`define EXE_BNE  6'b000101
`define EXE_BEQ  6'b000100
`define EXE_BLEZ 6'b000110
`define EXE_BGTZ 6'b000111

//J型
//转移
`define EXE_J    6'b000010
`define EXE_JAL  6'b000011
`define EXE_JR   6'b001000


`define EXE_NOP  6'b000000 //无操作
`define SSNOP 32'b00000000000000000000000001000000

`define EXE_SPECIAL_INST 6'b000000 //R型指令
`define EXE_REGIMM_INST 6'b000001
`define EXE_SPECIAL2_INST 6'b011100

//指令相关(R型的funct字段)
//逻辑
`define EXE_AND  6'b100100
`define EXE_OR   6'b100101
`define EXE_XOR  6'b100110
//算数
`define EXE_ADDU 6'b100001
`define EXE_SUB  6'b100010
//位移
`define EXE_SLL  6'b000000
`define EXE_SRL  6'b000010
`define EXE_SRLV 6'b000110


//AluOp  Alu操作
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP   8'b01011010
`define EXE_LUI_OP   8'b01011100   

`define EXE_ADDI_OP  8'b01010101

`define EXE_LW_OP    8'b11100011
`define EXE_SW_OP    8'b11101011
`define EXE_LB_OP    8'b11100000
`define EXE_SB_OP    8'b11101000

`define EXE_BNE_OP   8'b01010010
`define EXE_BEQ_OP   8'b01010001
`define EXE_BLEZ_OP  8'b01010011
`define EXE_BGTZ_OP  8'b01010100

`define EXE_J_OP     8'b01001111
`define EXE_JAL_OP   8'b01010000
`define EXE_JR_OP    8'b00001000


`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP   8'b00100110

`define EXE_ADDU_OP  8'b00100001
`define EXE_SUB_OP   8'b00100010

`define EXE_SLL_OP   8'b01111100
`define EXE_SRL_OP   8'b00000010
`define EXE_SRLV_OP  8'b00000110


`define EXE_NOP_OP 8'b00000000 //无

//ALusel  Alu选择
`define EXE_RES_LOGIC 3'b001 //逻辑操作模式
`define EXE_RES_SHIFT 3'b010 //选择移位操作
`define EXE_RES_ARITHMETIC 3'b100 //算数指令模式
`define EXE_RES_MOVE 3'b011 //数据移动（装载指令模式）

`define EXE_RES_NOP 3'b000

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