`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/05 16:26:12
// Design Name: 
// Module Name: pc_reg
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

module pc_reg(
    input   wire rst, //复位信号
    input   wire clk, //时钟信号

    //从ctrl输入的
    input wire[5:0] stall,

    output  reg[`InstAddrBus] pc, //要读取的指令地址
    output  reg ce //指令存储器使能信号
    );

    always @ (posedge clk) begin
        if (ce == `ChipDisable) begin // ce==0
            pc <= 32'h00000000;    // 指令存储器使能信号无效，pc赋值为0（<=非阻塞赋值）（相当于无效时保持为0）
        end else if(stall[0]==`NoStop)begin
            if(branch_flag_i==`Branch)begin
                pc<=branch_target_address_i;
            end else begin
                pc<=pc+4'h4;
            end
        end
    end

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin // 复位键按下，写使能信号无效，指令存储器禁用
			ce <= `ChipDisable;
		end else begin
			ce <= `ChipEnable;
		end
	end

endmodule
