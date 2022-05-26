% PermuteData
% Sarah West
% 5/11/22

% Permutes data for use with RunAnalysis.m. 

function [parameters] = PermuteData(parameters)
    
    % Display progress message to user.
    MessageToUser('Permuting ', parameters); 
    
    % Permute
    data_permuted = permute(parameters.data, parameters.DimOrder); 

    % Put into output structure.
    parameters.data_permuted = data_permuted;
end 