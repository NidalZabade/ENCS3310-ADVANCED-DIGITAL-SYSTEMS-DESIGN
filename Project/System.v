


module Mux4to1(B, Selection	, Out);
	input [3:0]B;
	input [1:0] Selection;
	output Out;
	wire [3:0] f;
	wire [1:0] Selection_Prime;
	not #3ns(Selection_Prime[0],Selection[0]);
	not #3ns(Selection_Prime[1],Selection[1]);
	nand #5ns(f[0], B[0],Selection_Prime[1],Selection_Prime[0]);
	nand #5ns(f[1], B[1],Selection_Prime[1],Selection[0]);
	nand #5ns(f[2], B[2],Selection[1],Selection_Prime[0]);
	nand #5ns(f[3], B[3],Selection[1],Selection[0]);
	nand #5ns(Out,f[0],f[1],f[2],f[3]);
endmodule	



module MuxTest;
	reg [3:0] B_Test;
	reg [1:0] Selection_Test;
	wire Out_Test;
	Mux4to1 Test(B_Test,Selection_Test,Out_Test);
	initial
		begin
			B_Test=4'b0110;
			Selection_Test=0;
			repeat(3)
			#30ns Selection_Test=Selection_Test+1;
		end
endmodule 



module FA(X,Y,Cin,Sum,Cout);
	input X,Y,Cin;
	output Sum,Cout;
	wire w1,w2,w3;
	
	xor #11ns(Sum,X,Y,Cin);
	nand #5ns(w1,X,Y);
	nand #5ns(w2,X,Cin);
	nand #5ns(w3,Y,Cin);	
	nand #5ns(Cout,w1,w2,w3);  
	
endmodule


module FATest;
	reg X_Test,Y_Test,Cin_Test;
	wire Sum_Test,Cout_Test;
	
	FA G(X_Test,Y_Test,Cin_Test,Sum_Test,Cout_Test);
	
	initial
		begin	
			{Y_Test,X_Test,Cin_Test}=0;
			repeat(7)
			begin
			#100ns {Y_Test,X_Test,Cin_Test}={Y_Test,X_Test,Cin_Test}+1;
			#30ns $display("A=%b, B=%b, Cin=%b, D=%b, Cout=%b",X_Test,Y_Test,Cin_Test,Sum_Test,Cout_Test);
			end
		end
endmodule  


module AU(A,B,Cin,S,D,Cout);
	input [3:0] A,B;
	input [1:0] S;
	input Cin;
	output [3:0]D;
	output Cout;
	wire [3:0] B_Prime;
	wire [3:1] C;
	wire [3:0] Mux_Output;
	
	not #3ns(B_Prime[0],B[0]); 
	not #3ns(B_Prime[1],B[1]);
	not #3ns(B_Prime[2],B[2]);
	not #3ns(B_Prime[3],B[3]);
	
	Mux4to1 M1({1'b1,1'b0,B_Prime[0],B[0]},S,Mux_Output[0]);
	Mux4to1 M2({1'b1,1'b0,B_Prime[1],B[1]},S,Mux_Output[1]);
	Mux4to1 M3({1'b1,1'b0,B_Prime[2],B[2]},S,Mux_Output[2]);
	Mux4to1 M4({1'b1,1'b0,B_Prime[3],B[3]},S,Mux_Output[3]);
	
	
	FA F1(A[0],Mux_Output[0],Cin,D[0],C[1]);
	FA F2(A[1],Mux_Output[1],C[1],D[1],C[2]);
	FA F3(A[2],Mux_Output[2],C[2],D[2],C[3]);
	FA F4(A[3],Mux_Output[3],C[3],D[3],Cout);
	
	
endmodule





