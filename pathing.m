%CAL BAND TRANSITIONS PROJECT%
%FILE - optimizes the path that the members of the cal band travel along

%CODED BY: Albert Li, Rachel Jang, Rohan Chakraborty

%LAST UPDATED: 4/26/16, afternoon. Albert.

%FORMAT: -Variables initialized at the top followed by the processes.
%        -Each variable initialization is labelled as: [V#]
%        -Each process is labeled as: [P#]. Ends of processes are: [/P#]

%INPUTS: (1) mapStruct - the struct produced from "mapper"
%        (2) totMoves - the total moves in the transition

%OUTPUTS: (1) pathStruct - struct with 3 fields:
%             (i) member - the tag of the member of the cal band
%             (ii) path - an array containing the path that member of the
%             band will travel on
%             (iii) status - a logical with values either 0, 1, or 2. 0
%             means the member has no choice about their path (straight
%             line or doesn't move). 1 means the member goes row-wise
%             first. 2 means the member goes col-wise first.
%             (iv) wait - how long the member waits. This is initialized to
%             0. This value in pathStruct should be used solely for
%             collision detection purposes.
%             (v) cardinal - the direction the member will travel. Used for
%             collision detection purposes and can be switched with
%             "pathSwitch".
%             (vi) switches - how many times pathSwitch has been used on
%             this member. Once it reaches a certain value (arbitrarily
%             determined by me through testing) then the member will
%             instead be remapped. Used for collision detection only.

%--------------------------------------------------------------------------------------------%
%--------------------------------------------CODE--------------------------------------------%
%--------------------------------------------------------------------------------------------%

function [pathStruct] = pathing(mapStruct,totMoves)

                        %-------------------------------%
                        %-----------VARIABLES-----------%
                        %-------------------------------%
    
    %[V1] Initializes pathStruct
    pathStruct = struct;
    
    %[V2] Initializes nb
    nb = length(mapStruct);
    
                        %-------------------------------%
                        %-----------PROCESSES-----------%
                        %-------------------------------%    

    %[P1] - fills pathStruct with row travel then col travel (default)
    for member = 1:nb
        
        %initial and final row/cols for that member of the band
        ri = mapStruct(member).startRow;
        ci = mapStruct(member).startCol;
        rt = mapStruct(member).finalRow;
        ct = mapStruct(member).finalCol;
        %mdist for that member of the band
        mdist = mapStruct(member).mdist;
        
        %initializing the array containing the path of that member
        pathArray = zeros(totMoves+1,2);
        
        %[P1.1] rows and columns are the same
        if ri == rt && ci == ct
            
            %doesn't move
            for n = 1:totMoves+1
                pathArray(n,:) = [ri, ci];
            end
            
            status = 0;
            cardinal = '.';
            
        %[P1.2] %rows are the same, columns aren't
        elseif ri == rt && ci ~= ct
            
            %initializes the length of the column steps
            colArray = zeros(abs(ct-ci)+1,1);
            index = 1;
            
            %[P1.2.1]
            %you know it travels in a straight line, so creating the
            %pathing instructions is pretty easy. This is the same for the
            %other loops where either rows or cols stays the same.
            if ci < ct
                for colStep = ci:ct
                    colArray(index) = colStep;
                    index = index + 1;
                end
                
                %rowArray is just the initial (and final) value the whole
                %time
                rowArray = ones(abs(ct-ci)+1,1)*ri;
                %the path is just both of them together
                pathArray = [rowArray, colArray];
                
                status = 0;
                cardinal = 'N';
                
            %[P1.2.2]
            elseif ci > ct
                for colStep = ci:-1:ct
                    colArray(index) = colStep;
                    index = index + 1;
                end
                
                rowArray = ones(abs(ct-ci)+1,1)*ri;
                pathArray = [rowArray, colArray];
               
                status = 0;
                cardinal = 'S';
                
            end
        %[/P1.2] rows same, cols different
            
        %[P1.3] %columns are the same, rows aren't
        elseif ri ~= rt && ci == ct
            
            rowArray = zeros(abs(rt-ri)+1,1);
            index = 1;
            
            %[P1.3.1]
            if ri < rt
                for rowStep = ri:rt
                    rowArray(index) = rowStep;
                    index = index + 1;
                end
                
                colArray = ones(abs(rt-ri)+1,1)*ci;
                pathArray = [rowArray, colArray];
            
                status = 0;
                cardinal = 'E';
                
            %[P1.3.2]
            elseif ri > rt
                for rowStep = ri:-1:rt
                    rowArray(index) = rowStep;
                    index = index + 1;
                end
                
                colArray = ones(abs(rt-ri)+1,1)*ci;
                pathArray = [rowArray, colArray];
                
                status = 0;
                cardinal = 'W';
                
            end
        %[P1.3] rows different, cols same
        
        %[P1.4] Neither rows nor cols are the same. Most common case. This
        %case is a bit different than the other ones because there is a
        %turn at some point. We initialize the pathing instructions to
        %always travel ROW-WISE then COL-WISE. Fill in the row values up
        %until the turn is made. Then all the row values are just the final
        %row value. Meanwhile, the col values are all the initial col value
        %until the turn is made. Then, col starts incrementing from ci to
        %ct.
        elseif ri ~= rt && ci ~= ct
            
            %[P1.4.1]
            if ri < rt && ci < ct
                
                index = 1;
                rowArray = ones(mdist+1,1)*rt;
                for rowStep = ri:rt
                    rowArray(index) = rowStep;
                    index = index + 1;
                end
                
                index = abs(rt-ri)+1;
                colArray = ones(mdist+1,1)*ci;
                for colStep = ci:ct
                    
                    colArray(index) = colStep;
                    index = index + 1;
                end
                
                pathArray = [rowArray, colArray];
                
                status = 1;
                cardinal = 'EN';
                
            elseif ri < rt && ci > ct
                
                index = 1;
                rowArray = ones(mdist+1,1)*rt;
                for rowStep = ri:rt
                    rowArray(index) = rowStep;
                    index = index + 1;
                end
                
                index = abs(rt-ri)+1;
                colArray = ones(mdist+1,1)*ci;
                for colStep = ci:-1:ct
                    colArray(index) = colStep;
                    index = index + 1;
                end
                
                pathArray = [rowArray, colArray];
                
                status = 1;
                cardinal = 'ES';
                
            elseif ri > rt && ci < ct
                
                index = 1;
                rowArray = ones(mdist+1,1)*rt;
                for rowStep = ri:-1:rt
                    rowArray(index) = rowStep;
                    index = index + 1;
                end
                
                index = abs(rt-ri)+1;
                colArray = ones(mdist+1,1)*ci;
                for colStep = ci:ct
                    colArray(index) = colStep;
                    index = index + 1;
                end
                
                pathArray = [rowArray, colArray];
                
                status = 1;
                cardinal = 'WN';
                
            elseif ri > rt && ci > ct
                
                index = 1;
                rowArray = ones(mdist+1,1)*rt;
                for rowStep = ri:-1:rt
                    rowArray(index) = rowStep;
                    index = index + 1;
                end
                
                index = abs(rt-ri)+1;
                colArray = ones(mdist+1,1)*ci;
                for colStep = ci:-1:ct
                    colArray(index) = colStep;
                    index = index + 1;
                end
                
                pathArray = [rowArray, colArray];
                
                status = 1;
                cardinal = 'WS';
                
            end
            
        %[/P1.4]
        
        end %end of P1 if statements
        
        for n = mdist+2:totMoves+1
            pathArray(n,:) = [rt ct];
        end
        
        pathStruct(member).member = member;
        pathStruct(member).path = pathArray;
        pathStruct(member).status = status;
        pathStruct(member).wait = 0;
        pathStruct(member).cardinal = cardinal;
        pathStruct(member).switches = 0;
        
    end
    %[/P1]
    
end