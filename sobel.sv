module sobel  #(
    parameter WIDTH = 8,
    parameter IMG_WIDTH = 6
) (
    input  logic             clock,
    input  logic             reset,
    input  logic             valid_in,
    input  logic             read_frame_clken,
    input  logic [WIDTH-1:0] inputpixel,
    output logic [WIDTH-1:0] outputpixel
);

logic [WIDTH-1:0] dout_r0;
logic [WIDTH-1:0] dout_r1;
logic [WIDTH-1:0] dout_r2;
logic read_frame_href;
logic [9:0] g, gx, gy;

line_buffer_top line_buffer_top_inst(
    .clock (clock),
    .din (inputpixel),
    .dout(),
    .dout_r0(dout_r0),
    .dout_r1(dout_r1),
    .dout_r2(dout_r2),
    .reset(reset),
    .valid_in(valid_in)
);


logic [WIDTH-1:0]  matrix_p11, matrix_p12, matrix_p13;
logic [WIDTH-1:0]  matrix_p21, matrix_p22, matrix_p23;
logic [WIDTH-1:0]  matrix_p31, matrix_p32, matrix_p33;
logic [9:0] cnt,cnt_y;
logic g_enable;
logic [9:0] gx1, gx2, gy1, gy2;
logic enable;

always_ff @(posedge clock) begin
    if (~(dout_r2 == 0))
        read_frame_href = 1;
    else
        read_frame_href = 0;
end


always_ff @(posedge clock) begin
    if(reset) begin
        // cnt <= 0;
        {matrix_p11, matrix_p12, matrix_p13} <= 24'h0;
        {matrix_p21, matrix_p22, matrix_p23} <= 24'h0;
        {matrix_p31, matrix_p32, matrix_p33} <= 24'h0;
    end
    else if (read_frame_href)
        begin
            if(read_frame_clken)
            begin
                {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p12, matrix_p13, dout_r0};
                {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p22, matrix_p23, dout_r1};
                {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p32, matrix_p33, dout_r2};
                // cnt <= cnt + 1;
            end
            else
            begin
                {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p11, matrix_p12, matrix_p13};
                {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p21, matrix_p22, matrix_p23};
                {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p31, matrix_p32, matrix_p33};
                // cnt <= cnt;
            end
        end
    else
    begin
        {matrix_p11, matrix_p12, matrix_p13} <= 24'h0;
        {matrix_p21, matrix_p22, matrix_p23} <= 24'h0;
        {matrix_p31, matrix_p32, matrix_p33} <= 24'h0;
        // cnt <= 0;
    end
end

always_ff @(posedge clock) begin
    if (matrix_p13!= 0)
        enable = 1;
    else
        enable = 0;
end

always_ff @(posedge clock) begin
    if(reset) begin
        cnt <= 0;
        cnt_y <= 0;
    end
    else if (read_frame_href && enable == 1)
        begin   
            if (cnt == IMG_WIDTH) begin
                cnt <= 1;
                cnt_y <= cnt_y + 1;
            end
            else
            begin
                cnt <= cnt + 1;
            end
        end
    else
    begin
        cnt <= 0;
    end
end

always_ff @(posedge clock) begin
    // if(reset) begin
    //     gx1 <= 0;
    //     gx2 <= 0;
    //     gy1 <= 0;
    //     gy2 <= 0;
    // end
    // else         
    if (cnt % IMG_WIDTH == (IMG_WIDTH-1) || cnt % IMG_WIDTH == 0 || cnt_y >= IMG_WIDTH -2 )begin
        gx1 <= 0;
        gx2 <= 0;
        gy1 <= 0;
        gy2 <= 0;
    end
    else begin
        gx1 <= (matrix_p33 + 2*matrix_p23 + matrix_p13);//+
        gx2 <= (matrix_p31 + 2*matrix_p21 + matrix_p11);//-
        gy1 <= (matrix_p11 + 2*matrix_p12 + matrix_p13);//+
        gy2 <= (matrix_p31 + 2*matrix_p32 + matrix_p33);//-
    end
end


always_comb begin
    if (gx1 > gx2) gx <= gx1-gx2;
        else gx <= gx2 - gx1;
    if (gy1 > gy2) gy <= gy1-gy2;
        else gy <= gy2-gy1;
end
   
always_comb g <= gy+gx; 
   



endmodule