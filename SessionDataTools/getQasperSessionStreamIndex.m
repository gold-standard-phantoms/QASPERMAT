function streamIndex = getQasperSessionStreamIndex(sessionData)
%% Function Name: getQasperSessionStreamIndex
%
% Description: creates a structure with indexes corresponding to the
% streamed data.
%
% Assumptions:
%
% Inputs:
%	sessionData - Qasper Session Data
%
% Outputs:
%	streamIndex - structure with indexes corresponding to stream names.

% $Date: June 25, 2018

streamNames = {sessionData.Stream.Name}; %create cell array of stream names

streamIndex.FlowRateSetPoint = find(strcmp(streamNames, 'flow_rate_set_point')); % Flow Rate Set Point
streamIndex.FlowRate = find(strcmp(streamNames, 'flow_rate')); % Flow Rate
streamIndex.WaveformAmplitude = find(strcmp(streamNames, 'waveform_amplitude')); %Waveform Amplitude
streamIndex.BatteryVoltage = find(strcmp(streamNames, 'voltage')); %Battery Voltage
streamIndex.BatteryCurrent = find(strcmp(streamNames, 'current_draw')); %Battery Current Draw
streamIndex.PerfusateTemperatureA = find(strcmp(streamNames, 'perfusate_temperature_in'));
streamIndex.PerfusateTemperatureB = find(strcmp(streamNames, 'perfusate_temperature_out'));
streamIndex.PCBTemperatureA = find(strcmp(streamNames, 'pcb_temperature_in'));
streamIndex.PCBTemperatureB = find(strcmp(streamNames, 'pcb_temperature_out'));
streamIndex.DrivingStatus = find(strcmp(streamNames, 'driving_status'));
	

	
end
	