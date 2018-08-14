clear all

[jsonFileName, jsonFilePath] = uigetfile('*.json', 'Please select the Qasper session data .json file'); %User selects tha Qasper session data json file.
[reportFileName, reportFilePath] = uiputfile('*.pdf', 'Please enter report filename');

reportOptions.format = 'pdf';
reportOptions.outputDir = reportFilePath;
reportOptions.figureSnapMethod = 'print';
reportOptions.imageFormat = 'jpg';
reportOption.evalCode = true;
reportOptions.showCode = false;

docname = publish('QasperPerformanceTestAnalysis.m', reportOptions);
movefile(docname, [reportFilePath, reportFileName],'f');
close all;