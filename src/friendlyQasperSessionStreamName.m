function [friendlyName, units] = friendlyQasperSessionStreamName(sessionDataName)
%% Function Name: friendlyQasperSessionStreamName
% 
% Description: Returns friendly names and units for the QASPER streams.
% 
%

% $Date: June 25, 2018
names = {	'pcb_temperature_in','PCB Temperature A', '°C';
	'pcb_thermistor_adc_a','PCB Temperature A ADC', 'count';
	'pcb_thermistor_adc_b','PCB Temperature B ADC', 'count';
	'battery_state_of_charge','Battery % Left', '%';
	'perfusate_temperature_out','Perfusate Temperature B', '°C';
	'voltage','Battery Voltage', 'mV';
	'perfusate_thermistor_adc_a','Perfusate Temperature A ADC', 'count';
	'positive_high_voltage','Positive High Voltage', 'V';
	'current_draw','Battery Current Draw', 'mA';
	'flow_rate','Flow Rate', 'ml/min';
	'negative_high_voltage','Positive High Voltage', 'V';
	'battery_time_left','Battery Time Left', 'min';
	'perfusate_temperature_in','Perfusate Temperature A', '°C';
	'perfusate_thermistor_adc_b','Perfusate Temperature A ADC', 'count';
	'driving_status','Driving Status', 'on/off';
	'pcb_temperature_out','PCB Temperature B', '°C';
	'flow_rate_set_point','Flow Rate Set Point', 'ml/min';
	'waveform_amplitude','Waveform Amplitude', 'a.u.';
	'flow_meter_frequency','Flow Meter Frequency', 'Hz'};

index = find(strcmp({names{:,1}}, sessionDataName));
friendlyName = names{index,2};
units = names{index,3};

		
end