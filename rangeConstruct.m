%CAL BAND TRANSITIONS PROJECT%
%FILE - This file makes a struct array that contains data about what
%members of the cal band are in range of each destination point (the points
%specified in the target formation). This is an intermediate result that
%will be used in the function "mapper."

%CODED BY: Albert Li, Rachel Jang, Rohan Chakraborty

%LAST UPDATED: 4/26/16, morning. Albert.

%FORMAT: -Variables initialized at the top followed by the processes.
%        -Each variable initialization is labelled as: [V#]
%        -Each process is labeled as: [P#]. Ends of processes are: [/P#]

%INPUTS: (1) initial_formation - the array containing the tagged members of
%            the cal band
%        (2) target_formation - the array containing the destination points
%        (3) totMoves - the maximum number of moves you can make (the beats
%            divided by 2)

%OUTPUTS: (1) rangeStruct - Struct with 6 fields:
%             (i) point - the coordinates of the destination point itself
%             (ii) m - the number of cal band members in range of the
%             destination point
%             (iii) mdist - array containing the Manhattan distances (the
%             grid distance, not Euclidean distance) of each of the members
%             of the band in range from the destination point
%             (iv) members - array containing the coordinates of the
%             members of the cal band in range. Matches up with the values
%             in mdist.
%             (v) mapped - logical that indicates whether a point has been
%             mapped yet. Relevant for the "mapped" function
%             (vi) tags - array of the tags of the members corresponding to
%             the points in "members"
%             (vii) priority - logical that indicates whether a point should
%             be prioritized (calculated from the algorithm in "mapped")

%--------------------------------------------------------------------------------------------%
%--------------------------------------------CODE--------------------------------------------%
%--------------------------------------------------------------------------------------------%

function [rangeStruct] = rangeConstruct(initial_formation,target_formation,totMoves)
    
                        %-------------------------------%
                        %-----------VARIABLES-----------%
                        %-------------------------------%

    %[V1] Number of members in the band
    nb = size(find(initial_formation),1);
    
    %[V2] Rows/Cols of the field
    [nr, nc] = size(target_formation);
    
    %[V3] Array with all the points of the members on the initial field
    [pointRow, pointCol] = find(initial_formation);
    allPoints = [pointRow, pointCol];
    
    %[V4] Initializing rangeStruct
    rangeStruct = struct;
    
    %[V5] Keeps track of how many destinations have been placed in
    %rangeStruct
    destinationCount = 1;
    
                        %-------------------------------%
                        %-----------PROCESSES-----------%
                        %-------------------------------%
    
    %[P1] Creates the rangeStruct holding information about the destination
    %points
    for row = 1:nr
        for col = 1:nc
            
            %Destination point at (row,col)
            if target_formation(row,col) ~= 0
                
                %[P1 - V1] Arrays hold data about the coordinates of
                %members in range of the destination as well as their
                %respective Manhattan Distances. pCount counts how many
                %points are in that range.
                pointsArray = zeros(nb,2);
                mdistArray = zeros(nb,1);
                pCount = 0;
                
                for members = 1:nb
                    
                    %defines each Manhattan distance of the member to the
                    %destination point
                    mdist = abs(allPoints(members,1)-row) + abs(allPoints(members,2)-col);
                    
                    %If it's in range
                    if mdist <= totMoves
                        
                        %store the mdist value and the coordinate,
                        %increment pCount
                        pCount = pCount + 1;
                        mdistArray(pCount) = mdist;
                        pointsArray(pCount,:) = [allPoints(members,1),allPoints(members,2)];
                    end
                    
                end
                
                %truncates arrays to correct size
                mdistArray = mdistArray(1:pCount,:);
                pointsArray = pointsArray(1:pCount,:);
                
                %temporarily combines arrays to sort them by shortest mdist
                combineArray = sortrows([mdistArray pointsArray]);
                
                %redefines both arrays
                mdistArray = combineArray(:,1);
                pointsArray = combineArray(:,2:3);
                tagArray = zeros(size(pointsArray,1),1);
                
                %lists tags of members
                for member = 1:size(pointsArray,1)
                    ri = pointsArray(member,1);
                    ci = pointsArray(member,2);
                    
                    tagArray(member) = initial_formation(ri,ci);
                end
                
                %creates fields for rangeStruct
                rangeStruct(destinationCount).point = [row, col];
                rangeStruct(destinationCount).m = pCount;
                rangeStruct(destinationCount).mdist = mdistArray;
                rangeStruct(destinationCount).members = pointsArray;
                rangeStruct(destinationCount).mapped = 0;
                rangeStruct(destinationCount).tags = tagArray;
                rangeStruct(destinationCount).priority = 0;
                
                destinationCount = destinationCount + 1;
                
            end
            
        end
    end
    %[/P1]
end