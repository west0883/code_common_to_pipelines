% CorrelateTimeseriesData.m
% Sarah West
% 2/2/21

% A function that correlates timeseries data.
% Is general, so you can use with all kinds of timeseries data. I think is
% limited to timeseries of 3 dimensions, though.


function [] = CorrelateTimeseriesData(periods_all, parameters)
   
    % Tell user where data is being saved
    disp(['Data saved in '  parameters.dir_out_base{1}]); 

    % For each mouse 
    for mousei=1:size( parameters.mice_all,2)
        mouse= parameters.mice_all(mousei).name;
    
        % Create data input directory and cleaner output directory. 
        dir_in_data = CreateFileStrings(parameters.dir_in_data_base, mouse, [], [], [], false);
        parameters.dir_in = dir_in_data;
        dir_out= CreateFileStrings(parameters.dir_out_base, mouse, [], [], [], false);
        mkdir(dir_out);
        
        % For each period,
        for periodi = 1:size(periods_all,1)
            period = periods_all{periodi};
            
            % Display mouse & day
            disp(['mouse ' mouse ' period ' period]);
            
            % Get filename.
            filename = CreateFileStrings(parameters.input_data_name, mouse, [], [], period, false);

            % Load the timeseries data 
            load([dir_in_data filename]);
          
            % Get relevant segment variable name
            variable_name = CreateFileStrings(parameters.input_data_variable, mouse, [], [], period, false);
            
             % Change the variable name of the timeseries data to
            % something generic. 
            eval(['Timeseries= ' variable_name ';']);

            % Take the ranges using a flexible number of dimensions
            % C is a holder of as many ':' indices as we need.
            C_source1 = repmat({':'},1, ndims(Timeseries));
            C_source2 = repmat({':'},1, ndims(Timeseries));
        
            % If no segment ranges, 
            if isempty(Timeseries)
                % Do nothing. Continue to next period
                continue
            else
                % Number of sources (for convenience)
                num_sources = size(Timeseries, parameters.corrDim);

                % Make a holding matrix that will hold all the
                % correlations. Is set as size source number x source
                % number x instance number.
                Corrs = NaN (num_sources, num_sources, size(Timeseries, parameters.instancesDim));
                 
                % Try rearranging all Timeseries data here to try the
                % parfor loop on instancei. 
                
                % List of timeseries pairs for correlations (to try
                % speeding things up)

                % For each instance
                for instancei=1:size(Timeseries, parameters.instancesDim) 
                    C_source1(parameters.instancesDim) = {instancei};
                    C_source2(parameters.instancesDim) = {instancei};

                    timeseries_list = NaN(num_sources^2, size(Timeseries,parameters.timeDim), 2);

                    % And for each timeseries to be correlated
                    for source1i=1:num_sources
                        C_source1(parameters.corrDim) = {source1i};

                        for source2i=1:num_sources
                            C_source2(parameters.corrDim) = {source2i};
                            
                            timeseries_list((source1i*num_sources-1)+source2i,:,1) = Timeseries(C_source1{:});
                            timeseries_list((source1i*num_sources-1)+source2i,:,2) = Timeseries(C_source2{:});
                            
                        end 
                    end
                    
                    % Vector of corrs.
                    corrs_hold = NaN(size(timeseries_list,1),1);
                    % For each pair in the timeseries list,
                    parfor i = 1:size(timeseries_list,1)
                       
                        % Perform correlation.
                        R=corrcoef(timeseries_list(i,:,1), timeseries_list(i,:,2)); 
                        corrs_hold(i) = R(1,2);

                        % Store correlation coefficient in Corrs
                        % matrix.
                       
                    end 

                     Corrs(:,:,instancei)=reshape(corrs_hold, [num_sources num_sources])';

                end 
            end 

            % Calculate mean and standard deviation of correlations
            meanCorrs = nanmean(Corrs, parameters.instancesDim); 
            stdCorrs = std(Corrs, [], parameters.instancesDim, 'omitnan');
            
            % Get the output variable name
            output_variable_name = CreateFileStrings(parameters.output_variable, mouse, [], [], period, false);
           
            % Convert correlation data to the desired variable name
            eval([output_variable_name '.all_instances = Corrs;']);
            eval([output_variable_name '.mean = meanCorrs;']);
            eval([output_variable_name '.std = stdCorrs;']);          
        
            % Get the right names for saving per period.
            saving_filename = CreateFileStrings(parameters.output_filename, mouse , [], [], period, false);
            
            % Save per period. 
            save([dir_out saving_filename], output_variable_name); 

        end
    end
end