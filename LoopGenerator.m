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
    
    % Make sure both a "load" and "save" field are included.
    if ~isempty(find(contains(loop_list(:,1),'load'),1)) || ~isempty(find(contains(loop_list(:,1),'save'), 1)) 
        error('A ''load'' and ''save'' condition are required in the first position of one of the rows of the loop matrix.');
    end
    
    % Initialize output variable as empty cell.
    looping_output_list = cell(1, size(loop_list,2));

    % Make a cell array to count how many iterations are at each level? (might
    % vary per mouse or whatever)
    loop_iteration_counts = cell(1, size(loop_list,2));
    
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
                 loop_iteration_counts = [loop_iteration_counts; {'load', 'load', 'load', 'load'}];
                 continue
           
            case 'save'
                % Continue (deal with this inside LoopSubGenerator or at end).
                loop_iteration_counts = [loop_iteration_counts; {'save', 'save', 'save', 'save'}];
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
    
    looping_output_list_2 = cell(1, size(looping_output_list, 2) + 2);

    % For each entry of the iterator at the previous (higher) level,
    for higheri = 1:size(looping_output_list, 1)
        
        % Determine if load or save, put in.
%         if strcmp(looping_output_list{higheri,1} == 'load')
% 
%             holder = cell(1, size(looping_output_list_2,2));
%             holder{1} = 'load';
%             looping_output_list_2 = [looping_output_list_2; holder]; 
% 
%             continue; 
% 
%         end

        % Get out all previous iterating values
        higher_values = looping_output_list(higheri, 1:(i-1));

        % Get the current values based on higher_values and where current
        % value is stored
        string_searches = [loop_list(1:i, 4) ];
        number_searches = looping_output_list(higheri, [2:2:end]);

        lower_values_string = CreateFileStrings(loop_list{i,3}, string_searches, number_searches ); 
        eval(['lower_values = {' lower_values_string '};']);

        % Loop through each current value
        for loweri = 1:numel(lower_values)
            
            lower_value = lower_values{loweri};

            % Concatenate to end of looping_output_list_2
            looping_output_list_2 = [looping_output_list_2; higher_values, lower_value, loweri];

        end
    end
end