function [data, text = loadQasperMetaData(filename)

jsonText = fileread(filename);
jsonStruct = jsondecode(jsonText);


if(~isempty(jsonStruct.data_streams))
	jsonStruct.data_streams = [jsonStruct.data_streams{:}]; %convert to struct array, remove empty cells
	nDataStreams = length(jsonStruct.data_streams);

	jsonDatenumOffset = datenum('01/01/1970');

	for n = 1:nDataStreams
		jsonStruct.data_streams(n).timestamp_offset = jsonStruct.data_streams(n).timestamp_offset/(60*60*24) + jsonDatenumOffset; %convert serial date number to matlab format (fractional days since 01/01/2000)
		data.stream(n).samples = double(typecast(swapbytes(matlab.net.base64decode(jsonStruct.data_streams(n).data_base64)), 'single'));
		data.stream(n).elapsed = double(typecast(swapbytes(matlab.net.base64decode(jsonStruct.data_streams(n).timestamps_base64)), 'single'));
		data.stream(n).name = jsonStruct.data_streams(n).stream_name;
	end
end

