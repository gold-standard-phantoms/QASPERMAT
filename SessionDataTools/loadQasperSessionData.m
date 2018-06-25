function [data, jsonStruct] = loadQasperSessionData(filename)
%% Function Name: loadQasperSessopmData
%
% Description: Loads in QASPER json session data, converts base64 streams to
% double precision, converts timestamps to Matlab format serial data
% numbers.
%
% Assumptions: Supplied json file is created by Gold Standard Phantom's QASPER Control software
%
% Inputs:
%	filename - string filename
%
% Outputs:
%	data - Structure containing the converted QASPER session data.
%	jsonStruct - unconverted json data, as loaded using jsondecode.

% $Date: June 25, 2018



jsonText = fileread(filename); %load json file as text
jsonStruct = jsondecode(jsonText); %decode text into json fields.

%copy across software/firmware version info and md5 hash.
data.PhantomSerialNumber = jsonStruct.phantom_serial_number;
data.QasperControlSoftwareVersion = jsonStruct.software_version;

if(isfield(jsonStruct, 'firmware_info')) %firmware info not present on old versions so check if this exists.
	data.FirmwareInfo.FirmwareName = jsonStruct.firmware_info.firmware_name;
	data.FirmwareInfo.FirmwareVersion = jsonStruct.firmware_info.firmware_version;
end
data.md5Hash = jsonStruct.md5_hash;

%if present, decode data streams
if(~isempty(jsonStruct.data_streams))
	jsonStruct.data_streams = [jsonStruct.data_streams{:}]; %convert to struct array, remove empty cells
	nDataStreams = length(jsonStruct.data_streams);

	for n = 1:nDataStreams
		jsonStruct.data_streams(n).timestamp_offset = convertQasperControlSerialDateNumber(jsonStruct.data_streams(n).timestamp_offset); %convert serial date number to matlab format (fractional days since 01/01/2000)
		data.Stream(n).Samples = double(typecast(swapbytes(matlab.net.base64decode(jsonStruct.data_streams(n).data_base64)), 'single')); %decode base64 data to float32, cast to double.
		data.Stream(n).Elapsed = double(typecast(swapbytes(matlab.net.base64decode(jsonStruct.data_streams(n).timestamps_base64)), 'single')); %decode base64 timestamps to float32, cast to double
		data.Stream(n).Name = jsonStruct.data_streams(n).stream_name; %copy stream name.
	end
end

%if present, copy across logs and correct time/dates.
if(~isempty(jsonStruct.log_entries))
	for n=1:length(jsonStruct.log_entries)
		data.LogEntries(n).LogText = jsonStruct.log_entries(n).log_text;
		data.LogEntries(n).LogTime = convertQasperControlSerialDateNumber(jsonStruct.log_entries(n).log_time); %convert log timestamp serial date number to matlab format (fractional days since 01/01/2000)
	end
end