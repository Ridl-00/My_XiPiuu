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
    input wire[`AluSelBus] alusel_i,
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o
    );

    // 保存逻辑运算的结果
    reg[`RegBus] logicout;
    
    //依据aluop_i进行运算,此处只有逻辑或
    always @(*) begin
        if(rst==`RstEnable)begin
            logicout<=`ZeroWord;
        end else begin
            case(aluop_i)
                `EXE_OR_OP:begin
                    logicout<=reg1_i|reg2_i;
                end
                default:begin
                    logicout<=`ZeroWord;
                end
            endcase
        end //if     
    end //always

    //依据alusel_i选择一个预算结果作为最终结果
    always @(*) begin
        wd_o<=wd_i;
        wreg_o<=wreg_i;
        case(alusel_i)
            `EXE_RES_LOGIC:begin
                wdata_o<=logicout; //运算结果
            end
            default:begin
                wdata_o<=`ZeroWord;
            end
        endcase
    end

endmodule
