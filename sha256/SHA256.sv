// Code your design here
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  SHA256
//////////////////////////////////////////////////////////////////////////////////
module SHA256(
clk,
rst_n,
valid_in,
valid_out,
message,
Hash_result);


//////////////////////////////////////////////////////////////////////////////////
//  Inputs and Outputs
//////////////////////////////////////////////////////////////////////////////////
input clk, rst_n, valid_in;
input [439:0] message;
output reg valid_out;
output reg [255:0] Hash_result;

//////////////////////////////////////////////////////////////////////////////////
//  Registers and Wires
//////////////////////////////////////////////////////////////////////////////////
reg [1:0] next_state,state;
reg [6:0] count;
reg [31:0] a_temp, b_temp, c_temp, d_temp, e_temp, f_temp, g_temp, h_temp;
reg [31:0] k;
reg [511:0] chunk;
reg [31:0] mreg_0, mreg_1, mreg_2, mreg_3, mreg_4, mreg_5, mreg_6, mreg_7, mreg_8, mreg_9, mreg_10, mreg_11, mreg_12, mreg_13, mreg_14, mreg_15;

wire [31:0] sigma_0, sigma_1, cap_sigma_0, cap_sigma_1, maj, ch;
//////////////////////////////////////////////////////////////////////////////////
//  Initial Values
//////////////////////////////////////////////////////////////////////////////////
parameter H0 = 32'h6a09e667;
parameter H1 = 32'hbb67ae85;
parameter H2 = 32'h3c6ef372;
parameter H3 = 32'ha54ff53a;
parameter H5 = 32'h9b05688c;
parameter H4 = 32'h510e527f;
parameter H6 = 32'h1f83d9ab;
parameter H7 = 32'h5be0cd19;

//////////////////////////////////////////////////////////////////////////////////
//  Constants
//////////////////////////////////////////////////////////////////////////////////
parameter K0 = 32'h428a2f98;
parameter K1 = 32'h71374491;
parameter K2 = 32'hb5c0fbcf;
parameter K3 = 32'he9b5dba5;
parameter K4 = 32'h3956c25b;
parameter K5 = 32'h59f111f1;
parameter K6 = 32'h923f82a4;
parameter K7 = 32'hab1c5ed5;
parameter K8 = 32'hd807aa98;
parameter K9 = 32'h12835b01;
parameter K10 = 32'h243185be;
parameter K11 = 32'h550c7dc3;
parameter K12 = 32'h72be5d74;
parameter K13 = 32'h80deb1fe;
parameter K14 = 32'h9bdc06a7;
parameter K15 = 32'hc19bf174;
parameter K16 = 32'he49b69c1;
parameter K17 = 32'hefbe4786;
parameter K18 = 32'h0fc19dc6;
parameter K19 = 32'h240ca1cc;
parameter K20 = 32'h2de92c6f;
parameter K21 = 32'h4a7484aa;
parameter K22 = 32'h5cb0a9dc;
parameter K23 = 32'h76f988da;
parameter K24 = 32'h983e5152;
parameter K25 = 32'ha831c66d;
parameter K26 = 32'hb00327c8;
parameter K27 = 32'hbf597fc7;
parameter K28 = 32'hc6e00bf3;
parameter K29 = 32'hd5a79147;
parameter K30 = 32'h06ca6351;
parameter K31 = 32'h14292967;
parameter K32 = 32'h27b70a85;
parameter K33 = 32'h2e1b2138;
parameter K34 = 32'h4d2c6dfc;
parameter K35 = 32'h53380d13;
parameter K36 = 32'h650a7354;
parameter K37 = 32'h766a0abb;
parameter K38 = 32'h81c2c92e;
parameter K39 = 32'h92722c85;
parameter K40 = 32'ha2bfe8a1;
parameter K41 = 32'ha81a664b;
parameter K42 = 32'hc24b8b70;
parameter K43 = 32'hc76c51a3;
parameter K44 = 32'hd192e819;
parameter K45 = 32'hd6990624;
parameter K46 = 32'hf40e3585;
parameter K47 = 32'h106aa070;
parameter K48 = 32'h19a4c116;
parameter K49 = 32'h1e376c08;
parameter K50 = 32'h2748774c;
parameter K51 = 32'h34b0bcb5;
parameter K52 = 32'h391c0cb3;
parameter K53 = 32'h4ed8aa4a;
parameter K54 = 32'h5b9cca4f;
parameter K55 = 32'h682e6ff3;
parameter K56 = 32'h748f82ee;
parameter K57 = 32'h78a5636f;
parameter K58 = 32'h84c87814;
parameter K59 = 32'h8cc70208;
parameter K60 = 32'h90befffa;
parameter K61 = 32'ha4506ceb;
parameter K62 = 32'hbef9a3f7;
parameter K63 = 32'hc67178f2;

//////////////////////////////////////////////////////////////////////////////////
//  FSM states
//////////////////////////////////////////////////////////////////////////////////
parameter PADDING = 'd0;
parameter COMPUTE = 'd1;
parameter IDLE = 'd2;

