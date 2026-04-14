module EDAES(
    input [2:0]sel,
    input wire clk,
    input wire reset,
    output reg flag
);
    reg [127:0] state,fullKey;
    wire [0:1407] fullKey128;
    wire [0:1663] fullKey192;
    wire [0:1919] fullKey256;
    reg [5:0] counter;
    wire [127:0] next_state,afterSubBytes, afterShiftRows,AfterMixColumns;
    wire [127:0] afterMixColumnsDEC, afterShiftRowsDEC,AfterRoundKeyDEC,afterShiftRowsCounter0,next_stateCounter0,next_state_DEC;
    wire [127:0] in = 128'h00112233445566778899aabbccddeeff;
    wire [127:0] key128 = 128'h000102030405060708090a0b0c0d0e0f;
    wire [191:0] key192 = 192'h000102030405060708090a0b0c0d0e0f1011121314151617;
    wire [255:0] key256 = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;

    KeyExpansion128 KEY128(key128, fullKey128);
    KeyExpansion192 KEY192(key192, fullKey192);
    KeyExpansion256 KEY256(key256, fullKey256);

    subBytes SB(state, afterSubBytes);
    shiftRows SR(afterSubBytes, afterShiftRows);
    MixColumns MC(afterShiftRows, AfterMixColumns);
    addRoundKey ADK1(AfterMixColumns, next_state, fullKey);
    
    addRoundKey ARK2(state,AfterRoundKeyDEC , fullKey);
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
    always @(posedge sel[0] or posedge sel[1] or posedge sel[2]) begin
      state = in;
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
        if(sel==3'b001)begin
            if(counter <= 22)begin
            counter = counter +1;
            if (counter == 1) begin
                state = in ^ fullKey128[0+:128];
                fullKey = fullKey128[128*(counter) +:128];
            end 
            else if (counter > 1 && counter < 11) begin
                state = next_state;
                fullKey = fullKey128[128*(counter) +:128];
              end
              else if (counter == 11) begin
                state =   afterShiftRows ^ fullKey128[128*(counter-1) +:128];
                fullKey = fullKey128[128*(21-counter) +:128];
              end
              else if (counter == 12) begin
                state = next_stateCounter0;
                fullKey = fullKey128[128*(21-counter) +:128];
              end
            else if (counter > 12 && counter < 22) begin
                state = next_state_DEC;
                fullKey = fullKey128[128*(21-counter) +:128];
              end
              else if (counter == 22) begin
                state = state ^ fullKey128[0+:128];
                flag =(state == in)?1:0;
              end 
          end
        end
        else if(sel==3'b010)begin
          if(counter <= 26)begin 
            counter = counter +1;
            if (counter == 1) begin
              state = in ^ fullKey192[0+:128];
              fullKey = fullKey192[128*(counter) +:128];
            end 
            else if (counter > 1 && counter < 13) begin
              state = next_state;
              fullKey = fullKey192[128*(counter) +:128];
            end
            else if (counter == 13) begin
              state =   afterShiftRows ^ fullKey192[128*(counter-1) +:128];
              fullKey = fullKey192[128*(25-counter) +:128];
            end
            else if (counter == 14) begin
              state = next_stateCounter0;
              fullKey = fullKey192[128*(25-counter) +:128];
            end
            else if (counter > 14 && counter < 26) begin
              state = next_state_DEC;
              fullKey = fullKey192[128*(25-counter) +:128];
            end
            else if (counter == 26) begin
              state = state ^ fullKey192[0+:128];
              flag = (state == in) ? 1:0;
            end 
          end
        end
        else if(sel==3'b100)begin
          if(counter <= 30)begin 
            counter = counter +1;
            if (counter == 1) begin
              state = in ^ fullKey256[0+:128];
              fullKey = fullKey256[128*(counter) +:128];
            end 
            else if (counter > 1 && counter < 15) begin
              state = next_state;
              fullKey = fullKey256[128*(counter) +:128];
            end
            else if (counter == 15) begin
              state =   afterShiftRows ^ fullKey256[128*(counter-1) +:128];
              fullKey = fullKey256[128*(29-counter) +:128];
            end
            else if (counter == 16) begin
              state = next_stateCounter0;
              fullKey = fullKey256[128*(29-counter) +:128];
            end
            else if (counter > 16 && counter < 30) begin
              state = next_state_DEC;
              fullKey = fullKey256[128*(29-counter) +:128];
            end
            else if (counter == 30) begin
              state = state ^ fullKey256[0+:128];
              flag = (state == in) ? 1:0;
            end 
          end
        end
        else  begin
          state =  in;
          flag = 0;
          counter =0;
        end
    end
endmodule

