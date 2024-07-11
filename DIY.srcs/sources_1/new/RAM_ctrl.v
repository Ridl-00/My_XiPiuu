`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 16:40:29
// Design Name: 
// Module Name: RAM_ctrl
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
/*
    | 虚地址区间            | 说明           |
    | 0x80000000-0x800FFFFF | 监控程序代码   |
    | 0x80100000-0x803FFFFF | 用户代码空间   |
    | 0x80400000-0x807EFFFF | 用户数据空间   |
    | 0x807F0000-0x807FFFFF | 监控程序数据   |
    | 0xBFD003F8-0xBFD003FD | 串口数据及状态 |

    | 地址       | 位    | 说明                                               |
    | 0xBFD003F8 | [7:0] | 串口数据，读、写地址分别表示串口接收、发送一个字节 |
    | 0xBFD003FC | [0]   | 只读，为1时表示串口空闲，可发送数据                |
    | 0xBFD003FC | [1]   | 只读，为1时表示串口收到数据                        |
*/
`include "defines.v"

// `define SerialState 32'hBFD003FC    //串口状态地址
// `define SerialData  32'hBFD003F8    //串口数据地址

module RAM_ctrl(
    input wire clk,
    input wire rst,

    //if阶段输入的信息和获得的指令
    input    wire[31:0]  rom_addr_i,        //读取指令的地址
    input    wire        rom_ce_i,          //指令存储器使能信号
    output   reg [31:0]  inst_o,            //获取到的指令

    //mem阶段传递的信息和取得的数据
    output   reg[31:0]   ram_data_o,        //读取的数据
    input    wire[31:0]  mem_addr_i,        //读（写）地址
    input    wire[31:0]  mem_data_i,        //写入的数据
    input    wire        mem_we_n,          //写使能，低有效
    input    wire[3:0]   mem_sel_n,         //字节选择信号
    input    wire        mem_ce_i,          //片选信号

    //BaseRAM信号
    inout    wire[31:0]  base_ram_data,     //BaseRAM数据
    output   reg [19:0]  base_ram_addr,     //BaseRAM地址
    output   reg [3:0]   base_ram_be_n,     //BaseRAM字节使能，低有效。
    output   reg         base_ram_ce_n,     //BaseRAM片选，低有效
    output   reg         base_ram_re_n,     //BaseRAM读使能，低有效
    output   reg         base_ram_we_n,     //BaseRAM写使能，低有效

    //ExtRAM信号
    inout    wire[31:0]  ext_ram_data,      //ExtRAM数据
    output   reg [19:0]  ext_ram_addr,      //ExtRAM地址
    output   reg [3:0]   ext_ram_be_n,      //ExtRAM字节使能，低有效。
    output   reg         ext_ram_ce_n,      //ExtRAM片选，低有效
    output   reg         ext_ram_re_n,      //ExtRAM读使能，低有效
    output   reg         ext_ram_we_n      //ExtRAM写使能，低有效

    // //直连串口信号
    // output   wire        txd,                //直连串口发送端
    // input    wire        rxd,                //直连串口接收端

    // output   wire[1:0]   state                //串口状态
    );

    //内存映射
    // wire is_SerialState = (mem_addr_i ==  `SerialState); 
    // wire is_SerialData  = (mem_addr_i == `SerialData);
    wire is_base_ram    = (mem_addr_i >= 32'h80000000) && (mem_addr_i < 32'h80400000);
    wire is_ext_ram     = (mem_addr_i >= 32'h80400000) && (mem_addr_i < 32'h80800000);

    // reg [31:0] serial_o;        //串口输出数据
    wire[31:0] base_ram_o;      //baseram输出数据
    wire[31:0] ext_ram_o;       //extram输出数据
    
    //BaseRAM相关（指令存储器）
    assign base_ram_data=is_base_ram?((mem_we_n==`WriteEnable_n)?mem_data_i:32'hzzzzzzzz):32'hzzzzzzzz;
    assign base_ram_o=base_ram_data; //输出就是读到的BaseRAM数据

    //当MEM阶段需要向BaseRAM的地址写入或读取数据时，发生结构冒险
    always @(*) begin
        base_ram_addr=20'h00000;
        base_ram_be_n=4'b0000; //字节使能低有效
        base_ram_ce_n=1'b0; //片选低有效
        base_ram_re_n=1'b1; //读使能低有效
        base_ram_we_n=1'b1; //写使能低有效
        inst_o=`ZeroWord;
//不懂这信号为什么这么设置
        if(is_base_ram)begin //涉及BaseRAM，需要暂停
            base_ram_addr=mem_addr_i[21:2]; //有对齐要求，低两位舍去
            base_ram_be_n=mem_sel_n;
            base_ram_ce_n=1'b0;
            base_ram_re_n=!mem_we_n;
            base_ram_we_n=mem_we_n;
            inst_o=`ZeroWord;
        end else begin//不涉及BaseRAM，继续取指
            base_ram_addr=mem_addr_i[21:2]; //有对齐要求，低两位舍去
            base_ram_be_n=4'b0000;
            base_ram_ce_n=1'b0;
            base_ram_re_n=1'b0;
            base_ram_we_n=1'b1;
            inst_o=base_ram_o;
        end
    end


    //ExtRAM相关（数据存储器）
    assign ext_ram_data=is_ext_ram?((mem_we_n==`WriteEnable_n)?mem_data_i:32'hzzzzzzzz):32'hzzzzzzzz;
    assign ext_ram_o=ext_ram_data;

    always @(*) begin
        ext_ram_addr=20'h00000;
        ext_ram_be_n=4'b0000;
        ext_ram_ce_n=1'b0;
        ext_ram_re_n=1'b1;
        ext_ram_we_n=1'b1;
        if(is_ext_ram)begin
            ext_ram_addr=mem_addr_i[21:2];
            ext_ram_be_n=mem_sel_n;
            ext_ram_ce_n=1'b0;
            ext_ram_re_n=!mem_we_n;
            ext_ram_we_n=mem_we_n;
        end else begin
            ext_ram_addr=20'h00000;
            ext_ram_be_n=4'b0000;
            ext_ram_ce_n=1'b0;
            ext_ram_re_n=1'b1;
            ext_ram_we_n=1'b1;
        end
    end

    //确认输出的数据
    always @(*) begin
        ram_data_o=`ZeroWord;
//有一个串口的情况，没写
        if(is_base_ram)begin
            case (mem_sel_n)
                4'b1110:begin
                    ram_data_o={{24{base_ram_o[7]}}, base_ram_o[7:0]};
                end 
                4'b1101:begin
                    ram_data_o={{24{base_ram_o[15]}}, base_ram_o[15:8]};
                end
                4'b1011:begin
                    ram_data_o={{24{base_ram_o[23]}}, base_ram_o[23:16]};
                end
                4'b0111:begin
                    ram_data_o={{24{base_ram_o[31]}}, base_ram_o[31:24]};
                end
                4'b0000:begin
                    ram_data_o=base_ram_o;
                end
                default:begin
                    ram_Data_o=base_ram_o;
                end
            endcase
        end else if(is_ext_ram)begin
            case (mem_sel_n)
                4'b1110:begin
                    ram_data_o={{24{ext_ram_o[7]}}, ext_ram_o[7:0]};
                end 
                4'b1101:begin
                    ram_data_o={{24{ext_ram_o[15]}}, ext_ram_o[15:8]};
                end
                4'b1011:begin
                    ram_data_o={{24{ext_ram_o[23]}}, ext_ram_o[23:16]};
                end
                4'b0111:begin
                    ram_data_o={{24{ext_ram_o[31]}}, ext_ram_o[31:24]};
                end
                4'b0000:begin
                    ram_data_o=ext_ram_o;
                end
                default:begin
                    ram_Data_o=ext_ram_o;
                end
            endcase
        end else begin
            ram_data_o=`ZeroWord;
        end
    end

endmodule
