module KeyGeneration192(key, newKey, rcon);
  input [0:191] key;
  output [0:191] newKey;
  input [0:31] rcon;
  wire [0:31] w5n;
  wire [0:31] w5sn;
  assign w5n[0:7] = key[168:175];
  assign w5n[8:15] = key[176:183];
  assign w5n[16:23] = key[184:191];
  assign w5n[24:31] = key[160:167];
  reg [31:0] r5n;
  
  always @(*)
  begin
    r5n = w5n;
  end

  subBytes sub(r5n, w5sn);
  assign newKey[0:31] = key[0:31] ^ w5sn ^ rcon;
  assign newKey[32:63] = key[32:63] ^ newKey[0:31];
  assign newKey[64:95] = key[64:95] ^ newKey[32:63];
  assign newKey[96:127] = key[96:127] ^ newKey[64:95];
  assign newKey[128:159] = key[128:159] ^ newKey[96:127];
  assign newKey[160:191] = key[160:191] ^ newKey[128:159];
endmodule

module KeyGeneration192Special(key, newKey, rcon);
  input [0:191] key;
  output [0:127] newKey;
  input [0:31] rcon;
  wire [0:31] w5n;
  wire [0:31] w5sn;
  assign w5n[0:7] = key[168:175];
  assign w5n[8:15] = key[176:183];
  assign w5n[16:23] = key[184:191];
  assign w5n[24:31] = key[160:167];
  reg [31:0] r5n;
  
  always @(*)
  begin
    r5n = w5n;
  end
  
  subBytes sub(r5n, w5sn);
  assign newKey[0:31] = key[0:31] ^ w5sn ^ rcon;
  assign newKey[32:63] = key[32:63] ^ newKey[0:31];
  assign newKey[64:95] = key[64:95] ^ newKey[32:63];
  assign newKey[96:127] = key[96:127] ^ newKey[64:95];
endmodule

module KeyExpansion192(key, expandedKey);
  input [0:191] key;
  output reg [0:1663] expandedKey;
  reg [0:255] Rcon;
  reg [0:1663] Rkey;
  wire [0:1663] WexpandedKey;
  assign WexpandedKey[0:191] = key;
  always@(*) begin 
    Rcon = 256'h0100000002000000040000000800000010000000200000004000000080000000;
    Rkey[0:191] = key;
  end
  genvar i;
  generate
  for(i = 1; i < 8; i=i+1) begin :Key_Expansion192
    KeyGeneration192 KG(Rkey[192*(i-1):192*(i-1)+191],WexpandedKey[192*i:192*i+191],Rcon[32*(i-1):32*(i-1)+31]);
    
    always@(*)
      Rkey[192*i:192*i+191] = WexpandedKey[192*i:192*i+191];
      
  end
  endgenerate
  KeyGeneration192Special KG2(Rkey[192*7:192*7+191],WexpandedKey[192*8:192*8+127],Rcon[32*7:32*7+31]);

  always@(*)
      Rkey[192*8:192*8+127] = WexpandedKey[192*8:192*8+127];
  
  always @(*)
     expandedKey = WexpandedKey;
    
endmodule
