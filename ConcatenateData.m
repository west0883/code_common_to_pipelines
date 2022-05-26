% ConcatenateData.m
% Sarah West
% 4/9/22
% Concatenates data together. 

% Input: parameters.data, 
%       parameters.concatenated_data - previously concatenated data that
%           you're adding this data to. 
%       parameters.concatDim -- the dimension the data should be
%       concatenated across.
% Output: parameters.concatenated_data 
        % - Structure with fields:
        %       "all_instances" -- the concatenated data
        %       "mean" -- the mean of the data
        %       "std" -- the std of the data

function [parameters] = ConcatenateData(parameters)
    
    % Display progress message to user.
    MessageToUser('Concatenating ', parameters);
    
    % If parameters.data has only one entry (no cells/not a cell array), or if user said to
    % concatenated across (instead of within) cells. 
    if ~iscell(parameters.data) || (isfield(parameters, 'concatenate_across_cells') && parameters.concatenate_across_cells)
        % Make an empty variable for celli to determine display
        % message (just puts an empty place in the message)
        celli = []; 

        % If concatenated_data doesn't exist yet, create it as empty
        % array.
        if ~isfield(parameters, 'concatenated_data')
            parameters.concatenated_data = [];
        end

        % If data to concatenate isn't empty, add it to the
        % concatenated data 
        if ~isempty(parameters.data)
            parameters.concatenated_data = SubConcatenateData(parameters.concatenated_data, parameters.data, parameters.concatDim, celli); 
        end

    % If parameters.data has more than one entry, in cell form 
    else iscell(parameters.data) 
       
        % If concatenated_data doesn't exist yet, create it as empty
        % cell array with same size as number of cells in data.
        if ~isfield(parameters, 'concatenated_data')
            parameters.concatenated_data = cell(size(parameters.data));
        end

        % Could do cellfun, but I want to disp where the errors occur.
        for celli = 1:numel(parameters.data)
            if ~isempty(parameters.data{celli})

                parameters.concatenated_data{celli} = SubConcatenateData(parameters.concatenated_data{celli}, parameters.data{celli}, parameters.concatDim, celli); 

            end
        end
    end 
end

function [concatenated_data] = SubConcatenateData(concatenated_data, data, concatDim, celli) 
    
    % Initialize empty output
    try
        concatenated_data = cat(concatDim, concatenated_data, data);
    catch 
        if isempty(celli)
            disp(['Dimension error.']);
        else
           disp(['Dimension error in cell ' num2str(celli) '.']);
        end
    end
end 
