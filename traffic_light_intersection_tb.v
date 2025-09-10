//=====================================================================
// Testbench for Traffic Light Intersection FSM (with Left Turns)
// Author: Rayon Dhali
//
// Purpose:
// --------
// This testbench simulates the Traffic Light FSM by applying a clock
// and reset signal, then monitoring how the North-South (NS) and
// East-West (EW) traffic lights behave over time. It verifies that
// the system cycles through the 8 states in the correct order:
//
//   NS Left Green → NS Left Yellow → NS Straight Green → NS Straight Yellow
//   → EW Left Green → EW Left Yellow → EW Straight Green → EW Straight Yellow
//
// Red lights are implied for all signals not active in a given state.
//=====================================================================

`timescale 1ns/1ps   // Simulation uses nanoseconds with picosecond precision

module traffic_light_intersection_tb;

    //=============================================================
    // Testbench Signals
    //=============================================================
    reg clk;          // Clock to drive FSM
    reg reset;        // Reset signal (forces FSM to start in S0)
    
    // Outputs from the DUT (Device Under Test)
    // Each bus [3:0] represents [Left, Green, Yellow, Red]
    wire [3:0] north_tl;
    wire [3:0] south_tl;
    wire [3:0] east_tl;
    wire [3:0] west_tl;

    //=============================================================
    // DUT Instantiation
    //=============================================================
    // "uut" = Unit Under Test (common naming convention).
    // We connect the testbench signals to the DUT ports.
    traffic_light_intersection uut (
        .clk(clk),
        .reset(reset),
        .north_tl(north_tl),
        .south_tl(south_tl),
        .east_tl(east_tl),
        .west_tl(west_tl)
    );

    //=============================================================
    // Clock Generation
    //=============================================================
    // Toggle the clock every 5ns → creates a 10ns period
    // which equals a 100 MHz frequency.
    always #5 clk = ~clk;

    //=============================================================
    // Test Sequence
    //=============================================================
    initial begin
        //---------------------------------------------------------
        // STEP 1: Initialize
        //---------------------------------------------------------
        clk = 0;          // Start clock low
        reset = 1;        // Assert reset (FSM forced to state S0: NS Left Green)

        //---------------------------------------------------------
        // STEP 2: Release Reset
        //---------------------------------------------------------
        // Hold reset for 10ns, then deassert it so the FSM begins running.
        #10 reset = 0;

        //---------------------------------------------------------
        // STEP 3: Let Simulation Run
        //---------------------------------------------------------
        // Allow the system to run for 500ns.
        // With parameters LEFT_TIME=5, GREEN_TIME=5, YELLOW_TIME=2,
        // this covers multiple full FSM cycles.
        #500;

        //---------------------------------------------------------
        // STEP 4: End Simulation
        //---------------------------------------------------------
        // Stop the simulator so we can view results in the waveform viewer.
        $stop;
    end

endmodule
