
/* Changes a value to a segment display representation */
module BCDtoSevenSegment
    (input  logic [3:0] bcd,
     output logic [6:0] segment);

    always_comb begin
        case ({bcd})
          	4'b0000: segment = 7'b100_0000; //test all the different decimals
          	4'b0001: segment = 7'b111_1001; 
          	4'b0010: segment = 7'b010_0100;
          	4'b0011: segment = 7'b011_0000;
          	4'b0100: segment = 7'b001_1001;
          	4'b0101: segment = 7'b001_0010;
          	4'b0110: segment = 7'b000_0010;
          	4'b0111: segment = 7'b111_1000;
			4'b1000: segment = 7'b000_0000;
		    4'b1001: segment = 7'b001_1000;
          	default: segment = 7'b111_1111; //if no case present, display off
        endcase
    end

endmodule: BCDtoSevenSegment


/* base module that changes 4 bit input to 7 bit output allows for blanking */
module SevenSegmentDigit  
    (input logic [3:0] bcd,
     output logic [6:0] segment,
     input logic blank);
    
    logic [6:0] decoded;

    BCDtoSevenSegment b2ss(bcd, decoded); //want to incorporate blanking
                                          //execute the BCDtoSS module
                                          //and then check the blank bool

    // to fill
    always_comb begin
    	if(blank == 1) 
          segment = 7'b111_1111; //turn display off
    	else 
          segment = decoded; //normally display the segments
    end

endmodule: SevenSegmentDigit

module SevenSegmentDigitTester

    (input logic [6:0] segment,
     output logic [3:0] bcd,
     output logic blank);

    initial begin
      $monitor($time,, "bcd = %b, segment = %b, blank = %b",bcd,segment,blank);
          bcd = 4'b0000;
          blank = 0;
      // blank 0, valid number
      #10 bcd = 4'b0000;
      #10 bcd = 4'b0111;
      #10 bcd = 4'b0101;

      // blank 1, valid number
      // pulse blank
      #10 blank = 1;
      #10 blank = 0;

      // blank 0, not valid number
      #10 bcd = 4'b1111;
      #10 bcd = 4'b1011;

      // blank 1, not valid number
      // pulse blank
      #10 blank = 1;
      #10 blank = 0;

    end
endmodule: SevenSegmentDigitTester




/* Controls the LED Number Display. It takes in a HEX (which number display) to display to
 * and displays that number sent into there (BCD_). The turn_on tells whether the 'blank' should be turned on or not
 * this was originally controlled via a switch.
 * EDIT: change from last lab. Controls only one LED at a time. 
*/
module SevenSegmentControl
    (output logic [6:0] HEX,
     input logic [3:0] BCD,
     input logic blank);
    
    SevenSegmentDigit zero  (BCD, HEX, blank);

endmodule: SevenSegmentControl



/* Displays the number of hits the bomb made
 * 
 */
module NumberHitControl 
    (input logic [3:0] numberHit,
     output logic [6:0] HEX)

    SevenSegmentDigit numHits (numberHit, HEX, 0);  // set the blank to 0 for now. I'm not sure but may need to be toggled for scoreNow. 

endmodule: NumberHitControl



/* This module handles the LED control for the hit, nearMiss and miss
 * It also handles the logic for the largest ship that was hit. 
 */
module BombLightControl
    (input logic isHit, isNearMiss, isMiss, 
     input logic [4:0] biggestShip, 
     output logic hit[17:12], 
     output logic nearMiss[11:6], 
     output logic miss[5:0], 
     output logic biggestShipHit[4:0]);

    always_comb begin
        // Might have to be flipped depending whether the LEDs are active High or active Low
        if(isHit)
            hit = 6'b111_111;
        else 
            hit = 6'b000_000;

        if(isNearMiss)
            nearMiss = 6'b111_111;
        else
            nearMiss = 6'b000_000;

        if(miss)
            miss = 6'b111_111;
        else
            miss = 6'b000_000;

        biggestShipHit = biggestShip; // biggestShip already contains the value we want. This was encoded when the hit was made
    end



endmodule: BombLightControl



