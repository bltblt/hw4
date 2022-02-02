`timescale 1ns/1ps
`define CLK_PERIOD 10//100MHZ

// module line_buffer_top_tb ();
// logic clock;
// logic [7:0] din;
// logic reset;
// logic valid_in;
// logic [7:0] dout;
// logic [7:0] dout_r0;
// logic [7:0] dout_r1;
// logic [7:0] dout_r2;

// line_buffer_top line_buffer_top_inst(
//     .clock (clock),
//     .din (din),
//     .dout(dout),
//     .dout_r0(dout_r0),
//     .dout_r1(dout_r1),
//     .dout_r2(dout_r2),
//     .reset(reset),
//     .valid_in(valid_in)
// );

module sobel_tb ();
logic clock;
logic [7:0] din;
logic reset;
logic valid_in;
logic read_frame_clken;
logic [7:0] inputpixel;
logic [7:0] outputpixel;
logic [10:0] i, k;

sobel sobel_inst(
    .clock (clock),
    .inputpixel (inputpixel),
    .outputpixel(outputpixel),
    .read_frame_clken(read_frame_clken),
    .reset(reset),
    .valid_in(valid_in)
);


initial begin
    clock = 0;
    reset = 1;
    valid_in = 0;
    read_frame_clken = 1;
    // #(`CLK_PERIOD * 10);
    // reset=0;
    // valid_in = 1;
    #20 reset=0;
    #20 valid_in = 1;
    // repeat(5) begin//Repeat here five times, because at least the first three lines of data can be aligned when the fourth line of data arrives
    //     #(`CLK_PERIOD*20);
    //         valid_in = 1;
    //     #(`CLK_PERIOD*20);
    //         valid_in = 0;
    // end
    for(i=1; i<37; i++)begin
        #0 @(posedge clock)
        inputpixel=i;
      end
    #(`CLK_PERIOD*20);
    $stop;
end

always #(`CLK_PERIOD/2) clock = ~clock;

/*
    Here, din will return 0 after 0-479, and return from 0-479 again;
    Therefore, each row of data is simulated from 0 to 479, so when the three rows of data are aligned during simulation, their data will be the same.

    If the input din is the real image data, because each row of the image data in a frame is different, the data of the three rows after alignment is also different.
*/
// always @ (posedge clock)begin
//     if(reset)
//         inputpixel <= 0;
//     else if(inputpixel == 36)
//         inputpixel <= 0;
//     else if (valid_in == 1'b1)
//         inputpixel <= inputpixel + 1'b1;
// end



endmodule