module i2c_tb();

reg [7:0] command;
reg clock = 1;
reg enable;
reg ack = 0;

wire sda;
wire scl;
wire next;

i2c U_i2c (
.enable (enable),
.clock (clock),
.command (command),
.ack (ack),
.next (next),
.sda (sda),
.scl (scl)
);


initial begin
	$dumpfile("i2c_tb.vcd");
	$dumpvars;

	com_list[0] = 8'haa;
	com_list[1] = 8'h11;
	com_list[2] = 8'h22;


	#5 command = 8'haa;
	#10 enable = 1;
	
	#1300 f = 1;
	#5 command = 8'h01;
	#5 comNum = 1;
	#0 enable = 1;
	
	#4000 $dumpoff;
	#4000 $finish;      // Terminate simulation
end

reg f;

always begin
	#5 clock = ~clock; // Toggle clock every 5 ticks
end

reg [7:0] com_list [4:0];
reg [3:0] comNum = 2;
reg [1:0] count = 0;

always @(posedge next) begin
	if (comNum == 0) begin
		enable = 0;
	end else begin
		command = com_list[comNum];
		comNum = comNum - 1;
		#5 ack = 1;
	end
end 

always @(negedge next) begin
	#5 ack = 0;
end

endmodule
