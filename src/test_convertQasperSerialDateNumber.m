%test for convertQasperSerialDateNumber.m

time = '03-Dec-2020 15:02:56';
%convert matlab datenum to a python style time in seconds since epoch
%(1/1/1970)
timeAsPythonDatenum = (datenum(time) - datenum('01/01/1970'))*(60*60*24);

result = convertQasperSerialDateNumber(timeAsPythonDatenum);
%assert that we get back to the original datestr
assert(strcmp(datestr(result), time));

%use values obtained directly from python
time = '03-Dec-2020 17:19:34';
timeAsPythonDatenum = 1607015974;
result = convertQasperSerialDateNumber(timeAsPythonDatenum);
%assert that we get back to the original datestr
assert(strcmp(datestr(result), time));
