
module SimpleCPU(clk, rst, data_fromRAM, wrEn, addr_toRAM, data_toRAM);

parameter SIZE = 10;

input clk, rst;
input wire [31:0] data_fromRAM;
output reg wrEn;
output reg [SIZE-1:0] addr_toRAM;
output reg [31:0] data_toRAM;

//////////////////////////
// write your design here
reg [6:0] state_current, state_next;
reg [SIZE-1:0] pc_current, pc_next; //program counter
reg [31:0] iw_current, iw_next; //instruction word
reg [31:0] r1_current, r1_next;
reg [31:0] r2_current, r2_next;

//controller state machine
always@(posedge clk) begin
	if(rst) begin
		state_current <= 0;
		pc_current <= 10'b0;
		iw_current <= 32'b0;
		r1_current <= 32'b0;
		r2_current <= 32'b0;
	end		
	else begin
		state_current <= state_next;
		pc_current <= pc_next;
		iw_current <= iw_next;
		r1_current <= r1_next;
		r2_current <= r2_next;
	end
end

always@(*) begin
	state_next						 = state_current;
	pc_next							 = pc_current;
	iw_next							 = iw_current;
	r1_next							 = r1_current;
	r2_next							 = r2_current;
	wrEn								 = 0;
	addr_toRAM						 = 0;
	data_toRAM						 = 0;
	case(state_current)
		0: begin
			pc_next					 = 0;
			iw_next					 = 0;
			r1_next					 = 0;
			r2_next					 = 0;
			state_next				 = 1;
		end
		1: begin //inst reading
			addr_toRAM				 = pc_current;
			state_next			 	 = 2;
		end
		2: begin //inst decoding and sending the addr of the first operand
			iw_next = data_fromRAM;
			case (data_fromRAM[31:28])
				{3'b000, 1'b0}: begin//ADD
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
				
				{3'b000, 1'b1}: begin//ADDi
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
				
				{3'b001, 1'b0}: begin//NAND
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
				
				{3'b001, 1'b1}: begin//NANDi
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
				
				{3'b011, 1'b0}: begin//LT
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
				
				
				{3'b011, 1'b1}: begin//LTi
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
	
				{3'b010, 1'b0}: begin//SRL
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
				{3'b010, 1'b1}: begin//SRLi
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
				{3'b100, 1'b0}: begin//CP
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
				{3'b100, 1'b1}: begin//CPi
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
////////////////////////////////////////////////////////////////////				
				{3'b101, 1'b0}: begin//CPI
					addr_toRAM		 = data_fromRAM[13:0];
					state_next		 = 5;
				end
				
				{3'b101, 1'b1}: begin//CPIi
					addr_toRAM		 = data_fromRAM[13:0];
					state_next		 = 6;
				end
////////////////////////////////////////////////////////////////////				
				
				{3'b110, 1'b0}: begin//BZJ
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end	
				{3'b110, 1'b1}: begin//BZJi skips to state 4 no need to read b
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
				
				{3'b111, 1'b0}: begin//MUL
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
				{3'b111, 1'b1}: begin//MULi
					addr_toRAM		 = data_fromRAM[27:14];
					state_next		 = 3;
				end
				
								
				default: begin
					pc_next 			 = pc_current + 1'b1;
					state_next		 = 1;
				end
			endcase
		end
		3: begin //storing the first operand and reading the second operand
			addr_toRAM				 = iw_current[13:0];
			r1_next					 = data_fromRAM;
			state_next				 = 4;
		end

		4: begin //execution of the operation and storing its result
			case(iw_current[31:28])
				{3'b000, 1'b0}: begin//ADD
					wrEn				 = 1;
					data_toRAM		 = data_fromRAM + r1_current;
					addr_toRAM		 = iw_current[27:14];
					pc_next			 = pc_current + 1;
					state_next		 = 1; 
				end
				{3'b000, 1'b1}: begin//ADDi
					wrEn				 = 1;
					data_toRAM		 = iw_current[13:0] + r1_current;
					addr_toRAM		 = iw_current[27:14];
					pc_next			 = pc_current + 1;
					state_next		 = 1;
				end
				{3'b001, 1'b0}: begin//NAND
					wrEn				 = 1;
					data_toRAM		 = ~(data_fromRAM & r1_current);
					addr_toRAM		 = iw_current[27:14];
					pc_next			 = pc_current + 1;
					state_next		 = 1;
				end
				
				{3'b001, 1'b1}: begin//NANDi
					wrEn				 = 1;
					data_toRAM		 = ~(iw_current[13:0] & r1_current);
					addr_toRAM		 = iw_current[27:14];
					pc_next			 = pc_current + 1;
					state_next		 = 1;
				end
				
				{3'b010, 1'b0}: begin//SRL
					wrEn				 = 1;
					if( data_fromRAM < 32  )begin
						data_toRAM		 = data_fromRAM >> 1;
						addr_toRAM		 = iw_current[27:14];
						pc_next			 = pc_current + 1;
						state_next		 = 1;
					end
					else begin
						data_toRAM		 = data_fromRAM << 1;
						addr_toRAM		 = iw_current[27:14];
						pc_next			 = pc_current + 1;
						state_next		 = 1;
					end	
				end
				
				{3'b010, 1'b1}: begin//SRLi
					wrEn				 = 1;
					if( iw_current[13:0] < 32  )begin
						data_toRAM		 = iw_current[13:0] >> 1;
						addr_toRAM		 = iw_current[27:14];
						pc_next			 = pc_current + 1;
						state_next		 = 1;
					end
					else begin
						data_toRAM		 = iw_current[13:0] << 1;
						addr_toRAM		 = iw_current[27:14];
						pc_next			 = pc_current + 1;
						state_next		 = 1;
					end	
				end
				
				
				{3'b011, 1'b0}: begin//LT
					wrEn				 = 1;
					if( r1_current < data_fromRAM )begin
						data_toRAM		 = 1;
						addr_toRAM		 = iw_current[27:14];
						pc_next			 = pc_current + 1;
						state_next		 = 1;
					end
					else begin
						data_toRAM		 = 0;
						addr_toRAM		 = iw_current[27:14];
						pc_next			 = pc_current + 1;
						state_next		 = 1;
					end	
				end
				
				
				{3'b011, 1'b1}: begin//LTi
					wrEn				 = 1;
					if( r1_current < iw_current[13:0] )begin
						data_toRAM		 = 1;
						addr_toRAM		 = iw_current[27:14];
						pc_next			 = pc_current + 1;
						state_next		 = 1;
					end
					else begin
						data_toRAM		 = 0;
						addr_toRAM		 = iw_current[27:14];
						pc_next			 = pc_current + 1;
						state_next		 = 1;
					end	
				end
				
				
				{3'b100, 1'b0}: begin//CP
					wrEn				 = 1;
					data_toRAM		 = data_fromRAM;
					addr_toRAM		 = iw_current[27:14];
					pc_next			 = pc_current + 1;
					state_next		 = 1;
				end
				
				{3'b100, 1'b1}: begin//CPi
					wrEn				 = 1;
					data_toRAM		 = iw_current[13:0];
					addr_toRAM		 = iw_current[27:14];
					pc_next			 = pc_current + 1;
					state_next		 = 1;
				end
				
				{3'b101, 1'b0}: begin//CPI
					wrEn				 = 1;
					data_toRAM		 = data_fromRAM;
					addr_toRAM		 = iw_current[27:14];
					pc_next			 = pc_current + 1;
					state_next		 = 1;
				end
