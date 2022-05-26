% MakeNullDistribution
% Sarah West
% 10/20/21

% Has all data of a single time instance stay together.

function [] = MakeNullDistribution(parameters)
    
    % Give parameters easier names. 
    comparisons = parameters.comparisions;
    mice_all = parameters.mice_all; 
    reps = parameters.reps; 
    dir_input_base = parameters.dir_input_base;
    input_file_name = parameters.input_file_name;
    input_variable_name = parameters.input_variable_name;
    dir_out_base = parameters.dir_out_base;
    shuffledDim = parameters.shuffledDim;
    output_file_name = parameters.output_file_name;
    output_variable_name = parameters.output_variable_name;
    
    % Establish output directory.
    dir_out = [dir_out_base '\']; 
    mkdir(dir_out);
    
    % For each comparison,
    for comparisoni = 1 : size(comparisons,1)
        
        % Get the periods in the comparison.
        period1=comparisons{comparisoni,1};
        period2=comparisons{comparisoni,2};
        disp(['comparing ' period2 ' to ' period1]); 
        
        % For each mouse,
        for mousei=1:size(mice_all,2) 
            mouse=mice_all.name(mousei,:);
          
            % Get the input directory
            dir_in = [dir_input_base '\' mouse '\'];
            
            % For periods 1 and 2, Get specific name of input filename.
            file_name_input1 = CreateFileStrings(input_file_name,[], [], [], period1, false);
            file_name_input2 = CreateFileStrings(input_file_name,[], [], [], period2, false);
           
            % Get specific name of input variable for period1
            variable_name_input1 = CreateFileStrings(input_variable_name,[], [], [], period1, false);
           
            % For period1, load the data.(Don't do periods 1 and 2 
            % at the same time because their input variable names might be
            % the same).
            load([dir_in file_name_input1], variable_name_input1); 

            % For periods 1, get the data that corresponds to that period, assign it
            % a generic name.
            eval(['mouse_instances1 = ' variable_name_input1 ';']); 

            % Repeat loading and re-assigning for period 2 (don't do
            % periods 1 and 2 at the same time because their input variable 
            % names might be the same).
            variable_name_input2 = CreateFileStrings(input_variable_name,[], [], [], period2, false);
            load([dir_in file_name_input2], variable_name_input2);
            eval(['mouse_instances2 = ' variable_name_input2 ';']); 
            
            % Set up matrix to hold shuffled data, depending on size
            % of the data being compared and the dimensions being shuffled.
            % Right now is set up to handle more than one shuffling
            % dimension, but I believe only one should ever be shuffled.
            dimensions_list = NaN(1,ndim(mouse_instances1));
            for dimi = 1:ndim(mouse_instances1)
                
                % If this is a dimension to be shuffleed, 
                if any(shuffledDim == dimi)
                   
                    % This dimension will be the number of reps.
                    dimensions_list(dimi) = reps;  
                end
            end 
                     
            % Now initialize output matrices with the dimensions you just found.
            differences_of_shufflings = NaN(dimensions_list); 
            tstats_of_shufflings = NaN(dimensions_list);
            
            % Complicated-looking stuff that lets you select the correct
            % dimension.
            inds = repmat({':'},1,ndims(mouse_instances1));
            
            % Begin shufflings.
            
            % For each repetition,
            for repi=1:reps
                
                % Change the index in the correct dimension.                
                inds{shuffledDim} = repi;
                
                % Concatenate all data of both periods.
                vect=cat(shuffledDim,mouse_instances1, mouse_instances2); 
                
                % Make a mixing vector that's made up of a random
                % permutation of the number of total instances of both
                % periods.
                vect_mix=randperm(size(vect,shuffledDim));
                
                % Apply this mixing vector to the data and split the
                % resulting shuffled data in two new shuffled datasets that
                % have the same number of instances as the two periods that 
                % were inputted.
                vectA=vect(:,:,(vect_mix(1:size(mouse_instances1,shuffledDim))));
                vectB=vect(:,:,(vect_mix((size(mouse_intances1,shuffledDim)+1):end)));
                
                % Take the difference of the mean of the two shuffled
                % datasets and put it in the right place.
                differences_of_shufflings(inds{:}) = nanmean(vectB,shuffledDim)-nanmean(vectA,shuffledDim);
                
                % Take a t-test of the shufflings (makes the distribution
                % more likely to be Guassian) and put them in the right place. 
                [~,~,~,stats] = ttest2(vectA, vectB, 'Dim', shuffledDim); 
                tstats_of_shufflings(inds{:}) = stats.tstat; 
            end
        
            % Assign per mouse.
            eval(['null_distributions.per_mouse.m' mouse '.differences_of_shufflings = differences_of_shufflings;']); 
            eval(['null_distributions.per_mouse.m' mouse '.tstats_of_shufflings = tstats_of_shufflings;']); 
            
        end
 
        % Get a distribution across mice.
       
        % Re-use the dimensions list from above to make a holding matrix,
        % then add a new dimension for the different mice. 
        dimensions_list = [dimensions_list size(mice_all,2)]; 
        
        % Make a new holding matrix with that dimension list. (Not sure yet
        % if it's "allowed" to average t-stastics, but I'm doing now so I
        % don't need to later.)
        differences_all_mice = NaN(dimensions_list);
        tstats_all_mice = NaN(dimensions_list); 
        
        % Reset the indices. Complicated-looking stuff that lets you select 
        % the correct dimension.
        inds = repmat({':'},1, size(dimensions_list,2));
        
        % For each mouse,
        for mousei=1:size(mice_all,2) 
            mouse=mice_all.name(mousei,:);
            
            % Put the mouse number in the correct dimension.
            inds{end} = mousei; 
            
            % Add mouse's data to the all mice matrix.
            eval(['differences_all_mice(inds{:}) = null_distributions.per_mouse.m' mouse '.differences_of_shufflings ;'])
            eval(['tstats_all_mice(inds{:}) = null_distributions.per_mouse.m' mouse '.tstats_of_shufflings ;'])
        end 
        
        % Now, average together mice for a single across-mice
        % distribution. Mice are in the last dimension.
        null_distributions.all_mice.differences_of_shufflings = nanmean(differences_all_mice, size(inds,2));
        null_distributions.all_mice.tstats_of_shufflings = nanmean(tstats_all_mice, size(inds,2));
        
        % Save for the comparison. 
        
        % Get specific name of output variable (if needed).
        variable_name_output = CreateFileStrings(output_variable_name,[], [], [], [period1 '2' period2] , false);
        
        % Give the variable the desired name.
        eval([variable_name_output ' = null_distributions;']); 
        
        % Get specific name of file for saving.
        filename_output = CreateFileStrings(output_file_name,[], [], [], [period1 '2' period2], false);

        % Save
        save([dir_out filename_output], variable_name_output);
    end
end