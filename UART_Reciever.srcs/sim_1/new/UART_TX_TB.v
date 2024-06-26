`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2024 18:01:31
// Design Name: 
// Module Name: UART_TX_TB
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


module UART_TX_TB(

    );

    reg clk = 1'b0;
    reg rst = 1'b0;
    reg TX_Dv = 0;
    wire TX_Done;
    reg [7:0] TX_Byte = 0;
    wire serial_out;

    UART_TX #(.CLKS_PER_BIT(104))uut(
        .clk(clk),
        .rst(rst),
        .DATA_IN(TX_Byte),
        .TX_DV(TX_Dv),
        .UART_TX_OUT(serial_out),
        .TX_DONE_OUT(TX_Done),
        .TX_ACTIVE_OUT()
    );


    always begin
        #41.667
        clk = ~clk;
    end

    initial begin
        #1
        rst = 1'b1;
        #10
        rst = 1'b0;
        @(negedge clk);
        @(negedge clk);
        TX_Dv <= 1'b1;
        TX_Byte <= 8'h55;
        @(negedge clk);
        TX_Dv = 1'b0;
        @(posedge TX_Done);


        $display("sent byte");
    end
endmodule
