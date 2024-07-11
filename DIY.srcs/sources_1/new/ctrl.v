`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 20:50:44
// Design Name: 
// Module Name: ctrl
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


module ctrl(
    input wire rst,
    input wire stallreq_from_id, //来自译码阶段的暂停请求
    input stallreq_from_ex, //来自执行阶段的暂停请求
    output reg[5:0] stall //暂停流水线控制信号
    );

    /*stall[0] 1 取指地址PC保持不变
     *stall[1] 1 取指阶段暂停
     *stall[2] 1 译码阶段暂停
     *stall[3] 1 执行阶段暂停
     *stall[4] 1 访存阶段暂停
     *stall[5] 1 回写阶段暂停
     */
    

    always @(*) begin
        if(rst==`RstEnable)begin
            stall<=6'b000000;
        end else if(stallreq_from_ex==`Stop)begin
            stall<=6'b001111;
        end else if(stallreq_from_id==`Stop)begin
            stall<=6'b000111;
        end else begin
            stall<=6'b000000;
        end
    end
endmodule
