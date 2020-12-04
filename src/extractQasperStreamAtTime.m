function [ extractedData ] = extractQasperStreamAtTime(phantomSessionData, startTime, Duration, timeOffset)
%extractQasperStreamAtTime Returns the streamed data corresponding to the start
%time, duration and time offset
%   phantomSessionData - structure of phantom session data, imported using
%   loadQasperSessionData
%   startTime - the start time to return data from
%   Duration - the duration (in seconds) of streamed data to return
%   Time offset - offset to apply to the streamed data, for example to
%   synchronise it to imaging data (accounting for differences in system
%   clocks)

%adjust the start time based on the offset
dnStart = datenum(startTime + timeOffset);
dnStop = datenum(startTime + duration(0,0,Duration) + timeOffset);

sid = 60*60*24; % the number of seconds in a day


for n = 1:length(phantomSessionData.Stream)
    samples = phantomSessionData.Stream(n).Samples;
    elapsed = phantomSessionData.Stream(n).Elapsed;
    toff = phantomSessionData.Stream(n).TimestampOffset;
    
    
    
    startIndex = dsearchn(toff + elapsed/sid, dnStart);
    endIndex = dsearchn(toff + elapsed/sid, dnStop);
    
    extractedData(n).Name = phantomSessionData.Stream(n).Name;
    extractedData(n).fName = phantomSessionData.Stream(n).fName;
    extractedData(n).units = phantomSessionData.Stream(n).units;
    extractedData(n).TimestampOffset = datenum(startTime);
    extractedData(n).Samples = samples(startIndex:endIndex);
    extractedData(n).Elapsed = elapsed(startIndex:endIndex) - elapsed(startIndex);
    
    %do some statistics
    extractedData(n).mean = mean(extractedData(n).Samples); %mean value in period
    extractedData(n).std = std(extractedData(n).Samples); %standard deviation in period
    extractedData(n).min = min(extractedData(n).Samples); %minimum value in period
    extractedData(n).max = max(extractedData(n).Samples); %maximum value in period
    extractedData(n).linfitcoeff = polyfit(extractedData(n).Elapsed, extractedData(n).Samples, 1); %linear fit to determine any trends
    
    
end


end

