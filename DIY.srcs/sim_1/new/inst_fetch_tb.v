`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/06 00:41:52
// Design Name: 
// Module Name: inst_fetch_tb
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


module inst_fetch_tb(

    );

    // 1 数据类型说明

    reg CLOCK_50; //激励信号CLOCK，时钟信号
    reg rst; //激励
    wire[31:0] inst; //显示信号

    // 2 激励向量定义

    // 定义CLOCK，每10个时间单位翻转一次（默认10ns）
    initial begin
        CLOCK_50=1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50; // forever创建永久循环
    end

    // 定义rst
    initial begin
        rst=1'b1;
        #195 rst=1'b0; //195个之后
        #1000 $stop; //1000个之后
    end

    // 3 待测试模块例化
    inst_fetch inst_fetch0(
        .clk(CLOCK_50),
        .rst(rst),
        .inst_o(inst)
    );


endmodule
