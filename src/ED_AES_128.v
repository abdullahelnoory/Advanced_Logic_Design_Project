module ED_AES_128 (
    input wire clk,
    input wire reset,
    output reg flag
);
    reg [127:0] state;
    wire [0:1407] fullKey;
    reg [5:0] counter;
    wire [127:0] next_state,afterSubBytes, afterShiftRows,AfterMixColumns;
    wire [127:0] afterMixColumnsDEC, afterShiftRowsDEC,AfterRoundKeyDEC,afterShiftRowsCounter0,next_stateCounter0,next_state_DEC;
    wire [127:0] in = 128'h00112233445566778899aabbccddeeff;
    wire [127:0] key = 128'h000102030405060708090a0b0c0d0e0f;

    KeyExpansion128 KE(key, fullKey);
    subBytes SB(state, afterSubBytes);
    shiftRows SR(afterSubBytes, afterShiftRows);
    MixColumns MC(afterShiftRows, AfterMixColumns);
    addRoundKey ADK1(AfterMixColumns, next_state, fullKey[128*(counter) +:128]);
    
    addRoundKey ARK2(state,AfterRoundKeyDEC , fullKey[128*(21-counter) +:128]);
    inverseMixColumns IMC(AfterRoundKeyDEC, afterMixColumnsDEC);
    inverseShiftRows ISR(afterMixColumnsDEC, afterShiftRowsDEC);
    inverseSubBytes ISB(afterShiftRowsDEC, next_state_DEC);
    
    inverseShiftRows ISRC0(AfterRoundKeyDEC, afterShiftRowsCounter0);
    inverseSubBytes ISBC0(afterShiftRowsCounter0, next_stateCounter0);
    
    initial begin
      state = 128'h00112233445566778899aabbccddeeff;
      counter = 0;
      flag =0;
    end
    always @(posedge clk or posedge reset) begin
        if (reset) 
        begin
            state = in;
            counter = 0;
            flag =0;
        end 
        else begin
          if(counter <= 22)begin 
            counter = counter +1;
            if (counter == 1) begin
                  state = in ^ fullKey[0+:128];
            end 
            else if (counter > 1 && counter < 11) begin
                  state = next_state;
              end
              else if (counter == 11) begin
                state =   afterShiftRows ^ fullKey[128*(counter-1) +:128];
              end
              else if (counter == 12) begin
                state = next_stateCounter0;
              end
            else if (counter > 12 && counter < 22) begin
                  state = next_state_DEC;
              end
              else if (counter == 22) begin
                  state = state ^ fullKey[0+:128];
                  flag =(state == in)?1:0;
              end 
          end
      end
    end
endmodule
