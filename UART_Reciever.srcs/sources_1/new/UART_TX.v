`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2024 17:10:07
// Design Name: 
// Module Name: UART_TX
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


module UART_TX #(parameter CLKS_PER_BIT = 104)(
    //inputs
    input clk,
    input rst,
    input [7:0] DATA_IN,
    input TX_DV, //DV initalises the transmission 

    //outputs
    output reg UART_TX_OUT,
    output  TX_DONE_OUT,
    output  TX_ACTIVE_OUT
    );

    localparam IDLE         = 3'b000;
    localparam START_BIT    = 3'b001;
    localparam DATA_BIT     = 3'b010;
    localparam STOP_BIT     = 3'b011;
    localparam CLEAN_UP     = 3'b100;

    reg [2:0] BIT_INDEX;
    reg [7:0] BIT_CLK_COUNT = 0; //count to 104, can count to 255 for higher clock speeds / lower bauds
    reg [2:0] STATE         = 0;
    reg [7:0] TX_Data;
    reg TX_DONE;
    reg TX_ACTIVE;

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1)begin
            STATE <= 0;
        end else begin
            TX_DONE <= 1'b0;
            
            case (STATE)
                IDLE:begin
                    UART_TX_OUT <= 1'b1; //drives line high in idle state
                    BIT_CLK_COUNT <= 0;
                    BIT_INDEX <= 0;
                    
                    if (TX_DV == 1'b1)begin
                        TX_ACTIVE <= 1'b1;
                        TX_Data <= DATA_IN;
                        STATE <= START_BIT;


                    end else begin
                        STATE <= IDLE;
                    end
                end

                START_BIT:begin

                    UART_TX_OUT <= 1'b0; //set low for start bit

                    if(BIT_CLK_COUNT < CLKS_PER_BIT - 1)begin

                        BIT_CLK_COUNT <= BIT_CLK_COUNT + 1;
                        STATE <= START_BIT;

                    end else begin
                        BIT_CLK_COUNT <= 0;
                        STATE <= DATA_BIT;
                    end
                end

                DATA_BIT:begin

                    UART_TX_OUT <= TX_Data[BIT_INDEX]; //sets TX line to the data bit
                    if (BIT_CLK_COUNT < CLKS_PER_BIT - 1)begin
                        BIT_CLK_COUNT <= BIT_CLK_COUNT + 1;
                        STATE <= DATA_BIT;

                    end else begin
                        BIT_CLK_COUNT <= 0;
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
                    UART_TX_OUT <= 1'b1; //go back to high for the stop bit

                    if (BIT_CLK_COUNT < CLKS_PER_BIT - 1)begin
                        BIT_CLK_COUNT <= BIT_CLK_COUNT + 1;
                        STATE <= STOP_BIT;

                    end else begin
                        TX_DONE <= 1'b1;
                        BIT_CLK_COUNT <= 0;
                        TX_ACTIVE <= 1'b0;
                        STATE <= CLEAN_UP;


                    end
                end

                CLEAN_UP:begin
                    TX_DONE <= 1'b1;
                    STATE <= IDLE;
                end

                default: STATE <= IDLE;
        
            endcase


        end
        
    end
    

    assign TX_DONE_OUT = TX_DONE;
    assign TX_ACTIVE_OUT = TX_ACTIVE;

//template
    // UART_TX #()(
    //     .clk(),
    //     .rst(),
    //     .DATA_IN(),
    //     .TX_DV(),
    //     .UART_TX_OUT(),
    //     .TX_DONE_OUT(),
    //     .TX_ACTIVE_OUT()
    // );

endmodule
