function [data, jsonStruct] = loadQasperSessionData(filename)
%% Function Name: loadQasperSessopmData
%
% Description: Loads in QASPER json session data, converts base64 streams to
% double precision, converts timestamps to Matlab format serial data
% numbers.  Returned timestamps are in UTC
%
% Assumptions: Supplied json file is created by Gold Standard Phantom's QASPER Control software
%
% Inputs:
%	filename - string filename
%
% Outputs:
%	data -  Structure containing the converted QASPER session data.  This 
%           struct has the following entries:
%
%           FirmwareInfo.FirmwareName: the pump controller firmware name
%           FirmwareInfo.FirmwareVersion: the pump controller firmware version
%           md5Hash: the md5 hash of the file when saved by the pump
%               control software, can be used to determine if the data is
%               valid or corrupt/modified.
%
%           Struct array 'Stream', each stream having:
%               TimestampOffset: the start time of the data stream
%               as a MATLAB datenumber.
%               Samples: the data samples from the stream.
%               Elapsed: the time in seconds elapsed since the start
%               of the data stream
%               Name: the snake_case name of the stream 
%               fName: the friendly name of the stream           
%               units: the units of the stream data

%           Struct array 'LogEntries', having for each log entry:
%               LogText: text description for the log
%               LogTime: time of the log as a MATLAB datenumber
%               LogElapsed: the time in seconds elapsed since the
%               TimestampOffset of Stream(1)
%               
%           SyncTimestamp: the timestamp of the synchronisation log as a
%           MATLAB datenumber
%           SyncDateAndTime: the timestamp of the synchronisation log as a
%           datestring.
%           LocalTimeZone: the timezone the QASPER session data was
%           recorded in. The QASPER session data saves timestamps in UTC
%           format, however knowledge of the local timezone may be of use
%           when synchronising this data with other modalities, e.g. the
%           MRI image's timestamps.
%           SessionDateAndTime: A datestring of the start of the QASPER
%           session, equivalent to the datestring of the TimestampOffset of
%           Stream(1)
%
%	jsonStruct - unconverted json data, as loaded using jsondecode.

% $Date: December 03, 2020
% $Author: Aaron Oliver-Taylor



jsonText = fileread(filename); %load json file as text
jsonStruct = jsondecode(jsonText); %decode text into json fields.

%copy across software/firmware version info and md5 hash.
data.PhantomSerialNumber = jsonStruct.phantom_serial_number;
data.QasperControlSoftwareVersion = jsonStruct.software_version;

if(isfield(jsonStruct, 'firmware_info')) %firmware info not present on old versions so check if this exists.
	data.FirmwareInfo.FirmwareName = jsonStruct.firmware_info.firmware_name;
	data.FirmwareInfo.FirmwareVersion = jsonStruct.firmware_info.firmware_version;
else
    data.FirmwareInfo.FirmwareName = [];
    data.FirmwareInfo.FirmwareVersion = [];
end
data.md5Hash = jsonStruct.md5_hash;

%if present, decode data streams
if(~isempty(jsonStruct.data_streams))
	if(iscell(jsonStruct.data_streams)) %if some data streams are empty (i.e. not in engineering mode) then this is a cell array and not a struct, so conver to a struct by removing empty cells
		jsonStruct.data_streams = [jsonStruct.data_streams{:}]; %convert to struct array, remove empty cells
	end
	nDataStreams = length(jsonStruct.data_streams);

	for n = 1:nDataStreams
		data.Stream(n).TimestampOffset = convertQasperSerialDateNumber(jsonStruct.data_streams(n).timestamp_offset); %convert serial date number to matlab format (fractional days since 01/01/0000)
		samples = double(typecast(swapbytes(matlab.net.base64decode(jsonStruct.data_streams(n).data_base64)), 'single')); %decode base64 data to float32, cast to double.
		elapsed = double(typecast(swapbytes(matlab.net.base64decode(jsonStruct.data_streams(n).timestamps_base64)), 'single')); %decode base64 timestamps to float32, cast to double
		[uniqueElapsed, uniqueIndexes] = unique(elapsed, 'last'); %samples are timestamped by the Qasper Control software, and the phantom can send multiple samples at once.  So, if a duplicate exists only use the last sample obtained for a given timestamp.
		
		data.Stream(n).Samples = samples(uniqueIndexes).'; 
		data.Stream(n).Elapsed = uniqueElapsed.';
		
		data.Stream(n).Name = jsonStruct.data_streams(n).stream_name; %copy stream name.
		[friendlyname, units] = friendlyQasperSessionStreamName(data.Stream(n).Name);
		data.Stream(n).fName = friendlyname;
		data.Stream(n).units = units;
	end
end

%if present, copy across logs and correct time/dates.
if(~isempty(jsonStruct.log_entries))
	for n=1:length(jsonStruct.log_entries)
		data.LogEntries(n).LogText = jsonStruct.log_entries(n).log_text;
		data.LogEntries(n).LogTime = convertQasperSerialDateNumber(jsonStruct.log_entries(n).log_time); %convert log timestamp serial date number to matlab format (fractional days since 01/01/0000)
		data.LogEntries(n).LogElapsed = (data.LogEntries(n).LogTime - data.Stream(1).TimestampOffset)*60*60*24; %determine log time in seconds w.r.t. start of streamed data.
	end
end

%if present, copy across the synchronisation timestamp and correct the
%time/date
if(~isempty(jsonStruct.sync_timestamp))
    data.SyncTimestamp = convertQasperSerialDateNumber(jsonStruct.sync_timestamp);
    data.SyncDateAndTime = datestr(data.SyncTimestamp);
else
    data.SyncTimestamp = [];
    data.SyncDateAndtime = [];
end

%if present, copy across timezone information
if(~isempty(jsonStruct.local_time_zone))
    data.LocalTimeZone = jsonStruct.local_time_zone;
else
    data.LocalTimeZone = [];
end
    
data.SessionDateAndTime = datestr(data.Stream(1).TimestampOffset);