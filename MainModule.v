`timescale 1ns / 1ps
module MainModule(
    input clk,
	input rst,
    input [3:0] Pin,
	input [5:0] WithDraw_Amount,
	input [4:0] Deposit_Amount,
	input [1:0] Operation,
	output reg[7:0] FinalBalance, CB,// الاستعلام
	input IC , LC ,Ex, goMain	 //InsertCard,LanguageChosen,Exit
    );
reg [3:0] pin_number = 4'b1101;	 //default password
reg [7:0] balance = 8'd50;
reg [3:0] next_state;
reg [3:0] current_state;
reg [1:0] Counter = 2'b00;
reg [1:0] op;
reg	VP= 1'b0,BC= 1'b0, EA =1'b0, GM=1'b0; //ValidPass,BalanceCheck,EnteredAmount, goMain

parameter  IDLE = 4'b0000,
			S1  = 4'b0001,
			S2  = 4'b0010,
			S3  = 4'b0011,
			S4  = 4'b0100,
			S5  = 4'b0101,
			S6  = 4'b0110,
			S7  = 4'b0111,
			S8  = 4'b1000,
			S9  = 4'b1001,
			reset = 4'b1111;	
				
always @( posedge clk or posedge rst)
	begin
		if (rst)
			begin
				current_state <= reset;
			end
		else	current_state <= next_state;
	end
	
//psl assert always(Operation >= 0 && Operation < 4) @(posedge clk);	
//psl assert always(balance >=0) @(posedge clk);
//psl assert never(next_state == S5 && op != 2'b01) @(posedge clk);
//psl assert never(next_state == S8 && current_state == S5 && EA == 0) @(posedge clk);
//psl assert never(next_state == S9 && current_state == S7 && BC == 0) @(posedge clk);
//psl assert never(next_state == S3 && current_state == S2 && VP == 0) @(posedge clk);

		
always@(*)
	begin
		CB = balance;
		case (current_state)
			IDLE:	if(IC) next_state = S1;
					else next_state = IDLE;
	
			S1: if(LC) next_state = S2;
				 else next_state = S1;
			
			S2: 
				begin
					if(Ex)next_state = reset;
					else next_state = S2;
					if(Pin==pin_number) VP = 1'b1;
					else VP = 1'b0;
					if(VP) 
						begin 
						next_state = S3; 				
						end
					else 
						begin
							Counter = Counter + 1'b1;
							next_state = S2; //added to be checked
							if(Counter == 2'b11)
								next_state = reset;
						end
				end
			S3:					    
				begin
					#1;
					op = Operation; //in verfication force user to exit as we dont have time
					if(op == 2'b00) next_state = S4;
					else if(op == 2'b01) next_state = S5;
					else if(op == 2'b10) next_state = S6;
					else next_state = reset;
				end
				
			S4:
				begin
					if(goMain)next_state = S3;
					else 
					begin
						if(WithDraw_Amount > 0) EA = 1'b1; 
						else EA = 1'b0;
						if(EA) next_state = S7;
						else next_state = S4;
					end 
				end
			
			S5:
				begin
					if(Deposit_Amount > 0) EA = 1'b1; 
					else EA = 1'b0;
					if(EA)next_state = S8;
					else next_state = S5;
				end
				
			S6:
				begin
					FinalBalance = balance;
					next_state = S3;
				end
			S7:
				begin
					if(WithDraw_Amount <= balance) BC = 1'b1;
					else BC = 1'b0;
					if(BC) next_state = S9;
					else next_state = S4;
				end
			S8: 
				begin
					balance = balance + Deposit_Amount;
					next_state = S3;
				end
			S9:
				begin
					balance = balance - WithDraw_Amount;
					next_state = S3; //TO BE SET TO S3
				end
			reset:
				begin
					next_state = IDLE;
					VP = 1'b0; BC= 1'b0; EA =1'b0; GM=1'b0;
					Counter = 2'b00;
					balance = 50;
					FinalBalance = 8'b0;
				end
			default:
				begin
					next_state = reset;
					FinalBalance = 8'b0;
				end
		endcase
	end

endmodule
