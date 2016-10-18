%CAL BAND TRANSITIONS PROJECT%
%FILE - modifies a pathStruct to include delay

%CODED BY: Albert Li, Rachel Jang, Rohan Chakraborty

%LAST UPDATED: 4/24/16, night. Albert.

%FORMAT: -Variables initialized at the top followed by the processes.
%        -Each variable initialization is labelled as: [V#]
%        -Each process is labeled as: [P#]. Ends of processes are: [/P#]

%INPUTS: (1) pathStruct - struct from "pathing"
%        (2) member - member of the cal band
%        (3) delay - how much you want to delay that member in MOVES. This
%        is important, because the WAIT field in pathStruct is in beats

%OUTPUTS: (1) newPathStruct - the modified struct that includes delay

%--------------------------------------------------------------------------------------------%
%--------------------------------------------CODE--------------------------------------------%
%--------------------------------------------------------------------------------------------%

function [newPathStruct] = delay(pathStruct,member,delay)

                        %-------------------------------%
                        %-----------VARIABLES-----------%
                        %-------------------------------%

    %[V1] initializes the new pathStruct
    newPathStruct = pathStruct;
    
    %[V2] sets the correct delay
    newPathStruct(member).wait = 2*delay;
    
    %[V3] the length of the path
    pathLength = size(pathStruct(member).path,1);
    
    %[V4] initial column and row
    ri = pathStruct(member).path(1,1);
    ci = pathStruct(member).path(1,2);
    
                        %-------------------------------%
                        %-----------PROCESSES-----------%
                        %-------------------------------%
    
    %[P1] shifts the path depending on the desired delay.
    %[WARNING] all delays assume that the desired input delay is VALID. If
    %a nonvalid delay is entered, there will be an error.
    
    %this case is if there's no current delay
    if pathStruct(member).wait == 0

        %sets the beginning of the path to the initial location
        for move = 1:delay
            newPathStruct(member).path(move,:) = [ri ci];
        end

        %once it starts moving, it will travel normally along its path
        newPathStruct(member).path(delay+1:pathLength,:) = pathStruct(member).path(1:pathLength - delay,:);
        
    %if there is a current delay, then you need to account for the shifted
    %path
    else
        
        %retrieves the current value of the delay
        curDelay = pathStruct(member).wait/2;
        
        for move = 1:delay
            newPathStruct(member).path(move,:) = [ri ci];
        end
        
        %end of the path takes into account the shifted path
        newPathStruct(member).path(delay+1:pathLength,:) = pathStruct(member).path(curDelay + 1:pathLength - delay + curDelay,:);
        
    end
    %[/P1]
    
end