`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/06 15:54:27
// Design Name: 
// Module Name: regfile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 实现32个32位通用整数寄存器
// 可以同时进行一个寄存器的写操作和两个寄存器的读操作
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module regfile(
    input wire rst,
    input wire clk,

    //写端口
    input wire we, //写使能
    input wire[`RegAddrBus] waddr,
    input wire[`RegBus] wdata,
    
    //读端口1
    input wire re1, //第一个读使能
    input wire[`RegAddrBus] raddr1, //第一个读寄存器端口要读取的寄存器地址
    output reg[`RegBus] rdata1, //输出的寄存器值

    //读端口2
    input wire re2,
    input wire[`RegAddrBus] raddr2,
    output reg[`RegBus] rdata2
    );

    // 定义32个32位寄存器
    reg[`RegBus] regs[0:`RegNum-1];

    //写操作
    always @(posedge clk) begin
        if(rst==`RstDisable)begin
            if((we==`WriteEnable)&&(waddr!=`RegNumLog2'h0))begin
                regs[waddr]<=wdata;
            end
        end
        
    end

    //读1操作
    always @(*) begin
        if(rst==`RstDisable)begin
            rdata1<=`ZeroWord;
        end else if(raddr1==`RegNumLog2'h0)begin
            rdata1<=`ZeroWord;
        end else if((raddr1==waddr)&&(we==`WriteEnable)&&(re1==`ReadEnable))begin
            rdata1<=wdata;
        end else if(re1==`ReadEnable)begin
            rdata1<=regs[raddr1];
        end else begin
            rdata1<=`ZeroWord;
        end
    end

    //读2
	always @ (*) begin
		if(rst == `RstEnable) begin
			rdata2 <= `ZeroWord;
	    end else if(raddr2 == `RegNumLog2'h0) begin
	  		rdata2 <= `ZeroWord;
	    end else if((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin
	  	    rdata2 <= wdata;
	    end else if(re2 == `ReadEnable) begin
	        rdata2 <= regs[raddr2];
	    end else begin
	        rdata2 <= `ZeroWord;
	    end
	end

endmodule
