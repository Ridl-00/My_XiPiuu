`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/07 15:06:10
// Design Name: 
// Module Name: inst_rom
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

module inst_rom(
    input wire ce,
    input wire[`InstAddrBus] addr,
    output reg[`InstBus] inst
    );

    reg[`InstBus] inst_mem[0:`InstMemNum-1];

    initial begin
        $readmemh("E:/projects_2024/FPGA_MIPS/DIY/inst_rom.txt", inst_mem);
        $display("%h",inst_mem[1]);
    end

    
    //不复位的时候 依据输入地址 给出指令存储器rom中对应的元素
    always @(*) begin
        if(ce==`ChipDisable)begin
            inst<=`ZeroWord;
        end else begin
            inst<=inst_mem[addr[`InstMemNumLog2+1:2]];
            //即inst_mem[addr[18:2]] 右移2位后的16位
        end 
    end

endmodule
