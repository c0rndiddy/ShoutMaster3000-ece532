module TRexTop(
    input wire 	 clk,
	input wire 	 btnR, // Reset button
	input wire 	 duckButton,
	input wire 	 jumpButton,
    input wire   restart,
	
	output wire 	 Hsync,
	output wire 	 Vsync,
	output reg [3:0] vgaRed,
	output reg [3:0] vgaGreen,
	output reg [3:0] vgaBlue,
    output wire      led,
    output wire      run,
    output wire      dead,
    output reg [7:0] obstacleCounter
);

    localparam ratio = 1;
    localparam ScreenH = 9'd480;
    localparam ScreenW = 10'd640;

    wire [9:0] x;       // VGA pixel scan X      
    wire [8:0] y;       // VGA pixel scan Y
   
    wire [8:0] GroundY; // Horizon Y coordinate

    wire [10:0] dinoX;
    wire [8:0]  dinoY;

    wire [10:0] ObsX;
   
    wire  pixel_clk;     // 25Mhz pixel scan clock rate
    wire  animateClock;  // controls the animation of dino's foot step, and bird wings
    wire  ScoreClock;    // Speed of Score coutner (1s = 10 points)
    wire  Frame_Clk;     // 60 FPS
    wire  moveClk;

    wire  rst;
    wire  jump;
    wire  duck;

    localparam dx = 5'd30;
   
    assign GroundY = ScreenH - (ScreenH >> 2);   // Ground Y coordinate assignment
                                                 // 640 - 160 = 480 --> Bottom 25 %

    wire [10:0] difficulty = 11'd500; 
   
    // Clock divider.
    vgaClk _vgaClk(
        .clk(clk), 
        .pix_clk(pixel_clk)  // 25MHz
    );
    
    ClockDivider #(.velocity(4))   
    animateClk (
        .clk(clk),
        .speed(animateClock)
    );
    
    ClockDivider #(.velocity(10))  // Period = 0.1s
    ScoreClkv (
        .clk(clk),
        .speed(ScoreClock)
    );
    
    ClockDivider #(.velocity(50))  // Period = 0.1s
    FPSClk (
        .clk(clk),
        .speed(Frame_Clk)
    );
					  
	ClockDivider #(.velocity(300))
	MoveClk (
	   .clk(clk),
	   .speed(moveClk)
	);
	
	// Debouncer Module
    Debouncer resetButton (
        .button_in(btnR),
        .clk(clk),
        .button_out(rst)
    );

    Debouncer jumpBtn (
        .button_in(jumpButton),
        .clk(clk),
        .button_out(jump)
    );
    
    Debouncer duckBtn(
        .button_in(duckButton),
        .clk(clk),
        .button_out(duck)
    );
    
    //----------------------------------------------------------------------------------------------------------------
    // Main Game Control Unit
    /* Game Delegate is a FSM
       00 - Initial state: 
              The game is frozen, everything is at there initial positon:
                Obstacles X = ScreenW + someOffset
                DinoX = defaultDinoX
                DinoY = GroundY
       01 - Gaming State:
              The game starts. Triggered by the 'initial jump'
       10 - Dead State:
              The game is frozen, dead dino and game over msg displayed.
      
       (01 - restart -)-> 00 -- Jump ----> 10 ------- Collided ---> 01 (Dead)
                                       |          |
                                       |          |
                                       |_!Collide_|
    */ 
    //----------------------------------------------------------------------------------------------------------------
   reg  collided;
   reg  collided_delayed;
   reg  collided_true;
   wire dino_inWhite;
   wire dino_inGrey;
   wire obstacle_inWhite;
   wire obstacle_inGrey;
   
   always @(posedge clk) begin
      if (rst) begin
        collided <= 0;
        collided_delayed <= 0;
        collided_true <= 0;
      end else if (collided && collided_delayed) begin
        collided_true <= 1;
      end else begin
        collided <= dino_inGrey & obstacle_inGrey;
        collided_delayed <= collided;
      end
   end
   assign led = collided_true;
   
    wire [1:0] gameState;	// wire[1] is run;
   
    GameDelegate gameFSM (
        .clk(clk),
        .rst(rst),
        .jump(jump),
        .restart(restart),
        .collided(collided_true),
        .state(gameState)
    );
    
    // VGA Unit
    VGA vga(
        .pixel_clock(pixel_clk),
        .rst(rst),
        .Hsync(Hsync),
        .Vsync(Vsync),
        .X(x),
        .Y(y)
    );
    
    wire BackGround_inGrey;
    BackGroundDelegate #(.ratio(ratio), .dx(dx))
    BGD (
        .moveClk(moveClk),
        .rst(rst),
        .GroundY(GroundY),
        .vgaX(x),
        .vgaY(y),
        .gameState(gameState),
        .inGrey(BackGround_inGrey)
    );		
   
    wire ScoreBoard_inGrey;
    ScoreBoardDelegate SBD(
        .ScoreClock(ScoreClock & gameState[1]),
        .rst(rst),
        .gameState(gameState),
        .vgaX(x),
        .vgaY(y),
        .inGrey(ScoreBoard_inGrey)
    );
   
    TRexDelegate #(.ratio(ratio))
    TRD (
        .rst(rst),
        .animationClk(animateClock),
        .FrameClk(Frame_Clk),
        .jump(jump),
        .duck(duck),
        .gameState(gameState),
        .GroundY(GroundY),
        .vgaX(x),
        .vgaY(y),
        .inGrey(dino_inGrey),
        .inWhite(dino_inWhite)
    );
    
    wire obstacleSpawned;
    ObstaclesDelegate #(.ratio(ratio), .dx(dx))
    OD (
        .clk(clk),
        .moveClk(moveClk),
        .rst(rst),
        .ObstacleY(GroundY),
        .vgaX(x),
        .vgaY(y),
        .gameState(gameState),
        .inGrey(obstacle_inGrey),
        .inWhite(obstacle_inWhite),
        .X_1(ObsX),
        .obstacleSpawned(obstacleSpawned)
    );
    
    // Color select
    wire isGrey;
    wire isWhite;
    wire isBackGround;
     
    assign isGrey = dino_inGrey | BackGround_inGrey | ScoreBoard_inGrey | obstacle_inGrey;
    assign isWhite = dino_inWhite | obstacle_inWhite;
    assign isBackGround = (x > 0) && (x <= ScreenW) && (y > 0) && (y <= ScreenH) && !isGrey;

    always @(posedge pixel_clk) begin
        if (isWhite) begin
            vgaRed <= 4'b1111;
            vgaGreen <= 4'b1111;
            vgaBlue <= 4'b1111;
        end
        else if (isGrey) begin
            vgaRed <= 4'b0000;
            vgaGreen <= 4'b0000;
            vgaBlue <= 4'b0000;
        end
        else if (isBackGround) begin
            vgaRed <= 4'b1111;
            vgaGreen <= 4'b1111;
            vgaBlue <= 4'b1111;
        end
        else begin
            vgaRed <= 4'b0000;
            vgaGreen <= 4'b0000;
            vgaBlue <= 4'b0000;
        end
    end
    
    assign run = gameState[1];
    assign dead = gameState[0];
    
    // Count the score
    reg obstacleSpawned_d; // delayed version of obstacleSpawned
    
    always @(posedge clk) begin
        obstacleSpawned_d <= obstacleSpawned; // store previous state
    end
    
    wire obstacleSpawned_rising = (obstacleSpawned && ~obstacleSpawned_d);
    
    always @(posedge clk) begin
        if (rst || gameState == 2'b00) begin
            obstacleCounter <= 0;
        end 
        else if (gameState == 2'b10 && obstacleSpawned_rising) begin
            obstacleCounter <= obstacleCounter + 1;
        end
    end

endmodule
