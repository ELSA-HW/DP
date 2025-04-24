// Wrapper for 192-bit CRC-32 using 12 position-specific LUTs (16-bit each)
module crc32_192bit_wrapper (
    input  logic        clk,
    input  logic [31:0] crc_in,
    input  logic [191:0] data_in,
    output logic [31:0] crc_out
);

    logic [31:0] crc_pos [0:11];

    // Instantiate LUTs for each 16-bit segment of the input
    crc_lut_16bit_pos0  u_crc0  (.clk(clk), .addr(data_in[15:0]),     .data(crc_pos[0]));
    crc_lut_16bit_pos1  u_crc1  (.clk(clk), .addr(data_in[31:16]),    .data(crc_pos[1]));
    crc_lut_16bit_pos2  u_crc2  (.clk(clk), .addr(data_in[47:32]),    .data(crc_pos[2]));
    crc_lut_16bit_pos3  u_crc3  (.clk(clk), .addr(data_in[63:48]),    .data(crc_pos[3]));
    crc_lut_16bit_pos4  u_crc4  (.clk(clk), .addr(data_in[79:64]),    .data(crc_pos[4]));
    crc_lut_16bit_pos5  u_crc5  (.clk(clk), .addr(data_in[95:80]),    .data(crc_pos[5]));
    crc_lut_16bit_pos6  u_crc6  (.clk(clk), .addr(data_in[111:96]),   .data(crc_pos[6]));
    crc_lut_16bit_pos7  u_crc7  (.clk(clk), .addr(data_in[127:112]),  .data(crc_pos[7]));
    crc_lut_16bit_pos8  u_crc8  (.clk(clk), .addr(data_in[143:128]),  .data(crc_pos[8]));
    crc_lut_16bit_pos9  u_crc9  (.clk(clk), .addr(data_in[159:144]),  .data(crc_pos[9]));
    crc_lut_16bit_pos10 u_crc10 (.clk(clk), .addr(data_in[175:160]),  .data(crc_pos[10]));
    crc_lut_16bit_pos11 u_crc11 (.clk(clk), .addr(data_in[191:176]),  .data(crc_pos[11]));

    assign crc_out = crc_in ^
                     crc_pos[0]  ^ crc_pos[1]  ^ crc_pos[2]  ^ crc_pos[3] ^
                     crc_pos[4]  ^ crc_pos[5]  ^ crc_pos[6]  ^ crc_pos[7] ^
                     crc_pos[8]  ^ crc_pos[9]  ^ crc_pos[10] ^ crc_pos[11];

endmodule
