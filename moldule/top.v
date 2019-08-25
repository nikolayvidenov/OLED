// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    output PIN_24,   
    output PIN_23,  
    output PIN_22,  
    output PIN_21,  
    output USBPU  // USB pull-up resistor
);

	assign USBPU = 0;
    assign PIN_24 = clock;   
    assign PIN_23 = scl;  
    assign PIN_22 = sda;  
    assign PIN_21 = tr;  

	wire clock;
	reg [25:0] clock_count;

	always @(posedge CLK) begin
		clock_count = clock_count + 1;
	end
	assign clock = clock_count[24];
		
	// i2c module stuff here on out
	reg [7:0] command;
	reg enable = 0;
	reg ack;

	reg [7:0] com_list [7:0];
	reg [3:0] comNum;

	wire sda;
	wire scl;
	wire next;
	wire tr;


	initial begin
		com_list[0] <= 8'haa;
		com_list[1] <= 8'h11;
		com_list[2] <= 8'h22;
		ack <= 0;
		comNum <= 2;
		command = 8'h3D;
	end

	reg [2:0] delay = 0;
	reg dummy_enable = 0;
	reg dummy_ack = 0;
	always @(posedge clock) begin

		if (delay < 2'b01) begin
			delay = delay + 1;
		end else if (delay == 2'b01) begin
			delay = delay + 1;
			enable = 1;
		end

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
			
	i2c U_i2c (
	.enable (enable),
	.clock (clock),
	.command (command),
	.ack (ack),
	.next (next),
	.sda (sda),
	.scl (scl),
	.trouble (tr)
	);
	

endmodule
