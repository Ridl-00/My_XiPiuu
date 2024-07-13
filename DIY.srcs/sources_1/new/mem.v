`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/06 21:48:44
// Design Name: 
// Module Name: mem
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

module mem(
    input wire rst,

	//从EX输入的	
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] mem_addr_i,
    input wire[`RegBus] reg2_i,

	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	input wire[`RegBus]	wdata_i,

    //从ExtRAM输入的（LW，LB）
    input wire[`RegBus] ram_data_i,


	//输出到WB的
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o,

    //输出到ExtRAM的(LW, SW, LB, SB)
    output reg[`RegBus] mem_addr_o,
    output wire mem_we_o,
    output reg[3:0] mem_sel_o,
    output reg[`RegBus] mem_data_o,
    output reg mem_ce_o, //是否可以访问存储器

    output wire stallreq

    );

    reg mem_we;

    assign mem_we_o=mem_we;

    //在用到的8MB后面的一个8MB里面，或许用不到？
    assign stallreq=(mem_addr_i>=32'h80000000) && (mem_addr_i<32'h80400000);

    always @(*) begin
        if(rst==`RstEnable)begin
            wd_o<=`NOPRegAddr;
            wreg_o<=`WriteDisable;
            wdata_o<=`ZeroWord;

            mem_addr_o <= `ZeroWord;
            mem_we <= `WriteDisable;
            mem_sel_o <= 4'b0000;
            mem_data_o <= `ZeroWord;	
            mem_ce_o <= `ChipDisable;	
        end else begin
            wd_o<=wd_i;
            wreg_o<=wreg_i;
            wdata_o<=wdata_i;

			mem_we <= `WriteDisable;
			mem_addr_o <= `ZeroWord;
			mem_sel_o <= 4'b1111;
			mem_ce_o <= `ChipDisable;

            case (aluop_i)
                `EXE_LB_OP:begin
                    wdata_o=ram_data_i;
                    mem_we<=`WriteDisable;
                    mem_ce_o<=`ChipEnable;

                    mem_addr_o<=mem_addr_i;
                    mem_data_o<=`ZeroWord;
                    case (mem_addr_i[1:0])
                        2'b00:begin
                            mem_sel_o = 4'b1110;
                        end 
                        2'b01: begin
                            mem_sel_o = 4'b1101;
                        end
                        2'b10: begin
                            mem_sel_o = 4'b1011;
                        end
                        2'b11: begin
                            mem_sel_o = 4'b0111;
                        end
                        default : begin
                            mem_sel_o = 4'b1111;
                        end
                    endcase
                end
                `EXE_LW_OP:begin
                    wdata_o=ram_data_i;
                    mem_addr_o<=mem_addr_i;
                    mem_data_o<=`ZeroWord;

                    mem_we<=`WriteDisable;
                    mem_ce_o<=`ChipEnable;

                    mem_sel_o<=4'b1111;
                end
                `EXE_SB_OP:begin
                    wdata_o=`ZeroWord;
                    mem_addr_o<=mem_addr_i;
                    mem_data_o<={4{reg2_i[7:0]}}; //低字节存储到指定位置
                    
                    mem_we<=`WriteEnable;
                    mem_ce_o<=`ChipEnable;
                    case (mem_addr_i[1:0])
                        2'b00: begin
                            mem_sel_o = 4'b1110;
                        end 
                        2'b01: begin
                            mem_sel_o = 4'b1101;
                        end
                        2'b10: begin
                            mem_sel_o = 4'b1011;
                        end
                        2'b11: begin
                            mem_sel_o = 4'b0111;
                        end
                        default : begin
                            mem_sel_o = 4'b1111;
                        end
                    endcase
                end
                `EXE_SW_OP:begin
                    wdata_o<=`ZeroWord;
                    mem_addr_o<=mem_addr_i;
                    mem_data_o<=reg2_i;

                    mem_we<=`WriteEnable;
                    mem_ce_o<=`ChipEnable;

                    mem_sel_o<=4'b0000;
                end
                default: begin
                    wdata_o <= wdata_i;
                    mem_addr_o <= `ZeroWord;
                    mem_data_o <= `ZeroWord;
                    mem_we <= `WriteDisable;
                    mem_ce_o <= `ChipDisable;
                    mem_sel_o <= 4'b1111;
                end
            endcase
        end
    end
endmodule
