`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:01:53 12/14/2022
// Design Name:   MainModule
// Module Name:   D:/Ain Shams University/Junior/Electronic Design Automation/Project/V2.0/EDA1.0/ATM_tb.v
// Project Name:  EDA1.0
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MainModule
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ATM_tb();

	// Inputs
	reg clk;
	reg rst;
	reg [3:0] Pin;
	reg [5:0] WithDraw_Amount;
	reg [4:0] Deposit_Amount;
	reg [1:0] Operation;
	reg IC;
	reg LC;
	reg Ex;
	integer numofoperations;
	reg goMain;
	integer j, decision, ran;
	// Outputs
	wire [7:0] FinalBalance, CB
	;

	// Instantiate the Unit Under Test (UUT)
	MainModule uut (
		.clk(clk), 
		.rst(rst), 
		.Pin(Pin), 
		.WithDraw_Amount(WithDraw_Amount), 
		.Deposit_Amount(Deposit_Amount), 
		.Operation(Operation), 
		.FinalBalance(FinalBalance),
		.CB(CB),
		.IC(IC), 
		.LC(LC), 
		.Ex(Ex),
		.goMain(goMain)
	);
	//Clock Generation
	always #12 clk = !clk;
	
	//Assertions
	//else $error("Error, Balance less than zero");
	initial begin
		// Initialize all Inputs by zero
		clk = 0;					//Clock
		rst = 0;					//Reset
		Pin = 0;					//input pin to login
		WithDraw_Amount = 0;		
		Deposit_Amount = 0;
		Operation = 0;				//operation Key: 0 -> withdraw, 1 -> deposit, 2 -> check balance, otherwise -> Exit
		IC = 0;						//To insert card
		LC = 0;						//To choose language 
		Ex = 0;						//To exit
		numofoperations = 0;		//counter for number of operations
		ran = 0;					//varible to hold random numbers
		goMain = 0;					//to return to the main menu and do another operation
		j = 0;						//counter of iterations
		decision=0;					//random number to decide the decision
			
		
		/***
		directed Randomized generator to test almost all possiblites of the desgin
		the flow is customized to not reset the design, although it test all other Statments and braches
		not including reseting or card inserting or language choosen
		
		each iterations is like one client doing a randomized number of operations
		the last operation is to exit the ATM as default
		***/
		
		
		


		#50 rst = 1;
		#50 rst = 0;
		
		for(j=0;j<1000;j=j+1)
		begin
			#25 IC = 1;				//default IC
			#25 LC = 1;				//default LC
			#25 Pin = 4'b1101;		// 4/30 probability to randomize the pin
			ran = {$random}%30;
			if(ran > 25)
				Pin = {$random}%16;
				
			numofoperations = 1 + {$random}%5;		//varied from 1 to 5
			#2;
			while(numofoperations > 2'b00)			//loop till excuating all the operations
			begin
				if(numofoperations == 1'b1)			//the last operation is to exit as defualt
					#25 Operation = 2'b11;			//exit operation and return to reset
				else
				begin
					#25 Operation = {$random}%3;	//operation from 0 ot 2
					if(Operation == 2'b00)			//if withdraw
					begin
						//first, randomize the withdraw amount
						#25 WithDraw_Amount = {$random}%64;
						
						while(WithDraw_Amount>CB)	//if not valid
						begin
							//randomized range from 0 to 39 to decide to enter another value or to leave
							#50 decision = {$random}%40;
							if(decision < 30)						//	3/4 percent to enter another value
							    #25 WithDraw_Amount = {$random}%64;
							else
							begin
								#25 goMain = 1'b1;					// 1/4 percent to return to the main menu
									WithDraw_Amount = 0;
							    #25 goMain = 1'b0;
							end
						end
					end
					else if(Operation == 2'b01)						// if to deposit
					begin
						 #25 Deposit_Amount = {$random}%32;			// randomize the deposit amount
					end
				end
				
				#25 numofoperations = numofoperations - 3'b001;		//decrement the number of remaining operations
			end
		end
		
				
		$display("first test finished");

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



		//randomize the IC, LC, reseting in different states
		
		
		#1 rst = 1;
		#1 rst = 0;
		
		for(j=0;j<10000;j=j+1)
		begin
			rst = 0;
			ran = {$random}%30;
			#2	IC = {$random}%2;
			#2	if(ran > 20)
					rst = 1;			
			#2	LC = {$random}%2; 
			#2	if(ran > 20)
					rst = 1;
			#2	Pin = 4'b1101;
				if(ran > 10)
					Pin = {$random}%16;
			#2	if(ran > 20)
					rst = 1;
				
			#2	Operation = {$random}%3;
				ran = {$random}%30;
			#2	if(ran > 20)
					rst = 1;
			
			#2	WithDraw_Amount = {$random}%64;
				goMain = {$random}%2;
			    Deposit_Amount = {$random}%32;
				ran = {$random}%30;
				#2	if(ran > 20)
					rst = 1;
				
			#2	Operation = 2'b01;
				ran = {$random}%30;
			#2	if(ran > 20)
					rst = 1;
			   
		end
		
		
		$display("Second test finished");
		
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		//Randomized test to suffle high range of state changes in the same cycle to increase coverage
		
		#1 rst = 1;
		#1 rst = 0;
		
		for(j=0;j<10000;j=j+1)
		begin
			rst = 0;
			ran = {$random}%30;
			IC = {$random}%2; 
			LC = {$random}%2; 
			Ex = {$random}%2; 
			Pin = 4'b1101;
			if(ran > 10)
				Pin = {$random}%16;
			Operation = {$random}%3;
			WithDraw_Amount = {$random}%64;
			goMain = {$random}%2;
			Deposit_Amount = {$random}%32;
			
			#2	Operation = 2'b11;
			   
		end

		$display("Third test finished");


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		//directed testing

		#50 rst = 1;
		#50 rst = 0;
		
		#50 IC = 1; LC = 1;
		#50 Pin = 4'b1101;
			Operation = 2;
			rst = 1;
			
		#50 rst = 0;
		
		#50 IC = 1; LC = 1;
		#50 Pin = 4'b1101;
			Operation = 2;
		#50	Operation = 3;
		
		
		$display("Last test finished");
		
		$stop;
	end
      
endmodule
