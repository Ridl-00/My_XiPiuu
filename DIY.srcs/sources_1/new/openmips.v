`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/07 13:43:56
// Design Name: 
// Module Name: openmips
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

module openmips(
    input wire clk,
    input wire rst,
    input wire[`RegBus] rom_data_i,
    output wire[`RegBus] rom_addr_o,
    output wire rom_ce_o
    );

//!pc干嘛用的？
    wire[`InstAddrBus] pc;

    // If/ID--ID
    wire[`InstAddrBus] id_pc_i;
    wire[`InstBus] id_inst_i;

    // ID--ID/EX
    wire[`AluOpBus] id_aluop_o;
    wire[`AluSelBus] id_alusel_o;
    wire[`RegBus] id_reg1_o;
    wire[`RegBus] id_reg2_o;
    wire id_wreg_o;
    wire[`RegAddrBus] id_wd_o;

    // Id/EX--EX
    wire[`AluOpBus] ex_aluop_i;
    wire[`AluSelBus] ex_alusel_i;
    wire[`RegBus] ex_reg1_i;
    wire[`RegBus] ex_reg2_i;
    wire ex_wreg_i;
    wire [`RegAddrBus] ex_wd_i;

    // EX--EX/MEM
    wire ex_wreg_o;
    wire[`RegAddrBus] ex_wd_o;
    wire[`RegBus] ex_wdata_o;

    // EX/MEM--MEM
    wire mem_wreg_i;
    wire[`RegAddrBus] mem_wd_i;
    wire[`RegBus] mem_wdata_i;

    //MEM--MEM/WB
    wire mem_wreg_o;
    wire[`RegAddrBus] mem_wd_o;
    wire[`RegBus] mem_wdata_o;

    // MEM/WB--WB
    wire wb_wreg_i;
    wire[`RegAddrBus] wb_wd_i;
    wire[`RegBus] wb_wdata_i;

    //ID--Regfile
    wire reg1_read;
    wire reg2_read;
    wire[`RegBus] reg1_data;
    wire[`RegBus] reg2_data;
    wire[`RegAddrBus] reg1_addr;
    wire[`RegAddrBus] reg2_addr;

    //pc_reg例化
    pc_reg pc_reg0(
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .ce(rom_ce_o)
    );

    //指令存储器的输入地址就是pc的地址
    assign rom_addr_o = pc;

    //IF/ID模块例化
    if_id if_id0(
        .clk(clk),
        .rst(rst),
        .if_pc(pc),
        .if_inst(rom_data_i),
        .id_pc(id_pc_i),
        .id_inst(id_inst_i)
    );

    //ID例化
    id id0(
        .rst(rst),
        //从IF/ID输入的
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),

        //从regfile输入的
        .reg1_data_i(reg1_data),
        .reg2_data_i(reg2_data),

        //输出到regfile的
        .reg1_read_o(reg1_read),
        .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr),
        .reg2_addr_o(reg2_addr),

        //输出到ID/EX的
        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),
        .wreg_o(id_wreg_o)
    );

    //regfile例化
    regfile regfile1(
        .clk(clk),
        .rst(rst),
        
        //从MEM/WB输入的
        .we(wb_wreg_i),
        .waddr(wb_wd_i),
        .wdata(wb_data_i),

        //从ID输入的
        .re1(reg1_read),
        .raddr1(reg1_addr),
        .re2(reg2_read),
        .raddr2(reg2_addr),

        //输出到ID的
        .rdata1(reg1_data),
        .rdata2(reg2_data)
    );

    //ID/EX模块例化
    id_ex id_ex0(
        .clk(clk),
        .rst(rst),

        //从ID输入的
        .id_aluop(id_aluop_i),
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),
        .id_wreg(id_wreg_o),

        //输出到EX的
		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i)
    );

    //EX模块例化
    ex ex0(
        .rst(rst),

        //从ID/EX输入的
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),

        //输出到EX/MEM的
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o)

    );

    //EX/MEM模块例化
  ex_mem ex_mem0(
		.clk(clk),
		.rst(rst),
	  
		//从EX输入的	
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),

		//输出到MEM的
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i)
	);

    //MEM模块例化
	mem mem0(
		.rst(rst),
	
		//从EX/MEM输入的	
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),
	  
		//输出到MEM/WB的
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o)
	);

    //MEM/WB模块例化
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),

		//从MEM输入的
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
	
		//输出到WB的
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i)
									       	
	);

endmodule