module line_buffer #(
    parameter WIDTH = 8,
    parameter IMG_WIDTH = 6
) (
    input  logic             clock,
    input  logic             reset,
    input  logic [WIDTH-1:0] in_din,
    input  logic             valid_in,//Input data valid, write enable
    output logic             valid_out,//Output to the next level of valid_in, that is, when the upper level starts to read, the lower level can start to write
    output logic [WIDTH-1:0] out_dout
);

logic   rd_en;//Read enable
logic   [9:0] cnt;//The width here should be based on img_ The value of width should be set to meet the requirement that the range of cnt is greater than or equal to the image width

always_ff @( posedge clock ) begin
    if(reset == 1'b1) begin
        cnt <= {10{1'b0}};
    end
    else if(valid_in == 1'b1) begin
        if(cnt == IMG_WIDTH) begin
            cnt <= IMG_WIDTH;
        end
        else begin
            cnt <= cnt + 1'b1;
        end
    end
    else begin
        cnt <= cnt;
    end
end
//After a line of data is written, the fifo of this stage can start to read, and the next stage can also start to write
assign rd_en = ((cnt == IMG_WIDTH) && (valid_in)) ? 1'b1:1'b0;
assign valid_out = rd_en;

fifo #(
    .FIFO_BUFFER_SIZE(1024),
    .FIFO_DATA_WIDTH(WIDTH)
) fifo_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(valid_in),
    .din(in_din),
    .full(),
    .rd_clk(clock),
    .rd_en(rd_en),
    .dout(out_dout),
    .empty()
);

endmodule