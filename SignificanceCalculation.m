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
    significance.pvals_raw = normcdf(parameters.testing_values, mean(parameters.null_distribution, parameters.shufflesDim, 'omitnan'), ...
        std(parameters.null_distribution,[], parameters.shufflesDim, 'omitnan'));  

    % If user wants you to find the significance with the p-values
    if isfield(parameters,'find_significance') && parameters.find_significance 

        % Default is 2-tailed
        % If  2-tailed
       % if ~isfield(parameters, 'twoTailed') || parameters.twoTailed
 
            % Divide alpha value in half (to get increase or decrease)
            alpha = parameters.alphaValue / 2;

            % Calculate significance for increase & decrease.
            significance.increase = parameters.pvals_raw > 1 - alpha; 
            significance.decrease = parameters.pvals_raw < 1 - alpha; 

            % All significant results.
            significance.all = significance.increase | significance.decrease;
           
%         % Else, user is specifically saying not to use two-tailed.
%         else
%             significance.
% 
%         end

        % Put significance into parameters structure.
        parameters.significance = significance;
    end 

end 