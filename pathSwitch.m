%CAL BAND TRANSITIONS PROJECT%
%FILE - changes the path of a member of the cal band

%CODED BY: Albert Li, Rachel Jang, Rohan Chakraborty

%LAST UPDATED: 4/26/16, afternoon. Albert.

%FORMAT: -Variables initialized at the top followed by the processes.
%        -Each variable initialization is labelled as: [V#]
%        -Each process is labeled as: [P#]. Ends of processes are: [/P#]

%INPUTS: (1) pathStruct - the struct produced from the start of "pathing"
%        (2) member - the member of the cal band whose path you're changing

%OUTPUTS: (1) newPathStruct - new struct with the same fields as pathStruct
%             but with values changed based on the path switched

%--------------------------------------------------------------------------------------------%
%--------------------------------------------CODE--------------------------------------------%
%--------------------------------------------------------------------------------------------%

function [newPathStruct] = pathSwitch(pathStruct,mapStruct,member)

                        %-------------------------------%
                        %-----------VARIABLES-----------%
                        %-------------------------------%

    %[V1] initializes the array containing the path of the member
    path = pathStruct(member).path;
    
    %[V2] initializes the starting row and col coordinates of the member
    startRow = path(1,1);
    startCol = path(1,2);
    
    %[V3] initializes the ending row and col coordinates of the member
    endRow = path(size(path,1),1);
    endCol = path(size(path,1),2);
    
    %[V4] initializes the new path array
    newPath = path;
    
    %[V5] new pathStruct
    newPathStruct = pathStruct;
    
    %[V6] retrieves the current delay
    curDelay = pathStruct(member).wait/2;
    
    %[V7]
    mdist = mapStruct(member).mdist;
    
                        %-------------------------------%
                        %-----------PROCESSES-----------%
                        %-------------------------------%
                        
    %[P1] switches the paths depending on status. Doesn't do anything for
    %status 0, which is convenient
    
    %if the member is going row-wise first
    if pathStruct(member).status == 1
        
        %only loops through the middle parts of the array (not the first
        %and last points, which won't change)
        for point = curDelay + 2:mdist + curDelay
            
            if strcmpi(pathStruct(member).cardinal,'EN')
            
                switchRow = path(point,1) - 1;
                switchCol = path(point,2) + 1;

                while (switchRow ~= startRow) && (switchCol ~= endCol)
                    switchRow = switchRow - 1;
                    switchCol = switchCol + 1;
                end

                %newPath updates with the switched point
                newPath(point,:) = [switchRow, switchCol];
                
            elseif strcmpi(pathStruct(member).cardinal,'WN')
                
                switchRow = path(point,1) + 1;
                switchCol = path(point,2) + 1;

                while (switchRow ~= startRow) && (switchCol ~= endCol)
                    switchRow = switchRow + 1;
                    switchCol = switchCol + 1;
                end

                newPath(point,:) = [switchRow, switchCol];
                
            elseif strcmpi(pathStruct(member).cardinal,'ES')
                
                switchRow = path(point,1) - 1;
                switchCol = path(point,2) - 1;

                while (switchRow ~= startRow) && (switchCol ~= endCol)
                    switchRow = switchRow - 1;
                    switchCol = switchCol - 1;
                end

                newPath(point,:) = [switchRow, switchCol];
                
            elseif strcmpi(pathStruct(member).cardinal,'WS')
                
                switchRow = path(point,1) + 1;
                switchCol = path(point,2) - 1;

                while (switchRow ~= startRow) && (switchCol ~= endCol)
                    switchRow = switchRow + 1;
                    switchCol = switchCol - 1;
                end

                newPath(point,:) = [switchRow, switchCol];
                
            end
        end
        
        newPathStruct(member).path = newPath;
        newPathStruct(member).status = 2;
        
    %if the member is going col-wise first - everything is the same
    %function as above but reversed
    elseif pathStruct(member).status == 2
        
        for point = curDelay + 2:mdist + curDelay
            
            if strcmpi(pathStruct(member).cardinal,'NE')
            
                switchRow = path(point,1) + 1;
                switchCol = path(point,2) - 1;

                while (switchRow ~= endRow) && (switchCol ~= startCol)
                    switchRow = switchRow + 1;
                    switchCol = switchCol - 1;
                end

                %newPath updates with the switched point
                newPath(point,:) = [switchRow, switchCol];
                
            elseif strcmpi(pathStruct(member).cardinal,'NW')
                
                switchRow = path(point,1) - 1;
                switchCol = path(point,2) - 1;

                while (switchRow ~= endRow) && (switchCol ~= startCol)
                    switchRow = switchRow - 1;
                    switchCol = switchCol - 1;
                end

                newPath(point,:) = [switchRow, switchCol];
                
            elseif strcmpi(pathStruct(member).cardinal,'SE')
                
                switchRow = path(point,1) + 1;
                switchCol = path(point,2) + 1;

                while (switchRow ~= endRow) && (switchCol ~= startCol)
                    switchRow = switchRow + 1;
                    switchCol = switchCol + 1;
                end

                newPath(point,:) = [switchRow, switchCol];
                
            elseif strcmpi(pathStruct(member).cardinal,'SW')
                
                switchRow = path(point,1) - 1;
                switchCol = path(point,2) + 1;

                while (switchRow ~= endRow) && (switchCol ~= startCol)
                    switchRow = switchRow - 1;
                    switchCol = switchCol + 1;
                end

                newPath(point,:) = [switchRow, switchCol];
                
            end
        end
        
        newPathStruct(member).path = newPath;
        newPathStruct(member).status = 1;
        
    end
    %[/P1]
    
    %defines the new cardinal instructions by flipping the old one
    newCardinal = fliplr(pathStruct(member).cardinal);
    newPathStruct(member).cardinal = newCardinal;
    
    %increases the number of switches that member has made.
    newPathStruct(member).switches = newPathStruct(member).switches + 1;
    
end