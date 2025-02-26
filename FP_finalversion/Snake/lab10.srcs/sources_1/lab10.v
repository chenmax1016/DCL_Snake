`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of Computer Science, National Chiao Tung University
// Engineer: Chun-Jen Tsai 
// 
// Create Date: 2018/12/11 16:04:41
// Design Name: 
// Module Name: lab9
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: A circuit that show the animation of a fish swimming in a seabed
//              scene on a screen through the VGA interface of the Arty I/O card.
// 
// Dependencies: vga_sync, clk_divider, sram 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lab10(
    input  clk,
    input  reset_n,
    input  [3:0] usr_btn,
    input [3:0] usr_sw,       // switches
    output [3:0] usr_led,
    // UART
    input  uart_rx,
    output uart_tx,
    
    // VGA specific I/O ports
    output VGA_HSYNC,
    output VGA_VSYNC,
    output [3:0] VGA_RED,
    output [3:0] VGA_GREEN,
    output [3:0] VGA_BLUE
    );

integer button0;
wire pressButton0 = (button0 == 10_00_0000);
always@(posedge clk) begin
  if (~reset_n || usr_btn[0] == 0) button0 <= 0;
  else button0 <= (button0 == 10_00_0002)? button0: button0+1;
end

integer button1;
wire pressButton1 = (button1 == 10_00_0000);
always@(posedge clk) begin
  if (~reset_n || usr_btn[1] == 0) button1 <= 0;
  else button1 <= (button1 == 10_00_0002)? button1: button1+1;
end

integer button2;
wire pressButton2 = (button2 == 10_00_0000);
always@(posedge clk) begin
  if (~reset_n || usr_btn[2] == 0) button2 <= 0;
  else button2 <= (button2 == 10_00_0002)? button2: button2+1;
end

integer button3;
wire pressButton3 = (button3 == 10_00_0000);
always@(posedge clk) begin
  if (~reset_n || usr_btn[3] == 0) button3 <= 0;
  else button3 <= (button3 == 10_00_0002)? button3: button3+1;
end

localparam snakeStartIndex = 3; // 0: background, 1: obstacle, 2: apple
reg [1:0] snakeHeadInitDirection;
reg [1:0] snakeHeadDirection; // 0 up 1 right 2 down 3 left
wire keyboard = usr_sw[1] == 0;
always@(posedge clk) begin
  if(~reset_n) begin
    snakeHeadDirection <= 0;
  end
  else if (isChooseMap) begin
    snakeHeadDirection <= snakeHeadInitDirection;
  end
  else begin
    case(keyboard)
    1:begin
        if(num_reg == "w"     &&gameGrid[snakeHeadY][snakeHeadX] != snakeStartIndex+2 ) snakeHeadDirection <= 0;
        else if(num_reg == "d" &&gameGrid[snakeHeadY][snakeHeadX] != snakeStartIndex+3) snakeHeadDirection <= 1;
        else if(num_reg == "s"  &&gameGrid[snakeHeadY][snakeHeadX] != snakeStartIndex) snakeHeadDirection <= 2;
        else if(num_reg == "a" &&gameGrid[snakeHeadY][snakeHeadX] != snakeStartIndex+1) snakeHeadDirection <= 3;
    end
    0:begin
        if(pressButton0  && gameGrid[snakeHeadY][snakeHeadX] != snakeStartIndex+2 ) snakeHeadDirection <= 0;
        else if(pressButton2 && gameGrid[snakeHeadY][snakeHeadX] != snakeStartIndex+3) snakeHeadDirection <= 1;
        else if(pressButton1 && gameGrid[snakeHeadY][snakeHeadX] != snakeStartIndex) snakeHeadDirection <= 2;
        else if(pressButton3 && gameGrid[snakeHeadY][snakeHeadX] != snakeStartIndex+1) snakeHeadDirection <= 3;
    end
    endcase
  end
end

reg [1:0] testCounter;
wire test = testCounter == 2;
integer snakeUpdateCounter;
wire[31:0] snakeUpdatePeriod = (keyboard)? 25_00_0000 : 50_00_0000;
wire needUpdateSnake = snakeUpdateCounter == snakeUpdatePeriod;
always@(posedge clk) begin
  if (~reset_n) begin
    snakeUpdateCounter <= 0;
    testCounter <= 0;
  end
  else if (needUpdateSnake) begin 
    snakeUpdateCounter <= 0;
    testCounter <= (test)?0 : testCounter+1;
  end
  else snakeUpdateCounter <= snakeUpdateCounter+1;
end


localparam grid_height = 24;
localparam grid_width = 24;
reg [4:0]gameGrid[grid_height-1:0][grid_width-1:0];
reg [$clog2(grid_width):0]snakeHeadX;
reg [$clog2(grid_height):0]snakeHeadY;
reg [$clog2(grid_width):0]snakeTailX;
reg [$clog2(grid_height):0]snakeTailY;

wire moveIsValid = (snakeHeadDirection == 0 && snakeHeadY > 0 && gameGrid[snakeHeadY-1][snakeHeadX] != 1 && gameGrid[snakeHeadY-1][snakeHeadX] < snakeStartIndex) || 
  (snakeHeadDirection == 1 && snakeHeadX < grid_width-1 && gameGrid[snakeHeadY][snakeHeadX+1] != 1 && gameGrid[snakeHeadY][snakeHeadX+1] < snakeStartIndex) ||
  (snakeHeadDirection == 2 && snakeHeadY < grid_height-1 && gameGrid[snakeHeadY+1][snakeHeadX] != 1 && gameGrid[snakeHeadY+1][snakeHeadX] < snakeStartIndex) || 
  (snakeHeadDirection == 3 && snakeHeadX > 0 && gameGrid[snakeHeadY][snakeHeadX-1] != 1 && gameGrid[snakeHeadY][snakeHeadX-1] < snakeStartIndex);

//wire [1:0] nextTail = (snakeTailY > 0 && gameGrid[snakeTailY-1][snakeTailX] == snakeStartIndex+1)? 0:(
 //                     (snakeTailX < grid_width-1 && gameGrid[snakeTailY][snakeTailX+1] == snakeStartIndex+1)? 1:(
  //                    (snakeTailY < grid_height-1 && gameGrid[snakeTailY+1][snakeTailX] == snakeStartIndex+1)? 2: 3));
                  
reg [1:0] snakeHeadChooseImage;  // 0 up 1 right 2 bottom 3 left
reg [1:0] snakeTailChooseImage;
integer i, j;
localparam snakeInitLength = 5;
reg [5:0] snakeLength;
wire fowardIsApple = moveIsValid && 
(( snakeHeadDirection == 0 && gameGrid[snakeHeadY-1][snakeHeadX] == 0)|| 
 (snakeHeadDirection == 1 && gameGrid[snakeHeadY][snakeHeadX+1] == 0) ||
 (snakeHeadDirection == 2 && gameGrid[snakeHeadY+1][snakeHeadX] == 0)||
 (snakeHeadDirection == 3 && gameGrid[snakeHeadY][snakeHeadX-1] == 0));
wire increaseLength = moveIsValid && 
(( snakeHeadDirection == 0 && gameGrid[snakeHeadY-1][snakeHeadX] == 0)|| 
 (snakeHeadDirection == 1 && gameGrid[snakeHeadY][snakeHeadX+1] == 0) ||
 (snakeHeadDirection == 2 && gameGrid[snakeHeadY+1][snakeHeadX] == 0)||
 (snakeHeadDirection == 3 && gameGrid[snakeHeadY][snakeHeadX-1] == 0));
 ///////////////////////////////////// start map state control
localparam mapNum = 3;
reg pleasRemoveIfHaveState;
reg isChooseMap;
reg [1:0] currMap;
reg resetMap;
always@(posedge clk) begin
  if (~reset_n) begin
    pleasRemoveIfHaveState <= 1;
    isChooseMap <= 1;
    currMap <= 0;
    resetMap <= 1;
  end
  else if (isChooseMap) begin
    if (resetMap) resetMap <= 0;
  
    if (pressButton0) begin 
      currMap <= (currMap == mapNum)? 0: currMap + 1;
      resetMap <= 1;
    end
    else if (pressButton1) begin 
      currMap <= (currMap == 0)? mapNum: currMap - 1;
      resetMap <= 1;
    end
    else if (pressButton2) isChooseMap <= 0;
  end 
end
////////////////////////////////////////////////end map state control

always@(posedge clk) begin
  if (~reset_n || resetMap) begin
    for (i = 0; i < grid_height; i=i+1) begin
      for (j = 0; j < grid_width; j=j+1) begin
        gameGrid[i][j] <= 2;
      end
    end
    snakeHeadInitDirection <= 0;
    
  end
  else if(isChooseMap) begin // snake position init
    if (currMap == 0) begin
      snakeHeadInitDirection <= 0;
      snakeLength <= snakeInitLength;
      gameGrid[5][2] <= snakeStartIndex;
      gameGrid[6][2] <= snakeStartIndex;
      gameGrid[7][2] <= snakeStartIndex;
      gameGrid[8][2] <= snakeStartIndex;
      gameGrid[9][2] <= snakeStartIndex;
      snakeHeadX <= 2;
      snakeHeadY <= 5;
      snakeTailX <= 2;
      snakeTailY <= 9;
      snakeHeadChooseImage <= 0;
      snakeTailChooseImage <= 0;
      ////////////////////////////////// obstacle /////////////////////////////////////
      
      ///////////////////////////// fence 1 ///////////////////////////////////////////
      
      gameGrid[0][0] <= 1; gameGrid[0][1] <= 1; gameGrid[0][2] <= 1;
      gameGrid[0][3] <= 1; gameGrid[0][4] <= 1; gameGrid[0][5] <= 1;
      gameGrid[0][6] <= 1; gameGrid[0][7] <= 1; gameGrid[0][8] <= 1;
      gameGrid[0][9] <= 1; gameGrid[0][10] <= 1; gameGrid[0][11] <= 1;
      gameGrid[0][12] <= 1; gameGrid[0][13] <= 1; gameGrid[0][14] <= 1;
      gameGrid[0][15] <= 1; gameGrid[0][16] <= 1; gameGrid[0][17] <= 1;
      gameGrid[0][18] <= 1; gameGrid[0][19] <= 1; gameGrid[0][20] <= 1;
      gameGrid[0][21] <= 1; gameGrid[0][22] <= 1; gameGrid[0][23] <= 1;
      
     /*gameGrid[0][23] <= 1;*/ gameGrid[1][23] <= 1; gameGrid[2][23] <= 1; 
     gameGrid[3][23] <= 1;gameGrid[4][23] <= 1; gameGrid[5][23] <= 1; 
     gameGrid[6][23] <= 1;gameGrid[7][23] <= 1; gameGrid[8][23] <= 1; 
     gameGrid[9][23] <= 1; gameGrid[10][23] <= 1; gameGrid[11][23] <= 1; 
     gameGrid[12][23] <= 1;gameGrid[13][23] <= 1; gameGrid[14][23] <= 1; 
     gameGrid[15][23] <= 1;gameGrid[16][23] <= 1; gameGrid[17][23] <= 1; 
     gameGrid[18][23] <= 1;gameGrid[19][23] <= 1; gameGrid[20][23] <= 1; 
     gameGrid[21][23] <= 1;gameGrid[22][23] <= 1; gameGrid[23][23] <= 1; 
     
     gameGrid[23][0] <= 1; gameGrid[23][1] <= 1; gameGrid[23][2] <= 1;
     gameGrid[23][3] <= 1; gameGrid[23][4] <= 1; gameGrid[23][5] <= 1;
     gameGrid[23][6] <= 1; gameGrid[23][7] <= 1; gameGrid[23][8] <= 1;
     gameGrid[23][9] <= 1; gameGrid[23][10] <= 1; gameGrid[23][11] <= 1;
     gameGrid[23][12] <= 1; gameGrid[23][13] <= 1; gameGrid[23][14] <= 1;
     gameGrid[23][15] <= 1; gameGrid[23][16] <= 1; gameGrid[23][17] <= 1;
     gameGrid[23][18] <= 1; gameGrid[23][19] <= 1; gameGrid[23][20] <= 1;
     gameGrid[23][21] <= 1; gameGrid[23][22] <= 1; //gameGrid[23][23] <= 1;
     
     /*gameGrid[0][0] <= 1;*/ gameGrid[1][0] <= 1; gameGrid[2][0] <= 1; 
     gameGrid[3][0] <= 1;gameGrid[4][0] <= 1; gameGrid[5][0] <= 1; 
     gameGrid[6][0] <= 1;gameGrid[7][0] <= 1; gameGrid[8][0] <= 1; 
     gameGrid[9][0] <= 1; gameGrid[10][0] <= 1; gameGrid[11][0] <= 1; 
     gameGrid[12][0] <= 1;gameGrid[13][0] <= 1; gameGrid[14][0] <= 1; 
     gameGrid[15][0] <= 1;gameGrid[16][0] <= 1; gameGrid[17][0] <= 1; 
     gameGrid[18][0] <= 1;gameGrid[19][0] <= 1; gameGrid[20][0] <= 1; 
     gameGrid[21][0] <= 1;gameGrid[22][0] <= 1; //gameGrid[23][0] <= 1; 
     
     ///////////////////////////// fence 1 ///////////////////////////////////////////
     
     ///////////////////////////// fence 2 ///////////////////////////////////////////
     gameGrid[4][4] <= 1; gameGrid[4][5] <= 1;
     gameGrid[4][6] <= 1; gameGrid[4][7] <= 1; gameGrid[4][8] <= 1;
     gameGrid[4][9] <= 1; gameGrid[4][10] <= 1; gameGrid[4][11] <= 1;
     //gameGrid[4][12] <= 1; gameGrid[4][13] <= 1; gameGrid[4][14] <= 1;
     gameGrid[4][15] <= 1; gameGrid[4][16] <= 1; gameGrid[4][17] <= 1;
     gameGrid[4][18] <= 1; gameGrid[4][19] <= 1;
     
     /*gameGrid[4][19] <= 1;*/ gameGrid[5][19] <= 1; 
     gameGrid[6][19] <= 1;gameGrid[7][19] <= 1; gameGrid[8][19] <= 1; 
     gameGrid[9][19] <= 1; //gameGrid[10][19] <= 1; gameGrid[11][19] <= 1; 
     gameGrid[12][19] <= 1;gameGrid[13][19] <= 1; gameGrid[14][19] <= 1; 
     gameGrid[15][19] <= 1;gameGrid[16][19] <= 1; gameGrid[17][19] <= 1; 
     gameGrid[18][19] <= 1;gameGrid[19][19] <= 1;
     
     gameGrid[19][4] <= 1; gameGrid[19][5] <= 1;
     gameGrid[19][6] <= 1; gameGrid[19][7] <= 1; gameGrid[19][8] <= 1;
     gameGrid[19][9] <= 1; gameGrid[19][10] <= 1; /*gameGrid[19][11] <= 1;
     gameGrid[19][12] <= 1; */gameGrid[19][13] <= 1; gameGrid[19][14] <= 1;
     gameGrid[19][15] <= 1; gameGrid[19][16] <= 1; gameGrid[19][17] <= 1;
     gameGrid[19][18] <= 1; //gameGrid[19][19] <= 1; 
     
     /*gameGrid[4][4] <= 1;*/ gameGrid[5][4] <= 1; 
     gameGrid[6][4] <= 1;/*gameGrid[7][4] <= 1;*/ gameGrid[8][4] <= 1; 
     gameGrid[9][4] <= 1; gameGrid[10][4] <= 1; gameGrid[11][4] <= 1; 
     gameGrid[12][4] <= 1;gameGrid[13][4] <= 1; gameGrid[14][4] <= 1; 
     gameGrid[15][4] <= 1;gameGrid[16][4] <= 1; gameGrid[17][4] <= 1; 
     gameGrid[18][4] <= 1;//gameGrid[19][4] <= 1;
     
     ///////////////////////////// fence 2 ///////////////////////////////////////////
     
     ///////////////////////////// fence 3 ///////////////////////////////////////////
     
     gameGrid[8][8] <= 1;
     gameGrid[8][9] <= 1; gameGrid[8][10] <= 1; gameGrid[8][11] <= 1;
     gameGrid[8][12] <= 1; //gameGrid[8][13] <= 1; gameGrid[8][14] <= 1;
     gameGrid[8][15] <= 1; 
     
     //gameGrid[8][15] <= 1; 
     gameGrid[9][15] <= 1; gameGrid[10][15] <= 1; gameGrid[11][15] <= 1; 
     gameGrid[12][15] <= 1;gameGrid[13][15] <= 1; gameGrid[14][15] <= 1; 
     gameGrid[15][15] <= 1;
     
     gameGrid[15][8] <= 1;
     gameGrid[15][9] <= 1; gameGrid[15][10] <= 1; gameGrid[15][11] <= 1;
     gameGrid[15][12] <= 1; gameGrid[15][13] <= 1; /*gameGrid[15][14] <= 1;*/
     //gameGrid[15][15] <= 1; 
     
     gameGrid[9][8] <= 1; gameGrid[10][8] <= 1; gameGrid[11][8] <= 1; 
     gameGrid[12][8] <= 1;gameGrid[13][8] <= 1; gameGrid[14][8] <= 1; 
    // gameGrid[15][8] <= 1;
     ///////////////////////////// fence 3 ///////////////////////////////////////////
     
     ////////////////////////////////// obstacle /////////////////////////////////////
     
     ////////////////////////////////// apple /////////////////////////////////////
      gameGrid[3][4] <= 0;
      gameGrid[2][20] <= 0;
      gameGrid[16][7] <= 0;
      gameGrid[9][9] <= 0;gameGrid[10][10] <= 0;gameGrid[11][11]<= 0;
      gameGrid[12][12] <= 0;gameGrid[13][13] <= 0;gameGrid[14][14] <= 0;
      gameGrid[9][14] <= 0;gameGrid[10][13] <= 0;gameGrid[11][12] <= 0;
      gameGrid[12][11] <= 0;gameGrid[13][10] <= 0;gameGrid[14][9] <= 0;
      
      ////////////////////////////////// apple /////////////////////////////////////
    end
    else if (currMap == 1) begin
      snakeHeadInitDirection <= 0;
      snakeLength <= snakeInitLength;
      gameGrid[5][2] <= snakeStartIndex;
      gameGrid[6][2] <= snakeStartIndex;
      gameGrid[7][2] <= snakeStartIndex;
      gameGrid[8][2] <= snakeStartIndex;
      gameGrid[9][2] <= snakeStartIndex;
      snakeHeadX <= 2;
      snakeHeadY <= 5;
      snakeTailX <= 2;
      snakeTailY <= 9;
      snakeHeadChooseImage <= 0;
      snakeTailChooseImage <= 0;
      
      ///////////////////////////// fence 1 ///////////////////////////////////////////
      
      gameGrid[0][0] <= 1; gameGrid[0][1] <= 1; gameGrid[0][2] <= 1;
      gameGrid[0][3] <= 1; gameGrid[0][4] <= 1; gameGrid[0][5] <= 1;
      gameGrid[0][6] <= 1; gameGrid[0][7] <= 1; gameGrid[0][8] <= 1;
      gameGrid[0][9] <= 1; gameGrid[0][10] <= 1; gameGrid[0][11] <= 1;
      gameGrid[0][12] <= 1; gameGrid[0][13] <= 1; gameGrid[0][14] <= 1;
      gameGrid[0][15] <= 1; gameGrid[0][16] <= 1; gameGrid[0][17] <= 1;
      gameGrid[0][18] <= 1; gameGrid[0][19] <= 1; gameGrid[0][20] <= 1;
      gameGrid[0][21] <= 1; gameGrid[0][22] <= 1; gameGrid[0][23] <= 1;
      
     /*gameGrid[0][23] <= 1;*/ gameGrid[1][23] <= 1; gameGrid[2][23] <= 1; 
     gameGrid[3][23] <= 1;gameGrid[4][23] <= 1; gameGrid[5][23] <= 1; 
     gameGrid[6][23] <= 1;gameGrid[7][23] <= 1; gameGrid[8][23] <= 1; 
     gameGrid[9][23] <= 1; gameGrid[10][23] <= 1; gameGrid[11][23] <= 1; 
     gameGrid[12][23] <= 1;gameGrid[13][23] <= 1; gameGrid[14][23] <= 1; 
     gameGrid[15][23] <= 1;gameGrid[16][23] <= 1; gameGrid[17][23] <= 1; 
     gameGrid[18][23] <= 1;gameGrid[19][23] <= 1; gameGrid[20][23] <= 1; 
     gameGrid[21][23] <= 1;gameGrid[22][23] <= 1; gameGrid[23][23] <= 1; 
     
     gameGrid[23][0] <= 1; gameGrid[23][1] <= 1; gameGrid[23][2] <= 1;
     gameGrid[23][3] <= 1; gameGrid[23][4] <= 1; gameGrid[23][5] <= 1;
     gameGrid[23][6] <= 1; gameGrid[23][7] <= 1; gameGrid[23][8] <= 1;
     gameGrid[23][9] <= 1; gameGrid[23][10] <= 1; gameGrid[23][11] <= 1;
     gameGrid[23][12] <= 1; gameGrid[23][13] <= 1; gameGrid[23][14] <= 1;
     gameGrid[23][15] <= 1; gameGrid[23][16] <= 1; gameGrid[23][17] <= 1;
     gameGrid[23][18] <= 1; gameGrid[23][19] <= 1; gameGrid[23][20] <= 1;
     gameGrid[23][21] <= 1; gameGrid[23][22] <= 1; //gameGrid[23][23] <= 1;
     
     /*gameGrid[0][0] <= 1;*/ gameGrid[1][0] <= 1; gameGrid[2][0] <= 1; 
     gameGrid[3][0] <= 1;gameGrid[4][0] <= 1; gameGrid[5][0] <= 1; 
     gameGrid[6][0] <= 1;gameGrid[7][0] <= 1; gameGrid[8][0] <= 1; 
     gameGrid[9][0] <= 1; gameGrid[10][0] <= 1; gameGrid[11][0] <= 1; 
     gameGrid[12][0] <= 1;gameGrid[13][0] <= 1; gameGrid[14][0] <= 1; 
     gameGrid[15][0] <= 1;gameGrid[16][0] <= 1; gameGrid[17][0] <= 1; 
     gameGrid[18][0] <= 1;gameGrid[19][0] <= 1; gameGrid[20][0] <= 1; 
     gameGrid[21][0] <= 1;gameGrid[22][0] <= 1; //gameGrid[23][0] <= 1; 
     
     ///////////////////////////// fence 1 ///////////////////////////////////////////

     gameGrid[4][4] <= 1; gameGrid[4][5] <= 1;
     gameGrid[4][6] <= 1; gameGrid[4][7] <= 1; gameGrid[4][8] <= 1;
     gameGrid[4][9] <= 1; gameGrid[4][10] <= 1; gameGrid[4][11] <= 1;
     //gameGrid[4][12] <= 1; gameGrid[4][13] <= 1; gameGrid[4][14] <= 1;
     gameGrid[4][15] <= 1; gameGrid[4][16] <= 1; gameGrid[4][17] <= 1;
     gameGrid[4][18] <= 1; gameGrid[4][19] <= 1;
     
     /*gameGrid[4][19] <= 1;*/ gameGrid[5][19] <= 1; 
     gameGrid[6][19] <= 1;gameGrid[7][19] <= 1; gameGrid[8][19] <= 1; 
     //gameGrid[9][19] <= 1; //gameGrid[10][19] <= 1; gameGrid[11][19] <= 1; 
     gameGrid[12][19] <= 1;gameGrid[13][19] <= 1; gameGrid[14][19] <= 1; 
     gameGrid[15][19] <= 1;gameGrid[16][19] <= 1; gameGrid[17][19] <= 1; 
     gameGrid[18][19] <= 1;gameGrid[19][19] <= 1;
     
     gameGrid[19][4] <= 1; gameGrid[19][5] <= 1;
     gameGrid[19][6] <= 1; gameGrid[19][7] <= 1; gameGrid[19][8] <= 1;
     gameGrid[19][9] <= 1; gameGrid[19][10] <= 1; /*gameGrid[19][11] <= 1;
     gameGrid[19][12] <= 1; gameGrid[19][13] <= 1;*/ gameGrid[19][14] <= 1;
     gameGrid[19][15] <= 1; gameGrid[19][16] <= 1; gameGrid[19][17] <= 1;
     gameGrid[19][18] <= 1; //gameGrid[19][19] <= 1; 
     
     /*gameGrid[4][4] <= 1;gameGrid[5][4] <= 1; 
     gameGrid[6][4] <= 1;*/gameGrid[7][4] <= 1; gameGrid[8][4] <= 1; 
     gameGrid[9][4] <= 1; gameGrid[10][4] <= 1; gameGrid[11][4] <= 1; 
     gameGrid[12][4] <= 1;gameGrid[13][4] <= 1; gameGrid[14][4] <= 1; 
     gameGrid[15][4] <= 1;gameGrid[16][4] <= 1; gameGrid[17][4] <= 1; 
     gameGrid[18][4] <= 1;//gameGrid[19][4] <= 1;;
     
      gameGrid[3][4] <= 0;
      gameGrid[2][20] <= 0;
      gameGrid[16][7] <= 0;

    end
    else if (currMap == 2) begin
      snakeHeadInitDirection <= 2;
      snakeLength <= snakeInitLength;
      gameGrid[5][2] <= snakeStartIndex+2;
      gameGrid[6][2] <= snakeStartIndex+2;
      gameGrid[7][2] <= snakeStartIndex+2;
      gameGrid[8][2] <= snakeStartIndex+2;
      gameGrid[9][2] <= snakeStartIndex;
      snakeHeadX <= 2;
      snakeHeadY <= 9;
      snakeTailX <= 2;
      snakeTailY <= 5;
      snakeHeadChooseImage <= 2;
      snakeTailChooseImage <= 2;
      
      
    gameGrid[5][10] <= 1; gameGrid[5][11] <= 1; gameGrid[5][12] <= 1;
    gameGrid[6][9] <= 1; gameGrid[6][10] <= 1; gameGrid[6][11] <= 1; gameGrid[6][12] <= 1; gameGrid[6][13] <= 1;
    gameGrid[7][8] <= 1; gameGrid[7][9] <= 1; gameGrid[7][10] <= 1; gameGrid[7][11] <= 1; gameGrid[7][12] <= 1; gameGrid[7][13] <= 1;gameGrid[7][14] <= 1;
    gameGrid[8][7] <= 1; gameGrid[8][8] <= 1; gameGrid[8][9] <= 1; gameGrid[8][10] <= 1; gameGrid[8][11] <= 1; gameGrid[8][12] <= 1; gameGrid[8][13] <= 1; gameGrid[8][14] <= 1; gameGrid[8][15] <= 1;
    gameGrid[9][6] <= 1; gameGrid[9][7] <= 1; gameGrid[9][8] <= 1; gameGrid[9][9] <= 1; gameGrid[9][10] <= 1; gameGrid[9][11] <= 1; gameGrid[9][12] <= 1; gameGrid[9][13] <= 1; gameGrid[9][14] <= 1; gameGrid[9][15] <= 1;gameGrid[9][16] <= 1;

      
      
     
    gameGrid[13][6] <= 1; gameGrid[13][7] <= 1; gameGrid[13][8] <= 1; gameGrid[13][9] <= 1; gameGrid[13][10] <= 1; gameGrid[13][11] <= 1; gameGrid[13][12] <= 1; gameGrid[13][13] <= 1; gameGrid[13][14] <= 1; gameGrid[13][15] <= 1; gameGrid[13][16] <= 1;
    gameGrid[14][7] <= 1; gameGrid[14][8] <= 1; gameGrid[14][9] <= 1; gameGrid[14][10] <= 1; gameGrid[14][11] <= 1; gameGrid[14][12] <= 1; gameGrid[14][13] <= 1; gameGrid[14][14] <= 1; gameGrid[14][15] <= 1;
    gameGrid[15][8] <= 1; gameGrid[15][9] <= 1; gameGrid[15][10] <= 1; gameGrid[15][11] <= 1; gameGrid[15][12] <= 1; gameGrid[15][13] <= 1; gameGrid[15][14] <= 1;
    gameGrid[16][9] <= 1; gameGrid[16][10] <= 1; gameGrid[16][11] <= 1; gameGrid[16][12] <= 1; gameGrid[16][13] <= 1;
    gameGrid[17][10] <= 1; gameGrid[17][11] <= 1; gameGrid[17][12] <= 1;
    
     gameGrid[0][0] <= 1; gameGrid[0][1] <= 1; gameGrid[0][2] <= 1;
      gameGrid[0][3] <= 1; gameGrid[0][4] <= 1; gameGrid[0][5] <= 1;
      gameGrid[0][6] <= 1; gameGrid[0][7] <= 1; gameGrid[0][8] <= 1;
      gameGrid[0][9] <= 1; gameGrid[0][10] <= 1; gameGrid[0][11] <= 1;
      gameGrid[0][12] <= 1; gameGrid[0][13] <= 1; gameGrid[0][14] <= 1;
      gameGrid[0][15] <= 1; gameGrid[0][16] <= 1; gameGrid[0][17] <= 1;
      gameGrid[0][18] <= 1; gameGrid[0][19] <= 1; gameGrid[0][20] <= 1;
      gameGrid[0][21] <= 1; gameGrid[0][22] <= 1; gameGrid[0][23] <= 1;
      
     /*gameGrid[0][23] <= 1;*/ gameGrid[1][23] <= 1; gameGrid[2][23] <= 1; 
     gameGrid[3][23] <= 1;gameGrid[4][23] <= 1; gameGrid[5][23] <= 1; 
     gameGrid[6][23] <= 1;gameGrid[7][23] <= 1; gameGrid[8][23] <= 1; 
     gameGrid[9][23] <= 1; gameGrid[10][23] <= 1; gameGrid[11][23] <= 1; 
     gameGrid[12][23] <= 1;gameGrid[13][23] <= 1; gameGrid[14][23] <= 1; 
     gameGrid[15][23] <= 1;gameGrid[16][23] <= 1; gameGrid[17][23] <= 1; 
     gameGrid[18][23] <= 1;gameGrid[19][23] <= 1; gameGrid[20][23] <= 1; 
     gameGrid[21][23] <= 1;gameGrid[22][23] <= 1; gameGrid[23][23] <= 1; 
     
     gameGrid[23][0] <= 1; gameGrid[23][1] <= 1; gameGrid[23][2] <= 1;
     gameGrid[23][3] <= 1; gameGrid[23][4] <= 1; gameGrid[23][5] <= 1;
     gameGrid[23][6] <= 1; gameGrid[23][7] <= 1; gameGrid[23][8] <= 1;
     gameGrid[23][9] <= 1; gameGrid[23][10] <= 1; gameGrid[23][11] <= 1;
     gameGrid[23][12] <= 1; gameGrid[23][13] <= 1; gameGrid[23][14] <= 1;
     gameGrid[23][15] <= 1; gameGrid[23][16] <= 1; gameGrid[23][17] <= 1;
     gameGrid[23][18] <= 1; gameGrid[23][19] <= 1; gameGrid[23][20] <= 1;
     gameGrid[23][21] <= 1; gameGrid[23][22] <= 1; //gameGrid[23][23] <= 1;
     
     /*gameGrid[0][0] <= 1;*/ gameGrid[1][0] <= 1; gameGrid[2][0] <= 1; 
     gameGrid[3][0] <= 1;gameGrid[4][0] <= 1; gameGrid[5][0] <= 1; 
     gameGrid[6][0] <= 1;gameGrid[7][0] <= 1; gameGrid[8][0] <= 1; 
     gameGrid[9][0] <= 1; gameGrid[10][0] <= 1; gameGrid[11][0] <= 1; 
     gameGrid[12][0] <= 1;gameGrid[13][0] <= 1; gameGrid[14][0] <= 1; 
     gameGrid[15][0] <= 1;gameGrid[16][0] <= 1; gameGrid[17][0] <= 1; 
     gameGrid[18][0] <= 1;gameGrid[19][0] <= 1; gameGrid[20][0] <= 1; 
     gameGrid[21][0] <= 1;gameGrid[22][0] <= 1; //gameGrid[23][0] <= 1; 
    
    gameGrid[3][4] <= 0;
    gameGrid[2][20] <= 0;
    gameGrid[16][7] <= 0;

    end
    else if (currMap == 3) begin
      snakeHeadInitDirection <= 0;
      snakeLength <= snakeInitLength;
      gameGrid[5][2] <= snakeStartIndex;
      gameGrid[6][2] <= snakeStartIndex;
      gameGrid[7][2] <= snakeStartIndex;
      gameGrid[8][2] <= snakeStartIndex;
      gameGrid[9][2] <= snakeStartIndex;
      snakeHeadX <= 2;
      snakeHeadY <= 5;
      snakeTailX <= 2;
      snakeTailY <= 9;
      snakeHeadChooseImage <= 0;
      snakeTailChooseImage <= 0;
      
       ///////////////////////////// fence 1 ///////////////////////////////////////////
      
      gameGrid[0][0] <= 1; gameGrid[0][1] <= 1; gameGrid[0][2] <= 1;
      gameGrid[0][3] <= 1; gameGrid[0][4] <= 1; gameGrid[0][5] <= 1;
      gameGrid[0][6] <= 1; gameGrid[0][7] <= 1; gameGrid[0][8] <= 1;
      gameGrid[0][9] <= 1; gameGrid[0][10] <= 1; gameGrid[0][11] <= 1;
      gameGrid[0][12] <= 1; gameGrid[0][13] <= 1; gameGrid[0][14] <= 1;
      gameGrid[0][15] <= 1; gameGrid[0][16] <= 1; gameGrid[0][17] <= 1;
      gameGrid[0][18] <= 1; gameGrid[0][19] <= 1; gameGrid[0][20] <= 1;
      gameGrid[0][21] <= 1; gameGrid[0][22] <= 1; gameGrid[0][23] <= 1;
      
     /*gameGrid[0][23] <= 1;*/ gameGrid[1][23] <= 1; gameGrid[2][23] <= 1; 
     gameGrid[3][23] <= 1;gameGrid[4][23] <= 1; gameGrid[5][23] <= 1; 
     gameGrid[6][23] <= 1;gameGrid[7][23] <= 1; gameGrid[8][23] <= 1; 
     gameGrid[9][23] <= 1; gameGrid[10][23] <= 1; gameGrid[11][23] <= 1; 
     gameGrid[12][23] <= 1;gameGrid[13][23] <= 1; gameGrid[14][23] <= 1; 
     gameGrid[15][23] <= 1;gameGrid[16][23] <= 1; gameGrid[17][23] <= 1; 
     gameGrid[18][23] <= 1;gameGrid[19][23] <= 1; gameGrid[20][23] <= 1; 
     gameGrid[21][23] <= 1;gameGrid[22][23] <= 1; gameGrid[23][23] <= 1; 
     
     gameGrid[23][0] <= 1; gameGrid[23][1] <= 1; gameGrid[23][2] <= 1;
     gameGrid[23][3] <= 1; gameGrid[23][4] <= 1; gameGrid[23][5] <= 1;
     gameGrid[23][6] <= 1; gameGrid[23][7] <= 1; gameGrid[23][8] <= 1;
     gameGrid[23][9] <= 1; gameGrid[23][10] <= 1; gameGrid[23][11] <= 1;
     gameGrid[23][12] <= 1; gameGrid[23][13] <= 1; gameGrid[23][14] <= 1;
     gameGrid[23][15] <= 1; gameGrid[23][16] <= 1; gameGrid[23][17] <= 1;
     gameGrid[23][18] <= 1; gameGrid[23][19] <= 1; gameGrid[23][20] <= 1;
     gameGrid[23][21] <= 1; gameGrid[23][22] <= 1; //gameGrid[23][23] <= 1;
     
     /*gameGrid[0][0] <= 1;*/ gameGrid[1][0] <= 1; gameGrid[2][0] <= 1; 
     gameGrid[3][0] <= 1;gameGrid[4][0] <= 1; gameGrid[5][0] <= 1; 
     gameGrid[6][0] <= 1;gameGrid[7][0] <= 1; gameGrid[8][0] <= 1; 
     gameGrid[9][0] <= 1; gameGrid[10][0] <= 1; gameGrid[11][0] <= 1; 
     gameGrid[12][0] <= 1;gameGrid[13][0] <= 1; gameGrid[14][0] <= 1; 
     gameGrid[15][0] <= 1;gameGrid[16][0] <= 1; gameGrid[17][0] <= 1; 
     gameGrid[18][0] <= 1;gameGrid[19][0] <= 1; gameGrid[20][0] <= 1; 
     gameGrid[21][0] <= 1;gameGrid[22][0] <= 1; //gameGrid[23][0] <= 1; 
     
     ///////////////////////////// fence 1 ///////////////////////////////////////////
      
      gameGrid[9][3] <= 1; gameGrid[9][4] <= 1; gameGrid[9][5] <= 1;gameGrid[9][6] <= 1;
      gameGrid[10][3] <= 1; gameGrid[10][6] <= 1;gameGrid[10][7] <= 1;
      gameGrid[11][3] <= 1; gameGrid[11][7] <= 1;
      gameGrid[12][3] <= 1; gameGrid[12][7] <= 1;
      gameGrid[13][3] <= 1; gameGrid[13][6] <= 1;gameGrid[13][7] <= 1;
      gameGrid[14][3] <= 1; gameGrid[14][4] <= 1;gameGrid[14][5] <= 1;gameGrid[14][6] <= 1;
      
      gameGrid[9][11] <= 1;gameGrid[9][12] <= 1; gameGrid[9][13] <= 1;gameGrid[9][14] <= 1;
      gameGrid[10][10] <= 1;gameGrid[10][11] <= 1;
      gameGrid[11][10] <= 1;
      gameGrid[12][10] <= 1;
      gameGrid[13][10] <= 1;gameGrid[13][11] <= 1;
      gameGrid[14][11] <= 1;gameGrid[14][12] <= 1;gameGrid[14][13] <= 1;gameGrid[14][14] <= 1;
      
      gameGrid[9][17] <= 1;
      gameGrid[10][17] <= 1;
      gameGrid[11][17] <= 1;
      gameGrid[12][17] <= 1;
      gameGrid[13][17] <=1 ;
      gameGrid[14][17] <= 1; gameGrid[14][18] <= 1; gameGrid[14][19] <= 1; gameGrid[14][20] <= 1;
      
      
      gameGrid[7][7] <= 0;
      gameGrid[1][15] <= 0;
      gameGrid[21][22] <= 0;
    end
  end
  
  else if(needUpdateSnake && moveIsValid) begin
    if (snakeHeadDirection == 0) begin
      gameGrid[snakeHeadY-1][snakeHeadX] <= snakeStartIndex;
      snakeHeadChooseImage <= 0;
      snakeHeadY <= snakeHeadY - 1;
      gameGrid[snakeHeadY][snakeHeadX] <= 3;
    end
    else if (snakeHeadDirection == 1) begin
      gameGrid[snakeHeadY][snakeHeadX+1] <= snakeStartIndex+1;
      snakeHeadChooseImage <= 1;
      snakeHeadX <= snakeHeadX + 1;
      gameGrid[snakeHeadY][snakeHeadX] <= 4;
    end
    else if (snakeHeadDirection == 2) begin
      gameGrid[snakeHeadY+1][snakeHeadX] <= snakeStartIndex+2;
      snakeHeadChooseImage <= 2;
      snakeHeadY <= snakeHeadY + 1;
      gameGrid[snakeHeadY][snakeHeadX] <= 5;
    end
    else begin
      gameGrid[snakeHeadY][snakeHeadX-1] <= snakeStartIndex+3;
      snakeHeadChooseImage <= 3;
      snakeHeadX <= snakeHeadX - 1;
      gameGrid[snakeHeadY][snakeHeadX] <= 6;
    end 
    
    if (increaseLength) snakeLength <= snakeLength+1;
    if (!increaseLength) begin
      gameGrid[snakeTailY][snakeTailX] <= 2;
      case(gameGrid[snakeTailY][snakeTailX]) 
        snakeStartIndex: snakeTailY <= snakeTailY - 1;
        snakeStartIndex+1: snakeTailX <= snakeTailX + 1;
        snakeStartIndex+2: snakeTailY <= snakeTailY + 1;
        snakeStartIndex+3: snakeTailX <= snakeTailX - 1;
      endcase
    end 
        /*
        if (!increaseLength) begin
          case(nextTail)
            0: snakeTailY <= snakeTailY - 1;
            1: snakeTailX <= snakeTailX + 1;
            2: snakeTailY <= snakeTailY + 1;
            3: snakeTailX <= snakeTailX - 1;
            default : snakeTailX <= snakeTailX;
          endcase
        end
        */
        /*
        for (i = 0; i < grid_height; i=i+1) begin
          for (j = 0; j < grid_width; j=j+1) begin
            if (gameGrid[i][j] == snakeStartIndex + snakeLength - 1) begin
              if (snakeHeadDirection == 0) begin
                gameGrid[i-1][j] <= snakeStartIndex + snakeLength - 1 + increaseLength;
                snakeHeadChooseImage <= 0;
                snakeHeadY <= snakeHeadY - 1;
              end
              else if (snakeHeadDirection == 1) begin
                gameGrid[i][j+1] <= snakeStartIndex + snakeLength - 1 + increaseLength;
                snakeHeadChooseImage <= 1;
                snakeHeadX <= snakeHeadX + 1;
              end
              else if (snakeHeadDirection == 2) begin
                gameGrid[i+1][j] <= snakeStartIndex + snakeLength - 1 + increaseLength;
                snakeHeadChooseImage <= 2;
                snakeHeadY <= snakeHeadY + 1;
              end
              else begin
                gameGrid[i][j-1] <= snakeStartIndex + snakeLength - 1 + increaseLength;
                snakeHeadChooseImage <= 3;
                snakeHeadX <= snakeHeadX - 1;
              end
            end
           
            if (increaseLength) snakeLength <= snakeLength+1;
            
            if (gameGrid[i][j] >= snakeStartIndex && !increaseLength) gameGrid[i][j] <= gameGrid[i][j] - 1;   
          
          end//for
        end*///for
    
  end
  else if (UpdateApple) begin
    if (gameGrid[seed1][seed2] == 2) gameGrid[seed1][seed2] <= 0;
    else if (gameGrid[seed3][seed4] == 2) gameGrid[seed3][seed4] <= 0;
    else if (gameGrid[seed5][seed6] == 2) gameGrid[seed5][seed6] <= 0;
  end
end



// General VGA control signals
wire vga_clk;         // 50MHz clock for VGA control
wire video_on;        // when video_on is 0, the VGA controller is sending
                      // synchronization signals to the display device.
  
wire pixel_tick;      // when pixel tick is 1, we must update the RGB value
                      // based for the new coordinate (pixel_x, pixel_y)
  
wire [9:0] pixel_x;   // x coordinate of the next pixel (between 0 ~ 639) 
wire [9:0] pixel_y;   // y coordinate of the next pixel (between 0 ~ 479)
  
reg  [11:0] rgb_reg;  // RGB value for the current pixel
reg  [11:0] rgb_next; // RGB value for the next pixel
  
localparam gridSize = 20;

localparam leftPos = 80;
localparam topPos = 0;

vga_sync vs0(
  .clk(vga_clk), .reset(~reset_n), .oHS(VGA_HSYNC), .oVS(VGA_VSYNC),
  .visible(video_on), .p_tick(pixel_tick),
  .pixel_x(pixel_x), .pixel_y(pixel_y)
);

clk_divider#(2) clk_divider0(
  .clk(clk),
  .reset(~reset_n),
  .clk_out(vga_clk)
);


reg [7:0] seed1;
reg [7:0] seed2;
reg [7:0] seed3;
reg [7:0] seed4;
reg [7:0] seed5;
reg [7:0] seed6;
reg UpdateApple;
always@(posedge clk) begin
  if (~reset_n) begin
    seed1 <= 0;
    seed2 <= 0;
    seed3 <= 0;
    seed4 <= 0;
    seed5 <= 0;
    seed6 <= 0;
    UpdateApple <= 0;
  end
  else if(isChooseMap) begin
    seed1 <= (seed1 >= grid_width-1)? seed1 -5: seed1 + 1;
    seed2 <= (seed2 >= grid_width-1)? seed2 - 8: seed2 + 1;
    seed3 <= (seed3 >= grid_width-1)? seed3 - 10: seed3 + 1;
    seed4 <= (seed4 >= grid_width-1)? seed4 - 14: seed4 + 1;
    seed5 <= (seed5 >= grid_width-1)? seed5 - 16: seed5 + 1;
    seed6 <= (seed6 >= grid_width-1)? seed6 - 3: seed6 + 1;
  end
  else if (needUpdateSnake && fowardIsApple) begin
    seed1 <= (seed1 + seed2 >= grid_width-1)? seed1 + seed2 - grid_width + 1: seed1 + seed2;
    seed2 <= (seed2 + seed3>= grid_width-1)? seed2 + seed3 - grid_width + 1: seed2 + seed3;
    seed3 <= (seed3 + seed4>= grid_width-1)? seed3 + seed4 - grid_width + 1: seed3 + seed4;
    seed4 <= (seed4 + seed5 >= grid_width-1)? seed4 + seed5 - grid_width + 1: seed4 + seed5;
    seed5 <= (seed5 + seed6 >= grid_width-1)? seed5 + seed6 - grid_width + 1: seed5 + seed6;
    seed6 <= (seed6 + seed1>= grid_width-1)? seed6 + seed1 - grid_width + 1: seed6 + seed1;
    UpdateApple <= 1;
  end
  else UpdateApple <= 0;
end


//////////////////////////////////////////////////////// start snake image block
wire [16:0] sram_snake_addr;
wire [11:0] data_snake_out;
reg  [17:0] pixel_snake_addr;
assign sram_snake_addr = pixel_snake_addr;
sramSnake #(.DATA_WIDTH(12), .ADDR_WIDTH(18), .RAM_SIZE( gridSize * gridSize * 9 ))
  ramSnake ( .clk(clk), .we(sram_we), .en(sram_en),.addr(sram_snake_addr), .data_i(data_in), .data_o(data_snake_out)); 
reg [17:0] snakeAddr[8:0];
initial begin
  snakeAddr[0] = 0;
  snakeAddr[1] = gridSize * gridSize * 1;
  snakeAddr[2] = gridSize * gridSize * 2;
  snakeAddr[3] = gridSize * gridSize * 3;
  snakeAddr[4] = gridSize * gridSize * 4;
  snakeAddr[5] = gridSize * gridSize * 5;
  snakeAddr[6] = gridSize * gridSize * 6;
  snakeAddr[7] = gridSize * gridSize * 7;
  snakeAddr[8] = gridSize * gridSize * 8;
end
always@ (posedge clk) begin
  if (~reset_n)
    pixel_snake_addr <= 0;
  else if (inGameGrid) begin
    if (currGridX == snakeHeadX && currGridY == snakeHeadY) begin // head
      case(snakeHeadChooseImage)
        0: pixel_snake_addr <= ((pixel_x - leftPos) % gridSize) + ((pixel_y-topPos) % gridSize) * gridSize + snakeAddr[0];
        1: pixel_snake_addr <= ((pixel_x - leftPos) % gridSize) + ((pixel_y-topPos) % gridSize) * gridSize + snakeAddr[1];
        2: pixel_snake_addr <= ((pixel_x - leftPos) % gridSize) + ((pixel_y-topPos) % gridSize) * gridSize + snakeAddr[2];
        3: pixel_snake_addr <= ((pixel_x - leftPos) % gridSize) + ((pixel_y-topPos) % gridSize) * gridSize + snakeAddr[3];
      endcase
    end
    else if (currGridX == snakeTailX && currGridY == snakeTailY) begin // tail
      case(gameGrid[snakeTailY][snakeTailX]) 
        snakeStartIndex: pixel_snake_addr <= ((pixel_x - leftPos) % gridSize) + ((pixel_y-topPos) % gridSize) * gridSize + snakeAddr[5];
        snakeStartIndex+1: pixel_snake_addr <= ((pixel_x - leftPos) % gridSize) + ((pixel_y-topPos) % gridSize) * gridSize + snakeAddr[6];
        snakeStartIndex+2: pixel_snake_addr <= ((pixel_x - leftPos) % gridSize) + ((pixel_y-topPos) % gridSize) * gridSize + snakeAddr[7];
        snakeStartIndex+3: pixel_snake_addr <= ((pixel_x - leftPos) % gridSize) + ((pixel_y-topPos) % gridSize) * gridSize + snakeAddr[8];
      endcase
    end
    else begin // body
      pixel_snake_addr <= snakeAddr[4]+1;
    end
    
  end
end
///////////////////////////////////////////////////////////////////////////////end snake image block


// VGA color pixel generator
assign {VGA_RED, VGA_GREEN, VGA_BLUE} = rgb_reg;


wire inGameGrid = pixel_x >= leftPos && pixel_y >= topPos && pixel_x < leftPos + gridSize * grid_width && pixel_y < topPos + gridSize * grid_height;
wire [7:0] currGridY = (pixel_y - topPos) / gridSize;
wire [7:0] currGridX = (pixel_x - leftPos) / gridSize;
wire [7:0] currGridVal = (inGameGrid) ? gameGrid[currGridY][currGridX] : 0;
/////////////////////////////////// declare darkmode variable///////////////////////////////////////
localparam RANGE_LIGHT = 3; 
wire [4:0] visibleMinX_LIGHT = (snakeHeadX > RANGE_LIGHT) ? (snakeHeadX - RANGE_LIGHT) : 0;
wire [4:0] visibleMaxX_LIGHT = (snakeHeadX + RANGE_LIGHT < grid_width) ? (snakeHeadX + RANGE_LIGHT) : grid_width - 1;
wire [4:0] visibleMinY_LIGHT = (snakeHeadY > RANGE_LIGHT) ? (snakeHeadY - RANGE_LIGHT) : 0;
wire [4:0] visibleMaxY_LIGHT= (snakeHeadY + RANGE_LIGHT < grid_height) ? (snakeHeadY + RANGE_LIGHT) : grid_height - 1;
wire light_region = 
             (visibleMinY_LIGHT <= currGridY) && (currGridY <= visibleMaxY_LIGHT) &&
             (visibleMinX_LIGHT <= currGridX) && (currGridX <= visibleMaxX_LIGHT);
wire dark_mode = (usr_sw[0] == 0);

always @(posedge clk) begin
  if (pixel_tick) rgb_reg <= rgb_next;
end


//////////////////////////////////// VGA display ////////////////////////////////////////////////////
always @(*) begin
  if (~video_on)
    rgb_next = 12'h000;
  else   if ( fish_region_1) rgb_next=data_fish2;  //score
  else if ( fish_region_2 ) rgb_next=data_fish3; //score 
  else if ( greedy_region ) rgb_next = data_greedy;
  else if ( scoreword_region ) rgb_next = data_scoreword;
  else if ( gameover_region && score==0 ) rgb_next = data_gameover;
  else if (inGameGrid && isChooseMap) begin // show when choosing map
    if (currGridVal >= snakeStartIndex && data_snake_out != 12'h0f0) rgb_next = data_snake_out;
    else if (currGridVal == 0 && data_apple!=12'h0f0) rgb_next = data_apple; // apple
    else if (currGridVal == 1) rgb_next = data_obstacle; // wall
    else  rgb_next = 12'h060; // background
 end
 else if (~dark_mode && inGameGrid)begin // not dark mode
    if (currGridVal >= snakeStartIndex && data_snake_out != 12'h0f0) rgb_next = data_snake_out;
    else if (currGridVal == 0 && data_apple!=12'h0f0) rgb_next = data_apple; // apple
    else if (currGridVal == 1) rgb_next = data_obstacle; // wall
    else  rgb_next = 12'h060; // background
  end
  else if (dark_mode && inGameGrid && light_region)begin //dark mode, show the light area
    if (currGridVal >= snakeStartIndex && data_snake_out != 12'h0f0) rgb_next = data_snake_out;
    else if (currGridVal == 0 && data_apple!=12'h0f0) rgb_next = data_apple; // apple
    else if (currGridVal == 1) rgb_next = data_obstacle; // wall
    else  rgb_next = 12'h060; // background
  end
  else rgb_next = 12'h000;

end


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////        score        /////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

wire        fish_region_1;
wire        fish_regioin_2;
wire [16:0] sram_addr_fish2;
wire [16:0] sram_addr_fish3;
wire [11:0] data_fish2;
wire [11:0] data_fish3;
reg  [17:0] pixel_addr_fish2,pixel_addr_fish3;
reg [17:0] score;

sram2 #(.DATA_WIDTH(12), .ADDR_WIDTH(18), .RAM_SIZE( 32000 ))
  ram_2 ( .clk(clk), .we(sram_we), .en(sram_en),.addr(sram_addr_fish2), .data_i(data_in), .data_o(data_fish2)); 
  
sram3#(.DATA_WIDTH(12), .ADDR_WIDTH(18), .RAM_SIZE( 32000))
  ram_3 ( .clk(clk), .we(sram_we), .en(sram_en),.addr(sram_addr_fish3), .data_i(data_in), .data_o(data_fish3)); 
  

assign sram_we = usr_led[3]; 

assign sram_addr_fish2 = pixel_addr_fish2;
assign sram_addr_fish3 = pixel_addr_fish3;
assign data_in = 12'h000; 


assign fish_region_1 =
           pixel_y >= 400 &&pixel_x>= 560&&pixel_x<600;
assign fish_region_2 =
           pixel_y >= 400 &&pixel_x >= 600;

always @ (posedge clk) begin
  if (~reset_n)begin
    pixel_addr_fish2 <= 0;
  end else begin
    pixel_addr_fish2 <= (score/10)*3200+ (pixel_x-560)+(pixel_y-400)*40;
  end                       
end

always @ (posedge clk) begin
  if (~reset_n||score==99)begin
    score <= 3;
  end else if(score== 0) begin
    score <= 0;
  end else if(fowardIsApple&&needUpdateSnake) begin
    score <= score+1;
   end else if( needUpdateSnake && !moveIsValid && !isChooseMap  ) 
    score<=score-1;                 
end

always @ (posedge clk) begin
  if (~reset_n)begin
    pixel_addr_fish3 <= 0;
  end else begin
       pixel_addr_fish3 <= score%10*3200+ (pixel_x-600)+(pixel_y-400)*40;
    end                       
end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////        score        ////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////       Greedy Snake  word          ////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire        greedy_region;
wire [16:0] sram_addr_greedy;
wire [11:0] data_greedy;
reg  [17:0] pixel_addr_greedy;

sramGreedy #(.DATA_WIDTH(12), .ADDR_WIDTH(18), .RAM_SIZE( 28800 ))
  ram_4 ( .clk(clk), .we(sram_we), .en(sram_en),.addr(sram_addr_greedy), .data_i(data_in), .data_o(data_greedy)); 

assign sram_addr_greedy = pixel_addr_greedy;

assign greedy_region = pixel_y <= 360 &&pixel_x>= 560;

always @ (posedge clk) begin
  if (~reset_n)begin
    pixel_addr_greedy <= 0;
  end else begin
    pixel_addr_greedy <=  (pixel_x-560)+ pixel_y*80 ;
  end                       
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////       Greedy Snake  word          ////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////       score  word          ////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire        scoreword_region;
wire [16:0] sram_addr_scoreword;
wire [11:0] data_scoreword;
reg  [17:0] pixel_addr_scoreword;

sramScore #(.DATA_WIDTH(12), .ADDR_WIDTH(18), .RAM_SIZE( 3200 ))
  ram_5 ( .clk(clk), .we(sram_we), .en(sram_en),.addr(sram_addr_scoreword), .data_i(data_in), .data_o(data_scoreword)); 

assign sram_addr_scoreword = pixel_addr_scoreword;

assign scoreword_region = pixel_y >= 360 && pixel_y <= 400 && pixel_x >= 560 ;

always @ (posedge clk) begin
  if (~reset_n)begin
    pixel_addr_scoreword <= 0;
  end else begin
    pixel_addr_scoreword <=  (pixel_x-560)+ (pixel_y-360)*80 ;
   end                       
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////       score  word          ////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////       gameover  word   ////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire        gameover_region;
wire [16:0] sram_addr_gameover;
wire [11:0] data_gameover;
reg  [17:0] pixel_addr_gameover;

sramGameover #(.DATA_WIDTH(12), .ADDR_WIDTH(18), .RAM_SIZE( 38400 ))
  ram_6 ( .clk(clk), .we(sram_we), .en(sram_en),.addr(sram_addr_gameover), .data_i(data_in), .data_o(data_gameover)); 

assign sram_addr_gameover = pixel_addr_gameover;

assign gameover_region = pixel_y >= 200 && pixel_y < 280 && pixel_x < 560 && pixel_x>=80 ;

always @ (posedge clk) begin
  if (~reset_n)begin
    pixel_addr_gameover <= 0;
  end else begin
    pixel_addr_gameover <=  (pixel_x-80) + (pixel_y-200)*480 ;
   end                       
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////          gameover          ////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////            obstacle          ////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

wire [16:0] sram_addr_obstacle;
wire [11:0] data_obstacle;
reg  [17:0] pixel_addr_obstacle;

sramOB #(.DATA_WIDTH(12), .ADDR_WIDTH(18), .RAM_SIZE( 400 ))
  ram_7 ( .clk(clk), .we(sram_we), .en(sram_en),.addr(sram_addr_obstacle), .data_i(data_in), .data_o(data_obstacle)); 

assign sram_addr_obstacle = pixel_addr_obstacle;


always @ (posedge clk) begin
  if (~reset_n)begin
    pixel_addr_obstacle <= 0;
  end else begin
    pixel_addr_obstacle <=  ((pixel_x - leftPos) % gridSize) + ((pixel_y-topPos) % gridSize) * gridSize ;
   end                       
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////           obstacle           ////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////              apple             ////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

wire [16:0] sram_addr_apple;
wire [11:0] data_apple;
reg  [17:0] pixel_addr_apple;

sramAP #(.DATA_WIDTH(12), .ADDR_WIDTH(18), .RAM_SIZE( 400 ))
  ram_8 ( .clk(clk), .we(sram_we), .en(sram_en),.addr(sram_addr_apple), .data_i(data_in), .data_o(data_apple)); 

assign sram_addr_apple = pixel_addr_apple;

always @ (posedge clk) begin
  if (~reset_n)begin
    pixel_addr_apple <= 0;
  end else begin
    pixel_addr_apple <=  ((pixel_x - leftPos) % gridSize) + ((pixel_y-topPos) % gridSize) * gridSize ;
   end                       
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////             apple             ////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////     UART   WASD         ////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam [1:0] S_MAIN_INIT = 0, 
                 S_MAIN_PROMPT_1 = 1, S_MAIN_READ_NUM_1 = 2,
                 S_MAIN_DIV = 3;
localparam [1:0] S_UART_IDLE = 0, S_UART_WAIT = 1,
                 S_UART_SEND = 2, S_UART_INCR = 3;
localparam INIT_DELAY = 10_000; // 1 msec @ 100 MHz

localparam PROMPT_STR_1 = 0;
localparam PROMPT_LEN_1 = 21;
localparam REPLY_STR = PROMPT_LEN_1;
localparam REPLY_LEN = 26;
localparam MEM_SIZE = PROMPT_LEN_1 + REPLY_LEN;

// declare system variables
wire enter_pressed;
wire print_enable, print_done;
reg [$clog2(MEM_SIZE):0] send_counter;
reg [2:0] P, P_next;
reg [1:0] Q, Q_next;
reg [$clog2(INIT_DELAY):0] init_counter;
reg [7:0] data[0:MEM_SIZE-1];
reg  [0:PROMPT_LEN_1*8-1] prompt_1 = { "\015\012Change direction: ", 8'h00 };
reg  [0:REPLY_LEN*8-1] div =         { "\015\012\015\012Your direction:    \015\012", 8'h00};
reg  [15:0] num_reg;  // The key-in number register

// declare UART signals
wire transmit;
wire received;
wire [7:0] rx_byte;
reg  [7:0] rx_temp;  // if recevied is true, rx_temp latches rx_byte for ONLY ONE CLOCK CYCLE!
wire [7:0] tx_byte;
wire [7:0] echo_key; // keystrokes to be echoed to the terminal
wire is_num_key;
wire is_receiving;
wire is_transmitting;
wire recv_error;

//assign recv_error = (num2_reg== 0);
/* The UART device takes a 100MHz clock to handle I/O at 9600 baudrate */
uart uart(
  .clk(clk),
  .rst(~reset_n),
  .rx(uart_rx),
  .tx(uart_tx),
  .transmit(transmit),
  .tx_byte(tx_byte),
  .received(received),
  .rx_byte(rx_byte),
  .is_receiving(is_receiving),
  .is_transmitting(is_transmitting),
  .recv_error(recv_error)
);

// Initializes some strings.
// System Verilog has an easier way to initialize an array,
// but we are using Verilog 2001 :(
//
integer idx;

always @(posedge clk) begin
  if (~reset_n) begin
    for(idx = 0; idx < PROMPT_LEN_1; idx = idx+1)data[idx]= prompt_1[idx*8 +: 8];
    for(idx = 0; idx < REPLY_LEN; idx = idx+1)data[idx+PROMPT_LEN_1] = div[idx*8 +:8];
  end
  else if (P != S_MAIN_DIV && P_next == S_MAIN_DIV) begin
    case (num_reg)
        "w" : begin
            data[REPLY_STR+19] <= "w";
        end
        "a" : begin
            data[REPLY_STR+19] <= "a";
        end
        "s" : begin
            data[REPLY_STR+19] <= "s";
        end
        "d" : begin
            data[REPLY_STR+19] <= "d";
        end
    endcase
  end
end

// Combinational I/O logics of the top-level system
assign usr_led = usr_btn;
assign enter_pressed = (rx_temp == "w")||(rx_temp == "a")||(rx_temp == "s")||(rx_temp == "d"); // don't use rx_byte here!

// ------------------------------------------------------------------------
// Main FSM that reads the UART input and triggers
// the output of the string "Hello, World!".
always @(posedge clk) begin
  if (~reset_n) P <= S_MAIN_INIT;
  else P <= P_next;
end

always @(*) begin // FSM next-state logic
  case (P)
    S_MAIN_INIT: // Wait for initial delay of the circuit.
	   if (init_counter < INIT_DELAY) P_next = S_MAIN_INIT;
		else P_next = S_MAIN_PROMPT_1;
    S_MAIN_PROMPT_1: // Print the prompt message.
      if (print_done) P_next = S_MAIN_READ_NUM_1;
      else P_next = S_MAIN_PROMPT_1;
    S_MAIN_READ_NUM_1: // wait for <Enter> key.
      if (enter_pressed) P_next = S_MAIN_DIV;
      //if (enter_pressed) P_next = S_MAIN_PROMPT_2;
      else P_next = S_MAIN_READ_NUM_1;
    S_MAIN_DIV:
      if(print_done) P_next = S_MAIN_INIT;
      else P_next = S_MAIN_DIV;
  endcase
end

// FSM output logics: print string control signals.
assign print_enable = (P != S_MAIN_PROMPT_1 && P_next == S_MAIN_PROMPT_1) ||(P != S_MAIN_DIV && P_next == S_MAIN_DIV);

assign print_done = (tx_byte == 8'h0);

// Initialization counter.
always @(posedge clk) begin
  if (P == S_MAIN_INIT) init_counter <= init_counter + 1;
  else init_counter <= 0;
end
// End of the FSM of the print string controller
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// FSM of the controller that sends a string to the UART.
always @(posedge clk) begin
  if (~reset_n) Q <= S_UART_IDLE;
  else Q <= Q_next;
end

always @(*) begin // FSM next-state logic
  case (Q)
    S_UART_IDLE: // wait for the print_string flag
      if (print_enable) Q_next = S_UART_WAIT;
      else Q_next = S_UART_IDLE;
    S_UART_WAIT: // wait for the transmission of current data byte begins
      if (is_transmitting == 1) Q_next = S_UART_SEND;
      else Q_next = S_UART_WAIT;
    S_UART_SEND: // wait for the transmission of current data byte finishes
      if (is_transmitting == 0) Q_next = S_UART_INCR; // transmit next character
      else Q_next = S_UART_SEND;
    S_UART_INCR:
      if (tx_byte == 8'h0) Q_next = S_UART_IDLE; // string transmission ends
      else Q_next = S_UART_WAIT;
  endcase
end

// FSM output logics: UART transmission control signals
assign transmit = (Q_next == S_UART_WAIT ||(P == S_MAIN_READ_NUM_1 && received) || print_enable);
assign is_num_key = (rx_byte == "w") ||  (rx_byte == "a") || (rx_byte == "s") || (rx_byte == "d") ;
assign echo_key = is_num_key?rx_byte:0;
assign tx_byte  = (((P == S_MAIN_READ_NUM_1)) && received)? echo_key : data[send_counter];

// UART send_counter control circuit
always @(posedge clk) begin
  case (P_next)
    S_MAIN_INIT: send_counter <= PROMPT_STR_1;
    S_MAIN_READ_NUM_1 : send_counter <= REPLY_STR;
    default: send_counter <= send_counter + (Q_next == S_UART_INCR);
  endcase
end
// End of the FSM of the print string controller
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// UART input logic
// Decimal number input will be saved in num1 or num2.

always @(posedge clk)begin
  if (~reset_n) begin
    num_reg <= 0;
  end
  //else if (P_next == S_MAIN_INIT) begin
    //num_reg <= 0;
  //end
  else if (P == S_MAIN_READ_NUM_1 && received && is_num_key && keyboard&& isChooseMap == 0) num_reg <= rx_byte;
end

// The following logic stores the UART input in a temporary buffer.
// The input character will stay in the buffer for one clock cycle.
always @(posedge clk) begin
  rx_temp <= (received)? rx_byte : 8'h0;
end
// End of the UART input logic
// ------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////     UART   WASD         ////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



endmodule
