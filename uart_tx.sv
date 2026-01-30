`timescale 1ns / 1ps
module uart_tx #(
    parameter DATA_WIDTH=8
)(
    input logic clk,
    input logic rst_n,
    input logic baud_tick,

    input logic [DATA_WIDTH-1:0]tx_data,
    input logic tx_valid,
    output logic tx_ready,

    output logic uart_tx
);

typedef enum logic [1:0] {
    IDLE,START,DATA,STOP
}tx_state_t;

tx_state_t state, next_state;

//ADD INTERNAL REGISTERS
logic [DATA_WIDTH-1:0] tx_shift_reg;
logic [$clog2(DATA_WIDTH):0] bit_cnt;

//STATE REGISTERS
always_ff @(posedge clk or negedge rst_n) begin
if(!rst_n)
state<=IDLE;
else
state<=next_state;
end

//NEXT STATE LOGIC
always_comb begin
next_state=state;

case(state)
IDLE : begin
if(tx_valid)
next_state=START;
end
START: begin
if(baud_tick)
next_state=DATA;
end
DATA : begin
if(baud_tick && bit_cnt == DATA_WIDTH-1)
next_state=STOP;
end
STOP : begin
if(baud_tick)
next_state=IDLE;
end
default:next_state=IDLE;
endcase
end

assign tx_ready =(state==IDLE);

//SHIFT REGISTER & BIT COUNTER LOGIC 
always_ff @(posedge clk or negedge rst_n) begin
if(!rst_n) begin
tx_shift_reg<='0;
bit_cnt<='0;
end
else begin 
case(state)
IDLE:begin
bit_cnt<='0;
if(tx_valid)
tx_shift_reg<=tx_data;
end
DATA:begin
if(baud_tick) begin
tx_shift_reg<=tx_shift_reg>>1;
bit_cnt<=bit_cnt+1'b1;
end
end
default:begin
bit_cnt<=bit_cnt;
tx_shift_reg<=tx_shift_reg;
end
endcase
end
end

//OUTPUT LOGIC
always_comb begin
case(state)
IDLE: uart_tx=1'b1;
START: uart_tx=1'b0;
DATA: uart_tx=tx_shift_reg[0];
STOP: uart_tx=1'b1;
default:uart_tx=1'b1;
endcase
end

endmodule
