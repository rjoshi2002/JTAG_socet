// ID Register
// TCK: JTAG clock signal
// TDI: JTAG input signal
// TDO: JTAG output signal
// In the Capture-DR state, the 32-bit device ID code is loaded into this shift section.
// In the Shift-DR state, this data is shifted out, least significant bit first.
// Nothing happens at the Update-DR state. The shifted-in data is ignored.

`include "idr_if.vh"

module idr(
    input logic TCK,
    // output logic [31:0] code,
    idr_if.IDR idrif
);

    logic [3:0] ver;
    logic [15:0] part;
    logic [10:0] id;
    // logic [31:0] code;
    logic [31:0] next_code;

    ver = 4'b0001;
    part = 16'b0000000000000001;
    id = 11'b00000000001;

    always_comb begin : idr_comb
        next_code = code;

        // if (bprif.ShiftDR) begin
        //     next_TDI = 1'b0
        // end
        if (bprif.CaptureDR) begin
            next_code[31:28] = ver;
            next_code[27:12] = part;
            next_code[11:1] = id;
            next_code[0] = 1'b1;
        end
    end

    always_ff @ (posedge TCK, negedge TRST) begin : idr_ff
        if(TRST == 1'b0) begin
            idrif.code <= 32'b0;
        end
        
        else begin
            idrif.code <= next_code;
        end
    end


endmodule