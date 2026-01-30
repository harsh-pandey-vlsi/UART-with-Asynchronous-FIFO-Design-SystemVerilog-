`timescale 1ns / 1ps
module uart_fifo_top #(
    parameter DATA_WIDTH=8,
    parameter FIFO_ADDR_WIDTH=4
)(
    input logic rx_clk,tx_clk,rst_n,uart_rx,
    output logic uart_tx
);

logic [DATA_WIDTH-1:0]rx_data;
logic rx_valid;
logic [DATA_WIDTH-1:0] fifo_dout;
logic fifo_full;
logic fifo_empty;
logic fifo_wr_en;
logic fifo_rd_en;
logic tx_ready;

logic rx_baud_tick;
logic tx_baud_tick;
integer rx_baud_cnt;
integer tx_baud_cnt;


uart_rx #(
    .DATA_WIDTH(DATA_WIDTH)
) u_rx (
    .clk(rx_clk),
    .rst_n(rst_n),
    .baud_tick(rx_baud_tick),
    .uart_rx(uart_rx),
    .rx_data(rx_data),
    .rx_valid(rx_valid)
);

async_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)
) u_fifo (
    .wr_clk(rx_clk),.wr_rst_n(rst_n),.wr_en(fifo_wr_en),.din(rx_data),.full(fifo_full),
    .rd_clk(tx_clk),.rd_rst_n(rst_n),.rd_en(fifo_rd_en),.dout(fifo_dout),.empty(fifo_empty)
);

uart_tx #(
    .DATA_WIDTH(DATA_WIDTH)
) u_tx (
    .clk(tx_clk),
    .rst_n(rst_n),
    .baud_tick(tx_baud_tick),
    .tx_data(fifo_dout),
    .tx_valid(fifo_rd_en),
    .tx_ready(tx_ready),
    .uart_tx(uart_tx)
);

//CONTROL LOGIC
assign fifo_wr_en = rx_valid && !fifo_full;
assign fifo_rd_en = tx_ready && !fifo_empty;

//RX BAUD GENERATOR
always_ff @(posedge rx_clk or negedge rst_n) begin
if(!rst_n) begin
rx_baud_cnt<=0;
rx_baud_tick<=0;
end else begin
if(rx_baud_cnt==15) begin
rx_baud_cnt<=0;
rx_baud_tick<=1;
end else begin
rx_baud_cnt<=rx_baud_cnt+1;
rx_baud_tick<=0;
end
end
end

//TX BAUD GENERATOR
always_ff @(posedge tx_clk or negedge rst_n) begin
if(!rst_n) begin
tx_baud_cnt<=0;
tx_baud_tick<=0;
end else begin
if(tx_baud_cnt == 15) begin
tx_baud_cnt<=0;
tx_baud_tick<=1;
end else begin
tx_baud_cnt<=tx_baud_cnt+1;
tx_baud_tick<=0;
end
end
end

endmodule
