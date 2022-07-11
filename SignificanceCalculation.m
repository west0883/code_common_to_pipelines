% SignificanceCalculation.m
% Sarah West
% 6/20/22

% Takes the "real" sample values and compares it to a null distribution of
% values to calculate p-values. Run with RunAnalysis.
% Inputs:
% parameters.testing_values
% parameters.null_distribution
% parameters.shufflesDim
% parameters.find_significance -- true/false 
% parameters.alphaValue -- the statistical alpha value.
% parameters.twoTailed -- true/false-- if the statistical significance should be checked
% as a two-tailed test. Default is "true"

% Outputs:
% parameters.significance -- .pvals_raw, .increase,
% .decrease, .all. 


function [parameters] = SignificanceCalculation(parameters)

    % Give user a progress message
    MessageToUser('Testing significance of ', parameters);

    % Find a p value by fitting a normal distibution to the null data & 
    % calculating the cumulative distribution function at the "real" sample values. 

    % If user doesn't want to use a normal distribution,
    if isfield(parameters, 'useNormalDistribution')  && ~parameters.useNormalDistribution

        % Divide alpha value in half (to get increase or decrease)
        alpha = parameters.alphaValue ./ 2;

        % (can't get out p-values from this, exactly)
        % Sort null distribution data
        null_distribution_sorted = sort(parameters.null_distribution, 2); 

        increase_threshold_element_index = round(size(null_distribution_sorted,2) * (1 - alpha));
        decrease_threshold_element_index = round(size(null_distribution_sorted,2) * alpha); 

        % threshold values. 
        increase_threshold_values = null_distribution_sorted(:, increase_threshold_element_index);
        decrease_threshold_values = null_distribution_sorted(:, decrease_threshold_element_index);

        % If the sizes of parameters.test_values & the threshold matrices
        % don't match, transpose the threshold matrices. 
        if ~isequal([size(parameters.test_values)], [size(increase_threshold_values)])

            increase_threshold_values = increase_threshold_values';
            decrease_threshold_values = decrease_threshold_values';
        end
        
        % Calculate significance for increase & decrease.
        significance.increase = parameters.test_values > increase_threshold_values;
        significance.decrease = parameters.test_values < decrease_threshold_values;

        % All significant results.
        significance.all = significance.increase | significance.decrease;

    % Otherwise, use a normal distribution
    else
       [~, significance.pvals_raw] = ztest(parameters.test_values, mean(parameters.null_distribution, parameters.shufflesDim, 'omitnan'), ...
            std(parameters.null_distribution,[], parameters.shufflesDim, 'omitnan'));  

       % Default is 2-tailed
       % If  2-tailed
       % if ~isfield(parameters, 'twoTailed') || parameters.twoTailed
 
            % Divide alpha value in half (to get increase or decrease)
            alpha = parameters.alphaValue ./ 2;

            % Calculate significance for increase & decrease.
            significance.increase = significance.pvals_raw > (1 - alpha); 
            significance.decrease = significance.pvals_raw < alpha; 

            % All significant results.
            significance.all = significance.increase | significance.decrease;
           
%         % Else, user is specifically saying not to use two-tailed.
%         else
%             significance.
% 
%         end
    end

    % Put significance into parameters structure.
    parameters.significance = significance;

end 