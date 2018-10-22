function [] = Truncate_HDF_MS(filePath, fileName, trl, outputFilePath, outputName )
% E-Mail Lars Holmstrom:
% Marlieke - I have attached the Matlab script for truncating an HDF file. 
% Before doing so, I recommend making a backup of all your HDF files, or perhaps 
% even a complete backup of your workspace. The workspace is, by default, 
% found in the installation directory (ususally c:\Program Files\Mobility Lab). 
% All of your recordings should be in the workspace/MobilityLabProject/monitorData folder. 
% If you make a complete backup of your workspace (which may be quite large if it has been 
% used for some time), you can then use the option in the File menu to switch workspaces 
% from within Mobility Lab. This will leave your original untouched.
% The function I provided to you uses Matlab's h5read function to grab just the data 
% between the start and end values you provide, in units of seconds. 
% You can specify the start and end time as fractional seconds (e.g., 1.23). 
% After reading out the data, they are stored in standard Matlab arrays. 
% You can customize this script to read out multiple sections of the data 
% and then merge them together before writing them back to a new HDF.



%filePath = 'D:\mscholten\Documents\Gait\Matlab\RawData\PD_DBS\DBS05\';
%fileName = ['DBS5Of_normal-20140710-084533.h5'];
%trl = [1/128 20; 30 40]; % start and end time of data in seconds 

outputFilePath = sprintf('%s%s.h5',outputFilePath,outputName);

monitorCaseIDList = h5read([filePath fileName], '/', 'CaseIdList'); %#ok<*HDFR>
labelList = h5read([filePath fileName], '/', 'MonitorLabelList');
fileFormat = h5read([filePath fileName], '/', 'FileFormatVersion');

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
    
    fs = double(h5read([filePath fileName], fsPath, 'SampleRate'));    
    
    writeAcc = false;
    writeGyro = false;
    writeMag = false;
    writeOrientation = false;
    for t = 1:size(trl,1)        
        firstSample = round(trl(t,1)*fs);
        lastSample = round(trl(t,2)*fs);
        span = lastSample-firstSample+1;
        
        time_check = h5read([filePath fileName], timePath);
        
        if length(time_check) < firstSample
            error('The recording is too short for the start time specified');
        end
        if length(time_check) < lastSample
            if iMonitor == 1
                message = ['Recording to short to accomodate specified truncation. End time truncated to ' num2str(length(time_check)/fs) ' s.'];
                disp(message);
            end
            lastSample = length(time_check);
            span = lastSample-firstSample+1;
        end
        
        if t == 1
            time = h5read([filePath fileName], timePath, firstSample, span);
            try
                acc = h5read([filePath fileName], accPath, [1 firstSample], [3 span]);
                writeAcc = true;
            catch ME
                disp('No accelerometer data. Skipping');
            end

            try
                gyro = h5read([filePath fileName], gyroPath, [1 firstSample], [3 span]);
                writeGyro = true;
            catch ME
                disp('No gyroscope data. Skipping');
            end

            try
                mag = h5read([filePath fileName], magPath, [1 firstSample], [3 span]);
                writeMag = true;
            catch ME
                disp('No magnetometer data. Skipping');
            end

            try
                orientation = h5read([filePath fileName], orientationPath, [1 firstSample], [4 span]);
                writeOrientation = true;
            catch ME
                disp('No orientation data. Skipping');
            end
        elseif t >= 2
               time2 = h5read([filePath fileName], timePath, firstSample, span);
               time = [time; time2];
               clear time2
            try
                acc2 = h5read([filePath fileName], accPath, [1 firstSample], [3 span]);%
                acc = [acc acc2];
                clear acc2
                writeAcc = true;
            catch ME
                disp('No accelerometer data. Skipping');
            end

            try
                gyro2 = h5read([filePath fileName], gyroPath, [1 firstSample], [3 span]);
                gyro = [gyro gyro2];
                clear gyro2
                writeGyro = true;
            catch ME
                disp('No gyroscope data. Skipping');
            end

            try
                mag2 = h5read([filePath fileName], magPath, [1 firstSample], [3 span]);
                mag = [mag mag2];
                clear mag2
                writeMag = true;
            catch ME
                disp('No magnetometer data. Skipping');
            end

            try
                orientation2 = h5read([filePath fileName], orientationPath, [1 firstSample], [4 span]);
                orientation = [orientation orientation2];
                clear orientation2
                writeOrientation = true;
            catch ME
                disp('No orientation data. Skipping');
            end
        end        
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
    
    info = h5info([filePath fileName], ['/' caseID]);
    attributes = info.Attributes;
    for iAttr = 1:length(attributes)
        h5writeatt(outputFilePath, ['/' caseID], attributes(iAttr).Name, attributes(iAttr).Value);
    end
end

details.AttachedTo = '/';
details.AttachType = 'group';
details.Name = 'MonitorLabelList';
h5write(outputFilePath, details, labelList, 'WriteMode', 'append');
details.Name = 'CaseIdList';
h5write(outputFilePath, details, monitorCaseIDList, 'WriteMode', 'append');
h5writeatt(outputFilePath, '/','FileFormatVersion', fileFormat);



