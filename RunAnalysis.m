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

    % Initialize iterator for looping through looping_output_list
    itemi = 1; 

    % For each item in the list of information to loop through, (Use a
    % while loop so you can have functions skip iterations if needed).
    while itemi <= size(looping_output_list, 1)

        % *** Loading ***
        
        % Get this list of loading and saving string-creating parameters.keywords and
        % variables
        % Keywords should be the names of each iterator, which are in the
        % first column of iterators cell. Also include the iterator names.
        parameters.keywords = [parameters.loop_list.iterators(:,1); parameters.loop_list.iterators(:,3)];

        % Values are the corresponding values in the looping output list
        % for each keyword's field.
        parameters.values = cell(size(parameters.keywords));
        for i = 1: numel(parameters.keywords)
            parameters.values{i} = getfield(looping_output_list(itemi), cell2mat(parameters.keywords(i)));
        end

        % Check each potential thing to load
        load_fields = fieldnames(parameters.loop_list.things_to_load);
        for loadi = 1:numel(load_fields)
            
            % Figure out if that item should be loaded
            load_flag = getfield(looping_output_list, {itemi}, [load_fields{loadi} '_load']);
            
            % If it should be loaded, start loading process
            if load_flag
             
                % Get the filename & input variable name formatting cells
                dir_cell = getfield(parameters.loop_list.things_to_load, load_fields{loadi}, 'dir');
                filename_cell = getfield(parameters.loop_list.things_to_load, load_fields{loadi}, 'filename');
                variable_cell = getfield(parameters.loop_list.things_to_load, load_fields{loadi}, 'variable');
             
                input_dir = CreateStrings(dir_cell, parameters.keywords, parameters.values);
                filename = CreateStrings(filename_cell, parameters.keywords, parameters.values);
                variable = CreateFileStrings(variable_cell, parameters.keywords, parameters.values);
                
                % Load 
                if isfile([input_dir filename])
                    loaded_variable = load([input_dir filename], variable); 

                    % Assign to the specific name in parameters structure
                    parameters = setfield(parameters, load_fields{loadi}, getfield(loaded_variable, variable));
                else
                    % If no file, report (sometimes we want this).
                    disp(['No file for ' load_fields{loadi} ' found at ' input_dir filename]);
                end
            end 
        end
        
        % Create continue flags for each level of iterator, so functions
        % run by user can tell RunAnalysis to skip only certain levels.
        parameters.continue_flag = repmat({true}, size(parameters.loop_list.iterators,1), 1);

        % Create list of the max iteration value that can be reached within
        % each loop level at this loop (i.e, in this mouse, how many days
        % are there). Makes it easier for called functions to throw errors
        % without accessing loop_list. 
            % Initialize. 
            parameters.max_iterations = cell(size(parameters.loop_list.iterators,1)); 
            
            % Largest iterator is just the 
            % For each iterator (largest to smallest)
                
            for i = 2:numel(parameters.max_iterations)
                
    
            end 

        % paramet


        % *** Run functions chosen by user. *** 
        
        % For each function, (run recursively on "parameters" structure).
        for functioni = 1:numel(functions)
            
            % Assign the function for this step
            F = functions{functioni};

            % Run the function
            parameters = F(parameters); 

        end

        % *** Save  ***
        
        % Check each potential thing to save
        save_fields = fieldnames(parameters.loop_list.things_to_save);
        for savei = 1:numel(save_fields)
            
            % Find out if you save at this level.
            save_flag = getfield(looping_output_list, {itemi}, [save_fields{savei} '_save']);
            
            % If you save at this level, or if the called function sends
            % out the "save_now flag", 
            if save_flag || (isfield(parameters, 'save_now') && parameters.save_now)
    
                % Create strings for all saving info
                dir_cell = getfield(parameters.loop_list.things_to_save, save_fields{savei}, 'dir');
                filename_cell = getfield(parameters.loop_list.things_to_save, save_fields{savei}, 'filename');
                variable_cell = getfield(parameters.loop_list.things_to_save, save_fields{savei}, 'variable');
             
                output_dir = CreateStrings(dir_cell, parameters.keywords, parameters.values);
                filename = CreateStrings(filename_cell, parameters.keywords, parameters.values);
                variable_string = CreateFileStrings(variable_cell, parameters.keywords, parameters.values);

                mkdir(output_dir);
         
                % Get data out of parameters structure
                variable =  getfield(parameters, save_fields{savei});
    
                % Convert to non-generic variable name
                eval([variable_string ' = variable;']);
    
                % Save
                save([output_dir filename], variable_string, '-v7.3'); 
            end
        end
        
        % If the run functions return a continue flag & the continue flag
        % on any iterator level is false
        if isfield(parameters, 'continue_flag') && any(~[parameters.continue_flag{:}])
           
            % Get the first (highest-level) iterator-level that's false
            iterator_level_to_skip = find(~[parameters.continue_flag{:}],1);

            % Get the current value of that iterator 
            current_iterator_to_skip = getfield(looping_output_list(itemi), parameters.loop_list.iterators{iterator_level_to_skip, 3});

            % In looping list, find when that iterator increases by 1
            eval(['holder = looping_output_list(:).' parameters.loop_list.iterators{iterator_level_to_skip, 3} ';']); 
            next_iteration = find(holder == current_iterator_to_skip +1,1); 
            
            % If "next_iteration" isn't empty
            if ~isempty(next_iteration)
                
                % Make itemi equal that location in the looping list.
                itemi = next_iteration; 
            
            % If it is empty, break out of item loop & end RunAnalysis
            else
                break
            end
        else
            % If no skipping, just increase the item iterator by 1.
            itemi = itemi + 1;
        end
    end 
end 