/* This module checks if there is something wrong with the inputs.
 * If there is, returns something wrong with 1. Vice versa. 
 * It only does this if scoreThis has been pressed
 */
module IsSomethingWrong
        (input logic [4:0] X, 
         input logic [4:0] Y,
         input logic big,
         input logic [1:0] bigLeft,
         input logic scoreThis,
         output logic wrong);

    always_comb begin
        if(scoreThis) begin
            if((X>0) && (X<11) && (Y>0) && (Y<11))  // OR ((X < 0) || (X > 10) || (Y < 0) || (Y > 10)) 
                somethingWrong = 1;
            else if(bigLeft == 2'b11) 
                somethingWrong = 1;
            else if((big==1) && (bigLeft==2'b00))
                somethingWrong = 1;
            else
                somethingWrong = 0;
        end
    end

endmodule: IsSomethingWrong


/* This module checks the square passed in and returns whether it was hit, a miss, a near miss...
 * 
 */
module checkSquare
    (input logic [3:0] X,
     input logic [3:0] Y,
     output logic isHit,
     output logic isNearMiss,
     output logic isMiss,
     output logic [4:0] biggestShip);

    logic calculateNearMiss;
     
    always_comb begin
        if(((X == 7 | X == 8) && Y == 6) | ((X == 9 | X == 10) && Y == 1)) // then this is the patrol boat
            biggestShip = 5'b000_01;
        else if(X == 2 && (Y == 10 | Y == 9 | Y == 8))
            biggestShip = 5'b000_10;
        else if((X == 2 | X == 3 | X == 4) && Y == 1)
            biggestShip = 5'b001_00;
        else if((X == 1 | X == 2 | X == 3 | X == 4) && Y == 2)
            biggestShip = 5'b010_00;
        else if((X == 2 | X == 3 | X == 4 | X == 5 | X == 6) && Y == 3)
            biggestShip = 5'b100_00;
        else
            biggestShip = 5'b000_00;

        if(biggestShip == 0) begin
            isHit = 0;
            isMiss = 1;
            calculateNearMiss = 1; // Ship did not get hit, need to calculate near miss
        end
        else begin
            isHit = 1;
            isMiss = 0;
            calculateNearMiss = 0; // because ship got hit, no near miss
        end
    end

    checkNearMiss CNM (X, Y, calculateNearMiss, isNearMiss);

endmodue: checkSquare


/* This module handles the near Miss
 * If the shot lands on a ship, nearMiss is 0
 * If the shot lands not on a ship but adjacent to a ship, then nearmiss is 1. (not diagonal)
 */
module checkNearMiss
    (input logic [3:0] X,
     input logic [3:0] Y,
     input logic calculate,
     output logic isNearMiss);

    always_comb begin
        if(calculate) begin
            for(i = -1; i < 2; i = i+2) begin
                for(j = i-1; j < 2; j = j+2) begin
                    if(X+i == 0 || Y+j == 0 || X+i == 11 || Y+j == 11) // then forget it, it's out of the map
                        isNearMiss = 0;
                    else if(((X+i == 7 | X+i == 8) && Y+j == 6) | ((X+i == 9 | X+i == 10) && Y+j == 1)) begin // then this is the patrol boat
                        isNearMiss = 1;
                        break; // we have a isNearMiss, get out. 
                    end
                    else if(X+i == 2 && (Y+j == 10 | Y+j == 9 | Y+j == 8))begin
                        isNearMiss = 1;
                        break; // we have a isNearMiss, get out.
                    end 
                    else if((X+i == 2 | X+i == 3 | X+i == 4) && Y+j == 1)begin
                        isNearMiss = 1;
                        break; // we have a isNearMiss, get out.
                    end 
                    else if((X+i == 1 | X+i == 2 | X+i == 3 | X+i == 4) && Y+j == 2)begin
                        isNearMiss = 1;
                        break; // we have a isNearMiss, get out. 
                    end
                    else if((X+i == 2 | X+i == 3 | X+i == 4 | X+i == 5 | X+i == 6) && Y+j == 3)begin
                        isNearMiss = 1;
                        break; // we have a isNearMiss, get out. 
                    end
                    else
                        isNearMiss = 0; // that means there is not a ship adjacent to it
                end
            end

        end
        else
            isNearMiss = 0; // that means that it already hit a boat. 

    end

endmodule: checkNearMiss



/* This module handles when there is a possible hit.
 * It checks if it is a big bomb or a small one and checks the right number of squares correspondingly. 
 */
module HandleHit
    (input logic somethingWrong,
     input logic [3:0] X,
     input logic [3:0] Y,
     input logic big,
     input logic scoreThis,
     output logic isHit,     
     output logic isNearMiss,
     output logic isMiss,
     output logic [4:0] biggestShip);

     always_comb begin
        if(~somethingWrong && scoreThis)  // handles what to do when everything is fine
            begin
                if(big) begin
                    // handles what to do when a big bomb is used
                end 
                else begin
                    // handles what to do when it is just a small bomb
                end
            end 

     end
endmodule: HandleHit




/* This module checks if there is somethingWrong
 * If there is, turn on all the LEDs in HEX6 and HEX7 using the module made in

 * the previous lab
 */
module HandleWrong
    (input logic somethingWrong,
     output logic [6:0] HEX6, HEX7);

    logic [3:0] displayValue;
    logic blank;

    always_comb begin

        if(somethingWrong) // turn on all the LEDs in HEX6 and HEX7
            begin
                displayValue = 4'b1000;
                blank = 0;
            end
        else
            begin
                displayValue = 4'b0000;
                blank = 1;
            end
    end    

    SevenSegmentControl control6 (HEX6, displayValue, blank);
    SevenSegmentControl control7 (HEX7, displayValue, blank);

endmodule: HandleWrong




/* This module takes in any inputs by the user, desides how to interpret them, and calls the right command 
 * in return. 
 *
 * The inputs to the system should be as follows:
 * [3:0] SW -> [3:0] Y
 * [7:4] SW -> [3:0] X
 * Key 0 -> Score this
 * [17] SW -> Big (use the big bomb or not)
 * [15:14] SW -> [1:0] BigLeft (number of big bombs left)
 * 
 * The outputs are: 
 * [17:12] LEDR -> Hit (Light up all)
 * [11:6] LEDR -> NearMiss (Light up all)
 * [5:0] LEDR -> Miss (Light up all)
 * [6:0] HEX0 -> NumHits [6:0]
 * [4:0] LEDG -> BiggestShipHit[4:0]
 * [6:0] HEX6 & HEX7 -> Something is Wrong
 */

module ChipInterface
    (output logic [6:0] HEX7, HEX6, HEX0,
     output logic [17:12] LEDR,
     output logic [11:6] LEDR,
     output logic [5:0] LEDR,
     output logic [4:0] LEDG,
     input logic [3:0] SW,
     input logic [7:4] SW,
     input logic [17] SW,
     input logic [15:14] SW,
     input logic [0] KEY);


    logic somethingWrong; 
    
    logic [3:0] bcd0, bcd1, bcd2, bcd3, bcd4, bcd5, bcd6, bcd7;

    logic isHit, isMiss, isNearMiss;
    logic [4:0] biggestShip;

    logic [3:0] numberHit;


    IsSomethingWrong ISW(X, Y, SW[17], SW[15:14], KEY[0], somethingWrong);


    always_comb begin //all displays defaulted at first



    end

    HandleHit HH (somethingWrong, X, Y, SW[17], KEY[0], isHit, isNearMiss, isMiss, biggestShip); // this handles both wrong or not wrong
    HandleWrong HW (somethingWrong, HEX6, HEX7);  handles what to do when something is wrong (ie. light up HEX6 and HEX7)

    // set the lights for hits and misses and stuffs
    BombLightControl BLC (isHit, isNearMiss, isMiss, biggestShip, LEDR[17:12], LEDR[11:6], LEDR[5:0], LEDG[4:0]);     // Handles all but NearMiss

    NumberHitControl NHC (numberHit, HEX0);


endmodule:ChipInterface




