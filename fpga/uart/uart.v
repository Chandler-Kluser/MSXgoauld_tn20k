module uart(
    input            clk,
    input            rst,
    input            uart0_rx,
    output           uart0_tx,
    output reg       reset4_n_ff,
    output reg       OSD,
    output reg       SCANLINES,
    output wire [7:0] ppi_port_b,        // PORTB output of specific keypress
    input  wire [3:0] ppi_port_c,        // PORTC[3:0] input of keyboard row to read
    output reg       SHIFT_UP
    // output reg       CAPS_ON
);

    parameter                        CLK_FRE  = 27;//Mhz
    parameter                        UART_FRE = 115200;//Mhz
    localparam                       IDLE =  0;
    localparam                       SEND =  1;   // send
    localparam                       WAIT =  1;   // wait 1 ms
    reg[7:0]                         tx_data_0;
    reg[7:0]                         tx_str;
    reg                              tx_data_valid;
    wire                             tx_data_ready;
    reg[7:0]                         tx_cnt;
    wire[7:0]                        rx_data_0;
    // wire[7:0]                        rx_data_1;
    wire                             rx_data_valid_0;
    // wire                             rx_data_valid_1;
    wire                             rx_data_ready_0;
    // wire                             rx_data_ready_1;
    reg[31:0]                        wait_cnt;
    reg[3:0]                         state;
    reg  [3:0] key_row;           // row for the key pressed
    reg  [2:0] key_col;           // col for the key pressed

    wire rst_n = !rst;

    // always can receive data,
    assign rx_data_ready_0 = 1'b1;

    // send raw byte over UART
    /// stty -F /dev/ttyUSB1 115200 cs8 -cstopb -parenb
    /// printf "\xF3" > /dev/ttyUSB1
    /// printf "a" > /dev/ttyUSB1

    initial begin
        reset4_n_ff <= 1'b1;
        key_row  <= 4'b1111;
        key_col  <=  3'b111;
        OSD      <=    1'b0;
        SCANLINES   <= 1'b1;
        SHIFT_UP    <= 1'b0;
        // CAPS_ON     <= 1'b0;
    end

    always @(posedge rx_data_valid_0) begin
        // keyboard key press/release command
        if (rx_data_0[7]==1'b1) begin
            if (rx_data_0[3:0]<4'd9) begin
                key_col <= rx_data_0[6:4];
                key_row <= rx_data_0[3:0];
            end
            // release
            else begin
                key_row <= 4'b1111;
                key_col <= 3'b111;
            end
        end
        // rx_data_0[7]==1'b0 ...
        else begin
            case (rx_data_0[6:0])
                7'd1:    OSD       <= ~OSD;
                7'd2:    SHIFT_UP  <= ~SHIFT_UP;
                7'd3:    reset4_n_ff  <= ~reset4_n_ff;
                default: SCANLINES <= ~SCANLINES;
            endcase
        end
    end

    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            wait_cnt <= 32'd0;
            tx_data_0 <= 8'd0;
            state <= IDLE;
            tx_cnt <= 8'd0;
            tx_data_valid <= 1'b0;
        end
        else case(state)
            IDLE:
                state <= SEND;
            SEND:
            begin
                wait_cnt <= 32'd0;
                tx_data_0 <= tx_str;
                if(tx_data_valid && tx_data_ready) //last byte sent is complete
                begin
                    tx_cnt <= 8'd0;
                    tx_data_valid <= 1'b0;
                    state <= WAIT;
                end
                else if(~tx_data_valid)
                begin
                    tx_data_valid <= 1'b1;
                end
            end
            WAIT:
            begin
                wait_cnt <= wait_cnt + 32'd1;

                // if(rx_data_valid_0 == 1'b1)
                // begin
                //     tx_data_valid <= 1'b1;
                //     tx_data_0 <= rx_data_0;   // send uart received data
                // end else
                if(tx_data_valid && tx_data_ready)
                begin
                    tx_data_valid <= 1'b0;
                end
                else if(wait_cnt >= CLK_FRE * 1_000) // wait for 1 ms
                    state <= SEND;
            end
            default:
                state <= IDLE;
        endcase
    end

    uart_rx#
    (
        .CLK_FRE(CLK_FRE),
        .BAUD_RATE(UART_FRE)
    ) uart_rx_inst1
    (
        .clk           (clk                      ),
        .rst_n         (rst_n                    ),
        .rx_data       (rx_data_0                  ),
        .rx_data_valid (rx_data_valid_0          ),
        .rx_data_ready (rx_data_ready_0          ),
        .rx_pin        (uart0_rx                  )
    );

    uart_tx#
    (
        .CLK_FRE(CLK_FRE),
        .BAUD_RATE(UART_FRE)
    ) uart_tx_inst0
    (
        .clk           (clk                      ),
        .rst_n         (rst_n                    ),
        .tx_data       (tx_data_0                ),
        .tx_data_valid (tx_data_valid            ),
        .tx_data_ready (tx_data_ready            ),
        .tx_pin        (uart0_tx                 )
    );
    fake_ppi ppi (
        .key_row(key_row),
        .key_col(key_col),
        .ppi_port_b(ppi_port_b),
        .ppi_port_c(ppi_port_c[3:0]),
        .SHIFT_UP(SHIFT_UP)
    );
endmodule
