%CAL BAND TRANSITIONS PROJECT%
%FILE - maps the points in the initial formation one to one with the target
%formation's destination points

%CODED BY: Albert Li, Rachel Jang, Rohan Chakraborty

%LAST UPDATED: 3/24/16, morning. Albert.

%FORMAT: -Variables initialized at the top followed by the processes.
%        -Each variable initialization is labelled as: [V#]
%        -Each process is labeled as: [P#]. Ends of processes are: [/P#]

%INPUTS: (1) initial_formation - the array containing the tagged members of
%            the cal band 
%        (2) rangeStruct - the rangeStruct output from "rangeConstruct"

%OUTPUTS: (1) mapStruct - struct with 5 fields:
%             (i) member - the tag of the member of the cal band
%             (ii) startRow - the starting row of the member
%             (iii) startCol - the starting col of the member
%             (iv) finalRow - the row of the coordinate the member is mapped to
%             (v) finalCol - the col of the coordinate the member is mapped to
%             (vi) mdist - the Manhattan distance between the start and end
%             points of the member

%--------------------------------------------------------------------------------------------%
%--------------------------------------------CODE--------------------------------------------%
%--------------------------------------------------------------------------------------------%

function [mapStruct] = mapper(initial_formation,rangeStruct)

                        %-------------------------------%
                        %-----------VARIABLES-----------%
                        %-------------------------------%
                        
    %[V1] Variable keeping track of the lowest number of available members
    lowestm = intmax;

    %[V2] initializing mapStruct
    mapStruct = struct;
    
    %[V3] finding nb
    nb = length(rangeStruct);
    
    %[V4] making a temporary structure for manipulation
    tempStruct = rangeStruct;
    
    %[V5] making a structure in case the program needs to retry
    retryStruct = rangeStruct;
    
    %[V6] initializes variable determining how many points have been mapped
    mapped = 0;
    
    %[V7] initializes variable determining whether you need to retry the
    %algorithm given a different prioritization of points
    retry = 0;
    
                        %-------------------------------%
                        %-----------PROCESSES-----------%
                        %-------------------------------%
    
    %[P1] finds the lowest m
    for point = 1:nb
        if tempStruct(point).m<lowestm
            lowestm = tempStruct(point).m;
        end
    end
    %[/P1]

    %[P2 - V1] number of priority destination points
    priorityCount = 0;
    
    %[P2 - V2] initializes the prioritization variable
    highestPriority = 0;

    %[P2] gets priorityCount
    for point = 1:nb
        if tempStruct(point).priority ~= 0
            priorityCount = priorityCount + 1;
            
            %calculates the highest priority level
            if tempStruct(point).priority > highestPriority
                highestPriority = tempStruct(point).priority;
            end
            
        end
    end
    %[/P2]
    
    %[P3 - V1] - array containing the indices of the rangeStruct that
    %correspond to prioritized points. preallocated and will be truncated
    %later.
    priorityIndexArray = zeros(nb,1);
    
    %[P3 - V2] - initializing the variable explained below
    index = 0;
    
    %[P3]
    for point = 1:nb
        if tempStruct(point).priority ~= 0 && tempStruct(point).mapped == 0
            %index that tracks which indices of rangeStruct have priority
            %points
            index = index + 1;
            %these indices are stored in priorityIndexArray
            priorityIndexArray(index) = point;
            
        end
    end
    %the array is truncated to the right size
    priorityIndexArray = priorityIndexArray(1:index,:);
    %[/P3]
    
    %[P4] - if there are still prioritized points that are unmapped
    while priorityCount > 0

        %initializes the priority points with the lowest members in range
        %corresponding to it. Also initializes the highest closest distance
        %for those members.
        priorityLowestm = intmax;
        highestmdist = 0;
        
        %calculates the priorityLowestm and highestmdist
        for point = 1:nb
            %if the point is of the highest priority level and it hasn't
            %been mapped yet
            if tempStruct(point).priority == highestPriority && tempStruct(point).mapped == 0
                %if the members in range is less than the lowest currently
                %recorded
                if tempStruct(point).m < priorityLowestm
                    %replace the lowest m value
                    priorityLowestm = tempStruct(point).m;
                end
            end
        end
        
        for point = 1:nb
            %if the m value in the rangeStruct is the lowest, it's
            %unmapped, and it's a prioritized point
            if tempStruct(point).m == priorityLowestm && tempStruct(point).mapped == 0 && tempStruct(point).priority ~= 0
                %also if the closest distance is farther than the current
                %recorded farthest distance, then that distance is replaced
                if tempStruct(point).mdist(1) > highestmdist
                    highestmdist = tempStruct(point).mdist(1);
                end
            end
        end
        
        %array that holds the indices of the points that have highest
        %priority (these are mapped first)
        highPrioritySliceIndexArray = zeros(nb,1);
        sliceIndex = 0;
        empty = 1;
        
        %loops through all the priority points
        for point = 1:index
            %makes the highPrioritySliceArray
            if tempStruct(priorityIndexArray(point)).priority == highestPriority && tempStruct(priorityIndexArray(point)).mapped == 0
                sliceIndex = sliceIndex + 1;
                highPrioritySliceIndexArray(sliceIndex) = priorityIndexArray(point);
                empty = 0;
            end
        end
        
        %if this array doesn't have anything in it, then reduce the
        %priority level and rerun the while loop
        if empty
            highestPriority = highestPriority - 1;
            
        else
            
            %truncate the above array
            highPrioritySliceIndexArray = highPrioritySliceIndexArray(1:sliceIndex,:);
            
            %loop through highPriorityIndexArray
            for point = 1:size(highPrioritySliceIndexArray,1)
                
                %if the point is the one calculated above (farthest closest
                %distance and lowest m)
                if tempStruct(highPrioritySliceIndexArray(point)).mdist(1) == highestmdist && tempStruct(highPrioritySliceIndexArray(point)).m == priorityLowestm
                    
                    priorityCount = priorityCount - 1;
                    tempStruct(highPrioritySliceIndexArray(point)).mapped = 1;
                    memberCoord = tempStruct(highPrioritySliceIndexArray(point)).members(1,:);
                    
                    %defines rows and columns of member who's being mapped
                    mapRow = memberCoord(1);
                    mapCol = memberCoord(2);
                    
                    %fills mapStruct with the information found above
                    mapStruct(initial_formation(mapRow,mapCol)).member = initial_formation(mapRow,mapCol);
                    mapStruct(initial_formation(mapRow,mapCol)).startRow = mapRow;
                    mapStruct(initial_formation(mapRow,mapCol)).startCol = mapCol;
                    mapStruct(initial_formation(mapRow,mapCol)).finalRow = tempStruct(highPrioritySliceIndexArray(point)).point(1,1);
                    mapStruct(initial_formation(mapRow,mapCol)).finalCol = tempStruct(highPrioritySliceIndexArray(point)).point(1,2);
                    mapStruct(initial_formation(mapRow,mapCol)).mdist = abs(mapRow-tempStruct(highPrioritySliceIndexArray(point)).point(1,1)) + abs(mapCol - tempStruct(highPrioritySliceIndexArray(point)).point(1,2));
                    
                    mapped = mapped + 1;
                    
                    %this loop will remove the member you just mapped from
                    %the ranges of other points so it isn't double counted
                    for removeIndex = 1:nb

                        if tempStruct(removeIndex).mapped == 0
                            %defines the size of the loop based on how many
                            %members correspond to the point
                            innerLoopSize = tempStruct(removeIndex).m;
                            memberArray = tempStruct(removeIndex).members;
                            mdistArray = tempStruct(removeIndex).mdist;

                            %loops through the member coordinates of each
                            %point
                            for innerIndex = 1:innerLoopSize
                                
                                %if the rows and columns match those of the
                                %member coordinates that were mapped above
                                if memberArray(innerIndex,1) == mapRow && memberArray(innerIndex,2) == mapCol
                                    
                                    %remove the coordinate from the range
                                    %and its mdist data
                                    memberArray(innerIndex,:) = [];
                                    mdistArray(innerIndex,:) = [];
                                    %replace the rangeStruct value with the
                                    %modified arrays
                                    tempStruct(removeIndex).members = memberArray;
                                    tempStruct(removeIndex).mdist = mdistArray;
                                    %decrease m
                                    tempStruct(removeIndex).m = tempStruct(removeIndex).m - 1;
                                    break
                                end
                            end

                            %if you removed coordinates such that a point
                            %no longer has members in range:
                            if isempty(tempStruct(removeIndex).members)
                                %need to rerun the algorithm and increase
                                %its priority level
                                retry = 1;
                                retryStruct(removeIndex).priority = retryStruct(removeIndex).priority + 1;
                                break
                            end
                        end
                    end

                    %immediately breaks the loop
                    if retry == 1
                        break
                    end

                end
            end
        end
        
        %immediately breaks the loop
        if retry == 1
            break
        end
        
    end
    %[/P4]
    
    %[P5] doesn't stop looping until all points have been mapped. only does
    %this if the priority points are all mapped
    if priorityCount == 0
        while mapped<nb
            
            %variable tracking how many points have m members corresponding
            mIndex = 1;

            %mArray contains index of tempStruct that has m members.
            %closeArray contains the corresponding mdist of each member.
            mArray = zeros(nb,1);
            closeArray = zeros(nb,1);

            %this loop fills the above arrays
            for point = 1:nb
                if tempStruct(point).m == lowestm && tempStruct(point).mapped == 0
                    mArray(mIndex) = point;
                    closeArray(mIndex) = tempStruct(point).mdist(1);
                    mIndex = mIndex + 1;
                end
            end

            %truncates the arrays to correct size
            mArray = mArray(1:mIndex-1,:);
            closeArray = closeArray(1:mIndex-1,:);

            %if there are any points with m members
            if ~isempty(mArray)

                %mapArray is a temporary array that sorts the indices with
                %their respective Manhattan distances
                mapArray = [closeArray, mArray];
                mapArray = sortrows(mapArray);
                
                %mArray is now sorted in order of closest to farthest
                mArray = mapArray(:,2);
                
                %the relevant index is the one corresponding to the farthest
                %Manhattan distance. We want to fill in the points that are
                %farther away first so we can move members of the band in the
                %way of others out of the way.
                mapIndex = mArray(mIndex-1);
                
                %retrieves the coordinates of the member that will be mapped
                memberPoint = tempStruct(mapIndex).members(1,:);

                %fills mapStruct with the tag of the band member
                mapStruct(initial_formation(memberPoint(1),memberPoint(2))).member = initial_formation(memberPoint(1),memberPoint(2));
                mapStruct(initial_formation(memberPoint(1),memberPoint(2))).startRow = memberPoint(1);
                mapStruct(initial_formation(memberPoint(1),memberPoint(2))).startCol = memberPoint(2);
                mapStruct(initial_formation(memberPoint(1),memberPoint(2))).finalRow = tempStruct(mapIndex).point(1);
                mapStruct(initial_formation(memberPoint(1),memberPoint(2))).finalCol = tempStruct(mapIndex).point(2);
                mapStruct(initial_formation(memberPoint(1),memberPoint(2))).mdist = abs(memberPoint(1) - tempStruct(mapIndex).point(1)) + abs(memberPoint(2) - tempStruct(mapIndex).point(2));
                
                %indicates the point is mapped
                tempStruct(mapIndex).mapped = 1;

                mapped = mapped + 1;

                %loops to remove the mapped member from the ranges of other
                %destination points
                for pointIndex = 1:nb

                    if tempStruct(pointIndex).mapped == 0

                        %temporary array for ease of checking the coordinate
                        tempArray = tempStruct(pointIndex).members;
                        tempmdistArray = tempStruct(pointIndex).mdist;

                        %loops through the temporary array of coordinates
                        for n = 1:tempStruct(pointIndex).m

                            %if a coordinate matches the one just mapped, it is
                            %removed from the range
                            if tempArray(n,1) == memberPoint(1,1) && tempArray(n,2) == memberPoint(1,2)
                                tempArray(n,:) = [];
                                tempmdistArray(n) = [];

                                %the destination point's members are updated
                                %and the number of members decreases
                                tempStruct(pointIndex).members = tempArray;
                                tempStruct(pointIndex).m = tempStruct(pointIndex).m - 1;
                                tempStruct(pointIndex).mdist = tempmdistArray;

                                %checks to see if m becomes lower
                                if tempStruct(pointIndex).m < lowestm
                                    lowestm = tempStruct(pointIndex).m;
                                end

                                %if there's a point that has no members, you
                                %messed up somewhere and need to assign that
                                %point a higher priority and rerun the
                                %algorithm
                                if tempStruct(pointIndex).m == 0
                                    retry = 1;
                                    retryStruct(pointIndex).priority = retryStruct(pointIndex).priority + 1;
                                end

                                %once this point is found, there are no
                                %duplicates, so we can break the loop to save
                                %time.
                                break
                            end
                        end %looping through temporary array

                        if retry == 1
                            break
                        end

                    end
                end %loop to remove mapped members

            %if there are no points with m members any longer, lowestm
            %increases. If it somehow becomes unbounded, it goes back and
            %resets
            else
                if lowestm > nb
                    lowestm = 1;
                else
                    lowestm = lowestm + 1;
                end
            end %are there any points with m members?

            if retry == 1
                break
            end

        end %big while loop
        %[/P5]
        
        %retries with new priority assignment
        if retry == 1
            mapStruct = mapper(initial_formation,retryStruct);
        end
    end
end