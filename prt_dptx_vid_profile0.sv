// chat gpt - MODIFIED VIDEO TX TOP with CRC32 and AE_SDP (Profile 0)
module prt_dptx_vid_profile0 (
    input  logic         rst,
    input  logic         clk,
    input  logic         cke,
    input  logic         vsync,
    input  logic [191:0] pix_data,
    input  logic         pix_valid,
    output logic         sdp_valid,
    output logic [319:0] sdp_payload
);

    logic [31:0] crc32_result;
    logic        crc_clear;

    // chat gpt - instantiate CRC engine
    crc32_192bit_wrapper u_crc (
        .clk(clk),
        .rst(rst),
        .enable(pix_valid & cke),
        .clear(crc_clear),
        .data_in(pix_data),
        .crc_out(crc32_result)
    );

    // chat gpt - AE_SDP generator for Profile 0
    prt_dptx_sdp_profile0 u_sdp (
        .rst(rst),
        .clk(clk),
        .vsync(vsync),
        .sdp_ready(1'b1),
        .crc_pixels_in(crc32_result),
        .sdp_valid(sdp_valid),
        .sdp_payload(sdp_payload)
    );

    // chat gpt - Reset CRC at frame start (vsync)
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            crc_clear <= 1'b1;
        else
            crc_clear <= vsync;
    end

endmodule
