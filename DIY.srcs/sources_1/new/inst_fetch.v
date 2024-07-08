`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/05 22:48:16
// Design Name: 
// Module Name: inst_fetch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 连接pc_reg和rom
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module inst_fetch(
    input wire rst,
    input wire clk,
    output wire[31:0]  inst_o //读出的指令
    );

    wire[5:0] pc;
    wire rom_ce;

    /*模块实例化
    pc_reg: 这是被实例化的模块的名称。
    pc_reg0: 这是实例化后的模块的名称，通常称为实例名。
    .clk(clk), .rst(rst), .pc(pc), .ce(rom_ce): 这些是模块实例的端口映射。
    每个点（.）前面是pc_reg模块的端口名，后面是inst_fetch模块中连接到该端口的信号名。
        .ce(rom_ce) 表示将inst_fetch模块的内部rom_ce信号连接到pc_reg模块的ce端口。
    
    */
    pc_reg pc_reg0(
        .clk(clk), 
        .rst(rst),
        .pc(pc), 
        .ce(rom_ce));

    rom rom0(
        .ce(rom_ce),  
        .addr(pc), 
        .inst(inst_o)
    );
endmodule
