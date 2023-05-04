%Greg Robinson ENGR 151; press-button and tic toc function testing

%This code combines the test for botton function with the test for
%understanding of the tic toc function. The green light will stay on until
%a button is pressed which starts a sequence that turns the yellow light on
%and then the red light on and then back to green until there is another
%button event.

%BEGIN PINOUT SECTION

%define main light LED pins
redPin = 'D13';
yellowPin = 'D12';
greenPin = 'D11';

%define cross street light LED pins
xRedPin = 'D10';
xYellowPin = 'D9';
xGreenPin = 'D8';

%define pedestrian crosswalk signal pins
noWalk = 'A2';
walk = 'D6';

%ultrasonic sensor (car sensor)
triggerPin = 'D5'; %call the sensor pin "carPin"
echoPin = 'D4';

%crosswalk switch
pedPin = 'A0';

%pressure sensor (bike sensor)
bikePin = 'A1';

%END PINOUT SECTION/
%BEGIN VARIABLE DECLARATIONS

threshold = 3.5; %analog threshold value unless something else needed

%create a variables to keep track of which sequence has been triggered
pedSwitchState = 0;
lightSequence = 0; 
eventQ = 0;
ultrasonicObj = ultrasonic(a,triggerPin, echoPin);

%END VARIABLE DECLARATIONS

%SET INITIAL/DEFAULT CONFIGURATION

%default to green light on
writeDigitalPin(a,redPin,0);
writeDigitalPin(a,yellowPin,0); 
writeDigitalPin(a,greenPin,1);
writeDigitalPin(a,xRedPin,1);
writeDigitalPin(a,xYellowPin,0); 
writeDigitalPin(a,xGreenPin,0);
writeDigitalPin(a,noWalk, 1);
writeDigitalPin(a,walk, 0);

tic %restart timer from 0

while(1) %run always


    %if sequence is not activated
    if lightSequence == 0 

           %see if the switch has been pressed

           %these have to stay here so the switchstate remains high
           pedSwitchState = readVoltage(a, pedPin);  

           distance = readDistance(ultrasonicObj)*100;
           time = readEchoTime(ultrasonicObj);

           bikeSwitchState = readVoltage(a, bikePin);

           %if it has been pressed, record the event but don't do anything
           %until all switchstates are back to 0
    else %read values but don't write them to switchState values yet
           ped = readVoltage(a, pedPin);   
           bike = readVoltage(a, bikePin);

           %if any of the buttons are pressed, make eventQ = 1 and clear
           %others
           if ped >= threshold% || bike >= threshold || car >= threshold
               eventQ = 1;
               ped = 0; 
               car = 0;
               bike = 0;
           end
           
    end   
        
    %BEGIN LIGHT SEQUENCE
    if pedSwitchState >= threshold || distance <=9 || bikeSwitchState > 0 %if    ANY   button is pressed

        %only reset clock the first time through the loop after button event
        if lightSequence == 0

            tic %start light sequence tic timer
        end

       lightSequence = 1; %button has been pressed, light sequence follows
       pedSwitchState = threshold;% validate second 'if' loop

        %sequence from green to yellow to red
        if toc < 2 && lightSequence == 1 % allows 2 second grace period
            writeDigitalPin(a,greenPin,1);
            writeDigitalPin(a,redPin,0);
            writeDigitalPin(a,yellowPin,0);        
        elseif toc < 6 && lightSequence == 1 %then turn yellow
            writeDigitalPin(a,greenPin,0);
            writeDigitalPin(a,redPin,0);
            writeDigitalPin(a,yellowPin,1);       
        elseif toc < 10 && lightSequence == 1%then turn red
            writeDigitalPin(a,greenPin,0);
            writeDigitalPin(a,redPin,1);
            writeDigitalPin(a,yellowPin,0);    

        %switch signals after pause
        elseif toc <12 && lightSequence == 1%pause for 2 seconds
        
        elseif toc <20 && lightSequence == 1%hold for 8 seconds

            writeDigitalPin(a,noWalk, 0);%change the pedestrian signal
            writeDigitalPin(a, walk, 1);

            writeDigitalPin(a,xGreenPin,1);%change the xstreet signal
            writeDigitalPin(a,xRedPin,0);
            writeDigitalPin(a,xYellowPin,0); 

        %change lights back to default in sequence
        elseif toc < 24 && lightSequence == 1 
           
            %turn x light yellow
            writeDigitalPin(a,xGreenPin,0);
            writeDigitalPin(a,xYellowPin,1);
            writeDigitalPin(a,xRedPin,0);
            if toc < 21           
                writeDigitalPin(a,walk,0);
            elseif toc <22
                writeDigitalPin(a,walk,1);
            elseif toc < 23
                writeDigitalPin(a,walk,0);
            elseif toc <24
                writeDigitalPin(a,walk,1);
            end
          
        elseif toc < 28 && lightSequence == 1

            %turn x light red
            writeDigitalPin(a,xGreenPin,0);
            writeDigitalPin(a,xYellowPin,0);
            writeDigitalPin(a,xRedPin,1);        

            %turn pedestrian light red
            writeDigitalPin(a,noWalk,1);
            writeDigitalPin(a,walk,0);     
        elseif toc <32 && lightSequence == 1
        
            %turn main street light back to green
            writeDigitalPin(a,greenPin,1);
            writeDigitalPin(a,yellowPin,0);
            writeDigitalPin(a,redPin,0);

        elseif toc > 42 && lightSequence == 1%keep main street green for some time

            if eventQ == 0
                lightSequence = 0;
                pedSwitchState = 0;
                bikeSwitchState = 0;
                carSwitchState = 0;
            else
                lightSequence = 1;     
                pedSwitchState = 5;
                eventQ = 0;
            end

            tic %reset timer            
        end          
    end
    %END LIGHT SEQUENCE
    
    %disp('break');
    disp(bikeSwitchState);
   % disp(eventQ);    

end