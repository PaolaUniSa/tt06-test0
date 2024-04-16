`define default_netname none

module tt_um_paolaunisa_top0 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  // use bidirectionals as outputs
    assign uio_oe = 8'b11111111;
    assign uio_out = 8'b0;
    

  wire reset;                  // Reset signal
  wire [7:0] input_current;    // Input current (8-bit fixed-point)
  wire [7:0] threshold;        // Firing threshold as input (8-bit fixed-point)
  wire [7:0] leak;             // Leak amount as input (8-bit fixed-point)
  wire [5:0] refractory_period;// Refractory period in clock cycles (6 bits)
  reg spike;                   // Spike output signal


    // Internal registers
    reg [7:0] voltage;                // Membrane voltage (8-bit fixed-point)
    reg [5:0] refractory_counter;     // Counter for refractory period (6 bits)

    // Parameters for neuron dynamics
    parameter [7:0] reset_voltage = 8'h00; // Voltage reset value (8-bit fixed-point)


 assign reset= !rst_n;
 assign input_current=ui_in;
 assign threshold=ui_in;
 assign leak=ui_in;
 assign refractory_period =ui_in [5:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset the voltage, spike signal, and refractory counter
            voltage <= reset_voltage;
            spike <= 0;
            refractory_counter <= 0;
        end
        else if (refractory_counter > 0) begin
            // Decrease refractory counter if neuron is in refractory period
            refractory_counter <= refractory_counter - 1;
            spike <= 0; // Ensure spike is not asserted during refractory period
        end
        else begin
            // Handle underflow condition
            if (voltage < leak) begin
                voltage <= input_current; // Set voltage to current if potential leak causes underflow
            end
            else begin
                // Integrate the input current, accounting for leakage
                // Check for overflow condition before adding
                if (voltage + input_current < voltage) begin
                    voltage <= threshold; // Set voltage to threshold if adding current causes overflow
                end
                else begin
                    // Normal case, integrate input current accounting for leak
                    voltage <= voltage + input_current - leak;
                end
            end

            // Check for firing threshold
            if (voltage >= threshold) begin
                spike <= 1;                    // Generate spike
                voltage <= reset_voltage;      // Reset voltage
                refractory_counter <= refractory_period; // Set refractory counter
            end
            else begin
                spike <= 0;                    // No spike
            end
        end
    end  
  
  assign uo_out[0]=spike;
  assign uo_out[7:1]=7'b0;
    
endmodule
