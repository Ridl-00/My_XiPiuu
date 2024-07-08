`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/06 15:23:34
// Design Name: 
// Module Name: if_id
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

module if_id(
    input wire rst,
    input wire clk,
    input wire[`InstAddrBus] if_pc,
    input wire[`InstBus] if_inst,
    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus] id_inst
    );

    always @(posedge clk) begin
        if (rst==`RstEnable)begin
            id_pc<=`ZeroWord;
            id_inst<=`ZeroWord; // 复位时为空指令
        end else begin //简单传递
            id_pc<=if_pc;
            id_inst<=if_inst;
        end
        
    end

endmodule
