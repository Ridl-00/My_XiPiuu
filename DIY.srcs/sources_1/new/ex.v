`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/06 21:25:55
// Design Name: 
// Module Name: ex
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

module ex(
    input wire rst,

    //输入到EX的
    input wire[`AluSelBus] alusel_i,
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    output reg whilo_o, //EX的指令是否要写HI、LO寄存器
    output reg[`RegBus] hi_o, //输入HI寄存器的值
    output reg[`RegBus] lo_o //输入LO寄存器的值

    );

    reg[`RegBus] logicout; // 保存逻辑运算的结果
    reg[`RegBus] shiftres; // 保存位移运算的结果
    reg[`RegBus] arithmeticres; // 算数运算的结果

    wire[`RegBus] reg2_i_mux; //寄存器2的多选器
    wire[`RegBus] reg1_i_not;
    wire[`RegBus] result_sum;
    
    //依据aluop_i进行运算,此处只有逻辑或
    always @(*) begin
        if(rst==`RstEnable)begin
            logicout<=`ZeroWord;
        end else begin
            case(aluop_i)
                `EXE_OR_OP:begin
                    logicout<=reg1_i|reg2_i;
                end
                `EXE_LUI_OP:begin
                    logicout<=reg1_i|reg2_i;
                end
                default:begin
                    logicout<=`ZeroWord;
                end
            endcase
        end //if     
    end //always


    // 算数部分
    assign reg2_i_mux=((aluop_i==`EXE_SUB_OP)||(aluop_i==`EXE_SUBU_OP)||(aluop_i==`EXE_SLT_OP))
                        ?(~reg2_i)+1:reg2_i; //如果是减法或slt指令reg2_i_mux就存补码，否则存原码
    assign result_sum=reg1_i+reg2_i_mux;


    always @(*) begin
        if(rst==`RstEnable)begin
            arithmeticres<=`ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:begin
                    arithmeticres<=result_sum;
                end 
                `EXE_SUB_OP:begin
                    arithmeticres<=result_sum;
                end
                default: begin
                    arithmeticres<=`ZeroWord;
                end
            endcase
        end
    end

    //依据alusel_i选择一个预算结果作为最终结果
    always @(*) begin
        wd_o<=wd_i;
        wreg_o<=wreg_i;
        case(alusel_i)
            `EXE_RES_LOGIC:begin
                wdata_o<=logicout; //运算结果
            end
            `EXE_RES_SHIFT:begin
                wdata_o<=shiftres;
            end
            `EXE_RES_ARITHMETIC:begin
                wdata_o<=arithmeticres;
            end
            default:begin
                wdata_o<=`ZeroWord;
            end
        endcase
    end

endmodule
