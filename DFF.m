% DFF.m
% Sarah West
% 12/2/22
% Function that finds the delta F/F, given a set of fluorescence values and
% a mean. Is run by RunAnalysis

% Inputs: 
% parameters.data -- the fluorescence values to convert into percents
% parameters.fluorescence_mean -- the mean fluorescence, should work with
% the dimensions of parameters.data

% Outputs:
% parameters.DFF -- the fluorescence values converted to percents

function [parameters] = DFF(parameters)

    MessageToUser('Calculating DFF on ', parameters);
    
    parameters.DFF = 100 * ((parameters.data + parameters.fluorescence_mean)./parameters.fluorescence_mean) - 100; 

end 