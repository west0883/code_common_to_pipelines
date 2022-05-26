% ReshapeData.m
% Sarah West
% 4/13/22

% Reshapes data for use with RunAnalysis.m. Uses a string cell array as
% input for dimensions.

function [parameters] = ReshapeData(parameters)

     dimensions_string = CreateStrings(parameters.reshapeDims, parameters.keywords, parameters.values);
     eval(['dimensions = ' dimensions_string ';']);

     parameters.data_reshaped = reshape(parameters.data, dimensions{:});

end 