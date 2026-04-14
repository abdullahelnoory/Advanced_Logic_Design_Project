module Encryption256(
    input wire clk,
    input wire reset
);
    reg [127:0] state;
    wire [0:1919] fullKey;
    reg [5:0] counter;
    wire [127:0] next_state;
    wire [127:0] afterSubBytes, afterShiftRows,AfterMixColumns;
    wire [127:0] in = 128'h00112233445566778899aabbccddeeff;
    wire [255:0] key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
    initial begin
      state = 128'h00112233445566778899aabbccddeeff;
      counter = 0;
    end
    KeyExpansion256 KE(key, fullKey);
    subBytes SB(state, afterSubBytes);
    shiftRows SR(afterSubBytes, afterShiftRows);
    MixColumns MC(afterShiftRows, AfterMixColumns);
    addRoundKey ADK1(AfterMixColumns, next_state, fullKey[128*(counter) +:128]);
    
    always @(posedge clk or posedge reset) begin
        if (reset) 
        begin
            state = in;
            counter = 0;
        end 
        else begin
          if(counter <= 15)begin 
          counter = counter +1;
          if (counter == 1) begin
              state = in ^ fullKey[0+:128];
          end 
          else if (counter > 1 && counter < 15) begin
                state = next_state;
            end
            else if (counter == 15) begin
              state =   afterShiftRows ^ fullKey[128*(counter-1) +:128];
            end
          end
      end
    end
endmodule


/*
vsim -gui work.Encryption256
add wave -position insertpoint  \
sim:/Encryption256/clk \
sim:/Encryption256/state \
sim:/Encryption256/fullKey \
sim:/Encryption256/counter \
sim:/Encryption256/next_state \
sim:/Encryption256/afterSubBytes \
sim:/Encryption256/afterShiftRows \
sim:/Encryption256/AfterMixColumns \
sim:/Encryption256/in \
sim:/Encryption256/key
force -freeze sim:/Encryption256/clk 1 0, 0 {50 ps} -r 100
run 2000ps
*/