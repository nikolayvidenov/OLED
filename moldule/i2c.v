module i2c (
	enable,
	clock,
	command,
	next,
	ack,
	sda,
	scl,
	trouble
); // End of port list

//-------------Input Ports-----------------------------

input clock ;
input enable;
input ack;
input [7:0] command;

wire clock ;
wire enable;
wire ack;
wire [7:0] command;

wire [8:0] word;
assign word = (command << 1);
//-------------Output Ports----------------------------

output next;
output sda;
output scl;
output trouble;

reg next;
reg sda;
reg scl;
reg fin;
reg trouble;

//------------- Internal stuff ----------------------------

reg start;
reg send_data ;
reg [3:0] index ;
reg [1:0] phase ;
reg [1:0] phase2 ;

initial begin
	scl = 1;
	sda = 1;
	next = 0;
	fin = 0;
	start = 0;
	send_data = 0;
	phase = 0;
	phase2 = 0;
	index = 0;
	trouble = 0;
end

	

reg dummy = 0;
always @(posedge clock) begin
	if (enable == 1 && dummy ==0) begin
		start = 1;
		next = 0;
		dummy = 1;
	end else if (start ==1) begin
		if (phase2 == 2'b00) begin
			sda = 1;
			scl = 1;
			phase2 = phase2 + 1;
		end else if (phase2 == 2'b01) begin
			sda = 0;
			phase2 = phase2 + 1;
		end else if (phase2 == 2'b10) begin
			scl = 0;
			phase2 = phase2 + 1;
		end else if (phase2 == 2'b11) begin
			start = 0;
			send_data = 1;
			phase2 = phase2 + 1;
		end
	end else if (send_data == 1) begin
		if (phase == 2'b00) begin
			scl = 0;
			phase = phase + 1;
		end else if (phase == 2'b01) begin
			sda = word[8-index];
			phase = phase + 1;
			index = index + 1;
		end else if (phase == 2'b10) begin
			scl = 1;
			phase = phase + 1;
		end else if (phase == 2'b11) begin
			scl = 0;
			phase = phase + 1;
			if (index == 4'b1001) begin
				next = 1;
				index = 0;
				send_data = 0;
			end
		end
	end else if (ack == 1) begin
		send_data = 1;
		next = 0;
	end else if (fin == 1) begin
		if (phase == 2'b00) begin
			sda = 0;
			scl = 0;
			phase = phase + 1;
		end else if (phase == 2'b01) begin
			scl = 1;
			phase = phase + 1;
		end else if (phase == 2'b10) begin
			sda = 1;
			phase = phase + 1;
		end else if (phase == 2'b11) begin
			phase = 0;
			fin = 0;
			dummy = 0;
		end
	end else if (enable == 0 && dummy == 1) begin
		fin = 1;
	end
end

endmodule // End of Module counter
