`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/07 15:28:04
// Design Name: 
// Module Name: openmips_min_sopc
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


module openmips_min_sopc(
    input wire clk,
    input wire rst
    );

    //连接指令存储器
    wire[`InstAddrBus] inst_addr;
    wire[`InstBus] inst;
    wire rom_ce;

    wire mem_ce_i;
    wire mem_we_i;
    wire[`RegBus] mem_addr_i;
    wire[`RegBus] mem_data_o;
    wire[3:0] mem_sel_i;

    // wire[5:0] int;


    //处理器OpenMIPS的例化
    openmips openmips0(
        .clk(clk),
        .rst(rst),

        // 跟rom（后续的BaseRAM连接）
        .rom_addr_o(inst_addr),
        .rom_data_i(inst),
        .rom_ce_o(rom_ce),

        // 跟ExtRAM连接
		.ram_we_o(mem_we_i),
		.ram_addr_o(mem_addr_i),
		.ram_sel_o(mem_sel_i),
		.ram_data_o(mem_data_i),
		.ram_data_i(mem_data_o),
		.ram_ce_o(mem_ce_i)

        // .int_i(int) //不懂什么用
    );

    //ROM的例化
    inst_rom inst_rom0(
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)
    );

    

endmodule
