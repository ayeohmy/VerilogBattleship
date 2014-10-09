module SevenSegmentDigitTester;

    logic [6:0] segment;
    logic [3:0] bcd;
    logic blank;
    

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



module IsSomethingWrongTest;

    logic [3:0] X;
    logic [3:0] Y;
    logic big;
    logic [1:0] bigLeft;
    logic scoreThis;
    logic wrong;

    isSomethingWrong test(X,Y,big,bigLeft,scoreThis,wrong);

    initial begin
        $monitor($time,,"X = %b, Y = %b, big = %b, bigLeft = %b, scoreThis = %b, wrong = %b", X, Y, big, bigLeft, scoreThis,wrong);
            X = 0;
            Y = 0;
            big = 0;
            bigLeft = 0;
            scoreThis = 0;

        #10 X = 4'b1011; // something should be wrong

        #10 X = 4'b0001; //something should be right

        #10 X = 4'b0000; // something should be wrong

        #10 X = 4'b0001; 
            Y = 4'b1011; //something should be wrong

        #10 X = 4'b0101; //X = 5, Y = 5 should be right
            Y = 4'b0101; 

        #10 big = 1;
            bigLeft = 2'b01; //something should be right

        #10 bigleft = 2'b00; //something should be wrong

        #10 bigLeft = 2'b11; //something should be wrong

        #10 $finish;
    end
endmodule: IsSomethingWrongTest;



module testCheckSquare;

    logic [3:0] X;
    logic [3:0] Y;
    logic isHit;
    logic isNearMiss;
    logic isMiss;
    logic [4:0] biggestShip;

    checkSquare test(X,Y,isHit,isNearMiss,isMiss,biggestShip);

    initial begin
        $monitor($time,,"X = %b, Y = %b, isHit = %b, isNearMiss = %b, isMiss = %b, biggestShip = %b", X, Y, isHit, isNearMiss, isMiss,biggestShip);
            X = 0;
            Y = 0;


        #10 X = 4'b0010; // (2,8)
            Y = 4'b1000; //isNearMiss and isMiss should be 0; ishit = 1, biggest ship should be the submarine (i.e ship 00010)

        #10 X = 4'b0001; // (1,8)
            Y = 4'b1000; //isNearMiss = 1, isHit = 0, isMiss = 0
        
        #10 X = 4'b0111; //(7,1)
            Y = 4'b0001; //isNearMiss = 0, isHit = 0, isMiss = 1

        #10 X = 4'b0101; // (5,1)
            Y = 4'b0001; //isnearMiss = 1, ishit = 0, isMiss = 0

        #10 X = 4'b0100; // (4,3)
            Y = 4'b0011; //isnearmiss = 0, ishit = 1, ismiss = 0, biggest ship should be aircraft carrier

        #10 X = 4'b0001; // (1,1)
            Y = 4'b0001; //is near miss = 0, ishit = 0, is miss = 0

        #10 X = 4'b1100; //(12,1)
                         //is nearmiss = 0, is hit = 0, is miss = 0, everything should be 0/off
        #10 X = 4'b0101;
            Y = 4'b1100; //same test as before but Y coordinate. should be off board

        #10 X = 4'b0000;
            Y = 4'b0001; //same test as before but X off board at 0

        #10 X = 4'b0001;
            Y = 4'b0000; //same test as before but Y is not valid (off board at 0)


        #10 $finish;
    end
endmodule: testCheckSquare




module testHandleHit;

    logic somethingWrong;
    logic [3:0] X;
    logic [3:0] Y;
    logic big;
    logic scoreThis;
    logic isHit;    
    logic isNearMiss;
    logic isMiss;
    logic [4:0] biggestShip;
    logic [3:0] numHit;

    HandleHit test(somethingWrong,X,Y,big,scoreThis,isHit,isNearMiss,isMiss,biggestShip,numHit);

    initial begin
        $monitor("somethingWrong = %b, X = %b, Y = %b, big = %b, scoreThis = %b, isHit = %b, 
                    isNearMiss = %b, isMiss = %b, biggestShip = %b, numHit = %b",
                    somethingWrong,X,Y,big,scoreThis,isHit,isNeariss,isMiss,biggestShip,numHit);

                somethingWrong = 0;
                X = 0;
                Y = 0;
                big = 0;
                scoreThis = 0;

        #10 somethingWrong = 1; //all LED'S in HEX7 and HEX6 should light up
        #10 somethingWRong = 0; //LED's should turn off. everything back to normal
        
        #10 X = 4'b0101;
            Y = 4'b0101; //LED's still should be off

        
        #10 scoreThis = 1; //nearMiss = 0, isMiss = 1, isHit = 0, biggestShip = 00000, numhit = 000000
        
        #10 scoreThis = 0; //USED BIG HIT
            X = 4'b0011;
            Y = 4'b0010;
            big = 1;
            scoreThis = 1; // numHits = 9, nearmiss = 0, ismiss = 0, ishit = 1, biggest ship = aircraft carrier

        #10 scoreThis = 0; //USED BIG HIT
            Y = 4'b0011;
            scoreThis = 1; // num hits = 6, nearmiss = 0, ismiss = 0, ishit = 1, biggest ship = aircraft carrier

        #10 scoreThis = 0;
            Y = 4'b0000;
            X = 4'b0000; // DONT CARE. the program will never let x and y be 0 because it will detect something is wrong at first

        #10 big = 0; //USED SMALL HIT
            X = 4'b1010;
            Y = 4'b1010; // ismiss = 1, ishit = 0, is nearmiss = 0; biggest ship = nothing, numhit = 0
            scoreThis = 1;

        #10 scoreThis = 0; //USED SMALL HIT
            X = 4'b0001;
            Y = 4'b0001;
            scoreThis = 1; //ismiss = 0, ishit = 0, isnearmiss = 1; biggestship = nothing, numhit = 0

        #10 scoreThis = 0; //USED BIG HIT
            X = 4'b0101;
            Y = 4'b0011;
            big = 1;
            scoreThis = 1; //ismiss = 0, ishit = 1, isnearmiss = 0, biggestship = aircraftcarreir, numhits = 4, 

        #10 Y = 4'b0010; //USED BIG HIT
            scoreThis = 1; //ismiss = 0, ishit = 1, isnearmiss = 0, biggestship = aircraftcarrier, numhits = 5

        #10 scoreThis = 0; //USED BIG HIT
            X = 4'b0011;
            Y = 4'b1001;
            scoreThis = 1; //ismiss = 0, ishit = 1, isnearmiss = 0, biggestship = submarine, numhits = 3

        #10 scoreThis = 0;
            X = 4'b0010; //USED BIG HIT
            Y = 4'b0101; 
            scoreThis = 1; //ismiss = 0, ishit = 1, isnearmiss = 1, biggestship = nothing, numhits = 0

        #10 $finish;

    end

endmodule: testHandleHit


    