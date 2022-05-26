% NullDistribution
% Sarah West
% 5/19/22

% To be run with RunAnalysis. Makes shufflings between two datasets (parameters.data1 &
% parameters.data2). Also takes the mean of each distribution and subtracts
% the mean of dataset 2 from the mean of dataset 1, for convenience. 

function [parameters] = NullDistribution(parameters)

    % Tell user what's happening.
    MessageToUser('Suffling ', parameters);

    % Set up matrix to hold shuffled data, depending on size
    % of the data being compared and the dimensions being shuffled.
    % Only one dimension should be shuffled. The last dimension is the the
    % number of shuffles.
    dimensions_list_1 = NaN(1, ndim(data1) + 1);
    dimensions_list_1(end) = parameters.shuffleNumber;

    dimensions_list_2 = NaN(1, ndim(data2) + 1);
    dimensions_list_2(end) = parameters.shuffleNumber;

    % Dimensions of differences will be the same as the datasets, but with
    % the shuffle dimension (instances) removed (will have been averaged
    % across that dimension).
    differences_dimensions_list = NaN(1, ndim(data1) + 1);
    differences_dimensions_list(parameters.shuffleDim) = [];
            
    % Complicated-looking stuff that lets you select the correct
    % dimension.
    inds_data = repmat({':'}, 1, ndims(data1) + 1);
    inds_difference = repmat({':'}, 1, ndims(data1));

    % Set up holders. First entry of parameters.null_distributions will be 
    % shuffled dataset 1, second will be shuffled dataset 2. Keep the
    % distributions together in same file/variable/context, because they're
    % meaningless on their own. 
    parameters.null_distributions = cell(1, 2);
    distributions1 = NaN(dimensions_list_1);
    distributions2 = NaN(dimensions_list_2);
    differences_of_distributions = NaN(differences_dimensions_list);

    % Begin shufflings.
    
    % For each repetition, (can't do parfor because of the unknown
    % dimensions)
    for shufflei = 1: parameters.shuffleNumber
        
        % Change the index in the correct dimension.                
        inds_data{end} = shufflei;
        inds_difference{end} = shufflei;
        
        % Concatenate all data of both periods.
        all_data = cat(parameters.shuffleDim, data1, data2); 
        
        % Make a mixing vector that's made up of a random
        % permutation of the number of total instances of both
        % periods.
        vect_mix = randperm(size(all_data, parameters.shuffleDim));
        
        % Apply this mixing vector to the concatenated data and split the
        % resulting shuffled data in two new shuffled datasets that
        % have the same number of instances as the two periods that 
        % were inputted.
        distributions1(inds_data{:}) = all_data(:,:,(vect_mix(1:size(data1, parameters.shuffleDim))));
        distributions2(inds_data{:}) = all_data(:,:,(vect_mix((size(data1, parameters.shuffleDim) + 1):end)));
        
        % Take the difference of the mean of the two shuffled
        % datasets and put it in the right place.
        differences_of_distributions(inds_difference{:}) = mean(distribution2, parameters.shuffleDim, 'omitnan') - mean(distribution1, parameters.shuffleDim, 'omitnan');

    end

    % Put into output structure.
    parameters.null_distributions{1} = distributions1;
    parameters.null_distributions{2} = distributions2; 
    parameters.differences_of_distributions = differences_of_distributions;
        
end