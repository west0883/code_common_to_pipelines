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
        
        % Get this list of loading and saving string-creating parameters.keywords and
        % variables
        % Keywords should be the names of each iterator, which are in the
        % first column of iterators cell. 
        parameters.keywords = parameters.loop_list.iterators(:,1);

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
            
            if save_flag
    
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
        % is false, break the for loop. 
        if isfield(parameters, 'continue_flag') && ~parameters.continue_flag
            break
        end
    end 
end 