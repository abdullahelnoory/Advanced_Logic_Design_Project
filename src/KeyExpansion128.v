module KeyGeneration128(key, newKey, rcon);
  input [0:127] key;
  output [0:127] newKey;
  input [0:31] rcon;
//  initial
 // begin
  //   rcon = 127'h01000000020000000400000008000000100000002000000040000000800000001B00000036000000;
 // end
  wire [0:31] w3n;
  wire [0:31] w3sn;
  assign w3n[0:7] = key[104:111];
  assign w3n[8:15] = key[112:119];
  assign w3n[16:23] = key[120:127];
  assign w3n[24:31] = key[96:103];
  reg [31:0] r3n;
  
  always @(*)
  begin
    r3n = w3n;
  end

  subBytes sub(r3n, w3sn);
  assign newKey[0:31] = key[0:31] ^ w3sn ^ rcon;
  assign newKey[32:63] = key[32:63] ^ newKey[0:31];
  assign newKey[64:95] = key[64:95] ^ newKey[32:63];
  assign newKey[96:127] = key[96:127] ^ newKey[64:95];
endmodule

module KeyExpansion128(key, expandedKey);
  input [0:127] key;
  output reg [0:1407] expandedKey;
  reg [0:319] Rcon;
  reg [0:1407] Rkey;
  wire [0:1407] WexpandedKey;
  assign WexpandedKey[0:127] = key;
  always@(*) begin 
    Rcon = 320'h01000000020000000400000008000000100000002000000040000000800000001B00000036000000;
    Rkey[0:127] = key;
  end
  genvar i;
  for(i = 1; i < 11; i=i+1) begin
    KeyGeneration128 KG(Rkey[128*(i-1):128*(i-1)+127],WexpandedKey[128*i:128*i+127],Rcon[32*(i-1):32*(i-1)+31]);
    
    always@(*)
      Rkey[128*i:128*i+127] = WexpandedKey[128*i:128*i+127];
      
  end
  
  always @(*)
     expandedKey = WexpandedKey;
    
endmodule
