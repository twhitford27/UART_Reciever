`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2024 02:10:42
// Design Name: 
// Module Name: UART_RX_TB
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


module UART_RX_TB(

    );

    parameter CLOCK_PERIOD_NS = 83.333;
    parameter clk_PER_BIT = 104;
    parameter BIT_PERIOD = 8600;

    reg sim_clk = 1'b0;
    reg rst = 1'b0;
    reg sim_UART_SERIAL = 1'b1;
    wire sim_DV;
    wire [7:0] sim_OUT;

    task UART_WRITE_BYTE;
        input [7:0] i_Data;
        integer  ii;
        begin
            //send start bit
            sim_UART_SERIAL <= 1'b0;
            #(BIT_PERIOD);
            #1000;

            for (ii=0; ii < 8; ii=ii+1)begin
                sim_UART_SERIAL <= i_Data[ii];
                #(BIT_PERIOD);
            end

            sim_UART_SERIAL <= 1'b1;
            #(BIT_PERIOD);

        end

    endtask //UART_WRITE_BYTE

    always begin
        #41.667 
        sim_clk = ~sim_clk;
    end

    UART_RX #(.CLKS_PER_BIT(104)) uut(
        .clk(sim_clk),
        .rst(rst),
        .UART_RX_IN(sim_UART_SERIAL),
        .RX_DATA(sim_OUT),
        .RX_DV(sim_DV)

    );


    initial begin
        @(posedge sim_clk);
        UART_WRITE_BYTE(8'b11111111);
        @(posedge sim_clk);

        if (sim_OUT == 8'b11111111)begin
            $display("Test Passed");
        end else begin
            $display("Test Failed");

        end
    $finish();
    end
endmodule
