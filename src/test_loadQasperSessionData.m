% Tests for the function loadQasperSessionData.m
locationOfThisScript = fileparts(mfilename('fullpath'));

% Test data files
exampleV300 = fullfile(locationOfThisScript, '..', 'data', 'example_3.0.0.json');

% load in exampleV300
S = loadQasperSessionData(exampleV300);

%check the fields are correct
assert(strcmp(S.FirmwareInfo.FirmwareName, 'QASPER STM32F373'));
assert(strcmp(S.FirmwareInfo.FirmwareVersion, '3.0.1'));
assert(strcmp(S.LocalTimeZone{1}, 'W. Europe Standard Time'));
assert(strcmp(S.LocalTimeZone{2}, 'W. Europe Daylight Time'));
assert(strcmp(S.md5Hash, 'ce782bc5aa7dcf375f7a1e916032ad65'));

