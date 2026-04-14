module ED_AES_192(
    input wire clk,
    input wire reset,
    output reg flag
);
    reg [127:0] state;
    wire [0:1663] fullKey;
    reg [5:0] counter;
    wire [127:0] next_state,afterSubBytes, afterShiftRows,AfterMixColumns;
    wire [127:0] afterMixColumnsDEC, afterShiftRowsDEC,AfterRoundKeyDEC,afterShiftRowsCounter0,next_stateCounter0,next_state_DEC;
    wire [127:0] in = 128'h00112233445566778899aabbccddeeff;
    wire [191:0] key = 192'h000102030405060708090a0b0c0d0e0f1011121314151617;

    KeyExpansion192 KE(key, fullKey);
    subBytes SB(state, afterSubBytes);
    shiftRows SR(afterSubBytes, afterShiftRows);
    MixColumns MC(afterShiftRows, AfterMixColumns);
    addRoundKey ADK1(AfterMixColumns, next_state, fullKey[128*(counter) +:128]);
    
    addRoundKey ke2(state,AfterRoundKeyDEC , fullKey[128*(25-counter) +:128]);
    inverseMixColumns imc(AfterRoundKeyDEC, afterMixColumnsDEC);
    inverseShiftRows r1(afterMixColumnsDEC, afterShiftRowsDEC);
    inverseSubBytes b1(afterShiftRowsDEC, next_state_DEC);
    
    inverseShiftRows r2(AfterRoundKeyDEC, afterShiftRowsCounter0);
    inverseSubBytes b2(afterShiftRowsCounter0, next_stateCounter0);
    
    initial begin
        state=128'h00112233445566778899aabbccddeeff;
        counter = 0;
        flag =0;
    end
    always @(posedge clk or posedge reset) begin
        if (reset) 
        begin
            state = in;
            counter = 0;
            flag = 0;
        end 
        else begin
          if(counter <= 26)begin 
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
            else if (counter == 14) begin
              state = next_stateCounter0;
            end
            else if (counter > 14 && counter < 26) begin
                state = next_state_DEC;
            end
            else if (counter == 26) begin
                state = state ^ fullKey[0+:128];
                flag = (state == in) ? 1:0;
            end 
          end
      end
    end
endmodule
