module Encryption192(
    input wire clk,
    input wire reset
);
    reg [127:0] state;
    wire [0:1663] fullKey;
    reg [5:0] counter;
    wire [127:0] next_state;
    wire [127:0] afterSubBytes, afterShiftRows,AfterMixColumns;
    wire [127:0] in = 128'h00112233445566778899aabbccddeeff;
    wire [191:0] key = 192'h000102030405060708090a0b0c0d0e0f1011121314151617;
    initial begin
      state = 128'h00112233445566778899aabbccddeeff;
      counter = 0;
    end
    KeyExpansion192 KE(key, fullKey);
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
          if(counter <= 13)begin 
          counter = counter +1;
          if (counter == 1) begin
              state = in ^ fullKey[0+:128];
          end 
          else if (counter > 1 && counter < 13) begin
                state = next_state;
            end
            else if (counter == 13) begin
              state =   afterShiftRows ^ fullKey[128*(counter-1) +:128];
            end
          end
      end
    end
endmodule


/*
vsim -gui work.Encryption192
add wave -position insertpoint  \
sim:/Encryption192/clk \
sim:/Encryption192/state \
sim:/Encryption192/fullKey \
sim:/Encryption192/counter \
sim:/Encryption192/next_state \
sim:/Encryption192/afterSubBytes \
sim:/Encryption192/afterShiftRows \
sim:/Encryption192/AfterMixColumns \
sim:/Encryption192/in \
sim:/Encryption192/key
run 50ps
force -freeze sim:/Encryption192/clk 1 0, 0 {50 ps} -r 100
run 2000ps
*/
