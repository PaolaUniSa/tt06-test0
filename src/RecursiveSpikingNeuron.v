module RecursiveSpikingNeuron(
    input wire clk,
    input wire reset,
    input wire [7:0] external_input_current,
    input wire [7:0] threshold,
    input wire [7:0] leak,
    input wire [5:0] refractory_period,
    input wire [7:0] scale_factor, // Now an input
    input wire feedback_delay, // Now a single bit input
    output wire spike
);

// Internal signals
reg [7:0] feedback_current; // Feedback current based on the spike output
wire [7:0] total_input_current; // Total input current is the sum of external input and feedback
wire internal_spike; // Internal spike signal from the instantiated neuron
reg delayed_spike; // Delayed spike signal for feedback control

// Instantiate the LeakyIntegrateFireNeuron
LeakyIntegrateFireNeuron lif_neuron(
    .clk(clk),
    .reset(reset),
    .input_current(total_input_current),
    .threshold(threshold),
    .leak(leak),
    .refractory_period(refractory_period),
    .spike(internal_spike)
);

// Calculate the total input current as the sum of external input and feedback current
assign total_input_current = external_input_current + feedback_current;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        feedback_current <= 0;
        delayed_spike <= 0;
    end
    else if (feedback_delay == 1'b0) begin
        // Apply feedback without delay
        feedback_current <= internal_spike ? scale_factor : 0;
    end
    else begin
        // Apply delayed feedback
        feedback_current <= delayed_spike ? scale_factor : 0;
        delayed_spike <= internal_spike;
    end
end

// Output the spike signal
assign spike = internal_spike;

endmodule
