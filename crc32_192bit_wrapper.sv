// chat gpt - CRC32 wrapper for 192-bit video data
module crc32_192bit_wrapper (
    input  logic         clk,
    input  logic         rst,
    input  logic         enable,
    input  logic         clear,
    input  logic [191:0] data_in,
    output logic [31:0]  crc_out
);

    logic [31:0] crc_reg, next_crc;

    // Polynomial for IEEE 802.3
    localparam [31:0] POLY = 32'h04C11DB7;

    function [31:0] crc32_next;
        input [31:0] crc_in;
        input [191:0] data;
        reg [31:0] crc;
        integer i;
        begin
            crc = crc_in;
            for (i = 0; i < 192; i++) begin
                if ((crc[31] ^ data[191 - i]) == 1'b1)
                    crc = (crc << 1) ^ POLY;
                else
                    crc = crc << 1;
            end
            crc32_next = crc;
        end
    endfunction

    // chat gpt - update CRC on enable
    always_ff @(posedge clk or posedge rst) begin
        if (rst || clear)
            crc_reg <= 32'hFFFFFFFF;
        else if (enable)
            crc_reg <= crc32_next(crc_reg, data_in);
    end

    assign crc_out = ~crc_reg; // Final inversion per IEEE spec

endmodule
