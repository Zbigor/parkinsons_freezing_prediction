function TruncateHDF(filePath, outputFilePath, startTime, endTime) 

if exist(outputFilePath)
    delete(outputFilePath);
end

monitorCaseIDList = hdf5read(filePath, '/', 'CaseIdList');
labelList = hdf5read(filePath, '/', 'MonitorLabelList');
fileFormat = hdf5read(filePath, '/', 'FileFormatVersion');

if fileFormat < 3
    error('TruncateHDF only works on fileFormat versions 3+');
end

caseIDs = {};
labels = {};

for iMonitor = 1:length(monitorCaseIDList)
    caseID = monitorCaseIDList(iMonitor).data;
    label = labelList(iMonitor).data;
    
    caseIDs{iMonitor} = caseID;
    labels{iMonitor} = label;
    
    fsPath = ['/' caseID ];
    timePath = ['/' caseID '/Time'];
    accPath = ['/' caseID '/Calibrated/Accelerometers'];
    gyroPath = ['/' caseID '/Calibrated/Gyroscopes'];
    magPath = ['/' caseID '/Calibrated/Magnetometers'];
    orientationPath = ['/' caseID '/Calibrated/Orientation'];
    
    fs = double(hdf5read(filePath, fsPath, 'SampleRate'));
    
    firstSample = round(startTime*fs);
    lastSample = round(endTime*fs);
    span = lastSample-firstSample+1;
    
    time = h5read(filePath, timePath);
    if length(time) < firstSample
        error('The recording is too short for the start time specified');
    end
    if length(time) < lastSample
        if iMonitor == 1
            message = ['Recording to short to accomodate specified truncation. End time truncated to ' num2str(length(time)/fs) ' s.'];
            display(message);
        end
        lastSample = length(time);
        span = lastSample-firstSample+1;
    end
    
    writeAcc = false;
    writeGyro = false;
    writeMag = false;
    writeOrientation = false;
    
    time = h5read(filePath, timePath, firstSample, span);
    try
        acc = h5read(filePath, accPath, [1 firstSample], [3 span]);
        writeAcc = true;
    catch ME
        display('No accelerometer data. Skipping');
    end
    
    try
        gyro = h5read(filePath, gyroPath, [1 firstSample], [3 span]);
        writeGyro = true;
    catch ME
        display('No gyroscope data. Skipping');
    end
    
    try
        mag = h5read(filePath, magPath, [1 firstSample], [3 span]);
        writeMag = true;
    catch ME
        display('No magnetometer data. Skipping');
    end
    
    try
        orientation = h5read(filePath, orientationPath, [1 firstSample], [4 span]);
        writeOrientation = true;
    catch ME
        display('No orientation data. Skipping');
    end
    
    h5create(outputFilePath, ['/' caseID '/Time'], size(time));
    h5write(outputFilePath, ['/' caseID '/Time'], time);
    if writeAcc
        h5create(outputFilePath, ['/' caseID '/Calibrated/Accelerometers'], size(acc));
        h5write(outputFilePath, ['/' caseID '/Calibrated/Accelerometers'], acc);
    end
    if writeGyro
        h5create(outputFilePath, ['/' caseID '/Calibrated/Gyroscopes'], size(gyro));
        h5write(outputFilePath, ['/' caseID '/Calibrated/Gyroscopes'], gyro);
    end
    if writeMag
        h5create(outputFilePath, ['/' caseID '/Calibrated/Magnetometers'], size(mag));
        h5write(outputFilePath, ['/' caseID '/Calibrated/Magnetometers'], mag);
    end
    if writeOrientation
        h5create(outputFilePath, ['/' caseID '/Calibrated/Orientation'], size(orientation));
        h5write(outputFilePath, ['/' caseID '/Calibrated/Orientation'], orientation);
    end
    
    info = h5info(filePath, ['/' caseID]);
    attributes = info.Attributes;
    for iAttr = 1:length(attributes)
        h5writeatt(outputFilePath, ['/' caseID], attributes(iAttr).Name, attributes(iAttr).Value);
    end
end

details.AttachedTo = '/';
details.AttachType = 'group';
details.Name = 'MonitorLabelList';
hdf5write(outputFilePath, details, labelList, 'WriteMode', 'append');
details.Name = 'CaseIdList';
hdf5write(outputFilePath, details, monitorCaseIDList, 'WriteMode', 'append');
h5writeatt(outputFilePath, '/','FileFormatVersion', fileFormat);


