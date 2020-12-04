# QASPERMAT
MATLAB functions for loading in session data for Gold Standard Phantom's QASPER phantom.
The QASPER Pump Control software saves the logged data as a JSON file.  The functions in
this library provide a means to load this data into MATLAB for further analysis.

## Requirements
- Requires the function jsonencode which was introduced in MATLAB R2016b
- Uses the class datetime which was introduced in MATLAB R2014b

## Getting Started
To see how to use the functions it is recommended to look at example.m.

## Functions:

- loadQasperSessionData: Loads the data from a supplied JSON file, handling conversion of base64 encoded streams and timestamps.
- convertQasperSerialDataNumber: Converts the timestamps in the QASPER session data to MATLAB format serial date numbers.
- extractQasperStreamAtTime: Returns QASPER session streams for given start time and duration, for example to get the samples for the interval when an image was acquired.
- friendlyQasperSessionStreamName: Provides 'friendly' names and units for each of the streams.
- getQasperSessionStreamIndex: Returns indices for stream names for accessing the QASPER session data structure returned by loadQasperSessionData

## Changelog

[1.0.0] 04/12/2020
- Added examples.m demonstrating use of the library
- Function for loading in the data
- Function for converting python timestamps
