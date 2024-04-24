//Developed by Xianmeng Zhang
//Nov 17 2019
//reference: http://verilogcodes.blogspot.com/2017/10/4-bit-binary-to-gray-code-and-gray-code.html

module flex_bin2gray
#(
	parameter bin2gray = 1, // set to 0 for gray2bin
	parameter width = 4
)
(
	input logic [width-1:0] Input, //binary input
	output logic [width-1:0] Output //gray code output
);

int i;

always_comb
begin
	//Output[width-1] = Input[width-1];
	Output = Input;
	if(bin2gray)
	  begin
		for(i=0;i<width-1;i++)
			Output[i] = Input[i+1] ^ Input[i];
	  end
	else
	  begin
		for(i=width-2;i>=0;i--)
			Output[i] = Output[i+1] ^ Input[i];
	  end
end

endmodule