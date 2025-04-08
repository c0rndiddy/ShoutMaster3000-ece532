# ShoutMaster3000

ShoutMaster3000 is an audio-controlled dinosaur game using Nexys 4 DDR board
inspired by Google’s dinosaur game. The player’s onboard microphone input is
captured and fed into the dinosaur game. This audio signal controls the dinosaur’s
jumps, allowing it to hop over obstacles. The VGA displays the game (without
MicroBlaze involvement). Additionally, the mono audio port on the FPGA outputs
the processed audio, serving as a confirmation that input sounds are being faithfully
captured and processed. Finally, a score tracker implemented using the MicroBlaze
and AXI interface sends the score to the SDK terminal

The design tree:
```
ShoutMaster3000
├── README.md
├── project.xpr                    // Project File
├── project.hw
├── project.sim
├── project.ip_user_files          // Generated RTL for IP blocks
│   └── bd
│       └── design_1               // Xilinx IP and packaged custom IP
│           ├── ip
│           │   ├── design_1_ShoutMaster3000_0_0
│           │   ├── design_1_microblaze_0_0
│           │   └── design_1_clk_wiz_1_0
│           └── ipshared
│               └── b368           // Custom IP core: ShoutMaster3000
│                   ├── hdl
│                   │   └── ShoutMaster3000_v1_0.v
│                   └── src
│                       ├── TRex_top.v
│                       ├── DinoFSM.v
│                       ├── ClockDivider.v
│                       ├── VGA.v
│                       ├── vgaClk.v
│                       ├── AudioDemo.v         // Audio process custom IP
│                       ├── BackGroundDelegate.v
│                       ├── drawBackGround.v
│                       ├── drawDino.v
│                       ├── drawNumber.v
│                       ├── drawObstacle.v
│                       ├── gameFSM.v           // Game control FSM
│                       └── JumpDetector.v      // Audio score converter custom IP
├── project.srcs
│   ├── constrs_1/new
│   │   └── ShoutMaster3000.xdc     // Constraints File
│   └── sources_1/bd/design_1
│       └── design_1.bd             // Main Block Diagram
├── project.sdk
│   ├── design_1_wrapper_hw_platform_1
│   │   ├── design_1_wrapper.bit
│   │   └── system.hdf              // MicroBlaze Hardware Files
│   ├── drivers
│   ├── ShoutMaster3000             // MicroBlaze Software Project
│   │   └── src
│   │       ├── helloworld.c
│   │       ├── platform.c
│   │       └── platform_config.h
│   └── ShoutMaster3000_bsp         // MicroBlaze BSP Files
