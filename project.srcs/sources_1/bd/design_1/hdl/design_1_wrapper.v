//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Mon Mar 31 00:54:34 2025
//Host        : LAPTOP-JRHJ62UT running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (Hsync_0,
    Vsync_0,
    btnc_i_0,
    btnl_i_0,
    led_o_0,
    micClk_0,
    micData_0,
    micLRSel_0,
    pwm_data_o_0,
    pwm_en_o_0,
    reset,
    sys_clock,
    usb_uart_rxd,
    usb_uart_txd,
    vgaBlue_0,
    vgaGreen_0,
    vgaRed_0);
  output Hsync_0;
  output Vsync_0;
  input btnc_i_0;
  input btnl_i_0;
  output [15:0]led_o_0;
  output micClk_0;
  input micData_0;
  output micLRSel_0;
  output pwm_data_o_0;
  output pwm_en_o_0;
  input reset;
  input sys_clock;
  input usb_uart_rxd;
  output usb_uart_txd;
  output [3:0]vgaBlue_0;
  output [3:0]vgaGreen_0;
  output [3:0]vgaRed_0;

  wire Hsync_0;
  wire Vsync_0;
  wire btnc_i_0;
  wire btnl_i_0;
  wire [15:0]led_o_0;
  wire micClk_0;
  wire micData_0;
  wire micLRSel_0;
  wire pwm_data_o_0;
  wire pwm_en_o_0;
  wire reset;
  wire sys_clock;
  wire usb_uart_rxd;
  wire usb_uart_txd;
  wire [3:0]vgaBlue_0;
  wire [3:0]vgaGreen_0;
  wire [3:0]vgaRed_0;

  design_1 design_1_i
       (.Hsync_0(Hsync_0),
        .Vsync_0(Vsync_0),
        .btnc_i_0(btnc_i_0),
        .btnl_i_0(btnl_i_0),
        .led_o_0(led_o_0),
        .micClk_0(micClk_0),
        .micData_0(micData_0),
        .micLRSel_0(micLRSel_0),
        .pwm_data_o_0(pwm_data_o_0),
        .pwm_en_o_0(pwm_en_o_0),
        .reset(reset),
        .sys_clock(sys_clock),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd),
        .vgaBlue_0(vgaBlue_0),
        .vgaGreen_0(vgaGreen_0),
        .vgaRed_0(vgaRed_0));
endmodule
