module osd (
    // 21M VDP clock
    input clk,
    input rst_n,
    input [8:0] osd_cx, // 320 pixels must have 9 bits
    input [7:0] osd_cy, // 240 pixels must have 8 bits
    output reg pixel,
    input [5:0] char_data,
    input       char_we,
    input [6:0] char_addr
);
    // OSD have 16 columns wide x 8 lines height (5+1 x 3+1 character bits)
    // 128 6-bit characters on total

    // Main idea here is to have an input character framebuffer
    reg[4:0][2:0] char_buf;
    reg buffer[4];
    reg state,next_state;

    initial begin
        buffer[0] <= 1'b0;
        buffer[1] <= 1'b1;
        buffer[2] <= 1'b1;
        buffer[3] <= 1'b0;
        state      = 3'b000;
        next_state = 3'b000;
    end

    always @(negedge clk) begin
        // generate alternate pattern for character printing
    end

    // assign char_x = char_addr[3:0]*(504-184)>>3 + 184;
    // 320x240 osd
    always_comb begin
        if (osd_cx<160) // 320/2 + 184
            if (osd_cy<120) pixel = buffer[0]; else pixel = buffer[1]; // 240/2 + 120
        else
            if (osd_cy<120) pixel = buffer[2]; else pixel = buffer[3]; // 240/2 + 120
    end

endmodule