//===================================================================================
//                         finite state machine    
//===================================================================================
always@(next_state)begin  //finite state machine
	case(next_state)
		//PADDING:	state = PADDING;
		IDLE:  state = IDLE;
		COMPUTE:  state = COMPUTE;
		default:  state = IDLE;
	endcase
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		next_state <= IDLE;
	end
	else begin
		if(next_state == IDLE && valid_in)begin
			next_state <= COMPUTE;
		end
      	else if(next_state == COMPUTE && count == 'd64)begin
			next_state <= IDLE;
		end
		else begin
			next_state <= next_state;
		end
	end
end
//===================================================================================
//                         Main function    
//===================================================================================
//Used in Computing
assign sigma_0 = ({a_temp[1:0], a_temp[31:2]}) ^ ({a_temp[12:0], a_temp[31:13]}) ^ ({a_temp[21:0], a_temp[31:22]});
assign sigma_1 = ({e_temp[5:0], e_temp[31:6]}) ^ ({e_temp[10:0], e_temp[31:11]}) ^ ({e_temp[24:0], e_temp[31:25]});
assign maj = (a_temp & b_temp) ^ (a_temp & c_temp) ^ (b_temp & c_temp);
assign ch = (e_temp & f_temp) ^ (~e_temp & g_temp);

//Used in Schduler
assign cap_sigma_0 = {mreg_1[6:0], mreg_1[31:7]} ^ {mreg_1[17:0], mreg_1[31:18]} ^ (mreg_1[31:0] >> 2'b11) ;
  assign cap_sigma_1 = {mreg_14[16:0], mreg_14[31:17]} ^ {mreg_14[18:0], mreg_14[31:19]} ^ (mreg_14[31:0] >> 4'b1010);




always@(posedge clk or negedge rst_n)begin		//chunk
	if(!rst_n)begin
		count <= 'd0;
	end
	else begin
		if(state == COMPUTE)begin
			count <= count + 'd1;
		end
		else begin
			count <= 0;
		end
	end
end

always@(posedge clk or negedge rst_n)begin		//chunk
	if(!rst_n)begin
		chunk <= 'd0;
	end
	else begin
		if(state == IDLE && valid_in)begin
          chunk <= {message[408:0], {8'b10000000}, {55'b0,9'b110111000}, {32'b0}};
		end
		else if(state == IDLE)begin
			chunk <= chunk;
		end
		else begin
			chunk <= chunk << 'd32;
		end
	end
end

always@(posedge clk or negedge rst_n)begin		//a_temp, b_temp, c_temp, d_temp, e_temp, f_temp, g_temp, h_temp
	if(!rst_n)begin
		a_temp <= 'd0;
		b_temp <= 'd0;
		c_temp <= 'd0;
		d_temp <= 'd0;
		e_temp <= 'd0;
		f_temp <= 'd0;
		g_temp <= 'd0;
		h_temp <= 'd0;
	end
	else begin
		if(state == IDLE)begin
			a_temp <= H0;
			b_temp <= H1;
			c_temp <= H2;
			d_temp <= H3;
			e_temp <= H4;
			f_temp <= H5;
			g_temp <= H6;
			h_temp <= H7;
		end
		else if(state == COMPUTE)begin
			a_temp <= h_temp + sigma_1 + ch + k + mreg_15 + sigma_0 + maj; 	// T2= semation_0 + maj(a,b,c);
			b_temp <= a_temp;
			c_temp <= b_temp;
			d_temp <= c_temp;
			e_temp <= d_temp + h_temp + sigma_1 + ch + k + mreg_15;		//T1 = h_out + semation_1 + ch + k + w(mreg_15);
			f_temp <= e_temp;
			g_temp <= f_temp;
			h_temp <= g_temp;
		end
		else begin
			a_temp <= a_temp;
			b_temp <= b_temp;
			c_temp <= c_temp;
			d_temp <= d_temp;
			e_temp <= e_temp;
			f_temp <= f_temp;
			g_temp <= g_temp;
			h_temp <= h_temp;
		end
	end
end


always@(*)begin		//Fixed Constant K
	case(count)
		0: k = K0;
		1: k = K1;
		2: k = K2;
		3: k = K3;
		4: k = K4;
		5: k = K5;
		6: k = K6;
		7: k = K7;
		8: k = K8;
		9: k = K9;
		10: k = K10;
		11: k = K11;
		12: k = K12;
		13: k = K13;
		14: k = K14;
		15: k = K15;
		16: k = K16;
		17: k = K17;
		18: k = K18;
		19: k = K19;
		20: k = K20;
		21: k = K21;
		22: k = K22;
		23: k = K23;
		24: k = K24;
		25: k = K25;
		26: k = K26;
		27: k = K27;
		28: k = K28;
		29: k = K29;
		30: k = K30;
		31: k = K31;
		32: k = K32;
		33: k = K33;
		34: k = K34;
		35: k = K35;
		36: k = K36;
		37: k = K37;
		38: k = K38;
		39: k = K39;
		40: k = K40;
		41: k = K41;
		42: k = K42;
		43: k = K43;
		44: k = K44;
		45: k = K45;
		46: k = K46;
		47: k = K47;
		48: k = K48;
		49: k = K49;
		50: k = K50;
		51: k = K51;
		52: k = K52;
		53: k = K53;
		54: k = K54;
		55: k = K55;
		56: k = K56;
		57: k = K57;
		58: k = K58;
		59: k = K59;
		60: k = K60;
		61: k = K61;
		62: k = K62;
		63: k = K63;
		default: k = 32'd0;
	endcase
end

always@(posedge clk or negedge rst_n)begin		//Hash_result
	if(!rst_n)begin
      	valid_out <= 'd0;
		Hash_result <= 'd0;
	end
	else begin
      if(state == COMPUTE && count == 'd64)begin
          	valid_out <= 'd1;
			Hash_result <= {H0 + a_temp, H1 + b_temp, H2 + c_temp, H3 + d_temp, H4 + e_temp, H5 + f_temp, H6 + g_temp, H7 + h_temp};
        end
      	else begin
          	valid_out <= 'd0;
			Hash_result <= 'd0;
        end
	end
end

always@(posedge clk or negedge rst_n)begin		//Scheduler
	if(!rst_n)begin
		mreg_15 <= 'd0;
		mreg_14 <= 'd0;
		mreg_13 <= 'd0;
		mreg_12 <= 'd0;
		mreg_11 <= 'd0;
		mreg_10 <= 'd0;
		mreg_9 <= 'd0;
		mreg_8 <= 'd0;
		mreg_7 <= 'd0;
		mreg_6 <= 'd0;
		mreg_5 <= 'd0;
		mreg_4 <= 'd0;
		mreg_3 <= 'd0;
		mreg_2 <= 'd0;
		mreg_1 <= 'd0;
		mreg_0 <= 'd0;
	end
	else begin
      if(state== IDLE  && valid_in)begin
        mreg_15 <= message[439:408];
			mreg_14 <= mreg_15;
			mreg_13 <= mreg_14;
			mreg_12 <= mreg_13;
			mreg_11 <= mreg_12;
			mreg_10 <= mreg_11;
			mreg_9 <= mreg_10;
			mreg_8 <= mreg_9;
			mreg_7 <= mreg_8;
			mreg_6 <= mreg_7;
			mreg_5 <= mreg_6;
			mreg_4 <= mreg_5;
			mreg_3 <= mreg_4;
			mreg_2 <= mreg_3;
			mreg_1 <= mreg_2;
			mreg_0 <= mreg_1;
		end
      else if((count < 15 && state == COMPUTE))begin
			mreg_15 <= chunk[511:480];
			mreg_14 <= mreg_15;
			mreg_13 <= mreg_14;
			mreg_12 <= mreg_13;
			mreg_11 <= mreg_12;
			mreg_10 <= mreg_11;
			mreg_9 <= mreg_10;
			mreg_8 <= mreg_9;
			mreg_7 <= mreg_8;
			mreg_6 <= mreg_7;
			mreg_5 <= mreg_6;
			mreg_4 <= mreg_5;
			mreg_3 <= mreg_4;
			mreg_2 <= mreg_3;
			mreg_1 <= mreg_2;
			mreg_0 <= mreg_1;
		end
      else if(count >= 15 && state == COMPUTE)begin
			mreg_15 <= (mreg_0 + cap_sigma_0 + mreg_9 + cap_sigma_1);
			mreg_14 <= mreg_15;
			mreg_13 <= mreg_14;
			mreg_12 <= mreg_13;
			mreg_11 <= mreg_12;
			mreg_10 <= mreg_11;
			mreg_9 <= mreg_10;
			mreg_8 <= mreg_9;
			mreg_7 <= mreg_8;
			mreg_6 <= mreg_7;
			mreg_5 <= mreg_6;
			mreg_4 <= mreg_5;
			mreg_3 <= mreg_4;
			mreg_2 <= mreg_3;
			mreg_1 <= mreg_2;
			mreg_0 <= mreg_1;
		end
      	
		else begin
			mreg_15 <= mreg_15;
			mreg_14 <= mreg_14;
			mreg_13 <= mreg_13;
			mreg_12 <= mreg_12;
			mreg_11 <= mreg_11;
			mreg_10 <= mreg_10;
			mreg_9 <= mreg_9;
			mreg_8 <= mreg_8;
			mreg_7 <= mreg_7;
			mreg_6 <= mreg_6;
			mreg_5 <= mreg_5;
			mreg_4 <= mreg_4;
			mreg_3 <= mreg_3;
			mreg_2 <= mreg_2;
			mreg_1 <= mreg_1;
			mreg_0 <= mreg_0;
		end
	end
end


endmodule