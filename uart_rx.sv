`timescale 1ns / 1ps
module uart_rx #(
    parameter DATA_WIDTH=8
)(
    input logic clk,rst_n,baud_tick,uart_rx,
    output logic [DATA_WIDTH-1:0]rx_data,
    output logic rx_valid
);
//RX STATES
typedef enum logic [1:0] {
    IDLE,START,DATA,STOP
}
rx_state_t;
rx_state_t state, next_state;

logic sample_tick;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        sample_tick <= 1'b0;
    else
        sample_tick <= baud_tick;  // For now direct, will refine
end

//INTERNAL REGISTERS
logic [$clog2(DATA_WIDTH):0] bit_cnt;
logic [DATA_WIDTH-1:0]rx_shift_reg;

//STATE REGISTER
always_ff @(posedge clk or negedge rst_n) begin
if(!rst_n)
state<=IDLE;
else
state<=next_state;
end

logic start_cnt;
  
//NEXT STATE LOGIC
always_comb begin
next_state = state;
case(state)
IDLE:begin
if(uart_rx==1'b0)
next_state=START;
end
START:begin
if(baud_tick)
next_state=DATA;
end
DATA:begin
if(baud_tick && bit_cnt == DATA_WIDTH-1)
next_state = STOP;
end
STOP: begin
if(baud_tick)
next_state=IDLE;
end
endcase
end

//rx_valid DEFAULT LOGIC
always_ff @(posedge clk or negedge rst_n) begin
if(!rst_n)
rx_valid<=1'b0;
else if (state == STOP && baud_tick)
rx_valid<=1'b1;
else
rx_valid<=1'b0;
end

//SAMPLING AND SHIFT REGISTER LOGIC
always_ff @(posedge clk or negedge rst_n) begin
if(!rst_n) begin
rx_shift_reg<='0;
bit_cnt<='0;
rx_data<='0;
end
else begin
case(state)
IDLE:begin
bit_cnt<=0;
end
START:begin
rx_shift_reg <= 0;  
bit_cnt<=0;
end
DATA:begin
if(baud_tick) begin
if (bit_cnt < DATA_WIDTH) begin
rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:1],uart_rx};
bit_cnt<=bit_cnt+1'b1;
end
end
end
STOP:begin
if(baud_tick)
rx_data<=rx_shift_reg;
end
endcase
end
end

endmodule 
