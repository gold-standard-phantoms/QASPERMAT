function out = convertQasperSerialDateNumber(in)
%% Function Name: convertQasperControlSerialDateNumber
%
% Description: Qasper Control provides timestamps as seconds elapsed since
% 01/01/1970.  Matlab uses fractional days since 01/01/0000.  This function
% converts Qasper Control serial date numbers to Matlab style.
%
% Assumptions: Provided serial date number is seconds elapsed since
% 01/01/1970.
%
% Inputs:
%	in - serial date number (seconds since 01/01/1970)
%
% Outputs:
%	out - serial date number (fractional days since 01/01/0000)

% $Date: June 25, 2018

out = in/(60*60*24) + datenum('01/01/1970');