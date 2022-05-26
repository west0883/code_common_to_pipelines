% AverageData.m
% Sarah West
% 4/11/22

function [parameters] = AverageData(parameters)

    % Display progress message to user.
    MessageToUser('Averaging ', parameters);

    %  Take the mean
    parameters.average = squeeze(mean(parameters.data, parameters.averageDim, 'omitnan')); 

    % Take the standard deviation
    parameters.std_dev = squeeze(std(parameters.data, 0, parameters.averageDim, 'omitnan')); 

end 