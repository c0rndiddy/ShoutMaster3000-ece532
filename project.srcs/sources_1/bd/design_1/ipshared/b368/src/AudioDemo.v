module AudioDemo (
    input              clk_i,
    input              rst_i,
    // Microphone PDM signals
    output             pdm_m_clk_o,     // Drives the microphone clock
    input              pdm_m_data_i,    // Microphone data input
    output             pdm_lrsel_o,     // Remains as in original (set to '0' for positive edge)
    // Audio output signals
    output             pwm_audio_o,   // Audio output PDM data
    output             pwm_sdaudio_o   // Audio enable signal (always high)
);

  // Generate a clock for the microphone by dividing the 100MHz clock by 32 (for 3.125MHz)
  reg [4:0] clk_cntr_reg = 5'b0;
  reg       pwm_val_reg;
  
  always @(posedge clk_i) begin
      clk_cntr_reg <= clk_cntr_reg + 1;
  end
  
  assign pdm_m_clk_o = clk_cntr_reg[4];
  
  // Sample pdm_m_data_i on a specific clock count value (when clk_cntr_reg == 5'b01111)
  always @(posedge clk_i) begin
      if (clk_cntr_reg == 5'b01111) pwm_val_reg <= pdm_m_data_i;
  end
  
  assign pdm_lrsel_o = 1'b0; // Tie the mic left/right select to 0
  assign pwm_audio_o = pwm_val_reg; // Drive the audio out
  assign pwm_sdaudio_o = 1'b1; // Audio enable signal: always high
  
endmodule