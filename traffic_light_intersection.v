//============================================================
// Traffic Light Controller for 2-Way Intersection
//============================================================
module traffic_light_intersection (
    input  wire clk,       // Clock input
    input  wire reset,     // Active-high synchronous reset
    output reg ns_red, ns_yellow, ns_green,  // NS direction lights
    output reg ew_red, ew_yellow, ew_green   // EW direction lights
);

    //============================================================
    // Parameters for timing
    //============================================================
    parameter GREEN_TIME_NS = 5;
    parameter GREEN_TIME_EW = 5;
    parameter YELLOW_TIME   = 2;

    //============================================================
    // State Encoding
    //============================================================
    typedef enum reg [1:0] {
        NS_GREEN  = 2'b00,
        NS_YELLOW = 2'b01,
        EW_GREEN  = 2'b10,
        EW_YELLOW = 2'b11
    } state_t;

    state_t current_state, next_state;
    integer counter;

    //============================================================
    // State Register
    //============================================================
    always @(posedge clk) begin
        if (reset) begin
            current_state <= NS_GREEN;
            counter <= 0;
        end else begin
            current_state <= next_state;
            counter <= counter + 1;
        end
    end

    //============================================================
    // Next State + Output Logic
    //============================================================
    always @(*) begin
        // Default outputs
        ns_red=0; ns_yellow=0; ns_green=0;
        ew_red=0; ew_yellow=0; ew_green=0;
        next_state = current_state;

        case (current_state)
            NS_GREEN: begin
                ns_green = 1; ew_red = 1;
                if (counter >= GREEN_TIME_NS) next_state = NS_YELLOW;
            end
            NS_YELLOW: begin
                ns_yellow = 1; ew_red = 1;
                if (counter >= YELLOW_TIME) next_state = EW_GREEN;
            end
            EW_GREEN: begin
                ew_green = 1; ns_red = 1;
                if (counter >= GREEN_TIME_EW) next_state = EW_YELLOW;
            end
            EW_YELLOW: begin
                ew_yellow = 1; ns_red = 1;
                if (counter >= YELLOW_TIME) next_state = NS_GREEN;
            end
        endcase
    end

    //============================================================
    // Reset counter whenever state changes
    //============================================================
    always @(posedge clk) begin
        if (reset) counter <= 0;
        else if (next_state != current_state) counter <= 0;
    end

endmodule
