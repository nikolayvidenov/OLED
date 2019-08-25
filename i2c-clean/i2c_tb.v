module i2c_tb();

reg [7:0] command;
reg clock = 1;
reg enable;
reg ack = 0;

wire sda;
wire scl;
wire next;
wire trouble;

i2c U_i2c (
.enable (enable),
.clock (clock),
.command (command),
.ack (ack),
.next (next),
.sda (sda),
.scl (scl),
.trouble (trouble)
);


initial begin
	$dumpfile("i2c_tb.vcd");
	$dumpvars;

	com_list[0] = 8'haa;
	com_list[1] = 8'h11;
	com_list[2] = 8'h22;
	command = com_list[0];



	#10 enable = 1;

	#1495 comNum = 2;
	#1500 enable = 1;
	
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


reg dummy_enable = 0;
reg dummy_ack = 0;


always @(posedge clock) begin
	if (next == 1 && dummy_enable == 0) begin
		if (comNum == 0) begin
			enable = 0;
		end else begin
			command = com_list[comNum];
			comNum = comNum - 1;
			ack = 1;
		end
		dummy_enable = 1;
	end else if (next == 0 && dummy_enable == 1) begin
		ack = 0;
		dummy_enable = 0;
	end
end


endmodule
