module Decryption192 (
    input wire clk,
    input wire reset
);
    reg [127:0] state;
    wire [0:1663] fullKey;
    reg [4:0] counter;
    wire [127:0] next_state;
    wire [127:0] afterMixColumns, afterShiftRows,AfterRoundKey,afterShiftRowsCounter0,next_stateCounter0;
    wire [127:0] in = 128'hdda97ca4864cdfe06eaf70a0ec0d7191;
    wire [191:0] key = 192'h000102030405060708090a0b0c0d0e0f1011121314151617;

    KeyExpansion192 ke(key, fullKey);
    addRoundKey ke2(state,AfterRoundKey , fullKey[128*(12-counter) +:128]);
    inverseMixColumns imc(AfterRoundKey, afterMixColumns);
    inverseShiftRows r1(afterMixColumns, afterShiftRows);
    inverseSubBytes b1(afterShiftRows, next_state);
    
    inverseShiftRows r2(AfterRoundKey, afterShiftRowsCounter0);
    inverseSubBytes b2(afterShiftRowsCounter0, next_stateCounter0);
    initial begin
      state = 128'hdda97ca4864cdfe06eaf70a0ec0d7191;
      counter = 0;
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state = in;
            counter = 0;
        end else begin
          if(counter <=13)begin
            counter = counter + 1;
            if (counter == 1) begin
                state = next_stateCounter0;
            end else if (counter > 1 && counter < 13) begin
                state = next_state;
            end
            else if (counter == 13) begin
              state = state ^ fullKey[0+:128];
            end
          end
        end
    end
endmodule
/*
vsim -gui work.Decryption192
add wave -position insertpoint  \
sim:/Decryption192/clk \
sim:/Decryption192/state \
sim:/Decryption192/fullKey \
sim:/Decryption192/counter \
sim:/Decryption192/next_state \
sim:/Decryption192/afterSubBytes \
sim:/Decryption192/afterShiftRows \
sim:/Decryption192/AfterMixColumns \
sim:/Decryption192/in \
sim:/Decryption192/AfterRoundKey \
sim:/Decryption192/key
run 50ps
force -freeze sim:/Decryption192/clk 1 0, 0 {50 ps} -r 100
run 2000ps
*/
