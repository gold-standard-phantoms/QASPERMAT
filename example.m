%% QASPER Session Data Example
% This script is to demonstrate the use of the QASPER session data in
% combination with some imaging data.  The script performs the following:
%   1. Loads in the imaging data for the series we are interested in
%   2. Loads in the imaging data for the synchronisation image series
%   3. Loads in the QASPER session data
%   4. Calculates the time-offset between the QASPER session data and the
%      synchronisation image.
%   5. Extracts the stream data corresponding to the image series we are
%      interested in.
%   6. Plots the data.
%
%
% To account for possible differences between the MRI scanner's time and
% the time on the computer that is running the QASPER pump control
% software, a special 'synchronisation log' is usually created within the
% QASPER pump control software at the same time as a particular image
% acquisition starts.  In this example we use the synchronisation log's
% timestamp, and the 'AcquisitionDateTime' of the synchronisation image to
% account for any offset in times.
%
% Note that this script uses dicm2nii's nii_tool to load in the NIFTI
% images.  It is not included as part of the QASPERMAT library however.
%
% A key parameter required for this is the 'AcquisitionDuration' field.
% This is not accessed in the same way for each vendor:
%   Philips: dicom tag (0018, 9073)
%   GE: dicom tag (0019, 105A) / 1e6 to obtain in seconds
%   Siemens: the most reliable method is to use the phoenix protocol
%   parameter 'm_sequenceParameters.ltotalscantimesec'
%
% In this example the json sidecars for the survey and image have been
% modified so that they have these fields.


%%
clear %start afresh

%define some file paths
locationOfThisScript = fileparts(mfilename('fullpath'));
dataFolder = fullfile(locationOfThisScript, 'data');
imageNiftiFilename = fullfile(dataFolder, 'pCASL_TL1800_PLD1800.nii.gz');
imageJsonFilename = fullfile(dataFolder, 'pCASL_TL1800_PLD1800.json');
syncImageNiftiFilename = fullfile(dataFolder, 'survey.nii.gz');
syncImageJsonFilename = fullfile(dataFolder, 'survey.json');
qasperSessionDataFilename = fullfile(dataFolder, 'image_sync_example.json');


% Load in the image data
imageNii = nii_tool('load', imageNiftiFilename);
imageSidecar = jsondecode(fileread(imageJsonFilename));

% Load in the synchronisation image data
syncImageNii = nii_tool('load', syncImageNiftiFilename);
syncImageSidecar = jsondecode(fileread(syncImageJsonFilename));

%Load in the QASPER session data
qasperSessionData = loadQasperSessionData(qasperSessionDataFilename);

%get the AcquisitionDateTime from the sync image
syncImageTime = datetime(syncImageSidecar.AcquisitionDateTime, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS');

%calculate the offset between the sync image and the synchronisation
%timestamp from the qasper session data.
syncOffset = datetime(qasperSessionData.SyncDateAndTime) - syncImageTime;

%get the corresponding streams for when the image was acquired.
qasperDataDuringImage = extractQasperStreamAtTime(...
    qasperSessionData,...
    datetime(imageSidecar.AcquisitionDateTime, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS'),...
    imageSidecar.AcquisitionDuration,...
    syncOffset);

%get the stream index's
streamIndex = getQasperSessionStreamIndex(qasperSessionData);
%%

fprintf('Flow rate during image acquisition is %0.2f ± %0.2f\n',...
    qasperDataDuringImage(streamIndex.FlowRate).mean,...
    qasperDataDuringImage(streamIndex.FlowRate).std)

fprintf('Flow rate setpoint is %0.2f\n',...
    qasperDataDuringImage(streamIndex.FlowRateSetPoint).mean)

fprintf('Perfusate Temperature during image acquisition is %0.2f ± %0.2f\n',...
    qasperDataDuringImage(streamIndex.PerfusateTemperatureA).mean,...
    qasperDataDuringImage(streamIndex.PerfusateTemperatureA).std)

% Plot the flow rate and perfusate temperatures
figure;
yyaxis('left');
hold on;
plot(qasperDataDuringImage(streamIndex.FlowRate).Elapsed, qasperDataDuringImage(streamIndex.FlowRate).Samples)
plot(qasperDataDuringImage(streamIndex.FlowRateSetPoint).Elapsed, qasperDataDuringImage(streamIndex.FlowRateSetPoint).Samples)
ylabel('Flow Rate (ml/min)');
ylim([0.9, 1.1]*qasperDataDuringImage(streamIndex.FlowRateSetPoint).mean)
yyaxis('right');
plot(qasperDataDuringImage(streamIndex.PerfusateTemperatureA).Elapsed, qasperDataDuringImage(streamIndex.PerfusateTemperatureA).Samples)
plot(qasperDataDuringImage(streamIndex.PerfusateTemperatureB).Elapsed, qasperDataDuringImage(streamIndex.PerfusateTemperatureB).Samples)
ylabel('Perfusate Temperature (°C)');
xlabel('Time (s)');






