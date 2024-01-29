// Jason Choi
// ID Register
// TCK: JTAG clock signal
// TDI: JTAG input signal
// TDO: JTAG output signal
// In the Capture-DR state, the 32-bit device ID code is loaded into this shift section.
// In the Shift-DR state, this data is shifted out, least significant bit first.
// Nothing happens at the Update-DR state. The shifted-in data is ignored.

`include "idr_if.vh"

module idr(
    input TCK,
    input TRST,
    idr_if.IDR idrif
);

    logic [3:0] ver;
    logic [15:0] part;
    logic [10:0] id;
    logic [31:0] code;
    logic [31:0] next_code;

    assign ver = 4'b0001;
    assign part = 16'b0000000000000001;
    assign id = 11'b00000000001;
    assign idrif.TDO = code[0];

    always_comb begin : idr_comb
        next_code = code;
        if (idrif.CaptureDR && idrif.idr_select) begin
            next_code[31:28] = ver;
            next_code[27:12] = part;
            next_code[11:1] = id;
            next_code[0] = 1'b1;
        end
        else if(idrif.ShiftDR && idrif.idr_select) begin
            next_code = {idrif.TDI, code[31:1]}; // LSB shift first
        end
        else if(idrif.tlr_reset)
            next_code = {ver, part, id, 1'b1};
    end

    always_ff @ (posedge TCK, negedge TRST) begin : idr_ff
        if (TRST == 1'b0) begin
            code <= {ver, part, id, 1'b1};
        end
        
        else begin
            code <= next_code;
        end
    end

endmodule