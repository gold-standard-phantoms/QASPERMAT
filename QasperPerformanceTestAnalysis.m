clear all;

[jsonFileName, jsonFilePath] = uigetfile('*.json', 'Please select the Qasper session data .json file'); %User selects tha Qasper session data json file.

qasperSessionData = loadQasperSessionData([jsonFilePath, filesep, jsonFileName]); %load in the Qasper session data

%%
streamIndex = getQasperSessionStreamIndex(qasperSessionData);

TestFlowRate = [350, 500];
TestWavAmp = 1.0;

%Flow Rate Loop
for n = 1:length(TestFlowRate)
	setpointIsTestRate = qasperSessionData.Stream(streamIndex.FlowRateSetPoint).Samples == TestFlowRate(n);
	cc = bwconncomp(setpointIsTestRate); %determine contiguous periods when the setpoint was set at the test setpoint
	if(cc.NumObjects > 0)
		TestIndexes = cc.PixelIdxList{1}; %Use the first contiguous period.
		ElapsedTestStart = qasperSessionData.Stream(streamIndex.FlowRateSetPoint).Elapsed(TestIndexes(1));
		ElapsedTestEnd = qasperSessionData.Stream(streamIndex.FlowRateSetPoint).Elapsed(TestIndexes(end));
	
	
	
		for m = 1:length(qasperSessionData.Stream)
			testStartIndex = dsearchn(qasperSessionData.Stream(m).Elapsed.', ElapsedTestStart);
			testEndIndex = dsearchn(qasperSessionData.Stream(m).Elapsed.', ElapsedTestEnd);
			testRange = testStartIndex:testEndIndex;
			testStreamDataFR(n,m).samples = qasperSessionData.Stream(m).Samples(testRange); %mean streamed value during test period.
			testStreamDataFR(n,m).elapsed = qasperSessionData.Stream(m).Elapsed(testRange); %mean streamed value during test period.
			testStreamDataFR(n,m).mean = mean(qasperSessionData.Stream(m).Samples(testRange)); %mean streamed value during test period.
			testStreamDataFR(n,m).std = std(qasperSessionData.Stream(m).Samples(testRange)); %mean streamed value during test period.
			testStreamDataFR(n,m).name = qasperSessionData.Stream(m).fName;
			testStreamDataFR(n,m).units = qasperSessionData.Stream(m).units;
			
		end
	else
		testStreamDataFR(n,m).samples = []; %empty struct if test flow rate set point was not found.
	end
	
end


%% QASPER Performance Test Report
% 
disp(['Session Data Generated: ', qasperSessionData.SessionDateAndTime]);
disp(['Report Generated on: ', datestr(now)]);
%
disp(['MCU UID: ', qasperSessionData.PhantomSerialNumber]);
disp(['Qasper Control Software Version: ', qasperSessionData.QasperControlSoftwareVersion]);
disp(['Firmware Version: ', qasperSessionData.FirmwareInfo.FirmwareVersion]);
%
% Flow Controlled Mode

fldn = fieldnames(streamIndex);
for m = 1:length(fldn)
	fieldIndex = streamIndex.(fldn{m});
	n=1;
	disp(testStreamDataFR(n,fieldIndex).name);
	for n=1:length(TestFlowRate)
		if(~isempty(testStreamDataFR(n,fieldIndex).samples))
			disp(['Test Flow Rate = ', num2str(TestFlowRate(n)), 'ml/min']);
			figure;
			plot(testStreamDataFR(n,fieldIndex).elapsed, testStreamDataFR(n,fieldIndex).samples);
			title(testStreamDataFR(n,fieldIndex).name, 'Interpreter', 'none');
			disp(['Mean ', testStreamDataFR(n,fieldIndex).name, ' = ', num2str(testStreamDataFR(n,fieldIndex).mean), ' ± ', num2str(testStreamDataFR(n,fieldIndex).std), testStreamDataFR(n,fieldIndex).units]);
			snapnow();
		end
	end
end



