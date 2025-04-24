// ===================================================================================
// Module: DisplayPort TX CRC Extension for Profile 0
// Description: Adds automatic CRC calculation over video data (192-bit) and signals
//              mismatch to Policy Maker via scalar port.
// 
// Modifications: Integration of CRC checking and scalar signaling for Profile 0
// ===================================================================================

`default_nettype none

module dp_tx_crc_profile0_ext (
    input  logic         clk,
    input  logic         rst,
    input  logic         video_valid,
    input  logic [191:0] video_data,
    input  logic         frame_start,    // Asserted at the start of a video frame
    input  logic         frame_end,      // Asserted at the end of a video frame
    input  logic [31:0]  sdp_crc,        // CRC from SDP (Sideband Data Packet)

    output logic [31:0]  crc_out,        // Calculated CRC output
    output logic         scalar_crc_err  // Scalar signal to PM on mismatch
);

    // ============================================================================
    // Internal signals
    // ============================================================================
    logic        crc_enable;
    logic        crc_clear;
    logic [31:0] crc_calc;
    logic        crc_valid;

    // ============================================================================
    // CRC Calculation Instantiation
    // ============================================================================
    crc32_192bit_wrapper u_crc32_192bit (
        .clk     (clk),
        .rst     (rst),
        .enable  (crc_enable),
        .clear   (crc_clear),
        .data_in (video_data),
        .crc_out (crc_calc)
    );

    // ============================================================================
    // CRC Control Logic
    // ============================================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            crc_enable     <= 0;
            crc_clear      <= 1;
            crc_valid      <= 0;
        end else begin
            if (frame_start) begin
                crc_clear  <= 1;
                crc_enable <= 0;
                crc_valid  <= 0;
            end else if (video_valid) begin
                crc_clear  <= 0;
                crc_enable <= 1;
            end else if (frame_end) begin
                crc_enable <= 0;
                crc_valid  <= 1;
            end
        end
    end

    assign crc_out = crc_calc;

    // ============================================================================
    // CRC Mismatch Detection and Scalar Signaling to PM
    // ============================================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            scalar_crc_err <= 0;
        end else if (crc_valid) begin
            scalar_crc_err <= (crc_calc != sdp_crc);
        end
    end

endmodule

`default_nettype wire
