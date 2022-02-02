module line_buffer_top #(
    parameter WIDTH = 8,//Data bit width
    parameter IMG_WIDTH = 6,//Image width
    parameter LINE_NUM = 3//The number of rows in the row cache
) (
    input  logic             clock,
    input  logic             reset,
    input  logic             valid_in,//Input data valid signal
    input  logic [WIDTH-1:0] din,//Input image data, the data of a frame from left to right, and then from top to bottom input
    output logic [WIDTH-1:0] dout,//Output data of the last line
    output logic [WIDTH-1:0] dout_r0,//Output data of the first line
    output logic [WIDTH-1:0] dout_r1,//Output data of the second line
    output logic [WIDTH-1:0] dout_r2//Output data of the third line
);

logic  [WIDTH-1:0]line[2:0];//Save each line_ Input data of buffer
logic  valid_in_r[2:0];
logic  valid_out_r[2:0];
logic  [WIDTH-1:0]dout_r[2:0];//Save each line_ Output data of buffer

assign dout_r0 = dout_r[0];
assign dout_r1 = dout_r[1];
assign dout_r2 = dout_r[2];
assign dout = dout_r[2];

genvar i;
generate
    begin:HDL1
    for (i = 0; i < LINE_NUM; i = i + 1)
        begin : buffer_inst
            // line 1
            if(i == 0) begin: MAPO
                always @(*)begin
                    line[i] <= din;
                    valid_in_r[i] <= valid_in;//The first line_ din and valid of FIFO_ In is provided directly from the top level
                end
            end
            // line 2 3 ...
            if(~(i == 0)) begin: MAP1
                always @(*) begin
                	//Place the previous line_ The output of FIFO is connected to the next line_fifo input
                    line[i] <= dout_r[i-1];
                    //Be a line_fifo writes 480 data and raises rd_en, indicating the start of reading data;
                    //valid_out and rd_en synchronization, valid_out is assigned to the next line_fifo's valid_in indicates that it is ready to write
                    valid_in_r[i] <= valid_out_r[i-1];
                end
            end
            
        line_buffer #(WIDTH,IMG_WIDTH)
            line_buffer_inst(
                .reset (reset),
                .clock (clock),
                .in_din (line[i]),
                .out_dout (dout_r[i]),
                .valid_in(valid_in_r[i]),
                .valid_out (valid_out_r[i])
                );
        end
    end
endgenerate

endmodule