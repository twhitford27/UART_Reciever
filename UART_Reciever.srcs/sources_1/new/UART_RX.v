`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2024 00:56:49
// Design Name: 
// Module Name: UART_RX
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


module UART_RX #(parameter CLKS_PER_BIT = 104)
    (
        //inputs
        input           clk,
        input           rst,
        input           UART_RX_IN,

        //outputs
        output [7:0]    RX_DATA,
        output          RX_DV
    );


    localparam IDLE         = 3'b000;
    localparam START_BIT    = 3'b001;
    localparam DATA_BIT     = 3'b010;
    localparam STOP_BIT     = 3'b100;
    localparam CLEAN_UP     = 3'b111;

    reg [7:0] BIT_CLK_COUNT = 0; //count to 104, can count to 255 for higher clock speeds / lower bauds
    reg [2:0] BIT_INDEX     = 0; //index of bit count
    reg [7:0] RX_BYTE       = 0; //data out internal register
    reg       RX_REG_DV     = 0; //data valid register
    reg [2:0] STATE         = 0; //3 bit state register

    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1)begin
            STATE <= 3'b0;
        end else begin

            case (STATE)
                IDLE:begin
                    
                    RX_REG_DV = 1'b0;
                    BIT_CLK_COUNT = 0;
                    BIT_INDEX = 0;
                    if (UART_RX_IN == 1'b0)begin
                        STATE <= START_BIT;
                    end else begin
                        STATE <= IDLE;
                    end
                end

                START_BIT:begin
                    if(BIT_CLK_COUNT == (CLKS_PER_BIT-1)/2)begin //checks if the start bit is still low in middle of section
                        if(UART_RX_IN == 1'b0)begin
                            BIT_CLK_COUNT <= 0;
                            STATE <= DATA_BIT;
                        end else begin
                            STATE <= IDLE;
                        end

                    end else begin
                        BIT_CLK_COUNT <= BIT_CLK_COUNT + 1;
                        STATE <= START_BIT;
                    end

                end
                
                DATA_BIT:begin
                    if(BIT_CLK_COUNT < CLKS_PER_BIT - 1)begin //performs the bit counter
                        BIT_CLK_COUNT <= BIT_CLK_COUNT + 1;
                        STATE <= DATA_BIT;
                    end else begin
                        BIT_CLK_COUNT <= 0;
                        RX_BYTE[BIT_INDEX] <= UART_RX_IN;

                        if (BIT_INDEX < 7)begin
                            BIT_INDEX <= BIT_INDEX + 1;
                            STATE <= DATA_BIT;

                        end else begin
                            BIT_INDEX <= 0;
                            STATE <= STOP_BIT;
                        end 


                    end
                end

                STOP_BIT:begin
                    if (BIT_CLK_COUNT < CLKS_PER_BIT - 1)begin
                        BIT_CLK_COUNT <= BIT_CLK_COUNT + 1; 
                        STATE <= STOP_BIT;
                    end else begin
                        BIT_CLK_COUNT <= 0;
                        RX_REG_DV <= 1'b1;
                        STATE <= CLEAN_UP;
                    end
                end

                CLEAN_UP:begin
                    STATE <= IDLE;
                    RX_REG_DV <= 1'b0;
                end
                
                default: STATE <= IDLE; 
        
        
            endcase


        end
        
    end

    assign RX_DV = RX_REG_DV;
    assign RX_DATA = RX_BYTE;

    //template
    // UART_RX #(.CLKS_PER_BIT()) (
    //     .clk(),
    //     .rst(),
    //     .UART_RX_IN(),
    //     .RX_DATA(),
    //     .RX_DV()

    // );


endmodule
