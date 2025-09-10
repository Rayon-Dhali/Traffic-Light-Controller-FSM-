//=====================================================================
// Traffic Light Controller with Left Turns (FSM)
// Author: Rayon Dhali
//
// Description:
// ------------
// An 8-state finite state machine (FSM) controlling a 2-way intersection
// with dedicated left-turn arrows and straight-through signals.
//
// Order of operation:
//   NS Left Green → NS Left Yellow → NS Straight Green → NS Straight Yellow
//   → EW Left Green → EW Left Yellow → EW Straight Green → EW Straight Yellow
//
// Red lights are ON for all signals not active in the current state.
//=====================================================================

module traffic_light_intersection (
    input  wire clk,    // System clock
    input  wire reset,  // Active-high synchronous reset
    output reg [3:0] north_tl, // North traffic lights [Left, Green, Yellow, Red]
    output reg [3:0] south_tl, // South traffic lights
    output reg [3:0] east_tl,  // East traffic lights
    output reg [3:0] west_tl   // West traffic lights
);

    //=============================================================
    // Output encoding (one-hot per signal light)
    //=============================================================
    localparam LEFT_GREEN       = 4'b1000; // Left arrow ON (green)
    localparam STRAIGHT_GREEN   = 4'b0100; // Straight green ON
    localparam LEFT_YELLOW      = 4'b0010; // Left arrow turns yellow
    localparam STRAIGHT_YELLOW  = 4'b0010; // Straight green turns yellow
    localparam RED              = 4'b0001; // Red light ON

    //=============================================================
    // State encoding (8 states total)
    //=============================================================
    typedef enum reg [2:0] {
        S0_NS_LEFT     = 3'b000,  // NS left arrow green
        S1_NS_LEFT_YEL = 3'b001,  // NS left arrow yellow
        S2_NS_STRAIGHT = 3'b010,  // NS straight green
        S3_NS_YELLOW   = 3'b011,  // NS straight yellow
        S4_EW_LEFT     = 3'b100,  // EW left arrow green
        S5_EW_LEFT_YEL = 3'b101,  // EW left arrow yellow
        S6_EW_STRAIGHT = 3'b110,  // EW straight green
        S7_EW_YELLOW   = 3'b111   // EW straight yellow
    } state_t;

    state_t current_state, next_state;
    integer counter;

    //=============================================================
    // Timing parameters (adjustable)
    //=============================================================
    parameter LEFT_TIME   = 5;  // Duration for left-turn green
    parameter GREEN_TIME  = 5;  // Duration for straight green
    parameter YELLOW_TIME = 2;  // Duration for yellow

    //=============================================================
    // State register + counter
    //=============================================================
    always @(posedge clk) begin
        if (reset) begin
            current_state <= S0_NS_LEFT;
            counter <= 0;
        end else begin
            current_state <= next_state;
            counter <= counter + 1;
        end
    end

    //=============================================================
    // Next state logic + outputs
    //=============================================================
    always @(*) begin
        // Default outputs: all directions Red
        north_tl = RED; south_tl = RED;
        east_tl  = RED; west_tl  = RED;
        next_state = current_state;

        case (current_state)
            //=================== NORTH-SOUTH CYCLE ===================
            S0_NS_LEFT: begin
                north_tl = LEFT_GREEN; south_tl = LEFT_GREEN; // NS left arrows ON
                east_tl  = RED; west_tl = RED;               // EW held at Red
                if (counter >= LEFT_TIME) next_state = S1_NS_LEFT_YEL;
            end

            S1_NS_LEFT_YEL: begin
                north_tl = LEFT_YELLOW; south_tl = LEFT_YELLOW; // NS left turns yellow
                east_tl  = RED; west_tl = RED;                  // EW held at Red
                if (counter >= YELLOW_TIME) next_state = S2_NS_STRAIGHT;
            end

            S2_NS_STRAIGHT: begin
                north_tl = STRAIGHT_GREEN; south_tl = STRAIGHT_GREEN; // NS straight green
                east_tl  = RED; west_tl = RED;                        // EW held at Red
                if (counter >= GREEN_TIME) next_state = S3_NS_YELLOW;
            end

            S3_NS_YELLOW: begin
                north_tl = STRAIGHT_YELLOW; south_tl = STRAIGHT_YELLOW; // NS straight yellow
                east_tl  = RED; west_tl = RED;                          // EW held at Red
                if (counter >= YELLOW_TIME) next_state = S4_EW_LEFT;
            end

            //=================== EAST-WEST CYCLE ===================
            S4_EW_LEFT: begin
                east_tl = LEFT_GREEN; west_tl = LEFT_GREEN; // EW left arrows ON
                north_tl = RED; south_tl = RED;             // NS held at Red
                if (counter >= LEFT_TIME) next_state = S5_EW_LEFT_YEL;
            end

            S5_EW_LEFT_YEL: begin
                east_tl = LEFT_YELLOW; west_tl = LEFT_YELLOW; // EW left turns yellow
                north_tl = RED; south_tl = RED;               // NS held at Red
                if (counter >= YELLOW_TIME) next_state = S6_EW_STRAIGHT;
            end

            S6_EW_STRAIGHT: begin
                east_tl = STRAIGHT_GREEN; west_tl = STRAIGHT_GREEN; // EW straight green
                north_tl = RED; south_tl = RED;                     // NS held at Red
                if (counter >= GREEN_TIME) next_state = S7_EW_YELLOW;
            end

            S7_EW_YELLOW: begin
                east_tl = STRAIGHT_YELLOW; west_tl = STRAIGHT_YELLOW; // EW straight yellow
                north_tl = RED; south_tl = RED;                       // NS held at Red
                if (counter >= YELLOW_TIME) next_state = S0_NS_LEFT;
            end
        endcase
    end

    //=============================================================
    // Reset counter on state change
    //=============================================================
    always @(posedge clk) begin
        if (reset) counter <= 0;
        else if (next_state != current_state) counter <= 0;
    end

endmodule
