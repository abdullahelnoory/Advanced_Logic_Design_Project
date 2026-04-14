module Decryption256 (
    input wire clk,
    input wire reset
);
    reg [127:0] state;
    wire [0:1919] fullKey;
    reg [4:0] counter;
    wire [127:0] next_state;
    wire [127:0] afterMixColumns, afterShiftRows,AfterRoundKey,afterShiftRowsCounter0,next_stateCounter0;
    wire [127:0] in = 128'h8ea2b7ca516745bfeafc49904b496089;
    wire [255:0] key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;

    KeyExpansion256 ke(key, fullKey);
    addRoundKey ke2(state,AfterRoundKey , fullKey[128*(14-counter) +:128]);
    inverseMixColumns imc(AfterRoundKey, afterMixColumns);
    inverseShiftRows r1(afterMixColumns, afterShiftRows);
    inverseSubBytes b1(afterShiftRows, next_state);
    
    inverseShiftRows r2(AfterRoundKey, afterShiftRowsCounter0);
    inverseSubBytes b2(afterShiftRowsCounter0, next_stateCounter0);
    initial begin
      state = 128'h8ea2b7ca516745bfeafc49904b496089;
      counter = 0;
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state = in;
            counter = 0;
        end else begin
          if(counter <=15)begin
            counter = counter + 1;
            if (counter == 1) begin
                state = next_stateCounter0;
            end else if (counter > 1 && counter < 15) begin
                state = next_state;
            end
            else if (counter == 15) begin
              state = state ^ fullKey[0+:128];
            end
          end
        end
    end
endmodule
/*
vsim -gui work.Decryption256
add wave -position insertpoint  \
sim:/Decryption256/clk \
sim:/Decryption256/state \
sim:/Decryption256/fullKey \
sim:/Decryption256/counter \
sim:/Decryption256/next_state \
sim:/Decryption256/afterSubBytes \
sim:/Decryption256/afterShiftRows \
sim:/Decryption256/AfterMixColumns \
sim:/Decryption256/in \
sim:/Decryption256/key
run 50ps
force -freeze sim:/Decryption256/clk 1 0, 0 {50 ps} -r 100
run 2000ps
*/
