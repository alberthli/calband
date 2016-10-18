%CAL BAND TRANSITIONS PROJECT%
%FILE - function that takes in default generated configurations and
%determines whether changes should be made (and what) based on the collisions

%CODED BY: Albert Li, Rachel Jang, Rohan Chakraborty

%LAST UPDATED: 4/28/16, night. Albert.

%FORMAT: -Variables initialized at the top followed by the processes.
%        -Each variable initialization is labelled as: [V#]
%        -Each process is labeled as: [P#]. Ends of processes are: [/P#]

%INPUTS: (1) initial_formation - the array containing the tagged members of
%            the cal band
%        (2) totMoves - total moves
%        (3) rangeStruct - the rangeStruct output from "rangeConstruct"
%        (4) mapStruct - the mapStruct output from "mapper"
%        (5) pathStruct - the pathStruct output from "pathing"
%        (6) allCollisions - the collisions struct array output from
%        "collisionDetect"

%OUTPUTS: (1) instructions - the final goodz
    
%TO-DO:
%         (1) resolve common collision code
%         (2) fix overlapping path problem

% WARNING - there are 2 "toc"s in this file that need to be set to whatever
% value you want to cap the function's run time as in seconds.

%--------------------------------------------------------------------------------------------%
%--------------------------------------------CODE--------------------------------------------%
%--------------------------------------------------------------------------------------------%

function [instructions] = collisionFixer(initial_formation,totMoves,rangeStruct,mapStruct,pathStruct,allCollisions)

                        %-------------------------------%
                        %----------SUBFUNCTION----------%
                        %-------------------------------%

    %[SF1] remaps a point by changing the rangeStruct and then remapping it
    %at the bottom of the function
    function newRangeStruct = remap(rangeIndex,init,tempRangeStruct)
        
        newRangeStruct = tempRangeStruct;
        innerLoopSize = tempRangeStruct(rangeIndex).m;
        memberArray = tempRangeStruct(rangeIndex).members;
        mdistArray = tempRangeStruct(rangeIndex).mdist;

        for innerIndex = 1:innerLoopSize
            if isequal(memberArray(innerIndex,:),init)
                
                memberArray(innerIndex,:) = [];
                mdistArray(innerIndex,:) = [];
                newRangeStruct(rangeIndex).members = memberArray;
                newRangeStruct(rangeIndex).mdist = mdistArray;
                newRangeStruct(rangeIndex).tags(innerIndex,:) = [];
                newRangeStruct(rangeIndex).m = tempRangeStruct(rangeIndex).m - 1;
                break
                
            end
        end
    end
                        
                        %-------------------------------%
                        %-----------VARIABLES-----------%
                        %-------------------------------%
                        
    %[V1] initializing instructions as a struct
    instructions = struct;
    
    %[V2] initializing temporary structs for manipulation and recursive
    %calls
    tempRangeStruct = rangeStruct;
    tempMapStruct = mapStruct;
    tempPathStruct = pathStruct;
    
    %[V3] initializing a variable determining whether the collision fixing
    %is complete. If it is, then complete stays 1. Otherwise, it is
    %assigned 0 and collisionFixer recursively calls itself again.
    complete = 1;
    
    %[V4] initializing a variable determining whether the mapStruct needs
    %to be regenerated based on a change in rangeStruct
    changeMap = 0;
    
    %[V5] initializing a variable that indicates whether a delay was made
    changeDelay = 0;
    
    %[V6] number of members
    nb = length(mapStruct);
    
                        %-------------------------------%
                        %-----------PROCESSES-----------%
                        %-------------------------------%
                        
    %this process is set to terminate after 3 minutes in total have passed.
    %the stopwatch begins in calband_transition
    while toc<180
        
        %[P1] All alterations to pathing/mapping occur here                    
        for move = 2:length(allCollisions)-1

            %There is at least one collision at move
            if ~isempty(fieldnames(allCollisions(move).collisionData))

                %if there's a collision, recheck to see if the correction was
                %made correctly
                complete = 0;
                
                numCollisions = length(allCollisions(move).collisionData);

                %for each collision, analyze the paths of the colliding members
                for collision = 1:numCollisions
                    numMembers = numel(allCollisions(move).collisionData(collision).members);

                    %***2-MEMBER COLLISION CASES***
                    %Cases 1-4 are for HEAD-ON collisions. Case 4 also
                    %covers the situation where members travel along the
                    %same line and are continuously colliding
                    %Cases 5-6 are for cases where the member collides into
                    %another member that has completed its transition
                    %[P1.1]
                    if numMembers == 2

                        member1 = allCollisions(move).collisionData(collision).members(1);
                        member2 = allCollisions(move).collisionData(collision).members(2);
                        mdist1 = tempMapStruct(member1).mdist;
                        mdist2 = tempMapStruct(member2).mdist;
                        wait1 = tempPathStruct(member1).wait/2;
                        wait2 = tempPathStruct(member2).wait/2;
                        dest1 = [mapStruct(member1).finalRow, mapStruct(member1).finalCol];
                        dest2 = [mapStruct(member2).finalRow, mapStruct(member2).finalCol];
                        init1 = [mapStruct(member1).startRow, mapStruct(member1).startCol];
                        init2 = [mapStruct(member2).startRow, mapStruct(member2).startCol];
                        
                        %retrieving the data associated with colliding members
                        %from rangeStruct in case of re-mapping
                        for point = 1:nb
                            if isequal(dest1,rangeStruct(point).point)
                                m1 = rangeStruct(point).m;
                                rangeIndex1 = point;
                            elseif isequal(dest2,rangeStruct(point).point)
                                m2 = rangeStruct(point).m;
                                rangeIndex2 = point;
                            end
                        end

                        %[P1.1.1] CASE 1 - if both of them can't change path, then you need to
                        %reassign the final destination of one of them by
                        %changing the rangeStruct and then recursively running
                        %it again.
                        if (strcmpi(tempPathStruct(member1).cardinal,'N') && strcmpi(tempPathStruct(member2).cardinal,'S')) || (strcmpi(tempPathStruct(member1).cardinal,'S') && strcmpi(tempPathStruct(member2).cardinal,'N')) || (strcmpi(tempPathStruct(member1).cardinal,'E') && strcmpi(tempPathStruct(member2).cardinal,'W')) || (strcmpi(tempPathStruct(member1).cardinal,'W') && strcmpi(tempPathStruct(member2).cardinal,'E')) || ((strcmpi(tempPathStruct(member1).cardinal,'.') && tempPathStruct(member2).status == 0) || (strcmpi(tempPathStruct(member2).cardinal,'.') && tempPathStruct(member1).status == 0))

                            changeMap = 1;

                            %changes the destination point of the one with
                            %greater than or equal mdist or there's only one
                            %member in range of member2
                            if (m1 > 1 && mapStruct(member1).mdist >= mapStruct(member2).mdist) || (m2 == 1)
                                
                                tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);

                            %If member2 has a higher mdist then it's changed
                            elseif m2 > 1
                                
                                tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);

                            end
                        %[/P1.1.1]

                        %[P1.1.2] CASE 2 - member 1 can't change paths. sees all
                        %the possibilities for member 2.
                        elseif tempPathStruct(member1).status == 0 && tempPathStruct(member2).status ~= 0

                            prevSpace1 = [tempPathStruct(member1).path(move-1,1),tempPathStruct(member1).path(move-1,2)];
                            curSpace1 = [tempPathStruct(member1).path(move,1),tempPathStruct(member1).path(move,2)];
                            prevSpace2 = [tempPathStruct(member2).path(move-1,1),tempPathStruct(member2).path(move-1,2)];
                            curSpace2 = [tempPathStruct(member2).path(move,1),tempPathStruct(member2).path(move,2)];

                            %Covers all possibilities for member1's path.
                            %if member1 can't move at all, member2 should
                            %switch paths
                            if strcmpi(tempPathStruct(member1).cardinal,'.')
                                
                                if tempPathStruct(member2).switches<1
                                    tempPathStruct = pathSwitch(tempPathStruct,mapStruct,member2);
                                    tempPathStruct(member2).switches = tempPathStruct(member2).switches+1;
                                elseif m2>1
                                    
                                    changeMap = 1;
                                    
                                    tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);
                                end

                            %if member1 can only go east and member 2 collided
                            %with it when heading west, member2 should switch
                            %paths
                            elseif strcmpi(tempPathStruct(member1).cardinal,'E')

                                if prevSpace2(1) == curSpace2(1) + 1
                                    if tempPathStruct(member2).switches<1
                                        tempPathStruct = pathSwitch(tempPathStruct,mapStruct,member2);
                                        tempPathStruct(member2).switches = tempPathStruct(member2).switches+1;
                                    elseif m2>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);
                                    end
                                end

                            %same as above with different direction
                            elseif strcmpi(tempPathStruct(member1).cardinal,'S')

                                if prevSpace2(2) == curSpace2(2) - 1
                                    if tempPathStruct(member2).switches<1
                                        tempPathStruct = pathSwitch(tempPathStruct,mapStruct,member2);
                                        tempPathStruct(member2).switches = tempPathStruct(member2).switches+1;
                                    elseif m2>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);
                                    end
                                end

                            elseif strcmpi(tempPathStruct(member1).cardinal,'W')

                                if prevSpace2(1) == curSpace2(1) - 1
                                    if tempPathStruct(member2).switches<1
                                        tempPathStruct = pathSwitch(tempPathStruct,mapStruct,member2);
                                        tempPathStruct(member2).switches = tempPathStruct(member2).switches+1;
                                    elseif m2>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);
                                    end
                                end

                            elseif strcmpi(tempPathStruct(member1).cardinal,'N')

                                if prevSpace2(2) == curSpace2(2) + 1
                                    if tempPathStruct(member2).switches<1
                                        tempPathStruct = pathSwitch(tempPathStruct,mapStruct,member2);
                                        tempPathStruct(member2).switches = tempPathStruct(member2).switches+1;
                                    elseif m2>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);
                                    end
                                end

                            elseif isequal(prevSpace1,prevSpace2) && isequal(curSpace1,curSpace2)

                                changeDelay = 1;

                                if mdist1<=mdist2 && wait1+mdist1<=totMoves-1
                                    tempPathStruct = delay(tempPathStruct,member1,wait1+1);

                                elseif wait2+mdist2<=totMoves-1
                                    tempPathStruct = delay(tempPathStruct,member2,wait1+1);

                                elseif mdist1>mdist2 && m1>1

                                    changeMap = 1;

                                    tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);

                                elseif m2>1

                                    changeMap = 1;

                                    tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);

                                end
                                
                            end
                        %[/P1.1.2]

                        %[P1.1.3] CASE 3 - reverse of CASE 2 (switch member1 and member2)
                        elseif tempPathStruct(member2).status == 0 && tempPathStruct(member1).status ~= 0

                            prevSpace1 = [tempPathStruct(member1).path(move-1,1),tempPathStruct(member1).path(move-1,2)];
                            curSpace1 = [tempPathStruct(member1).path(move,1),tempPathStruct(member1).path(move,2)];
                            prevSpace2 = [tempPathStruct(member2).path(move-1,1),tempPathStruct(member2).path(move-1,2)];
                            curSpace2 = [tempPathStruct(member2).path(move,1),tempPathStruct(member2).path(move,2)];

                            if strcmpi(tempPathStruct(member2).cardinal,'.')
                                if tempPathStruct(member1).switches<1
                                    
                                    tempPathStruct = pathSwitch(tempPathStruct,tempMapStruct,member1);
                                    tempPathStruct(member1).switches = tempPathStruct(member1).switches + 1;
                                    
                                elseif m1>1
                                    
                                    changeMap = 1;
                                    
                                    tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);
                                end

                            elseif strcmpi(tempPathStruct(member2).cardinal,'E')

                                if prevSpace1(1) == curSpace1(1) + 1
                                    if tempPathStruct(member1).switches<1
                                    
                                        tempPathStruct = pathSwitch(tempPathStruct,tempMapStruct,member1);
                                        tempPathStruct(member1).switches = tempPathStruct(member1).switches + 1;

                                    elseif m1>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);
                                    end
                                end

                            elseif strcmpi(tempPathStruct(member2).cardinal,'S')

                                if prevSpace1(2) == curSpace1(2) - 1
                                    if tempPathStruct(member1).switches<1
                                    
                                        tempPathStruct = pathSwitch(tempPathStruct,tempMapStruct,member1);
                                        tempPathStruct(member1).switches = tempPathStruct(member1).switches + 1;

                                    elseif m1>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);
                                    end
                                end

                            elseif strcmpi(tempPathStruct(member2).cardinal,'W')

                                if prevSpace1(1) == curSpace1(1) - 1
                                    if tempPathStruct(member1).switches<1
                                    
                                        tempPathStruct = pathSwitch(tempPathStruct,tempMapStruct,member1);
                                        tempPathStruct(member1).switches = tempPathStruct(member1).switches + 1;

                                    elseif m1>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);
                                    end
                                end

                            elseif strcmpi(tempPathStruct(member2).cardinal,'N')

                                if prevSpace1(2) == curSpace1(2) + 1
                                    if tempPathStruct(member1).switches<1
                                    
                                        tempPathStruct = pathSwitch(tempPathStruct,tempMapStruct,member1);
                                        tempPathStruct(member1).switches = tempPathStruct(member1).switches + 1;

                                    elseif m1>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);
                                    end
                                end

                            elseif isequal(prevSpace1,prevSpace2) && isequal(curSpace1,curSpace2)

                                changeDelay = 1;

                                if mdist1<=mdist2 && wait1+mdist1<=totMoves-1
                                    tempPathStruct = delay(tempPathStruct,member1,wait1+1);

                                elseif wait2+mdist2<=totMoves-1
                                    tempPathStruct = delay(tempPathStruct,member2,wait1+1);

                                elseif mdist1>mdist2 && m1>1

                                    changeMap = 1;

                                    tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);

                                elseif m2>1

                                    changeMap = 1;

                                    tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);

                                end
                                
                            end
                        %[/P1.1.3]

                        %[P1.1.4] CASE 4 - both members can change paths.
                        elseif tempPathStruct(member1).status ~= 0 && tempPathStruct(member2).status ~= 0

                            prevSpace1 = [tempPathStruct(member1).path(move-1,1),tempPathStruct(member1).path(move-1,2)];
                            curSpace1 = [tempPathStruct(member1).path(move,1),tempPathStruct(member1).path(move,2)];
                            prevSpace2 = [tempPathStruct(member2).path(move-1,1),tempPathStruct(member2).path(move-1,2)];
                            curSpace2 = [tempPathStruct(member2).path(move,1),tempPathStruct(member2).path(move,2)];

                            %member1 going N, member2 going S
                            if prevSpace1(2) < curSpace1(2) && prevSpace2(2) > curSpace2(2)
                                if mapStruct(member1).mdist <= mapStruct(member2).mdist
                                    if tempPathStruct(member1).switches<4
                                    
                                        tempPathStruct = pathSwitch(tempPathStruct,tempMapStruct,member1);
                                        tempPathStruct(member1).switches = tempPathStruct(member1).switches + 1;

                                    elseif m1>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);
                                    end
                                    
                                elseif mapStruct(member2).mdist < mapStruct(member1).mdist
                                    if tempPathStruct(member2).switches<4
                                        tempPathStruct = pathSwitch(tempPathStruct,mapStruct,member2);
                                        tempPathStruct(member2).switches = tempPathStruct(member2).switches+1;
                                    elseif m2>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);
                                    end
                                end

                            %member1 going S, member2 going N
                            elseif prevSpace1(2) > curSpace1(2) && prevSpace2(2) < curSpace2(2)
                                if mapStruct(member1).mdist <= mapStruct(member2).mdist
                                    if tempPathStruct(member1).switches<4
                                    
                                        tempPathStruct = pathSwitch(tempPathStruct,tempMapStruct,member1);
                                        tempPathStruct(member1).switches = tempPathStruct(member1).switches + 1;

                                    elseif m1>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);
                                    end
                                    
                                elseif mapStruct(member2).mdist < mapStruct(member1).mdist
                                    if tempPathStruct(member2).switches<4
                                        tempPathStruct = pathSwitch(tempPathStruct,mapStruct,member2);
                                        tempPathStruct(member2).switches = tempPathStruct(member2).switches+1;
                                    elseif m2>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);
                                    end
                                end

                            %member1 going E, member2 going W
                            elseif prevSpace1(1) < curSpace1(1) && prevSpace2(1) > curSpace2(1)
                                if mapStruct(member1).mdist <= mapStruct(member2).mdist
                                    if tempPathStruct(member1).switches<4
                                    
                                        tempPathStruct = pathSwitch(tempPathStruct,tempMapStruct,member1);
                                        tempPathStruct(member1).switches = tempPathStruct(member1).switches + 1;

                                    elseif m1>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);
                                    end
                                    
                                elseif mapStruct(member2).mdist < mapStruct(member1).mdist
                                    if tempPathStruct(member2).switches<4
                                        tempPathStruct = pathSwitch(tempPathStruct,mapStruct,member2);
                                        tempPathStruct(member2).switches = tempPathStruct(member2).switches+1;
                                    elseif m2>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);
                                    end
                                end

                            %member1 going W, member2 going E
                            elseif prevSpace1(1) > curSpace1(1) && prevSpace2(1) < curSpace2(1)
                                if mapStruct(member1).mdist <= mapStruct(member2).mdist
                                    if tempPathStruct(member1).switches<4
                                    
                                        tempPathStruct = pathSwitch(tempPathStruct,tempMapStruct,member1);
                                        tempPathStruct(member1).switches = tempPathStruct(member1).switches + 1;

                                    elseif m1>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);
                                    end
                                    
                                elseif mapStruct(member2).mdist < mapStruct(member1).mdist
                                    if tempPathStruct(member2).switches<4
                                        tempPathStruct = pathSwitch(tempPathStruct,mapStruct,member2);
                                        tempPathStruct(member2).switches = tempPathStruct(member2).switches+1;
                                    elseif m2>1

                                        changeMap = 1;

                                        tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);
                                    end
                                end
                                
                            %mini case where members are travelling along
                            %the same path and colliding at each step
                            elseif isequal(prevSpace1,prevSpace2) && isequal(curSpace1,curSpace2)
                                
                                changeDelay = 1;
                                
                                if mdist1<=mdist2 && wait1+mdist1<=totMoves-1
                                    tempPathStruct = delay(tempPathStruct,member1,wait1+1);
                                    
                                elseif wait2+mdist2<=totMoves-1
                                    tempPathStruct = delay(tempPathStruct,member2,wait1+1);
                                    
                                elseif mdist1>mdist2 && m1>1
                                    
                                    changeMap = 1;
                                    
                                    tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);
                                    
                                elseif m2>1
                                    
                                    changeMap = 1;
                                    
                                    tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);
                                    
                                end
                                
                            elseif (strcmpi(tempPathStruct(member1).cardinal,'N') && ~strcmpi(tempPathStruct(member2).cardinal,'S')) || (strcmpi(tempPathStruct(member1).cardinal,'S') && ~strcmpi(tempPathStruct(member2).cardinal,'N')) || (strcmpi(tempPathStruct(member1).cardinal,'E') && ~strcmpi(tempPathStruct(member2).cardinal,'W')) || (strcmpi(tempPathStruct(member1).cardinal,'W') && ~strcmpi(tempPathStruct(member2).cardinal,'E'))
                                
                                changeDelay = 1;
                                
                                if mdist1<=mdist2 && wait1+mdist1<=totMoves-1
                                    tempPathStruct = delay(tempPathStruct,member1,wait1+1);
                                    
                                elseif wait2+mdist2<=totMoves-1
                                    tempPathStruct = delay(tempPathStruct,member2,wait1+1);
                                    
                                elseif mdist1>mdist2 && m1>1
                                    
                                    changeMap = 1;
                                    
                                    tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);
                                    
                                elseif m2>1
                                    
                                    changeMap = 1;
                                    
                                    tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);
                                    
                                end
                                
                            end
                        %[/P1.1.4]
                        
                        %[P1.1.5] CASE 5 - if member1 has reached
                        %its final destination and member2 is colliding
                        %into it
                        elseif isequal(allCollisions(move).collisionData(collision).point,dest1)
                            
                            if tempPathStruct(member2).switches<1
                                
                                tempPathStruct = pathSwitch(tempPathStruct,mapStruct,member2);
                                tempPathStruct(member2).switches = tempPathStruct(member2).switches+1;
                                
                            elseif m2>1
                                    
                                changeMap = 1;

                                tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);
                                
                            end
                        %[/P1.1.5]
                        
                        %[P1.1.6] CASE 6 - reverse of case 5
                        elseif isequal(allCollisions(move).collisionData(collision).point,dest2)
                            
                            if tempPathStruct(member1).switches<1
                                
                                tempPathStruct = pathSwitch(tempPathStruct,mapStruct,member1);
                                tempPathStruct(member1).switches = tempPathStruct(member1).switches+1;
                                
                            elseif m1>1
                                    
                                changeMap = 1;

                                tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);
                            end
                        %[/P1.1.6]

                        %[P1.1.7] CASE 7 - everything else. Just delays.
                        else
                            changeDelay = 1;
                                
                            if mdist1<=mdist2 && wait1+mdist1<=totMoves-1
                                tempPathStruct = delay(tempPathStruct,member1,wait1+1);

                            elseif wait2+mdist2<=totMoves-1
                                tempPathStruct = delay(tempPathStruct,member2,wait1+1);

                            elseif mdist1>mdist2 && m1>1

                                changeMap = 1;

                                tempRangeStruct = remap(rangeIndex1,init1,tempRangeStruct);

                            elseif m2>1

                                changeMap = 1;

                                tempRangeStruct = remap(rangeIndex2,init2,tempRangeStruct);

                            end
                        %[/P1.1.7]
                        
                        end
                    %[/P1.1]

                    %***N-MEMBER COLLISION CASES. N>2***
                    %Try to reduce these cases to just a 2 collision case. Try
                    %to let the recursive looping handle them.
                    %[P1.2]
                    else
                        
                        %problematic temporary solution
                        for n = 1:length(allCollisions(move).collisionData(collision).members) - 2
                            
                            bandMember = allCollisions(move).collisionData(collision).members(n);
                            dest = [mapStruct(bandMember).finalRow, mapStruct(bandMember).finalCol];
                            init = [mapStruct(bandMember).startRow, mapStruct(bandMember).startCol];
                            
                            for point = 1:nb
                                if isequal(dest,rangeStruct(point).point)
                                    rangeIndex = point;
                                end
                            end
                            
                            if tempPathStruct(bandMember).switches<1
                                
                                tempPathStruct = pathSwitch(tempPathStruct,mapStruct,bandMember);
                                tempPathStruct(bandMember).switches = tempPathStruct(bandMember).switches+1;
                                
                            elseif tempMapStruct(bandMember).mdist + (tempPathStruct(bandMember).wait/2) <= totMoves - n
                                tempPathStruct(bandMember).wait = tempPathStruct(bandMember).wait + 2*n;
                                
                            else
                                tempRangeStruct = remap(rangeIndex,init,tempRangeStruct);
                                
                            end
                            
                        end
                        
                    end
                    %[/P1.2]
                    
                end
            end
            
            if changeMap == 1 || changeDelay == 1
                break
            end
            
        end
        %[/P1]
        
        if changeMap == 1 || changeDelay == 1
            break
        end
        
    end
    
    %[P2] fills the instructions array
    if complete == 1 || toc>180
        for member = 1:nb
            instructions(member).i_target = tempMapStruct(member).finalRow;
            instructions(member).j_target = tempMapStruct(member).finalCol;
            instructions(member).wait = tempPathStruct(member).wait;
            instructions(member).direction = tempPathStruct(member).cardinal;
            
            struct2table(collisionDetect(tempMapStruct,tempPathStruct,totMoves))
            struct2table(tempRangeStruct)
            struct2table(tempMapStruct)
            struct2table(tempPathStruct)
            
        end
    else
        
        %needs to recalculate the structs if corrections were made
        if changeMap == 1
            tempMapStruct = mapper(initial_formation,tempRangeStruct);
            tempPathStruct = pathing(tempMapStruct,totMoves);
        end
        
        %recursively calls collisionFixer
        instructions = collisionFixer(initial_formation,totMoves,tempRangeStruct,tempMapStruct,tempPathStruct,collisionDetect(tempMapStruct,tempPathStruct,totMoves));
    end
    %[/P2]
end