module Generator(CLK,A,B,Cin,S,Ans);
	input CLK;
	output reg [3:0] A,B;
	output reg Cin;
	output reg [1:0] S;
	output reg [4:0]Ans;
	integer counter=0;
	integer E=1;
	always @(posedge CLK)
		if (E)
			begin
				{S,Cin,A,B}=counter;
				counter=counter+1;
				case ({S,Cin})
					0: Ans=A+B;
					1: Ans=A+B+1'b1;
					2: Ans=A+{1'b0,~B};
					3: Ans=A+{1'b0,~B}+1'b1;
					4: Ans=A;
					5: Ans=A+1'b1;
					6: Ans=A+4'b1111;
					7: Ans={1'b1,A};
				endcase
				if(counter==2**11)
					E=0;
			end
	
endmodule

	

module Analayzer(CLK,A,B,Mode,AUAns,GenAns);
	input CLK;
	input [3:0] A,B;
	input [2:0] Mode;
	input [4:0] AUAns, GenAns;
	always @(negedge CLK)
		if(AUAns[4:0] != GenAns[4:0])
			$display ("A=%b, B=%b, Mode=%b, AUAns=%b, GenAns=%b",A,B,Mode,AUAns,GenAns);
endmodule

	


module Stage1_Test;
	reg CLK=0;
	reg [3:0] A,B;
	reg Cin;
	reg [1:0] S;
	reg [4:0] Ans;
	wire [3:0]Sum;
	wire Cout;
	Generator G(CLK,A,B,Cin,S,Ans);
	AU Au(A,B,Cin,S,Sum,Cout);
	Analayzer Anz(CLK,A,B,{S,Cin},{Cout,Sum},Ans);
	always
		begin
		#100ns CLK=~CLK;
		end
	initial #1000us $finish;
endmodule
			

module CLA(X,Y,Cin,Sum,Cout);
	input [3:0]X,Y;
	input Cin;
	output [3:0] Sum;
	output Cout;
	wire [3:1]C;
	wire [0:3]P;
	wire [0:3]G;
	wire [0:3]G_Prime;
	wire [10:1]Temp;
	
	not #3ns(G_Prime[0],G[0]); 
	not #3ns(G_Prime[1],G[1]);
	not #3ns(G_Prime[2],G[2]);
	not #3ns(G_Prime[3],G[3]);
	
	xor #11ns(P[0],X[0],Y[0]); 
	xor #11ns(P[1],X[1],Y[1]);
	xor #11ns(P[2],X[2],Y[2]);
	xor #11ns(P[3],X[3],Y[3]);
	
	and #7ns(G[0],X[0],Y[0]); 
	and #7ns(G[1],X[1],Y[1]);
	and #7ns(G[2],X[2],Y[2]);
	and #7ns(G[3],X[3],Y[3]);
	
	nand #5ns(Temp[1],P[0],Cin);
	nand #5ns(C[1],G_Prime[0],Temp[1]);
	
	nand #5ns(Temp[2] , P[1] , G[0]);
  	nand #5ns(Temp[3] , P[1] , P[0] , Cin);
  	nand #5ns(C[2] , Temp[2] , Temp[3] , G_Prime[1]); 
	  
	nand #5ns(Temp[4] , P[2] , G[1]);
  	nand #5ns(Temp[5] , P[2] , P[1] , G[0]);
	nand #5ns(Temp[6] , P[2] , P[1] , P[0],  Cin);
  	nand #5ns(C[3] , Temp[4] , Temp[5] , Temp[6] , G_Prime[2]);
	 
	nand #5ns(Temp[7] , P[3] , G[2]);
  	nand #5ns(Temp[8] , P[3] , P[2] , G[1]);
	nand #5ns(Temp[9] , P[3] , P[2] , P[1],  G[0]);
	nand #5ns(Temp[10] , P[3] , P[2] , P[1],  P[0],Cin);
  	nand #5ns(Cout , Temp[7] , Temp[8] , Temp[9] , Temp[10] , G_Prime[3]);
	  
	xor #11ns(Sum[0] , P[0] , Cin);
    xor #11ns(Sum[1] , P[1] , C[1]);
    xor #11ns(Sum[2] , P[2] , C[2]);
    xor #11ns(Sum[3] , P[3] , C[3]);
endmodule
	  


module AU2(A,B,Cin,S,D,Cout);
	input [3:0] A,B;
	input [1:0] S;
	input Cin;
	output [3:0]D;
	output Cout;
	wire [3:0] B_Prime;
	wire [3:1] C;
	wire [3:0] Mux_Output;
	
	not #3ns(B_Prime[0],B[0]); 
	not #3ns(B_Prime[1],B[1]);
	not #3ns(B_Prime[2],B[2]);
	not #3ns(B_Prime[3],B[3]);
	
	Mux4to1 M1({1'b1,1'b0,B_Prime[0],B[0]},S,Mux_Output[0]);
	Mux4to1 M2({1'b1,1'b0,B_Prime[1],B[1]},S,Mux_Output[1]);
	Mux4to1 M3({1'b1,1'b0,B_Prime[2],B[2]},S,Mux_Output[2]);
	Mux4to1 M4({1'b1,1'b0,B_Prime[3],B[3]},S,Mux_Output[3]);
	
	
	CLA CLA1(A,Mux_Output,Cin,D,Cout);
	
	
endmodule


	

module Stage2_Test;
	reg CLK=0;
	reg [3:0] A,B;
	reg Cin;
	reg [1:0] S;
	reg [4:0] Ans;
	wire [3:0]Sum;
	wire Cout;
	Generator G(CLK,A,B,Cin,S,Ans);
	AU2 Au2(A,B,Cin,S,Sum,Cout);
	Analayzer Anz(CLK,A,B,{S,Cin},{Cout,Sum},Ans);
	always
		begin
		#100ns CLK=~CLK;
		end
	initial #1000us $finish;
endmodule
	
	
