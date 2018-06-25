%% QASPER GSP Performance Test Analysis
% 
%%

[jsonFileName, jsonFilePath] = uigetfile('*.json', 'Please select the Qasper session data .json file'); %User selects tha Qasper session data json file.

qasperSessionData = loadQasperMetaData([jsonFilePath, filesep, jsonFileName]); %load in the Qasper session data