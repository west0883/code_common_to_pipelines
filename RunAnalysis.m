% RunAnalysis.m 
% Sarah West
% 3/11/21

% A function that abstracts & generalizes all for loops, loading,
% calculations, and saving for analysis done by the Ebner lab. Information
% and parameters need to be formatted properly into the "parameters"
% structure. 
% Functions are given as a cell array of function handles

% Example data to use
% loop_list_1.iterators = {'mouse', {'mice_all(:).name'}, 'mouse_iterator'; 'day', {'mice_all(', 'mouse_iterator', ').days(:).name'}, 'day_iterator'; 'stack', {'mice_all(', 'mouse_iterator', ').days(', 'day_iterator', ').stacks'}, 'stack_iterator'};
% loop_list_1.things_to_load.mask.load_level = 'mouse';
% loop_variables.mice_all = mice_all;
% loop_list_1.save_level = 'stack';
% loop_list_1.things_to_load.data.load_level = 'stack';
% loop_variables.mice_all = mice_all;

function [] = RunAnalysis(functions, parameters)

    % *** Generate list of information to loop through. ***
    looping_output_list = LoopGenerator(parameters.loop_list, parameters.loop_variables);

    % For each item in the list of information to loop through, 
    for itemi = 1: size(looping_output_list, 1)

        % *** Loading ***
        
        % Get this list of loading and saving string-creating keywords and
        % variables
        % Keywords should be the names of each iterator, which are in the
        % first column of iterators cell. 
        keywords = parameters.loop_list.iterators(:,1);

        % Values are the corresponding values in the looping output list
        % for each keyword's field.
        values = cell(size(keywords));
        for i = 1: numel(keywords)
            values{i} = getfield(looping_output_list(itemi), keywords{i});
        end

        % Check each potential thing to load
        load_fields = fieldnames(parameters.loop_list.things_to_load);
        for loadi = 1:numel(load_fields)
            
            % Figure out if that item should be loaded
            load_flag = getfield(looping_output_list, {itemi}, [load_fields{loadi} '_load']);
            
            % If it should be loaded, start loading process
            if load_flag
             
                % Get the filename & input variable name formatting cells
                input_dir_cell = getfield(parameters.loop_list.things_to_load, load_fields{loadi}, 'input_dir');
                input_filename_cell = getfield(parameters.loop_list.things_to_load, load_fields{loadi}, 'input_filename');
                input_variable_cell = getfield(parameters.loop_list.things_to_load, load_fields{loadi}, 'input_variable');
             
                input_dir = CreateStrings(input_dir_cell, keywords, values);
                input_filename = CreateStrings(input_filename_cell, keywords, values);
                input_variable = CreateFileStrings(input_variable_cell, keywords, values);
                
                % Load 
                loaded_variable = load([input_dir input_filename], input_variable); 

                % Assign to the specific name in parameters structure
                parameters = setfield(parameters, input_variable, getfield(loaded_variable, input_variable));
            end 
        end

        % *** Run functions chosen by user. *** 
    
        % For each function, (run recursively on "parameters" structure).
        for functioni = 1:numel(functions)
            
            % Assign the function for this step
            F = functions{functioni};

            % Run the function
            parameters = F(parameters); 

        end

        % *** Save  ***

        % If you save at this item level, 
        save_flag = getfield(looping_output_list, {itemi}, 'save');
        if save_flag

            % Create strings for all saving info
            output_dir= CreateFileStrings(parameters.output_dir, keywords, values);
            mkdir(output_dir);
            output_filename = CreateFileStrings(parameters.output_filename, keywords, values);
            output_variable_string = CreateFileStrings(parameters.output_variable, keywords, values);
            
            % Get data out of parameters structure
            output_variable =  getfield(parameters, output_variable_string);

            % Convert to non-generic variable name
            eval([output_variable_string ' = output_variable;']);

            % Save
            save([dir_out output_filename], output_variable, '-v7.3'); 

        end
    end 
end 