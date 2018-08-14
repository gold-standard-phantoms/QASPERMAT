
if(~exist('jsonFileName'))
	[jsonFileName, jsonFilePath] = uigetfile('*.json', 'Please select the Qasper session data .json file'); %User selects tha Qasper session data json file.
end

qasperSessionData = loadQasperSessionData([jsonFilePath, filesep, jsonFileName]); %load in the Qasper session data


streamIndex = getQasperSessionStreamIndex(qasperSessionData);
amplitudeThreshold = 0.1;

a= 1;
for n = 1:length(qasperSessionData.LogEntries)
	
	testType = qasperSessionData.LogEntries(n).LogText(1);
	doParse = false;
	if(testType == 'Q')
		testSpec(a).type = 'Constant Flow Rate';
		testSpec(a).testConditionIndex = streamIndex.FlowRateSetPoint;
		doParse = true;
	elseif(testType == 'A')
		testSpec(a).type = 'Constant Amplitude';
		testSpec(a).testConditionIndex = streamIndex.WaveformAmplitude;
		doParse = true;
	elseif(testType == 'O')
		testSpec(a).type = 'Pump Off';
		testSpec(a).testConditionIndex = streamIndex.DrivingStatus;
		doParse = true;
	end
	if(doParse)
		testSpec(a).value = str2num(qasperSessionData.LogEntries(n).LogText(3:end));
		testSpec(a).units = qasperSessionData.Stream(testSpec(a).testConditionIndex).units;
		testSpec(a).startElapsed = qasperSessionData.LogEntries(n).LogElapsed;
		testSpec(a).conditionsMet = qasperSessionData.Stream(testSpec(a).testConditionIndex).Samples == testSpec(a).value;
		
		
		
		testStartIndex = dsearchn(qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed.', testSpec(a).startElapsed); %find start findex corresponding with the log entry timestamp.
		
		% check that the other conditions do not change in these periods by
		% doing an AND with the condition values at the start of the test
		% period...
		
		%interpolate condition stream data to the timebase of the test.
		%flow rate set point
		if(length(qasperSessionData.Stream(streamIndex.FlowRateSetPoint).Elapsed) ~= length(qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed))
			
			data = interp1(qasperSessionData.Stream(streamIndex.FlowRateSetPoint).Elapsed, qasperSessionData.Stream(streamIndex.FlowRateSetPoint).Samples, qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed);
		elseif(~all(qasperSessionData.Stream(streamIndex.FlowRateSetPoint).Elapsed == qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed))
			data = interp1(qasperSessionData.Stream(streamIndex.FlowRateSetPoint).Elapsed, qasperSessionData.Stream(streamIndex.FlowRateSetPoint).Samples, qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed);
		else
			data = qasperSessionData.Stream(streamIndex.FlowRateSetPoint).Samples;
		end
		conditionCFR = data == data(testStartIndex);
		
		%amplitude
		if(length(qasperSessionData.Stream(streamIndex.WaveformAmplitude).Elapsed) ~= length(qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed))
			data = interp1(qasperSessionData.Stream(streamIndex.WaveformAmplitude).Elapsed, qasperSessionData.Stream(streamIndex.WaveformAmplitude).Samples, qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed);
		elseif(~all(qasperSessionData.Stream(streamIndex.WaveformAmplitude).Elapsed == qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed))
			data = interp1(qasperSessionData.Stream(streamIndex.WaveformAmplitude).Elapsed, qasperSessionData.Stream(streamIndex.WaveformAmplitude).Samples, qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed);
		else
			data = qasperSessionData.Stream(streamIndex.WaveformAmplitude).Samples;
		end
		if(data(testStartIndex) == 0) %special case when the pump is off.
			conditionCA = data == 0;
		else
			conditionCA = (data < data(testStartIndex) + amplitudeThreshold*data(testStartIndex)) & (data > data(testStartIndex) - amplitudeThreshold*data(testStartIndex)); %condition is amplitude is not greater/less than the threshold multiple
		end
		%driving state
		if(length(qasperSessionData.Stream(streamIndex.DrivingStatus).Elapsed) ~= length(qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed))
			data = interp1(qasperSessionData.Stream(streamIndex.DrivingStatus).Elapsed, qasperSessionData.Stream(streamIndex.DrivingStatus).Samples, qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed);
		elseif(~all(qasperSessionData.Stream(streamIndex.DrivingStatus).Elapsed == qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed))
			data = interp1(qasperSessionData.Stream(streamIndex.DrivingStatus).Elapsed, qasperSessionData.Stream(streamIndex.DrivingStatus).Samples, qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed);
		else
			data = qasperSessionData.Stream(streamIndex.DrivingStatus).Samples;
		end
		conditionDS = data == data(testStartIndex);
		
		%combine
		testSpec(a).conditionsMet = testSpec(a).conditionsMet & conditionCFR & conditionCA & conditionDS;
		
		cc = bwconncomp(testSpec(a).conditionsMet);
		if(cc.NumObjects > 0)
			testSpec(a).doTest = true;
			% check the timestamp for the test log entry is within the
			% contiguous period
			idx = 1;
			while(~any(testStartIndex == cc.PixelIdxList{idx}))
				idx = idx + 1;
				if(idx > cc.NumObjects)
					testSpec(a).doTest = false;
					break; %no match found, 
				end
			end
			
			testSpec(a).testIndexes = cc.PixelIdxList{idx}; 
			testSpec(a).endElapsed = qasperSessionData.Stream(testSpec(a).testConditionIndex).Elapsed(testSpec(a).testIndexes(end));
		else
			testSpec(a).doTest = false;
		end
		a = a+1; %increment testSpec counter
	end
end

	



% Analyse the data for each test period
for n = 1:length(testSpec)
	
	if(testSpec(n).doTest)
	
		for m = 1:length(qasperSessionData.Stream)
			testStartIndex = dsearchn(qasperSessionData.Stream(m).Elapsed.', testSpec(n).startElapsed);
			testEndIndex = dsearchn(qasperSessionData.Stream(m).Elapsed.', testSpec(n).endElapsed);
			testSpec(n).data(m).testRange = testStartIndex:testEndIndex;
			testSpec(n).data(m).samples = qasperSessionData.Stream(m).Samples(testSpec(n).data(m).testRange); %streamed data during test period
			testSpec(n).data(m).elapsed = qasperSessionData.Stream(m).Elapsed(testSpec(n).data(m).testRange); %streamed data elapsed timestamps during test period
			testSpec(n).data(m).mean = mean(qasperSessionData.Stream(m).Samples(testSpec(n).data(m).testRange)); %mean streamed value during test period.
			testSpec(n).data(m).std = std(qasperSessionData.Stream(m).Samples(testSpec(n).data(m).testRange)); %mean streamed value during test period.
			testSpec(n).data(m).name = qasperSessionData.Stream(m).fName;
			testSpec(n).data(m).units = qasperSessionData.Stream(m).units;
			
		end
	else
		testSpec(n).data(m).samples = []; %empty struct if test flow rate set point was not found.
	end
	
end

fldn = fieldnames(streamIndex);
for fn = 1:length(fldn)
	fldn{fn,2} = 1;
	if(strcmp(fldn{fn,1}, 'FlowRateSetPoint')) %set display flag to off
		fldn{fn,2} = 0;
	elseif(strcmp(fldn{fn,1}, 'DrivingStatus')) %set display flag to off
		fldn{fn,2} = 0;
	end
end


%%% QASPER Performance Test Report
%
% Session Information
disp(['Session Data Generated: ', qasperSessionData.SessionDateAndTime]);
disp(['Report Generated on: ', datestr(now)]);
%
disp(['MCU UID: ', qasperSessionData.PhantomSerialNumber]);
disp(['Qasper Control Software Version: ', qasperSessionData.QasperControlSoftwareVersion]);
disp(['Firmware Version: ', qasperSessionData.FirmwareInfo.FirmwareVersion]);
snapnow();
pause(0.1);
%%
%%% Test Data

snapnow();




for n=1:length(testSpec)
	%%
	disp([testSpec(n).type, ' = ' num2str(testSpec(n).value), testSpec(n).units]);
	snapnow();
	for m = 1:length(fldn)
		fieldIndex = streamIndex.(fldn{m,1});
		
		if(~isempty(testSpec(n).data(fieldIndex).samples))
			if(fldn{m,2})
				disp(testSpec(n).data(fieldIndex).name);
				figure;
				plot(testSpec(n).data(fieldIndex).elapsed, testSpec(n).data(fieldIndex).samples);
				title(testSpec(n).data(fieldIndex).name, 'Interpreter', 'none');
				disp(['Mean ', testSpec(n).data(fieldIndex).name, ' = ', num2str(testSpec(n).data(fieldIndex).mean), ' ± ', num2str(testSpec(n).data(fieldIndex).std), testSpec(n).data(fieldIndex).units]);
				snapnow();
			end
		end
	end
end



