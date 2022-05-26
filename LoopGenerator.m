% LoopGenerator.m
% Sarah West
% 2/25/22

% Creates list of data variables to cycle through. Is meant to make lab
% code abstractable across users with different data division levels.

% Inputs:
% loop_list - a cell array (? will maybe make a Map or something later, but order is immportant)
% with information about each level to loop, where list of data for each
% loop can be found, what iterator to use (important for finding data the next level down)
% and when to load or save data in relation to those loops. 
% Ex. loop_list.iterators = {
%      'mouse', 'mice_all(:).name',' mousei'; 
%      'day', 'mice_all(mousei).days(:).name'; 'dayi';
%      'stack', 'mice_all(mousei).days(dayi).stacks', 'stacki';
%     loop_list.load_level = 'stack';
%     loop_list.save_level = 'stack';

% Things that need to be loaded, ex.
% loop_list.things_to_load.data.load_level = 'stack'; 


% loop_variables -- a structure of the variables
% where the list of data for each can be found (Ex above would be
% loop_variables.mice_all);

function [looping_output_list, maxIterations] = LoopGenerator(loop_list, loop_variables)
    
    % Make sure all fields of loop_list are present.
    % iterators field
    if ~isfield(loop_list, 'iterators') || isempty(loop_list.iterators)
       error('A non-empty field in loop list called "iterators" is required.');
    end 
%     % load level field
%     if ~isfield(loop_list, 'things_to_load') || isempty(loop_list.things_to_load)
%        error('A non-empty field in loop list called "things_to_load" is required.');
%     end 
%     % save level field
%     if ~isfield(loop_list, 'things_to_save') || isempty(loop_list.things_to_save)
%        error('A non-empty field in loop list called "things_to_save" is required.');
%    end 
    
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

    % Grab the number of digits user wants to use for iterating numbers in
    % filenames (like with stacks). Otherwise, default to 3 digits.
    if isfield(loop_list, 'digitNumber')
       digitNumber = loop_list.digitNumber;
    else 
       digitNumber = 3; 
    end

    % Initialize output variable as empty cell.
    looping_output_list.iterators = {cell(1, 2)};
    
    % Initialize variable that holds max iterator values;
    maxIterations = []; 

    % For each loop level the user asks for,
    for i = 1:size(loop_list.iterators,1)
        
        % Run the output variable recursively through the LoopSubGenerator
        % function. Needs to know where everything is, so also include other loop info variables. 
        [looping_output_list_2, maxIterations] = LoopSubGenerator(i,looping_output_list.iterators, loop_list.iterators, loop_variables, maxIterations, digitNumber);
        looping_output_list.iterators = looping_output_list_2;
            
    end
   
    % Potentially deal with "load" and "save" at the very end-->insert them
    % based on changes in the relevant iterator value in loop_list. (when
    % the iterator value changes)

    % Load locations.

    % For each item in the things_to_load field, 
    if isfield(loop_list,'things_to_load' )
        load_fields = fieldnames(loop_list.things_to_load);
        for i = 1:numel(load_fields)
            
            % Get the level of loading for that item. 
            load_level = getfield(loop_list.things_to_load, load_fields{i}, 'level');
    
            % Get the level of loading from loop_list
            load_level_index = find(strcmp(loop_list.iterators(:,1), load_level));
            
            % Get column of looping_output_list that corresponds to the numeric iterations of
            % the relevant looping level.
            numeric_iterations = looping_output_list.iterators(:, load_level_index*2);
        
            % Find level of changing iterator. Include 0 at beginning to use for
            % loading first dataset (so each entry corresponds to a change from the previous entry).
            change_in_iterator = diff([0; cell2mat(numeric_iterations)]);
            
            % Put into output list as a true/false list.
            holder = change_in_iterator ~= 0;
            looping_output_list = setfield(looping_output_list, 'load', load_fields{i}, num2cell(holder));
        
        end 
    else
        load_fields = {};
    end
    
    % Save locations
    % For each item in the things_to_save field, 
    if isfield(loop_list,'things_to_save' )
        save_fields = fieldnames(loop_list.things_to_save);
        for i = 1:numel(save_fields)
            
            % Get the level of saveing for that item. 
            save_level = getfield(loop_list.things_to_save, save_fields{i}, 'level');
    
            % Get the level of saveing from loop_list
            save_level_index = find(strcmp(loop_list.iterators(:,1), save_level));
            
            % Get column of looping_output_list that corresponds to the numeric iterations of
            % the relevant looping level.
            numeric_iterations = looping_output_list.iterators(:, save_level_index*2);
        
            % Find level of changing iterator. Include 0 at END to use for
            % saving at the end of each dataset (so each entry corresponds to a change from the previous entry).
            change_in_iterator = diff([cell2mat(numeric_iterations); 0]);
            
            % Put into output list as a true/false list.
            holder = change_in_iterator ~= 0;
            looping_output_list = setfield(looping_output_list, 'save', save_fields{i}, num2cell(holder));
        end 
    else
        save_fields = {}; 
    end
    % Change to structure for easier (non-ordered indexing) use.

    % Make empty structure to put things in.
    output_structure = struct;

    % Get names for structure
    structure_names ={};  
    for i = 1:size(loop_list.iterators,1)
        structure_names = [structure_names; [loop_list.iterators{i, 1}]; [loop_list.iterators{i,3}]];
    end

    % Put values in to structure, starting with load and save fields.
    for ii = 1:size(looping_output_list.iterators,1)

        % Go through each thing to load
        for loadi = 1:numel(load_fields)
            % Get the yes-or-no to load
            load_flag = getfield(looping_output_list.load, load_fields{loadi}, {ii});

            % Set the yes-or-no to the proper place in the output structure
            output_structure = setfield(output_structure, {ii}, [load_fields{loadi} '_load'], cell2mat(load_flag));
        end 

        % Go through each thing to save
        for savei = 1:numel(save_fields)
            % Get the yes-or-no to save
            save_flag = getfield(looping_output_list.save, save_fields{savei}, {ii});

            % Set the yes-or-no to the proper place in the output structure
            output_structure = setfield(output_structure, {ii}, [save_fields{savei} '_save'], cell2mat(save_flag));
        end 

        % Now run for each iterator field. 
        for i = 1:numel(structure_names)
            output_structure(ii).(structure_names{i}) = looping_output_list.iterators{ii, i};
        end
    end
   
    % Rename output structure
    looping_output_list = output_structure'; 
   
end

function [looping_output_list_2, maxIterations_out] = LoopSubGenerator(i,looping_output_list, loop_list, loop_variables, maxIterations_in, digitNumber)

    % Initialize recursion version of output list as empty cell.
    looping_output_list_2 = {}; 
    maxIterations_out = []; 

    % For each entry of the iterator at the previous (higher) level (skip
    % first because it's empty)
    for higheri = 1:size(looping_output_list, 1)
        
        % Get out all previous iterating values
        higher_values = looping_output_list(higheri, 1:2*(i-1));
        
        % If previous value entry is empty
        if i > 1
            last_value = higher_values{end-1};
            if isempty(last_value)
                % Put in padding.S
                looping_output_list_2 = [looping_output_list_2; higher_values,cell(1,2)];
                
                continue
            end 
        end 
        if ~isempty(maxIterations_in)
            higher_max_iterations = maxIterations_in(higheri, :); 
        end

        % Get the current values based on higher_values and where current
        % value is stored. Make a list of keys-values for creating the
        % right strings.
        string_searches = [loop_list(1:i-1, 3) ];
        number_searches = looping_output_list(higheri, [2:2:end]);
        
        % Create a string for "eval" evalutaion of lower value name.
        lower_values_string = CreateStrings(loop_list{i,2}, string_searches, number_searches ); 
        eval(['lower_values = {' lower_values_string '};']);
        
        % If the list you want is a numeric array inside a cell array, get
        % it out, turn into strings, then turn to a cell array.
        if max(size(lower_values)) == 1 && ~isempty(lower_values{1}) && ~iscell(lower_values{1}) && isnumeric(lower_values{1})
            % Turn into strings with desired digit numbers. 
            
            % Convert the input digit number to a character for easier use with
            % sprintf. 
            digitChar=num2str(digitNumber);

            % Initiate holdList, an empty cell array.
            holdList=cell(numel(lower_values{1}(:)) ,1); 

            % Make a for loop for each lower value entry, because sprintf doesn't have a
            % convenient way to separate outputs. 
            for numi=1:numel(lower_values{1}(:)) 
                holdList{numi}=sprintf(['%0' digitChar 'd'], lower_values{1}(numi)); 
            end

            lower_values = holdList; 


%             lower_values = num2str(lower_values{1}(:));
%             lower_values = cellstr(lower_values);
           
        % Or remove the extra nesting step.
        elseif max(size(lower_values)) == 1 && ~isempty(lower_values{1}) && iscell(lower_values{1})
            lower_values = lower_values{1,1};
        end     

        max_iteration = numel(lower_values);

        % Loop through each current value
        for loweri = 1:numel(lower_values)
            
            lower_value = lower_values{loweri};
            
            % Skip if lower value is NaN.
            if isnan(lower_value)
                % Put in padding.
                looping_output_list_2 = [looping_output_list_2; higher_values, cell(1,2)];
                 maxIterations_out = [maxIterations_out; higher_max_iterations, max_iteration];
                continue
            end

            % Skip if lower value is empty.
            if  isempty(lower_value)
                 % Put in p adding.
                looping_output_list_2 =  [looping_output_list_2; higher_values, cell(1,2)];
                maxIterations_out = [maxIterations_out; higher_max_iterations, max_iteration];
                continue
            end

            % Concatenate to end of looping_output_list_2

            % If the very first instance, overwrite the first empty entry.
            if i == 1 && higheri ==1 && loweri == 1
                looping_output_list_2(1,:) = [{lower_value}, {loweri}];
                maxIterations_out = max_iteration;

            % If the very first iteration level, don't need to include any higher
            % level values.
            elseif i == 1 && higheri ==1
                looping_output_list_2 = [looping_output_list_2; {lower_value}, {loweri}];
                maxIterations_out = [maxIterations_out; max_iteration];

            % Concatenate new information along with information about higher level values.    
            else
                looping_output_list_2 = [looping_output_list_2; higher_values, {lower_value}, {loweri}];
                maxIterations_out = [maxIterations_out; higher_max_iterations, max_iteration];
            end

        end
    end
end