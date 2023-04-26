%Greg Robinson ENGR 151; press-button and tic toc function testing

%This code combines the test for botton function with the test for
%understanding of the tic toc function. The green light will stay on until
%a button is pressed which starts a sequence that turns the yellow light on
%and then the red light on and then back to green until there is another
%button event.


%define LED pins
redPin = 'D13';
yellowPin = 'D12';
greenPin = 'D11';

%momentary button
sensorPin = 'A0';

%Threshold for momentary button on analog w/ pulldown
threshold = 3.5;
lightEvent = 0;

%default to green light on
writeDigitalPin(a,redPin,0);
writeDigitalPin(a,yellowPin,0); 
writeDigitalPin(a,greenPin,1);
pause(2);

tic %restart timer from 0
while(1) 
        
    if lightEvent == 0 %check to see if the light loop is running

        %if the light sequence isn't running, see if the switch has been
        %pressed
        switchState = readVoltage(a, sensorPin);  

    end

    if switchState >= threshold %if button is pressed

        %only reset clock the first time through the loop after button event
        if lightEvent == 0
       tic %start light sequence tic timer
        end

       lightEvent = 1; %button has been pressed, light sequence follows
       switchState = threshold;% validate second 'if' loop

        %sequence from green to yellow to red
        if toc < 2 && lightEvent == 1 % allows 2 second grace period
            writeDigitalPin(a,greenPin,1);
            writeDigitalPin(a,redPin,0);
            writeDigitalPin(a,yellowPin,0);        
        elseif toc < 6 && lightEvent == 1 %then turn yellow
            writeDigitalPin(a,greenPin,0);
            writeDigitalPin(a,redPin,0);
            writeDigitalPin(a,yellowPin,1);       
        elseif toc < 10 && lightEvent == 1
            writeDigitalPin(a,greenPin,0);
            writeDigitalPin(a,redPin,1);
            writeDigitalPin(a,yellowPin,0);            
        else 
            writeDigitalPin(a,greenPin,1);
            writeDigitalPin(a,yellowPin,0);
            writeDigitalPin(a,redPin,0);
            tic
            lightEvent = 0;
            switchState = 0;
        end  
  
        
 end

%disp('toc');
%disp(toc);
%disp(switchState); 
end
