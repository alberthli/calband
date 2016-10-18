%CAL BAND TRANSITIONS PROJECT%
%FILE - detects the collisions in the current path configuration of members of the cal band

%CODED BY: Albert Li, Rachel Jang, Rohan Chakraborty

%LAST UPDATED: 4/28/16, afternoon. Albert.

%FORMAT: -Variables initialized at the top followed by the processes.
%        -Each variable initialization is labelled as: [V#]
%        -Each process is labeled as: [P#]. Ends of processes are: [/P#]

%INPUTS: (1) mapStruct - struct from "mapper"
%        (2) pathStruct - the struct produced from the start of "pathing"
%        (3) totMoves - total number of moves you can make

%OUTPUTS: (1) allCollisions - a struct containing the collisionData for
%             each move. It has one field, collisionData, which is a
%             struct. This struct has two further fields:
%             (i) point - the destination points where there are collisions
%             at that move slice
%             (ii) members - the members of the cal band that are at that
%             point during that move slice

%--------------------------------------------------------------------------------------------%
%--------------------------------------------CODE--------------------------------------------%
%--------------------------------------------------------------------------------------------%

function [allCollisions] = collisionDetect(mapStruct, pathStruct, totMoves)

                        %-------------------------------%
                        %-----------VARIABLES-----------%
                        %-------------------------------%

    %[V1] initializes nb                    
    nb = length(mapStruct);

    %[V2] initializes the array that will indicate every member's position
    %at every time. will be used for collision testing
    timeArray = ones(nb,totMoves+1,2);
    
                        %-------------------------------%
                        %-----------PROCESSES-----------%
                        %-------------------------------%    
    
    %[P1] filling the timeArray with values from pathStruct
    for member = 1:nb
       timeArray(member,:,1) = pathStruct(member).path(:,1);
       timeArray(member,:,2) = pathStruct(member).path(:,2);
    end
    %[/P1]
    
    %[P2] gathering collision data
    %[P2 - V1] struct with one field, collisionData, which is also a
    %struct. There is a collisionData for each move, indicating at that
    %move which points have collisions and which members of the cal band
    %collide at that point.
    allCollisions = struct;
    
    %loops through the total moves (makes collisionData for each move)
    for move = 1:totMoves + 1
        %slice at that time with all coordinates.
        moveSlice = [timeArray(:,move,1),timeArray(:,move,2)];
        
        %this chunk is pretty convoluted, but it determines the points of
        %collision and which members are colliding. It doesn't determine
        %which members collide at which points
        [distinctPoints,~,uniqueIndices] = unique(moveSlice,'rows');
        pointsOfCollision = distinctPoints(hist(uniqueIndices,1:numel(moveSlice)/2) > 1,:);
        collidingMembers = find(ismember(moveSlice,pointsOfCollision,'rows'));
        
        %initializes collisionStruct (which will be collisionData). Needs
        %to be newly initialized as an empty struct every iteration through
        %moves.
        collisionStruct = struct;
        
        %for the points of collision...
        for point = 1:size(pointsOfCollision,1)
            
            %record the point where a collision occurs
            collisionStruct(point).point = pointsOfCollision(point,:);
            
            %array that stores which members of the band crash at that
            %point
            crashArray = zeros(numel(collidingMembers),1);
            
            count = 0;
            
            %tests to see which of the colliding members crashes here
            for member = 1:numel(collidingMembers)
                memberLoc = [timeArray(collidingMembers(member),move,1),timeArray(collidingMembers(member),move,2)];
                
                %if it does crash, then it's added to the members list
                if isequal(memberLoc,pointsOfCollision(point,:))
                    count = count + 1;
                    crashArray(count) = collidingMembers(member);
                end
            end
            
            %crashArray is truncated then added to the collisionStruct
            crashArray = crashArray(1:count,:);
            
            if ~isempty(crashArray)
                collisionStruct(point).members = crashArray;
            else
                collisionStruct(point).members = [];
            end
            
        end
        
        allCollisions(move).move = move;
        allCollisions(move).collisionData = collisionStruct;
        
        if ~isempty(fieldnames(allCollisions(move).collisionData))
            allCollisions(move).collisions = length(allCollisions(move).collisionData);
        else
            allCollisions(move).collisions = 0;
        end
        
    end
    %[/P2]

end