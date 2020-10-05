module alu #(
    parameter INT_W  = 3,
    parameter FRAC_W = 5,
    parameter INST_W = 3,
    parameter DATA_W = INT_W + FRAC_W
)(
    input                   i_clk,
    input                   i_rst_n,
    input                   i_valid,
    input signed [ DATA_W-1 : 0 ] i_data_a,
    input signed [ DATA_W-1 : 0 ] i_data_b,
    input  [ INST_W-1 : 0 ] i_inst,
    output                  o_valid,
    output [ DATA_W-1 : 0 ] o_data,
    output                  o_overflow
);

// operations
localparam OP_ADD  = 3'b000;
localparam OP_SUB  = 3'b001;
localparam OP_MUL  = 3'b010;
localparam OP_OR   = 3'b011;
localparam OP_XOR  = 3'b100;
localparam OP_RELU = 3'b101;
localparam OP_MEAN = 3'b110;
localparam OP_MIN  = 3'b111;
    
// ---------------------------------------------------------------------------
// Wires and Registers
// ---------------------------------------------------------------------------
reg  [  DATA_W-1:0] o_data_w, o_data_r;
reg                 o_valid_w, o_valid_r;
reg                 o_overflow_w, o_overflow_r;
// ---- Add your own wires and registers here if needed ---- //

wire [  DATA_W  :0] add_result;
wire [  DATA_W  :0] sub_result;
wire [2*DATA_W-1:0] mul_result_temp;
wire [2*INST_W+FRAC_W-1:0] mul_result;
wire [  DATA_W-1:0] or_result;
wire [  DATA_W-1:0] xor_result;
wire [  DATA_W-1:0] relu_result;
wire [  DATA_W-1:0] mean_result;
wire [  DATA_W-1:0] min_result;

wire                add_overflow;
wire                sub_overflow;
wire                mul_overflow;

wire                mul_carryin;
wire                mean_carryin;


// ---------------------------------------------------------------------------
// Continuous Assignment
// ---------------------------------------------------------------------------
assign o_valid = o_valid_r;
assign o_data = o_data_r;
assign o_overflow = o_overflow_r;
// ---- Add your own wire data assignments here if needed ---- //

assign add_result = {i_data_a[DATA_W-1], i_data_a} + {i_data_b[DATA_W-1], i_data_b};
assign add_overflow = add_result[DATA_W] ^ add_result[DATA_W-1];

assign sub_result = {i_data_a[DATA_W-1], i_data_a} - {i_data_b[DATA_W-1], i_data_b};
assign sub_overflow = sub_result[DATA_W] ^ sub_result[DATA_W-1];

assign mul_result_temp = {{DATA_W{i_data_a[DATA_W-1]}}, i_data_a} * {{DATA_W{i_data_b[DATA_W-1]}}, i_data_b};
assign mul_carryin  = mul_result_temp[FRAC_W-1];
assign mul_result = mul_result_temp[2*DATA_W-1:FRAC_W] + {{(2*INST_W+FRAC_W-1)'b0}, mul_carryin};
assign mul_overflow = ~( ~|mul_result[2*DATA_W-1:2*DATA_W-INT_W-1] | &mul_result[2*DATA_W-1:2*DATA_W-INT_W-1] );

assign or_result    = i_data_a | i_data_b;

assign xor_result   = i_data_a ^ i_data_b;

assign relu_result  = i_data_a[DATA_W-1] ? DATA_W'b0 : i_data_a;

assign mean_result  = add_result[DATA_W:1];
assign mean_carryin = add_result[0];

assign min_result   = (i_data_a < i_data_b) ? i_data_a : i_data_b;


// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
// ---- Write your conbinational block design here ---- //
always@(*) begin
    case (i_inst)
        OP_ADD: begin
            o_data_w = add_result[DATA_W-1:0];
            o_overflow_w = add_overflow;
            o_valid_w = 1'b1;
        end
        OP_SUB: begin
            o_data_w = sub_result[DATA_W-1:0];
            o_overflow_w = sub_overflow;
            o_valid_w = 1'b1;
        end
        OP_MUL: begin
            // o_data_w = mul_result[INT_W + 2*FRAC_W - 1: FRAC_W];
            o_overflow_w = ;
            o_valid_w = 1'b1;
        end
        OP_OR: begin
            
        end
        OP_XOR: begin
            
        end
        OP_RELU: begin
            
        end
        OP_MEAN: begin
            
        end
        OP_MIN: begin
            
        end
    endcase
end




// ---------------------------------------------------------------------------
// Sequential Block
// ---------------------------------------------------------------------------
// ---- Write your sequential block design here ---- //
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_data_r <= 0;
        o_overflow_r <= 0;
        o_valid_r <= 0;
    end else begin
        o_data_r <= o_data_w;
        o_overflow_r <= o_overflow_w;
        o_valid_r <= o_valid_w;
    end
end




endmodule
