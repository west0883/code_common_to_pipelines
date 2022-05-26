% LoopGenerator.m
% Sarah West
% 2/25/22

% Creates list of data variables to cycle through. Is meant to make lab
% code abstractable across users with different data division levels.

% Inputs:
% loop_list - a cell array (? will maybe make a Map or something later)
% with information about each level to loop, where list of data for each
% loop can be found, what iterator to use (important for finding data the next level down)
% and when to load or save data in relation to those loops. 
% Ex. {'iterator', 'mouse', 'mice_all(:).name',' mousei'; 
%      'iterator','day', 'mice_all(mousei).days(:).name'; 'dayi';
%      'iterator', 'stack', 'mice_all(mousei).days(dayi).stacks', 'stacki';
%      'load', [], [], []; 
%      'save', [], [], []};

% loop_variables -- a cell array (? or maybe structure) of the variables
% where the list of data for each can be found (Ex above would be
% mice_all);

function [looping_ouput_list] = LoopGenerator(loop_list, loop_variables)
    
    % Initialize output variable as empty cell.
    looping_output_list = {};

    % Make a cell array to count how many iterations are at each level? (might
    % vary per mouse or whatever)
    loop_iteration_counts = cell(1, size(loop_list,1));
    
    % For each loop level the user asks for,
    for i = 1:size(loop_list,1)
        
        % Check first entry to know what to do.
        instruction = loop_variables{i,1};

        switch instruction
            case 'iterator'
                 % Run the output variable recursively through the LoopSubGenerator
                 % function. Needs to know where everything is, so also include other loop info variables. 
                 [looping_output_list, loop_iteration_counts] = LoopSubGenerator(i,looping_output_list, loop_list, loop_variables, loop_iteration_counts);

            case 'load'
                 % Continue (deal with this inside LoopSubGenerator or at end).
                 continue
           
            case 'save'
                % Continue (deal with this inside LoopSubGenerator or at end).
                continue 

            otherwise % Give catch error message.
                error(['Unrecognized instruction tag in position ' num2str(i) ', 1. Must be ''iterator'', ''load'', or ''save''.']);
        end
    end
   
    % Potentially deal with "load" and "save" at the very end-->insert them
    % based on position in loop list and loop_iteration_counts.

    % Code to work with from https://www.mathworks.com/matlabcentral/answers/322130-insert-an-array-into-another-array-in-a-specific-location
%     iwant = zeros(1,length(B)+length(A)) ;
%     % get positions to fill A at C
%     pos = (C+1):(C+1):length(iwant) ;
%     % other positions 
%     idx = ones(1,length(iwant)) ;
%     idx(pos) = 0 ;
%     % fill 
%     iwant(pos) = A ;
%     iwant(logical(idx)) = B
end

function [looping_output_list_2, loop_iteration_counts_2] = LoopSubGenerator(i,looping_output_list, loop_list, loop_variables, loop_iteration_counts)

    % Check if the next entry of loop_list is "load" or "save"?
end