////////////////////////////////////////////////////////////////////				
				
				{3'b101, 1'b1}: begin//CPIi				
					wrEn				 = 1;
					data_toRAM		 = r2_current;
					addr_toRAM		 = data_fromRAM;
					pc_next			 = pc_current + 1;
					state_next		 = 1;
				end
////////////////////////////////////////////////////////////////////				
				
				
				{3'b110, 1'b0}: begin//BZJ
					//wrEn				 = 1;
					if	(	data_fromRAM == 0	)	begin
						pc_next = r1_current;
						state_next		 = 1;
					end
					else begin 
						pc_next			 = pc_current + 1;
						state_next		 = 1;				
					end
				end

				{3'b110, 1'b1}: begin//BZJi no need to b and implement state 3 so i can use A register directly
					//wrEn				 = 1;
					pc_next = r1_current;
					state_next		 = 1;

				end
				
				{3'b111, 1'b0}: begin//MUL
					wrEn				 = 1;
					data_toRAM		 = data_fromRAM * r1_current;
					addr_toRAM		 = iw_current[27:14];
					pc_next			 = pc_current + 1;
					state_next		 = 1;
				end
				
				{3'b111, 1'b1}: begin//MULi
					wrEn				 = 1;
					data_toRAM		 = iw_current[13:0] * r1_current;
					addr_toRAM		 = iw_current[27:14];
					pc_next			 = pc_current + 1;
					state_next		 = 1;
				end
				
				
				
				
			endcase//iw case	
		end//4.state

			5:begin//state for CPI
				addr_toRAM				 = data_fromRAM;
				state_next				 = 4;	
			end
////////////////////////////////////////////////////////////////////				
			
			6:begin//state for CPIi		

				addr_toRAM				 = iw_current[27:14];
				r2_next					 = data_fromRAM;
				state_next				 = 4;
			end
			
			7:begin//following state for CPIi 
				addr_toRAM				 = data_fromRAM;
				state_next				 = 4;
			
			end
////////////////////////////////////////////////////////////////////				
				
			
		
	endcase//stateCase
end//always
//////////////////////////

endmodule

module blram(clk, rst, i_we, i_addr, i_ram_data_in, o_ram_data_out);

parameter SIZE = 10, DEPTH = 1024;

input clk;
input rst;
input i_we;
input [SIZE-1:0] i_addr;
input [31:0] i_ram_data_in;
output reg [31:0] o_ram_data_out;

reg [31:0] memory[0:DEPTH-1];

always @(posedge clk) begin
  o_ram_data_out <= #1 memory[i_addr[SIZE-1:0]];
  if (i_we)
		memory[i_addr[SIZE-1:0]] <= #1 i_ram_data_in;
end 

initial begin
//////////////////////////
// write BRAM content here
//memory[0] = 32'hc8033;
//memory[50] = 32'h5;
//memory[51] = 32'h3;
memory[0] = 32'h20114045;
memory[1] = 32'h10114001;
memory[2] = 32'hb0118064;
memory[3] = 32'h190045;
memory[4] = 32'h8011c064;
memory[5] = 32'h7011c001;
memory[6] = 32'h10118001;
memory[7] = 32'hc0120047;
memory[8] = 32'h118045;
memory[9] = 32'ha0128046;
memory[10] = 32'h8012c046;
memory[11] = 32'h12c045;
memory[12] = 32'ha013004b;
memory[13] = 32'he013004a;
memory[14] = 32'h8012804c;
memory[15] = 32'h8013404b;
memory[16] = 32'h701343e9;
memory[17] = 32'hc012404d;
memory[18] = 32'h8019404c;
memory[19] = 32'hd0050013;
memory[20] = 32'h0;
memory[69] = 32'h1;
memory[70] = 32'h3e8;
memory[72] = 32'h2;
memory[73] = 32'hb;
memory[100] = 32'h6;
memory[101] = 32'h0;
memory[999] = 32'h1;
//////////////////////////
end

endmodule
