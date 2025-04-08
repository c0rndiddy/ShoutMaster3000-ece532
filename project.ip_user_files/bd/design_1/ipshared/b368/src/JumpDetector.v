module JumpDetector (
    input  wire clk,         // system clock (e.g., 100MHz)
    input  wire reset,       // synchronous reset
    input  wire pwm_signal,  // audio output signal (1-bit PWM from AudioDemo)
    output reg  jump         // drives TRexTop's jump button (or LED)
);

    // Parameters in Q8.8 fixed point.
    // STEP: Increment when pwm_signal is high.
    // EXTRA_DECAY: Extra subtraction per cycle.
    // THRESHOLD_ON: Level above which jump is asserted.
    // THRESHOLD_OFF: Level below which jump is deasserted.
    // Increase threshold to require louder audio to trigger jump.
    // STEP=20, EXTRA_DECAY=4, THRESHOLD_ON=600, THRESHOLD_OFF=400 works for at home
    // STEP=20, EXTRA_DECAY=2, THRESHOLD_ON=600, THRESHOLD_OFF=400 works for in lab
    parameter STEP         = 16'd20;
    parameter EXTRA_DECAY  = 16'd3;
    parameter THRESHOLD_ON = 16'd600; // about 4.0 in effective units
    parameter THRESHOLD_OFF= 16'd400;  // hysteresis: release if level falls below ~2.0

    // Use a signed 16-bit register in Q8.8 fixed-point format.
    // (The upper 8 bits are the integer part; the lower 8 bits are the fractional part.)
    reg signed [15:0] level;

    // Baseline subtraction: (STEP/2 + EXTRA_DECAY)
    wire [15:0] baseline = (STEP >> 1) + EXTRA_DECAY;

    // Compute delta = (pwm_signal ? STEP : 0) - baseline.
    // At a 50% duty cycle, average delta = (0.5 * STEP) - (STEP/2 + EXTRA_DECAY) = -EXTRA_DECAY.
    wire signed [15:0] delta = (pwm_signal ? STEP : 16'd0) - $signed({1'b0, baseline});

    // Compute new level with saturation (clamp to 0)
    wire signed [15:0] new_level_temp = level + delta;
    wire [15:0] new_level = (new_level_temp < 0) ? 16'd0 : new_level_temp[15:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            level <= 16'sd0;
            jump  <= 1'b0;
        end else begin
            level <= new_level;
            // Hysteresis: only turn jump on when level exceeds THRESHOLD_ON,
            // and only turn it off when it falls below THRESHOLD_OFF.
            if (!jump) begin
                if (new_level > THRESHOLD_ON)
                    jump <= 1'b1;
            end else begin
                if (new_level < THRESHOLD_OFF)
                    jump <= 1'b0;
            end
        end
    end

endmodule