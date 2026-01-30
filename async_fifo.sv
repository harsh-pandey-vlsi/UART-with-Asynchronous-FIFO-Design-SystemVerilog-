`timescale 1ns / 1ps
module async_fifo #(
    parameter DATA_WIDTH =8,
    parameter ADDR_WIDTH =4 //FIFO DEPTH =2^ADDR_WIDTH
)(
    //Write clock domain
    input logic wr_clk,
    input logic wr_rst_n,
    input logic wr_en,
    input logic [DATA_WIDTH-1:0]din,
    output logic full,

    //Read clock domain
    input logic rd_clk,
    input logic rd_rst_n,
    input logic rd_en,
    output logic [DATA_WIDTH-1:0]dout,
    output logic empty
);
localparam DEPTH =1<<ADDR_WIDTH;
logic [DATA_WIDTH-1:0]mem[0:DEPTH-1];

logic [ADDR_WIDTH-1:0]wr_ptr_bin;
logic [ADDR_WIDTH-1:0]rd_ptr_bin;
logic [ADDR_WIDTH:0]wr_ptr_gray;
logic [ADDR_WIDTH:0]rd_ptr_gray;
logic [ADDR_WIDTH:0]wr_ptr_gray_sync_rd1, wr_ptr_gray_sync_rd2;
logic [ADDR_WIDTH:0]rd_ptr_gray_sync_wr1, rd_ptr_gray_sync_wr2;
logic [ADDR_WIDTH:0]wr_ptr_bin_next;
logic [ADDR_WIDTH:0]wr_ptr_gray_next;

assign wr_ptr_bin_next = wr_ptr_bin + (wr_en & ~full);
assign wr_ptr_gray_next = (wr_ptr_bin_next>>1)^wr_ptr_bin_next;

always_ff @(posedge wr_clk or negedge wr_rst_n) begin
if (!wr_rst_n)begin
wr_ptr_bin<='0;
end
else if (wr_en && !full) begin
mem[wr_ptr_bin[ADDR_WIDTH-1:0]]<=din;
wr_ptr_bin<=wr_ptr_bin+1'b1;
end
end

always_ff @(posedge rd_clk or negedge rd_rst_n) begin
if (!rd_rst_n) begin
rd_ptr_bin<='0;
dout<='0;
end
else if (rd_en && !empty) begin
dout<=mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
rd_ptr_bin<=rd_ptr_bin+1'b1;
end
end

assign wr_ptr_gray = (wr_ptr_bin>>1)^wr_ptr_bin;
assign rd_ptr_gray = (rd_ptr_bin>>1)^rd_ptr_bin;

always_ff @(posedge rd_clk or negedge rd_rst_n) begin
if(!rd_rst_n) begin
wr_ptr_gray_sync_rd1<='0;
wr_ptr_gray_sync_rd2<='0;
end
else begin
wr_ptr_gray_sync_rd1<=wr_ptr_gray;
wr_ptr_gray_sync_rd2<=wr_ptr_gray_sync_rd1;
end
end

always_ff @(posedge wr_clk or negedge wr_rst_n) begin
if(!wr_rst_n) begin
rd_ptr_gray_sync_wr1<='0;
rd_ptr_gray_sync_wr2<='0;
end
else begin 
rd_ptr_gray_sync_wr1<=rd_ptr_gray;
rd_ptr_gray_sync_wr2<=rd_ptr_gray_sync_wr1;
end
end

always_ff @(posedge wr_clk or negedge wr_rst_n) begin
if (!wr_rst_n)
full<=1'b0;
else 
full<=(wr_ptr_gray_next=={~rd_ptr_gray_sync_wr2[ADDR_WIDTH:ADDR_WIDTH-1],
       rd_ptr_gray_sync_wr2[ADDR_WIDTH-2:0]});
end

always_ff @(posedge rd_clk or negedge rd_rst_n) begin
if(!rd_rst_n)
empty<=1'b1;
else
empty<=(wr_ptr_gray_sync_rd2==rd_ptr_gray);
end

endmodule 
