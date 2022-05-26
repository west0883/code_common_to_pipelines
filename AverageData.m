% AverageData.m
% Sarah West
% 4/11/22

function [parameters] = AverageData(parameters)

    % If there's a "values" field from RunAnalysis, print updating message
    % for user. 
    if isfield(parameters, 'values')
        message = ['Averaging '];
        for dispi = 1:numel(parameters.values)/2
           message = [message ', ' parameters.values{dispi}];
        end
        disp(message); 
    end

    %  Take the mean
    parameters.average = squeeze(mean(parameters.data, parameters.averageDim, 'omitnan')); 

    % Take the standard deviation
    parameters.std_dev = squeeze(std(parameters.data, 0, parameters.averageDim, 'omitnan')); 

end 