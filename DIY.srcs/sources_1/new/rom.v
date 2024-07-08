`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/05 22:39:48
// Design Name: 
// Module Name: rom
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


module rom(
    input wire ce, //使能信号
    input wire[5:0] addr, //要读取的指令地址
    output reg[31:0] inst //读出的指令
    );

    reg[31:0] rom[63:0]; //二维向量定义存储器
                        //深度64，每个元素宽度32
    
    //初始化
    initial $readmemh ( "E:/projects_2024/FPGA_MIPS/DIY/DIY.srcs/sources_1/new/rom.txt", rom);

    always @ (*) begin
        if(ce==1'b0) begin //写使能信号无效
            inst<=32'h0;
        end else begin
            inst<=rom[addr];
        end
    end
endmodule
