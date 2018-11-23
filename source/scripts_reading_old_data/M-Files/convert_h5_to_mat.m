%% Convert

pathway = ['']; % pathway

% identify files with ending '.h5'
listfiles = dir([pathway filesep '*.h5']);
gr(1).a = ['Accelerometers'];
gr(2).a = ['Gyroscopes'];
gr(3).a = ['Magnetometers'];
grname(1).a = ['acc'];
grname(2).a = ['gyr'];
grname(3).a = ['mag'];
monitorname(1).a = ['leftankle'];
monitorname(2).a = ['rightankle'];
monitorname(3).a = ['lumbar'];
locationname = {'Left Leg';'Right Leg';'Lumbar'};
for k = 1:size(listfiles,1)
    namefile = listfiles(k,1).name;    
    info = h5info([pathway filesep namefile]);    
    kinedata = [];
    for m = 1:3;% number of monitors
        % assign location of monitor to the number of monitor
        monitor(:,1) = h5readatt([pathway filesep namefile],'/','MonitorLabelList');
        monitor(:,2) = h5readatt([pathway filesep namefile],'/','CaseIdList');
        for e = 1:3
            monitor{e,2} = monitor{e,2}(1:9);
        end
        name = info.Groups(m,1).Name;        
        % find cooresponding location
        l = strcmp(name(2:end),monitor(:,2));
        loc = find(l);
        nameloc = deblank(monitor(l,1));
        %        
        if strcmp(locationname(1),nameloc)
            indexloc = 1;
        elseif strcmp(locationname(2),nameloc)
            indexloc = 2;
        elseif strcmp(locationname(3), nameloc)
            indexloc = 3;
        end
        for g = 1:3 % measure
            clear namedata acc
            grp = gr(g).a;
            %fs = h5readatt(filename, name, 'SampleRate'); % sample frequency
            time = h5read([pathway filesep namefile],[name '/Time']);
            time = double(time);
            t = ((time-time(1))/1000000)';
            %fs = double(fs);
            path = [name '/Calibrated/' grp]; % Accelerometers / Gyroscopes / Magnetometers
            acc = h5read([pathway filesep namefile],path)';
            eval(['kinedata.' monitorname(indexloc).a '.' grname(g).a '= acc;' ])
            eval(['kinedata.time = t;'])
        end
    end    
    save([pathway filesep namefile(1:end-3)],'kinedata')
    clear namefile info kinedata
end




