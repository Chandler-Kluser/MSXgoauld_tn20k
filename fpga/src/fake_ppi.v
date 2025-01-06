// Fake MSX Keypress Handler Module
module fake_ppi (
    input  wire [3:0] key_row,           // row for the key pressed
    input  wire [2:0] key_col,           // col for the key pressed
    output wire [7:0] ppi_port_b,        // PORTB output of specific keypress
    input  wire [3:0] ppi_port_c,        // PORTC[3:0] input of keyboard row to read
    input  wire       SHIFT_UP
);

    reg [7:0] row[9];                    // eight keyboard rows for MSX to poll

    initial begin
        integer i;
        for (i = 0; i < 9; i = i + 1) row[i] <= 8'hFF;
    end

    assign ppi_port_b = (ppi_port_c == 4'd0) ? row[0] :
                        (ppi_port_c == 4'd1) ? row[1] :
                        (ppi_port_c == 4'd2) ? row[2] :
                        (ppi_port_c == 4'd3) ? row[3] :
                        (ppi_port_c == 4'd4) ? row[4] :
                        (ppi_port_c == 4'd5) ? row[5] :
                        (ppi_port_c == 4'd6) ? row[6] :
                        (ppi_port_c == 4'd7) ? row[7] :
                        (ppi_port_c == 4'd8) ? row[8] :
                        8'hFF;

    always_comb begin
             if (key_row == 4'd8) row[8] = ~(8'b00000001 << key_col[2:0]);
        else if (key_row == 4'd7) row[7] = ~(8'b00000001 << key_col[2:0]);
        else if (key_row == 4'd6)
        // shift logic must be separated
        row[6] = ~(8'b00000001 << key_col[2:0]) & {7'b1111111,SHIFT_UP};
        else if (key_row == 4'd5) row[5] = ~(8'b00000001 << key_col[2:0]);
        else if (key_row == 4'd4) row[4] = ~(8'b00000001 << key_col[2:0]);
        else if (key_row == 4'd3) row[3] = ~(8'b00000001 << key_col[2:0]);
        else if (key_row == 4'd2) row[2] = ~(8'b00000001 << key_col[2:0]);
        else if (key_row == 4'd1) row[1] = ~(8'b00000001 << key_col[2:0]);
        else if (key_row == 4'd0) row[0] = ~(8'b00000001 << key_col[2:0]);
        else begin
            row[0]      = 8'hFF;
            row[1]      = 8'hFF;
            row[2]      = 8'hFF;
            row[3]      = 8'hFF;
            row[4]      = 8'hFF;
            row[5]      = 8'hFF;
            // shift logic must be separated
            row[6]      = {7'b1111111,SHIFT_UP};
            row[7]      = 8'hFF;
            row[8]      = 8'hFF;
        end
    end
endmodule
