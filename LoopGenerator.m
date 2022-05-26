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
% Ex. loop_list.iterators = {
%      'mouse', 'mice_all(:).name',' mousei'; 
%      'day', 'mice_all(mousei).days(:).name'; 'dayi';
%      'stack', 'mice_all(mousei).days(dayi).stacks', 'stacki';
%     loop_list.load_level = 'stack';
%     loop_list.save_level = 'stack';

% loop_variables -- a structure of the variables
% where the list of data for each can be found (Ex above would be
% loop_variables.mice_all);

function [looping_output_list] = LoopGenerator(loop_list, loop_variables)
    
    % Make sure all fields of loop_list are present.
    % iterators field
    if ~isfield(loop_list, 'iterators') || isempty(loop_list.iterators)
       error('A non-empty field in loop list called "iterators" is required.');
    end 
    % load level field
    if ~isfield(loop_list, 'load_level') || isempty(loop_list.load_level)
       error('A non-empty field in loop list called "load_level" is required.');
    end 
    % save level field
    if ~isfield(loop_list, 'save_level') || isempty(loop_list.save_level)
       error('A non-empty field in loop list called "save_level" is required.');
    end 
    
    % Display to user what iterators are being used.
    display_string = ['Looping through'];
    for i = 1:size(loop_list.iterators,1)
        display_string = [display_string ' ' loop_list.iterators{i,1}];
        
        % On all but last entry, also include a comma.
        if i ~= size(loop_list.iterators,1)
            display_string = [display_string ','];
        end
    end
    disp(display_string);

    % Initialize output variable as empty cell.
    looping_output_list.iterators = {cell(1, 2)};
    
    % For each loop level the user asks for,
    for i = 1:size(loop_list.iterators,1)
        
        % Run the output variable recursively through the LoopSubGenerator
        % function. Needs to know where everything is, so also include other loop info variables. 
        [looping_output_list_2] = LoopSubGenerator(i,looping_output_list.iterators, loop_list.iterators, loop_variables);
        looping_output_list.iterators = looping_output_list_2;
            
    end
   
    % Potentially deal with "load" and "save" at the very end-->insert them
    % based on changes in the relevant iterator value in loop_list. (when
    % the iterator value changes)

    % Load locations.
    
    % Get the level of loading from loop_list
    load_level = find(strcmp(loop_list.iterators(:,1), loop_list.load_level));
    
    % Get column of looping_output_list that corresponds to the numeric iterations of
    % the relevant looping level.
    numeric_iterations = looping_output_list.iterators(:, load_level*2);

    % Find level of changing iterator. Include 0 at beginning to use for
    % loading first dataset (so each entry corresponds to a change from the previous entry).
    change_in_iterator = diff([0; cell2mat(numeric_iterations)]);
    
    % Put into output list as a true/false list.
    looping_output_list.load = change_in_iterator ~= 0;

    % Save locations

    % Get the level of saving from loop_list
    save_level = find(strcmp(loop_list.iterators(:,1), loop_list.save_level));
    
    % Get column of looping_output_list that corresponds to the numeric iterations of
    % the relevant looping level.
    numeric_iterations = looping_output_list.iterators(:, save_level*2);

    % Find level of changing iterator. Include 0 at beginning to use for
    % loading first dataset (so each entry corresponds to a change from the previous entry).
    change_in_iterator = diff([0; cell2mat(numeric_iterations)]);
    
    % Put into output list as a true/false list.
    looping_output_list.save = change_in_iterator ~= 0;

end

function [looping_output_list_2] = LoopSubGenerator(i,looping_output_list, loop_list, loop_variables)
    
    % Initialize recursion version of output list as empty cell.
    looping_output_list_2 = {}; 

    % For each entry of the iterator at the previous (higher) level (skip
    % first because it's empty)
    for higheri = 1:size(looping_output_list, 1)
        
        % Get out all previous iterating values
        higher_values = looping_output_list(higheri, 1:2*(i-1));
      
        % Get the current values based on higher_values and where current
        % value is stored. Make a list of keys-values for creating the
        % right strings.
        string_searches = [loop_list(1:i-1, 3) ];
        number_searches = looping_output_list(higheri, [2:2:end]);
        
        % Create a string for "eval" evalutaion of lower value name.
        lower_values_string = CreateStrings(loop_list{i,2}, string_searches, number_searches ); 
        eval(['lower_values = {' lower_values_string '};']);
        
        % If the list you want is a numeric array inside a cell array, get
        % it out and turn to a cell array.
        if max(size(lower_values)) == 1 && ~isempty(lower_values{1}) && ~iscell(lower_values{1})
            lower_values = num2cell(lower_values{:}); 
        
        % Or remove the extra nesting step.
        elseif max(size(lower_values)) == 1 && ~isempty(lower_values{1}) && iscell(lower_values{1})
            lower_values = lower_values{1,1};
        end     

        % Loop through each current value
        for loweri = 1:numel(lower_values)
            
            lower_value = lower_values{loweri};
            
            % Skip if lower value is NaN.
            if isnan(lower_value)
                continue
            end

            % Concatenate to end of looping_output_list_2

            % If the very first instance, overwrite the first empty entry.
            if i == 1 && higheri ==1 && loweri == 1
                looping_output_list_2(1,:) = [{lower_value}, {loweri}];
            
            % If the very first iteration level, don't need to include any higher
            % level values.
            elseif i == 1 && higheri ==1
                looping_output_list_2 = [looping_output_list_2; {lower_value}, {loweri}];
            
            % Concatenate new information along with information about higher level values.    
            else
                looping_output_list_2 = [looping_output_list_2; higher_values, {lower_value}, {loweri}];
            end

        end
    end
end