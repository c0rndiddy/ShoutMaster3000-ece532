
`timescale 1 ns / 1 ps

	module ShoutMaster3000_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here
		input wire ck100MHz,
    
        input wire btnl_i,
        input wire btnc_i,
    
        output wire [15:0] led_o,
    
        input  wire micData,   // Input PDM data from the microphone
        output wire micClk,    // Output clk signal to microphone
        output wire micLRSel,  // Microphone select (0 for micClk rising edge)
   
        output wire [3:0] vgaRed,
        output wire [3:0] vgaGreen,
        output wire [3:0] vgaBlue,
        output wire       Hsync,
        output wire       Vsync,
    
        output wire pwm_data_o,
        output wire pwm_en_o,

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
	
	wire [7:0] obstacleCounter_temp;
	
// Instantiation of Axi Bus Interface S00_AXI
	ShoutMaster3000_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) ShoutMaster3000_v1_0_S00_AXI_inst (
	    .obstacleCounter(obstacleCounter_temp),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here
	wire dino_jump;
    
    assign led_o[0] = dino_jump;

    AudioDemo process_audio (
        .clk_i(ck100MHz),
        .rst_i(1'b0),
        .pdm_m_clk_o(micClk),
        .pdm_m_data_i(micData),
        .pdm_lrsel_o(micLRSel),
        .pwm_audio_o(pwm_data_o),
        .pwm_sdaudio_o(pwm_en_o)
   );
    
    JumpDetector score_audio (
        .clk(ck100MHz),
        .reset(1'b0),
        .pwm_signal(pwm_data_o),
        .jump(dino_jump)
    );
    
    TRexTop dino (
        .clk(ck100MHz),
        .btnR(btnc_i), // Reset button
        .duckButton(btnl_i), 
        .jumpButton(dino_jump), 
        .restart(1'b0),
        .Hsync(Hsync),
        .Vsync(Vsync),
        .vgaRed(vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue(vgaBlue),
        .led(),
        .run(),
        .dead(),
        .obstacleCounter(obstacleCounter_temp)
    );

	// User logic ends

	endmodule
