%CAL BAND TRANSITIONS PROJECT%
%FILE - Main Transition File

%CODED BY: Albert Li, Rachel Jang, Rohan Chakraborty

%FORMAT: -Variables initialized at the top followed by the processes.
%        -Each variable initialization is labelled as: [V#]
%        -Each process is labeled as: [P#]. Ends of processes are: [/P#]

%METHOD:
%       1) Use mapping algorithm to determine the final destinations of the
%       members of the cal band
%       2) Generate a default path configuration for each member of the cal
%       band
%       3) Analyze collisions and alter paths/delay until all collisions
%       are eliminated - use this configuration to generate instructions

%--------------------------------------------------------------------------------------------%
%--------------------------------------------CODE--------------------------------------------%
%--------------------------------------------------------------------------------------------%

function [instructions] = calband_transition(initial_formation, target_formation, max_beats)
    
    %starts timer - function will end after a certain amount of time                    
    tic
    
                        %-------------------------------%
                        %-----------VARIABLES-----------%
                        %-------------------------------%
                        
    %[V1] Initializing variable counting total number of moves
    %(2 beats/move)
    totMoves = max_beats/2;
    
    %[V2] finding the number of members in the cal band
    nb = size(find(initial_formation),1);
    
                        %-------------------------------%
                        %-----------PROCESSES-----------%
                        %-------------------------------%
                        
    %[P1] Mapping the cal band members to a destination                    
    rangeStruct = rangeConstruct(initial_formation,target_formation,totMoves);
    mapStruct = mapper(initial_formation,rangeStruct);
    
    %[P2] Constructing the default path the members travel on and analyzing
    %the collisions from that path
    pathStruct = pathing(mapStruct,totMoves);
    allCollisions = collisionDetect(mapStruct,pathStruct,totMoves);
    
    %[FOR REAL] [P3] Runs the collision-fixing algorithm to generate a
    %final set of instructions. This is the most important function.
    instructions = collisionFixer(initial_formation,totMoves,rangeStruct,mapStruct,pathStruct,allCollisions);
    
    %[FOR BETA] [P3] Default instructions are used (will probably have
    %collisions)
    %instructions = struct;
    %for member = 1:nb
    %    instructions(member).i_target = mapStruct(member).finalRow;
    %    instructions(member).j_target = mapStruct(member).finalCol;
    %    instructions(member).wait = pathStruct(member).wait;
    %    instructions(member).direction = pathStruct(member).cardinal;
    %end
end