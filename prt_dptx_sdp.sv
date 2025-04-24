// chat gpt - AE_SDP Inserter Module
module prt_dptx_sdp (
    input  logic        rst,
    input  logic        clk,
    input  logic        vsync,
    input  logic        sdp_ready,
    input  logic [31:0] crc_in,
    output logic        sdp_valid,
    output logic [127:0] sdp_payload
);

    typedef enum logic [1:0] {
        IDLE,
        WAIT_VSYNC,
        SEND_SDP
    } state_t;

    state_t state, next_state;
    logic send_sdp;

    // chat gpt - SDP state machine
    always_ff @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else     state <= next_state;
    end

    always_comb begin
        next_state = state;
        send_sdp = 0;

        case (state)
            IDLE: if (vsync) next_state = WAIT_VSYNC;
            WAIT_VSYNC: begin
                if (!vsync && sdp_ready) begin
                    next_state = SEND_SDP;
                    send_sdp = 1;
                end
            end
            SEND_SDP: next_state = IDLE;
        endcase
    end

    // chat gpt - SDP valid flag
    always_ff @(posedge clk) begin
        sdp_valid <= (state == SEND_SDP);
    end

    // chat gpt - SDP Payload Construction
    always_ff @(posedge clk) begin
        sdp_payload <= {
            8'h01,        // Header: Secondary Data Packet ID
            8'hA1,        // AE SDP type ID
            8'h10,        // Payload length
            8'h00,        // Reserved
            32'hDEADBEEF, // Placeholder for meta
            crc_in        // 32-bit CRC from pixel frame
        };
    end

endmodule
