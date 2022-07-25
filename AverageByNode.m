% AverageByNode.m
% Sarah West
% 7/25/22

% Takes correlation-type data and finds an average of that data by node.
% Uses RunAnalysis.
% Inputs: 
% parameters.data -- correlation values (correlation matrix or lower triangle of a
% correlation matrix only). Matrices must be put in with number_of_sources
% x number_of_sources dimensions as first two dimensions.
% parameters.isVector -- flag saying if the inputted data is in the
% lower-triangle vector form or not. If it is, then the vector needs to be
% reshaped into a matrix to identify which correlations belong to which
% node pairs.
% parameters.number_of_sources -- number of unique nodes.

function [parameters] = AverageByNode(parameters)

    % Send message to user.
    MessageToUser('Averaging ', parameters);

    number_of_sources = parameters.number_of_sources;

    % If this has a comparison type, pull it out.

    % Make a default comparison flag, false.
    comparison_flag = false;

    % Find if "comparison_type" is in the loop keywords.
    if any(strcmp(parameters.keywords, 'comparison_type'))

        comparison_type = parameters.values(strcmp(parameters.keywords, 'comparison_type'));
        comparison_flag = true; 

    elseif isfield(parameters, 'comparison_type')
        comparison_type = parameters.comparison_type;
        comparison_flag = true;

    else
        comparison_flag = false;

    end

    % Calculate indices of the lower triangle if hasn't been done already.
    if ~isfield(parameters, 'indices')
        parameters.indices = find(tril(ones(parameters.number_of_sources), -1));
    end
  
    % Pull out data from parameters structure for easier use.
    data = parameters.data;

    % If correlations are in vector format, reshape into a full correlation
    % matrix.
    if parameters.isVector

        % If the different correlation pairs aren't in the first dimension,
        % permute so they are.
        if parameters.corrsDim ~= 1
            
            data = permute(data, [parameters.corrsDim  setdiff(1:ndims(data), parameters.corrsDim, 'stable')]);

        end 

        % If this is a "comparison" from PLSR, need to check if there was
        % more than one variable included (like for "continuous"
        % comparisons).
        if comparison_flag
            
            % Find number of response variables (will be a multiple of
            % number of unique correlation pairs).

            unique_corr_pairs = number_of_sources * (number_of_sources - 1)/2;
            response_variable_number = size(data, 1) / unique_corr_pairs;

            if rem(size(data,1), unique_corr_pairs) ~= 0
                error('Wrong number of correlations.')
            end

            data = reshape(data, unique_corr_pairs, response_variable_number, size(data,2));
            
            % Permute so different mice are still in dimension 2.
            data = permute(data, [1 3 2]);

        end

        % Make a holder matrix, insert the data.
        % For now just assuming the original vectors had no more than 3
        % dimensions.
        holder = NaN(parameters.number_of_sources, parameters.number_of_sources, size(data, 2), size(data, 3));

        % Get some variables before parfor loop
        indices = parameters.indices;
        size3 = size(holder,3);
        size4 = size(holder, 4);

        indices_upper = find(triu(ones(parameters.number_of_sources), 1));

        % Insert.
        for i = 1:size3
            for j = 1:size4

                subholder = NaN(number_of_sources, number_of_sources);
                subholder(indices) = data(:, i, j);

                % Duplicate betas across diagonal.
                betas_flipped = subholder';
                elements_upper = betas_flipped(indices_upper);
                subholder(indices_upper) = elements_upper;

                holder(:, :, i, j) = subholder;

            end
        end

        % Rename holder to match non-vector condition.
        data = holder;

    else
       
        % If not a vector, make sure there aren't any values in the
        % diagonals.
        for i = 1:number_of_sources
            data(i, i, :, :) = NaN;
        end
    end

    % Check if there are any infinities in the matrix (can happen if values
    % of 1 are sent through the Fisher transform). Turn to NaNs if there are. 
    index = data == Inf;
    if any(index, 'all')
        data(index) = NaN;
    end

    % Take averages.
    node_averages = squeeze(mean(data, 1, 'omitnan'));
    node_stds = squeeze(std(data, [], 1, 'omitnan'));

    % Put into output structure.
    parameters.node_averages = node_averages;
    parameters.node_stds = node_stds;

end