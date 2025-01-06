module osd_char_rom (
    // Character Address (0~45 = 46 characters) -- 6 bits wide address space
    // 5x3 = 15 bits pixel characters
    // 5x3x46 = 690 bits on total rom character set
    // 0 to 689
    input [5:0] char_add,
    input [2:0] px_line,
    input clock,
    input [7:0] data,
    // input wren,
    output [CHAR_WIDTH-1:0] q
);
    localparam CHAR_LENGTH = 46;
    localparam CHAR_HEIGHT = 5;
    localparam CHAR_WIDTH = 3;

    reg [CHAR_HEIGHT-1:0][CHAR_WIDTH-1:0] mem_r[0:CHAR_LENGTH-1];
    reg [CHAR_WIDTH-1:0] q_r;

initial begin
    // $readmemh("char_rom.hex", mem_r);
end

    always @(posedge clock) begin
        // q_r <= mem_r[address];
        case (px_line)
            0:
                q_r <= 3'b010;
            1:
                q_r <= 3'b101;
            2:
                q_r <= 3'b101;
            3:
                q_r <= 3'b101;
            4:
                q_r <= 3'b010;
            default:
                q_r <= 3'b000;
        endcase
        // if (wren == 1) begin
        //     mem_r[address] <= data;
        // end
    end
    assign q = q_r;

endmodule
