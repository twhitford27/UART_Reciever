`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MinervaElectronics
// Engineer: Thomas Whitford
// 
// Create Date: 26.06.2024 00:43:24
// Design Name: 
// Module Name: TOP
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


module TOP(
        //inputs
        input clk,
        input rst_btn,
        input UART_RX_PIN,

        output UART_TX_PIN
   
    );

 
    wire [7:0] out_byte;
    wire RX_DV;
    wire TX_Active;
    wire TX_Serial;    

    UART_RX #(.CLKS_PER_BIT(104)) uart_rx(
        .clk(clk),
        .rst(rst_btn),
        .UART_RX_IN(UART_RX_PIN),
        .RX_DATA(out_byte),
        .RX_DV(RX_DV)

    );
    
    UART_TX #(.CLKS_PER_BIT(104)) uart_tx(
        .clk(clk),
        .rst(rst_btn),
        .DATA_IN(out_byte),
        .TX_DV(RX_DV),
        .UART_TX_OUT(TX_Serial),
        .TX_DONE_OUT(),
        .TX_ACTIVE_OUT(TX_Active)
    );

    assign UART_TX_PIN = TX_Active ? TX_Serial:1'b1;

   
endmodule
