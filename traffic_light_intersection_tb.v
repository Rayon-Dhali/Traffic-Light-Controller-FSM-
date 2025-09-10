//=====================================================================
// Testbench for Traffic Light Intersection Controller
// Author: Rayon Dhali
// Description: This testbench verifies the functionality of the
//              2-way intersection traffic light controller FSM.
//              It applies a clock and reset, then observes how
//              the North-South (NS) and East-West (EW) traffic
//              lights change state over time.
//=====================================================================

`timescale 1ns/1ps  // Set simulation time unit (1ns) and precision (1ps)

module traffic_light_intersection_tb;

    //=============================================================
    // Testbench signals
    //=============================================================
    reg clk;           // Clock signal for driving the FSM
    reg reset;         // Reset signal to initialize the FSM

    // Outputs from the DUT (Device Under Test)
    wire ns_red, ns_yellow, ns_green;  // North-South lights
    wire ew_red, ew_yellow, ew_green;  // East-West lights

    //=============================================================
    // DUT Instantiation (connects testbench to design)
    //=============================================================
    // "uut" = Unit Under Test (common naming convention)
    traffic_light_intersection uut (
        .clk(clk),
        .reset(reset),
        .ns_red(ns_red), .ns_yellow(ns_yellow), .ns_green(ns_green),
        .ew_red(ew_red), .ew_yellow(ew_yellow), .ew_green(ew_green)
    );

    //=============================================================
    // Clock Generation
    //=============================================================
    // Clock toggles every 5ns → full period = 10ns → 100 MHz clock
    always #5 clk = ~clk;

    //=============================================================
    // Simulation Sequence
    //=============================================================
    initial begin
        // Step 1: Initialize signals
        clk = 0;       // Start with clock low
        reset = 1;     // Apply reset (active high)
        
        // Step 2: Hold reset for 10ns, ensuring DUT starts in known state
        #10 reset = 0; // Release reset, FSM starts operating

        // Step 3: Let simulation run for 300ns
        // This allows the FSM to cycle through multiple states:
        //   - NS Green → NS Yellow → EW Green → EW Yellow → repeat
        #300;

        // Step 4: Stop simulation
        $stop;         // Halts the simulator (view results in waveform viewer)
    end

endmodule
