module Encryption128 (
    input wire clk,
    input wire reset
);
    reg [127:0] state;
    wire [0:1407] fullKey;
    reg [4:0] counter;
    wire [127:0] next_state;
    wire [127:0] afterSubBytes, afterShiftRows,AfterMixColumns;
    wire [127:0] in = 128'h00112233445566778899aabbccddeeff;
    wire [127:0] key = 128'h000102030405060708090a0b0c0d0e0f;

    KeyExpansion128 ke(key, fullKey);
    subBytes b1(state, afterSubBytes);
    shiftRows r1(afterSubBytes, afterShiftRows);
    MixColumns m1(afterShiftRows, AfterMixColumns);
    addRoundKey ke2(AfterMixColumns, next_state, fullKey[128*(counter) +:128]);
    initial begin
      state = 128'h00112233445566778899aabbccddeeff;
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
                state = in ^ fullKey[0+:128];
            end else if (counter > 1 && counter < 11) begin
                state = next_state;
            end
            else if (counter == 11) begin
              state =   afterShiftRows ^ fullKey[128*(counter-1) +:128];
            end
          end
        end
    end
endmodule
/*
vsim -gui work.Encryption128
add wave -position insertpoint  \
sim:/Encryption128/clk \
sim:/Encryption128/state \
sim:/Encryption128/fullKey \
sim:/Encryption128/counter \
sim:/Encryption128/next_state \
sim:/Encryption128/afterSubBytes \
sim:/Encryption128/afterShiftRows \
sim:/Encryption128/AfterMixColumns \
sim:/Encryption128/in \
sim:/Encryption128/key
run 50ps
force -freeze sim:/Encryption128/clk 1 0, 0 {50 ps} -r 100
run 2000ps
*/
