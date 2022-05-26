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
    
    % Because this is running analysis, a load and save field is required.
    % Give errors if those are not present.
    % load level field
    if ~isfield(parameters.loop_list, 'things_to_load') || isempty(parameters.loop_list.things_to_load)
       error('A non-empty field in loop list called "things_to_load" is required.');
    end 
    % save level field
    if ~isfield(parameters.loop_list, 'things_to_save') || isempty(parameters.loop_list.things_to_save)
       error('A non-empty field in loop list called "things_to_save" is required.');
    end 

    % Grab the number of digits user wants to use for iterating numbers in
    % filenames in LoopGenerator (like with stacks). Otherwise, default to 3 digist.
    if isfield(parameters, 'digitNumber')
       parameters.loop_list.digitNumber = parameters.digitNumber;
    else 
        parameters.loop_list.digitNumber = 3; 
    end

    % Generate list of things to loop through.
    [looping_output_list, maxIterations] = LoopGenerator(parameters.loop_list, parameters.loop_variables);
   
    % Initialize iterator for looping through looping_output_list
    itemi = 1; 

    % For each item in the list of information to loop through, (Use a
    % while loop so you can have functions skip iterations if needed).
    while itemi <= size(looping_output_list, 1)

        % Make a default abort flag, which allows continuing to next item
        abort = false; 

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

        % *** Loading ***
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
                variable_string = CreateFileStrings(variable_cell, parameters.keywords, parameters.values);
                
                % Load 

                % Make sure file exists
                if isfile([input_dir filename])

                    % Check if "variable" has a period in it (and therefore
                    % would become a structure).
                    if contains(variable_string, '.')
                        
                        % Find location of the period & only use the string
                        % up to that point to load -- because that's how
                        % loading structures works in Matlab. 
                        index = find(variable_string == '.', 1);
                        variable = load([input_dir filename], variable_string(1:index-1)); 
                        retrieved_value = getfield(variable, variable_string(1:index -1), variable_string(index+1:end)); 

                    else
                        variable = load([input_dir filename], variable_string); 
                        retrieved_value = getfield(variable, variable_string);
                    end 

                    % Assign to the specific name in parameters structure
                    parameters = setfield(parameters, load_fields{loadi}, retrieved_value);
                else
                    % If the user said to abort this item if there was no existing file
                    % (default is to just give the message)
                    if isfield(parameters, 'load_abort_flag') && parameters.load_abort_flag 
                        
                        % Say to abort this item and continue to next item
                        abort = true; 
                        disp(['Aborting analysis: No file for ' load_fields{loadi} ' found at ' input_dir filename ]);
                        
                        % Break out of loading loop
                        break 
                    else
                        % If no file, report (sometimes we want this).
                        disp(['No file for ' load_fields{loadi} ' found at ' input_dir filename]);
                    end
                end
            end 
        end
        
        % If a load abort flag was given, skip to next item
        if abort 
           % Go to the next item i value where there's loading for the
           % failed load field
           eval(['holder =  [looping_output_list(itemi + 1:end).' load_fields{loadi} '_load];']);
           
           % If there's no next one, finish the loop 
           if isempty (find(holder, 1))
              break
           else
               % If there is a next one, make itemi equal that.
               itemi = itemi + find(holder, 1);
           end
           continue 
        end
        
        % Create continue flags for each level of iterator, so functions
        % run by user can tell RunAnalysis to skip only certain levels.
        parameters.continue_flag = repmat({true}, size(parameters.loop_list.iterators,1), 1);

        % Pull out the max iteration values that can be reached within
        % each loop level at this loop (i.e, in this mouse, how many days
        % are there). Makes it easier for called functions to throw
        % errors/know where they are in analysis without accessing loop_list.  
        parameters.maxIterations = [];
        parameters.maxIterations.numbers_only = [];
        for i = 1:size(parameters.loop_list.iterators,1)
            parameters.maxIterations = setfield(parameters.maxIterations, parameters.loop_list.iterators{i,3}, maxIterations(itemi, i));
            parameters.maxIterations.numbers_only = [parameters.maxIterations.numbers_only maxIterations(itemi, i)];
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
            
            % If you save at this level, or if the called function sends
            % out the "save_now flag", 
            if save_flag || (isfield(parameters, 'save_now') && parameters.save_now)
    
                % Create strings for all saving info
                dir_cell = getfield(parameters.loop_list.things_to_save, save_fields{savei}, 'dir');
                filename_cell = getfield(parameters.loop_list.things_to_save, save_fields{savei}, 'filename');
                variable_cell = getfield(parameters.loop_list.things_to_save, save_fields{savei}, 'variable');
             
                output_dir = CreateStrings(dir_cell, parameters.keywords, parameters.values);
                filename = CreateStrings(filename_cell, parameters.keywords, parameters.values);
             
                mkdir(output_dir);
         
                % Get data out of parameters structure
                variable =  getfield(parameters, save_fields{savei});
                
                % Check if variable is a figure handle. First have to make
                % sure it's a graphics object handle specifically or else 
                % Matlab freaks out. Making sure it's specifically a figure
                % is good to be sure someone didn't make a typo.
                if  strcmp(class(variable), 'matlab.ui.Figure')
                    % ~ismatrix(variable) && isgraphics(variable) 
                    % If it is a figure, save as figure. Uses the "compact"
                    % fig format, apparently makes it faster & smaller
                    % file.
                    savefig(variable, [output_dir filename],'compact'); 

                    % If user wants to save a fancy version (in addition to
                    % .fig type)

                    % Get out the loop_list info 
                    fig_list_variable = getfield(parameters.loop_list.things_to_save, save_fields{savei});
                    
                    % Check if user put in a saveas type. 
                    if isfield(fig_list_variable, 'saveas_type')

                        % Get the save type
                        fig_type = getfield(fig_list_variable, 'saveas_type');
                        
                        % Save the fancy figure, too. 
                        saveas(variable, filename, fig_type);

                    end 
                else
                    % If not a figure, save as variable. 
                    
                    % If variable is a structure, see if there's a field in loop list to save
                    % everything as variables (default is as structure)
                    
                    % Get the relevant sub-structure (have to do it like
                    % this because isfield doesn't nest)
                    loop_list_variable = getfield(parameters.loop_list.things_to_save, save_fields{savei});
                       
                    if isstruct(variable) && isfield(loop_list_variable, 'save_as_variables') && loop_list_variable.save_as_variable

                            % Save with structure-to-variables feature
                            save([output_dir filename], '-struct', 'variable'); 
                            
                            % To make it even more flexible... but I'll
                            % leave this for later.
                            % Get out the list of variables they want to
                            % save these as. Do it as just a cell array,
                            % I'm tired. 
%                           % subvariables  = getfield(list_variable);
%                           %for i = 1:size(subvariables,1)
%                           %      eval([subvariables{i,1} ' = ' subvariables{i,2} ';']);
%                           % end     
                    else
                        % If not a structure or if user is okay saving as structure, save variable as usual
                        variable_string = CreateFileStrings(variable_cell, parameters.keywords, parameters.values);

                        % Convert to non-generic variable name
                        eval([variable_string ' = variable;']);
                        
                        % Save
                        save([output_dir filename], variable_string, '-v7.3'); 
                    end 
                end

                % Once you've saved it, remove that variable from parameters 
                % structure so called functions don't over write or add to it.
                parameters = rmfield(parameters,save_fields{savei});
            end
        end
        
        % If the run functions return a continue flag & the continue flag
        % on any iterator level is false
        if isfield(parameters, 'continue_flag') && any(~[parameters.continue_flag{:}])
           
            % Get the first (highest-level) iterator-level that's false
            iterator_level_to_skip = find(~[parameters.continue_flag{:}],1);

            % Go to next iteration of level ABOVE that. 
            next_iterator_level = iterator_level_to_skip - 1; 

            % If there are no higher levels (iterator level is 0), then
            % you're done! Break. 
            if next_iterator_level <= 0
                break
            end

            % Get the current value of that iterator 
            current_iterator_to_skip = getfield(looping_output_list(itemi), parameters.loop_list.iterators{next_iterator_level, 3});

            % In looping list, find when that iterator increases by 1
            eval(['holder = [looping_output_list(:).' parameters.loop_list.iterators{next_iterator_level, 3} '];']); 
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