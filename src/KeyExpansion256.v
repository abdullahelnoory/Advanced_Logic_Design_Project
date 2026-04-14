module KeyGeneration256(key, newKey, rcon);
input [0:255] key;
  output [0:255] newKey;
  input [0:31] rcon;
  wire [0:31] w7n;
  wire [0:31] w7sn;
  assign w7n[0:7] = key[232+:8];
  assign w7n[8:15] = key[240+:8];
  assign w7n[16:23] = key[248+:8];
  assign w7n[24:31] = key[224+:8];
  reg [31:0] r7n;
  reg [31:0] rmid;
  wire [31:0] wmid;

  always @(*)
  begin
    r7n = w7n;
    rmid = newKey[96:127];
  end

  subBytes sub(r7n, w7sn);
  assign newKey[0:31] = key[0:31] ^ w7sn ^ rcon;
  assign newKey[32:63] = key[32:63] ^ newKey[0:31];
  assign newKey[64:95] = key[64:95] ^ newKey[32:63];
  assign newKey[96:127] = key[96:127] ^ newKey[64:95];
  
  subBytes subMid(rmid, wmid);
  
  assign newKey[128:159] = key[128:159] ^ wmid;
  assign newKey[160:191] = key[160:191] ^ newKey[128:159];
  assign newKey[192+:32] = key[192+:32] ^ newKey[160+:32];
  assign newKey[224+:32] = key[224+:32] ^ newKey[192+:32];
endmodule

module KeyGeneration256Special(key, newKey, rcon);
  input [0:255] key;
  output [0:127] newKey;
  input [0:31] rcon;
  wire [0:31] w7n;
  wire [0:31] w7sn;
  assign w7n[0:7] = key[232+:8];
  assign w7n[8:15] = key[240+:8];
  assign w7n[16:23] = key[248+:8];
  assign w7n[24:31] = key[224+:8];
  reg [31:0] r7n;

always @(*)
  begin
    r7n = w7n;
  end

 subBytes sub(r7n, w7sn);
 assign newKey[0:31] = key[0:31] ^ w7sn ^ rcon;
 assign newKey[32:63] = key[32:63] ^ newKey[0:31];
 assign newKey[64:95] = key[64:95] ^ newKey[32:63];
 assign newKey[96:127] = key[96:127] ^ newKey[64:95];
endmodule

module KeyExpansion256(key, expandedKey);
  input [0:255] key;
  output reg [0:1919] expandedKey;
  reg [0:223] Rcon;
  reg [0:1919] Rkey;
  wire [0:1919] WexpandedKey;
  assign WexpandedKey[0:255] = key;
  always@(*) begin 
    Rcon = 224'h01000000020000000400000008000000100000002000000040000000;
    Rkey[0:255] = key;
  end
genvar i;
generate
  for(i = 1; i < 7; i=i+1) begin:Key_Expansion256
    KeyGeneration256 KG(Rkey[256*(i-1):256*(i-1)+255],WexpandedKey[256*i:256*i+255],Rcon[32*(i-1):32*(i-1)+31]);
    
    always@(*)
       Rkey[256*i:256*i+255] = WexpandedKey[256*i:256*i+255];
      
  end
  endgenerate
  
  KeyGeneration256Special KG2(Rkey[256*6:256*6+255],WexpandedKey[256*7:256*7+127],Rcon[32*6:32*6+31]);

  always@(*)
       Rkey[256*7:256*7+127] = WexpandedKey[256*7:256*7+127];
    
  always@(*)
       expandedKey = WexpandedKey;
    
endmodule




module KeyExpansion256_tb();
  reg [0:255] key;
  wire [0:1919] expandedKey;

  initial
  begin
     key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
          
  end
  
  KeyExpansion256 KE(key, expandedKey);
  
  initial begin
    $monitor("%d %h %h", $time, key, expandedKey);
  end
endmodule

module KeyGeneration256_tb();
  reg [0:255] key;
  reg [0:31] rcon;
  wire [0:255] newKey;
  
  initial
  begin
     key = 256'h603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4;
     rcon = 31'h01000000;         
  end
  
  KeyGeneration256 KE(key, newKey, rcon);
  
  initial begin
    $monitor("%d %h %h", $time, key, newKey);
  end
endmodule