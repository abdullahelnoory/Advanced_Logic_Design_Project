module Decryption128 (
    input wire clk,
    input wire reset
);
    reg [127:0] state;
    wire [0:1407] fullKey;
    reg [4:0] counter;
    wire [127:0] next_state;
    wire [127:0] afterMixColumns, afterShiftRows,AfterRoundKey,afterShiftRowsCounter0,next_stateCounter0;
    wire [127:0] in = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
    wire [127:0] key = 128'h000102030405060708090a0b0c0d0e0f;

    KeyExpansion128 ke(key, fullKey);
    addRoundKey ke2(state,AfterRoundKey , fullKey[128*(10-counter) +:128]);
    inverseMixColumns imc(AfterRoundKey, afterMixColumns);
    inverseShiftRows r1(afterMixColumns, afterShiftRows);
    inverseSubBytes b1(afterShiftRows, next_state);
    
    inverseShiftRows r2(AfterRoundKey, afterShiftRowsCounter0);
    inverseSubBytes b2(afterShiftRowsCounter0, next_stateCounter0);
    initial begin
      state = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
      counter = 0;
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state = in;
            counter = 0;
        end else begin
          if(counter <=11)begin
            counter = counter + 1;
            if (counter == 1) begin
                state = next_stateCounter0;
            end else if (counter > 1 && counter < 11) begin
                state = next_state;
            end
            else if (counter == 11) begin
              state = state ^ fullKey[0+:128];
            end
          end
        end
    end
endmodule
/*
vsim -gui work.Decryption128
add wave -position insertpoint  \
sim:/Decryption128/clk \
sim:/Decryption128/state \
sim:/Decryption128/fullKey \
sim:/Decryption128/counter \
sim:/Decryption128/next_state \
sim:/Decryption128/afterSubBytes \
sim:/Decryption128/afterShiftRows \
sim:/Decryption128/AfterMixColumns \
sim:/Decryption128/in \
sim:/Decryption128/key
run 50ps
force -freeze sim:/Decryption128/clk 1 0, 0 {50 ps} -r 100
run 2000ps
*/
