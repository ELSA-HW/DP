// chat gpt - AE_SDP Inserter (Profile 0) with 1-frame delayed CRC_PIXELS
module prt_dptx_sdp_profile0 (
    input  logic         rst,
    input  logic         clk,
    input  logic         vsync,
    input  logic         sdp_ready,
    input  logic [31:0]  crc_pixels_in,
    output logic         sdp_valid,
    output logic [319:0] sdp_payload   // 40 bytes = 320 bits
);

    typedef enum logic [1:0] {
        IDLE,
        WAIT_VSYNC,
        SEND_SDP
    } state_t;

    state_t state, next_state;
    logic send_sdp;

    // Registers to hold previous frame's CRC_PIXELS
    logic [31:0] stored_crc_pixels;
    logic [7:0] frame_id;
    logic fusa_compare;

    // chat gpt - FSM for sending AE_SDP once per vblank
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        send_sdp = 1'b0;

        case (state)
            IDLE: if (vsync) next_state = WAIT_VSYNC;
            WAIT_VSYNC: begin
                if (!vsync && sdp_ready) begin
                    next_state = SEND_SDP;
                    send_sdp = 1'b1;
                end
            end
            SEND_SDP: next_state = IDLE;
        endcase
    end

    // chat gpt - AE_SDP transmission valid pulse
    always_ff @(posedge clk or posedge rst) begin
        if (rst) sdp_valid <= 1'b0;
        else     sdp_valid <= (state == SEND_SDP);
    end

    // chat gpt - CRC storage at frame end
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            stored_crc_pixels <= 32'h0;
            frame_id <= 8'h0;
            fusa_compare <= 1'b0;
        end else if (vsync) begin
            stored_crc_pixels <= crc_pixels_in;
            frame_id <= frame_id + 1;
            fusa_compare <= 1'b1;  // Always 1 after first frame
        end
    end

    // chat gpt - Build 40-byte AE_SDP Payload (see AE spec section 10.8.6)
    always_ff @(posedge clk) begin
        sdp_payload <= {
            8'h01,           // Secondary Data Packet ID
            8'hA1,           // AE_SDP Type ID
            8'd40,           // Payload Length
            8'h00,           // Reserved
            24'h000001,      // IEEE Vendor ID
            8'h00,           // SDP Type (0 = CRC)
            frame_id,        // Frame ID
            8'h00,           // Reserved
            32'h00000000,    // CRC_MSA_DATA
            32'h00000000,    // CRC_SDP_DATA
            32'h00000000,    // CRC_COMP_BYTES (not used)
            stored_crc_pixels, // CRC_PIXELS (delayed one frame)
            32'h00000000,    // CRC_AE_SDP (optional for Profile 0)
            {31'h0, fusa_compare} // FUSA_COMPARE bit (bit 0)
        };
    end

endmodule
