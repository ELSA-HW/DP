// chat gpt - Full pipeline: Pixel packer -> 4x collector -> 192b CRC
module crc_pixel_pipeline (
    input  logic         clk,
    input  logic         rst,
    input  logic         pixel_valid,
    input  logic [15:0]  red_in,
    input  logic [15:0]  green_in,
    input  logic [15:0]  blue_in,
    input  logic [3:0]   bpc,  // 6, 8, 10, 12, 16

    output logic [31:0]  crc_out
);

    logic [47:0] packed_pixel;
    logic [191:0] crc_data;
    logic         crc_valid;

    // Stage 1: BPC-aware pixel packer
    pixel_packer packer_inst (
        .red_in(red_in),
        .green_in(green_in),
        .blue_in(blue_in),
        .bpc(bpc),
        .packed_pixel(packed_pixel)
    );

    // Stage 2: Collector for 4 pixels = 192-bit word
    pixel4_to_crc192 collector_inst (
        .clk(clk),
        .rst(rst),
        .pixel_valid(pixel_valid),
        .pixel_in(packed_pixel),
        .crc_data_out(crc_data),
        .crc_valid(crc_valid)
    );

    // Stage 3: 192-bit CRC engine (IEEE 802.3)
    crc32_192bit_wrapper crc_inst (
        .clk(clk),
        .rst(rst),
        .enable(crc_valid),
        .clear(rst),  // can be tied to vsync externally
        .data_in(crc_data),
        .crc_out(crc_out)
    );

endmodule
