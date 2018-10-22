% First half of function: calculate stride length and stride velocity
% Second half of function: Calculate temporal parameters

function [kinedata] = gaitparameters(kinedata)

if nargin == 0
    disp('Not enough input arguments');
    return;
end


% Calculate the stride length and stride velocity
for s = [1 2]
    if s == 1
        clear t_event g mx my mz ll
        if isfield(kinedata.segment,'selevent_left')
            t_event = kinedata.segment.selevent_left;
        else
            t_event = kinedata.segment.event_left;
        end
        g = kinedata.leftankle.gyr(:,2)*180/pi;
        mx = kinedata.leftankle.mag(:,1);
        my = kinedata.leftankle.mag(:,2);
        mz = kinedata.leftankle.mag(:,3);
        ll = subjectdata.legleft;
    elseif s == 2
        clear t_event g mx my mz ll
        if isfield(kinedata.segment,'selevent_right')
            t_event = kinedata.segment.selevent_right;
        else
            t_event = kinedata.segment.event_right;
        end
        g = kinedata.rightankle.gyr(:,2)*180/pi;
        mx = kinedata.rightankle.mag(:,1);
        my = kinedata.rightankle.mag(:,2);
        mz = kinedata.rightankle.mag(:,3);
        ll = subjectdata.legright;
    end
    stridelength = zeros(size(t_event.way,2),10);
    stridevelocity = zeros(size(t_event.way,2),10);
    normstridevelocity = zeros(size(t_event.way,2),10);
    for w = 1:size(t_event.way,2)
        
        for i = 1:size(t_event.way{1,w},1)-1
            clear x  angle_swing length1 midstance_vectors heelstrike_vectors ms_n hs_n angle_vert_to_heelstrike length2_1 length2_2
            
            % if toe-off, midswing, or heelstrike of the event-values is 0 (indicate the value belongs to a turn),
            % proceed to next step
            x = t_event.way{1,w}(i,:);
            if any(x(1,2:4)==0)
                continue
                % if midstance of next gait cycle is zero, proceed
            elseif t_event.way{1,w}(i+1,1) == 0
                continue
                % if a value has nans
            elseif any(isnan(x))
                continue
            elseif any(isnan(t_event.way{1,w}(i+1,:)))
                continue
            end
            % calculate first half of step length by integrating gyroscope
            % signal
            angle_swing = abs(trapz(g(x(1,2):x(1,4))))*(1/128);
            length1 = sin((angle_swing*pi/180)/2)*ll;
            % calculate second half of step length using the magnetometer
            % take midstance after heelstrike for the reference 'leg in
            % extension'
            midstance_vectors(1,1) = mx(t_event.way{1,w}(i+1,1));
            midstance_vectors(1,2) = my(t_event.way{1,w}(i+1,1));
            midstance_vectors(1,3) = mz(t_event.way{1,w}(i+1,1));
            % vectors at heelstrike
            heelstrike_vectors(1,1) = mx(t_event.way{1,w}(i,4));
            heelstrike_vectors(1,2) = my(t_event.way{1,w}(i,4));
            heelstrike_vectors(1,3) = mz(t_event.way{1,w}(i,4));
            ms_n = midstance_vectors(1, 1:3 ) / norm(midstance_vectors(1, 1:3 ));
            hs_n = heelstrike_vectors(1, 1:3 ) / norm(heelstrike_vectors(1, 1:3 ));
            angle_vert_to_heelstrike = acos(sum(ms_n.*hs_n))*180/pi;
            % angle_vert_to_heelstrike should be between 1 and 40 degrees
            % otherwise display text
            if angle_vert_to_heelstrike < 1
                display('angle_vert_to_heelstrike is below 1 degree')
                continue
            elseif angle_vert_to_heelstrike > 40
                display('angle_vert_to_heelstrike is greater than 40 degrees')
                continue
            end
            length2_1 = sin((angle_swing*pi/180)/2)*(ll/2);
            length2_2 = sin(angle_vert_to_heelstrike*pi/180)*(ll/2);
            stridelength(w,i) = length1 + length2_1+length2_2;
            % calculate stride velocity
            stridevelocity(w,i) = (length1 + length2_1+length2_2)/(t_event.way{1,w}(i+1,2)-t_event.way{1,w}(i,2));
            normstridevelocity(w,i) = ((length1 + length2_1+length2_2)*100/...
                ll)/(t_event.way{1,w}(i+1,2)-t_event.way{1,w}(i,2));
        end
    end
    if s == 1
        clear stridelengthl
        stridelengthl = stridelength;
        stridevelocityl = stridevelocity;
        normstridevelocityl = normstridevelocity;
    elseif s == 2
        clear stridelengthr
        stridelengthr = stridelength;
        stridevelocityr = stridevelocity;
        normstridevelocityr = normstridevelocity;
    end
end


% normalize stridelength and insert in kinedata structure
kinedata.param.stridelength_right = [];
kinedata.param.normstridelength_right = [];
stridelengthrr = reshape(stridelengthr,[size(stridelengthr,1)*size(stridelengthr,2),1]); % reshape to one column
kinedata.param.stridelength_right = stridelengthrr(stridelengthrr~=0); % remove zeros
kinedata.param.normstridelength_right = stridelengthrr(stridelengthrr~=0)*100/subjectdata.legright; % normalized

kinedata.param.stridelength_left = [];
kinedata.param.normstridelength_left = [];
stridelengthll = reshape(stridelengthl,[size(stridelengthl,1)*size(stridelengthl,2),1]); % reshape to one column
kinedata.param.stridelength_left = stridelengthll(stridelengthll~=0); % remove zeros
kinedata.param.normstridelength_left = stridelengthll(stridelengthll~=0)*100/subjectdata.legleft; % normalized


% stridevelocity
kinedata.param.stridevel_right = [];
kinedata.param.normstridevel_right = [];
stridevelr = reshape(stridevelocityr,[size(stridevelocityr,1)*size(stridevelocityr,2),1]);
normstridevelr = reshape(normstridevelocityr,[size(normstridevelocityr,1)*size(normstridevelocityr,2),1]);
kinedata.param.stridevel_right = stridevelr(stridevelr~=0);
kinedata.param.normstridevel_right = normstridevelr(normstridevelr~=0);

kinedata.param.stridevel_left = [];
kinedata.param.normstridevel_left = [];
stridevell = reshape(stridevelocityl,[size(stridevelocityl,1)*size(stridevelocityl,2),1]);
normstridevell = reshape(normstridevelocityl,[size(normstridevelocityl,1)*size(normstridevelocityl,2),1]);
kinedata.param.stridevel_left = stridevell(stridevell~=0);
kinedata.param.normstridevel_left = normstridevell(normstridevell~=0);

angvell = 0;angvelr = 0;steptimel = 0;steptimer = 0;stancetimel = 0;stancetimer = 0;swingtimel = 0;swingtimer = 0;stridetimel = 0;stridetimer = 0;
doublesuppinil = 0;doublesuppinir = 0;doublesupptermil = 0; doublesupptermir = 0;
for ww = 1:size(kinedata.segment.event_left.way,2)
    clear t_event* dl dlr dr
    if isfield(kinedata.segment,'selevent_left')
        t_eventl = kinedata.segment.selevent_left.way{1,ww};
        t_eventr = kinedata.segment.selevent_right.way{1,ww};
    else
        t_eventl = kinedata.segment.event_left.way{1,ww};
        t_eventr = kinedata.segment.event_right.way{1,ww};
    end
    % create matrix with each column: Toe_off-Midswing-HS-Toe_off-Midswing-HS
    % then calculate step time: 4th - 2nd column;
    % event_way consist of 4 columns: midstance - toe-off -
    % midswing - heelstrike
    % delete rows with nans or zeros
    if any(any(isnan(t_eventl)))
        [r,c] = find(isnan(t_eventl));
        t_eventl(r,:) = [];
        clear r c
    end
    if any(any(isnan(t_eventr)))
        [r,c] = find(isnan(t_eventr));
        t_eventr(r,:) = [];
        clear r c
    end
    %% create matrix later, first check separately t_eventl and t_eventr and then add them together
    [r,d] = find(t_eventl == 0);
    if isempty(r) == 0
        t_eventl(r,:) = [];
    end
    clear d r
    % right
    [r,d] = find(t_eventr == 0);
    if isempty(r) == 0
        t_eventr(r,:) = [];
    end
    clear d r
    if isempty(t_eventl) || isempty(t_eventr)
        continue
    end
    % detect gaitcycles separated more than two seconds   
    dl = find( diff(t_eventl(:,3)) > 128*2);    
    dr = find( diff(t_eventr(:,3)) > 128*2);      
    % delete zero's if present
    % left
    
    if isempty(dl) || isempty(dr)
        dlr = [];
        if isempty(dl) && ~isempty(dr)
            if dr(1) > (size(t_eventr,1)/2)
                t_eventr([(dr+1):end],:) = [];
            else 
                t_eventr([1:dr+1],:) = [];
            end
        elseif ~isempty(dl) && isempty(dr)
            if dl(1) > (size(t_eventl,1)/2)
                t_eventl([(dl+1):end],:) = [];
            else 
                t_eventl([1:dl+1],:) = [];
            end
        end
    else
        dlr = max(length(dl),length(dr));
    end
    for k = 1:min(length(dl),length(dr))+1
        clear t_eventpart* matrix
        if k == 1 && isempty(dlr)
            t_eventpartl = t_eventl;
            t_eventpartr = t_eventr;
        elseif k == 1 && ~isempty(dlr)
            t_eventpartl = t_eventl(1:dl(k),:);
            t_eventpartr = t_eventr(1:dr(k),:);
        elseif k == (min(length(dl),length(dr))+1)
            t_eventpartl = t_eventl(dl(k-1)+1:end,:);
            t_eventpartr = t_eventr(dr(k-1)+1:end,:);
        else
            t_eventpartl = t_eventl(dl(k-1):dl(k),:);
            t_eventpartr = t_eventr(dr(k-1):dr(k),:);
        end
        if size(t_eventpartl,1) == 0 || size(t_eventpartr,1) == 0
            %display(['block ' num2str(ww) ' of file ' subjectdata.kinename(5:12) ' has no gaitcycles'])
            continue
        end
        % check whether all distances between the gait cycles are smaller
        % than 2 seconds
        i = 0;
        while i == 0
            clear dlpart drpart
            dlpart = find( diff(t_eventpartl(:,3)) > 128*2);    
            drpart = find( diff(t_eventpartr(:,3)) > 128*2);
            if ~isempty(dlpart) || ~isempty(drpart)
                if ~isempty(dlpart)                    
                    if dlpart(1) < round(size(t_eventpartl,1)/2)
                        t_eventpartl(1:dlpart(1),:) = [];
                    else
                        t_eventpartl(dlpart(1):end,:) = [];
                    end                 
                end
                if ~isempty(drpart)
                    if drpart(1) < round(size(t_eventpartr,1)/2)
                        t_eventpartr(1:drpart(1),:) = [];
                    else
                        t_eventpartr(drpart(1):end,:) = [];
                    end 
                end
            else
                i = 1;
            end
        end
        sz = [size(t_eventpartl,1) size(t_eventpartr,1)];
        if find(sz == 0)
            continue
        end
        matrix = zeros(max(sz),6);
        if t_eventpartl(1,4) < t_eventpartr(1,4)
            firststep = 1; % if left is first
            matrix(1:size(t_eventpartl,1),1:3) = t_eventpartl(:,2:4);
            matrix(1:size(t_eventpartr,1),4:6) = t_eventpartr(:,2:4);
        else
            firststep = 2; % if right is first
            matrix(1:size(t_eventpartr,1),1:3) = t_eventpartr(:,2:4);
            matrix(1:size(t_eventpartl,1),4:6) = t_eventpartl(:,2:4);
        end
        [r,d] = find(matrix == 0);
        if isempty(r) == 0
            matrix(r,:) = [];
        end
        clear d r        
        % create vector of matrix and check if all numbers are consecutive        
        i = 0;
        while i == 0
            clear B d
            B = reshape(matrix',[1, prod(size(matrix))]);
            d = find(diff(B) <=0 );             
            if ~isempty(d)                
                if ceil(d(1)/size(matrix,2)) < round(size(matrix,1)/2)
                        matrix(1:ceil(d(1)/size(matrix,2)),:) = [];
                else
                    matrix(ceil(d(1)/size(matrix,2)):end,:) = [];
                end   
            else
                i = 1;
            end
        end
        if size(matrix,1) == 1
            display(['block ' num2str(ww) ' of file ' subjectdata.kinename(5:12) ' has less than 2 gaitcycles'])
            if firststep == 1
                angvell = [angvell; kinedata.leftankle.gyr(matrix(:,2),2)];
                angvelr = [angvelr; kinedata.rightankle.gyr(matrix(:,5),2)];
                
                steptimer = [steptimer; matrix(:,6) - matrix(:,3)];
                
                swingtimel = [swingtimel; matrix(:,3) - matrix(:,1)];
                swingtimer = [swingtimer; matrix(:,6) - matrix(:,4)];
                
            elseif firststep == 2
                angvell = [angvell; kinedata.leftankle.gyr(matrix(:,5),2)];
                angvelr = [angvelr; kinedata.rightankle.gyr(matrix(:,2),2)];
                
                steptimel = [steptimel; matrix(:,6) - matrix(:,3)];
                
                swingtimel = [swingtimel; matrix(:,6) - matrix(:,4)];
                swingtimer = [swingtimer; matrix(:,3) - matrix(:,1)];
            end
            continue            
        end    
        
        % compute angular velocity, steptime, stride time, stance time, swingtime, double
        % support, and single support out of the matrix
        if firststep == 1
            
            angvell = [angvell; kinedata.leftankle.gyr(matrix(:,2),2)];
            angvelr = [angvelr; kinedata.rightankle.gyr(matrix(:,5),2)];
            
            steptimel = [steptimel; matrix(2:end,3) - matrix(1:end-1,6)];
            steptimer = [steptimer; matrix(:,6) - matrix(:,3)];
            
            stridetimel = [stridetimel; diff(matrix(:,3))];
            stridetimer = [stridetimer; diff(matrix(:,6))];
            
            swingtimel = [swingtimel; matrix(:,3) - matrix(:,1)];
            swingtimer = [swingtimer; matrix(:,6) - matrix(:,4)];
            
            stancetimel = [stancetimel; matrix(2:end,1) - matrix(1:end-1,3)];
            stancetimer = [stancetimer; matrix(2:end,4) - matrix(1:end-1,6)];
            
            doublesuppinil = [doublesuppinil; (((matrix(1:end-1,4) - matrix(1:end-1,3))/128)./(diff(matrix(:,3))/128))*100];
            doublesuppinir = [doublesuppinir; (((matrix(2:end,1) - matrix(1:end-1,6))/128)./(diff(matrix(:,6))/128))*100];
            
            doublesupptermil = [doublesupptermil; (((matrix(2:end,1) - matrix(1:end-1,6))/128)./(diff(matrix(:,3))/128))*100];
            doublesupptermir = [doublesupptermir; (((matrix(1:end-1,4) - matrix(1:end-1,3))/128)./(diff(matrix(:,6))/128))*100];
        elseif firststep == 2
            
            angvell = [angvell; kinedata.leftankle.gyr(matrix(:,5),2)];
            angvelr = [angvelr; kinedata.rightankle.gyr(matrix(:,2),2)];
            
            
            steptimel = [steptimel; matrix(:,6) - matrix(:,3)];
            steptimer = [steptimer; matrix(2:end,3) - matrix(1:end-1,6)];
            
            stridetimel = [stridetimel; diff(matrix(:,6))];
            stridetimer = [stridetimer; diff(matrix(:,3))];
            
            swingtimel = [swingtimel; matrix(:,6) - matrix(:,4)];
            swingtimer = [swingtimer; matrix(:,3) - matrix(:,1)];
            
            stancetimel = [stancetimel; matrix(2:end,4) - matrix(1:end-1,6)];
            stancetimer = [stancetimer; matrix(2:end,1) - matrix(1:end-1,3)];
            
            doublesuppinil = [doublesuppinil; (((matrix(2:end,1) - matrix(1:end-1,6))/128)./(diff(matrix(:,6))/128))*100];
            doublesuppinir = [doublesuppinir; (((matrix(1:end-1,4) - matrix(1:end-1,3))/128)./(diff(matrix(:,3))/128))*100];
            
            doublesupptermil = [doublesupptermil; (((matrix(1:end-1,4) - matrix(1:end-1,3))/128)./(diff(matrix(:,6))/128))*100];
            doublesupptermir = [doublesupptermir; (((matrix(2:end,1) - matrix(1:end-1,6))/128)./(diff(matrix(:,3))/128))*100];
        end
        clear matrix
    end
end
% convert from samples to seconds and save in kinedata
kinedata.param.angvel_left = [];
kinedata.param.angvel_left = angvell(2:end)*-180/pi;
kinedata.param.angvel_right = [];
kinedata.param.angvel_right = angvelr(2:end)*-180/pi;
kinedata.param.steptime_left = [];
kinedata.param.steptime_left = steptimel(2:end)/128;
kinedata.param.steptime_right = [];
kinedata.param.steptime_right = steptimer(2:end)/128;
kinedata.param.stridetime_left = [];
kinedata.param.stridetime_left = stridetimel(2:end)/128;
kinedata.param.stridetime_right = [];
kinedata.param.stridetime_right = stridetimer(2:end)/128;
kinedata.param.swingtime_left = [];
kinedata.param.swingtime_left = swingtimel(2:end)/128;
kinedata.param.swingtime_right = [];
kinedata.param.swingtime_right = swingtimer(2:end)/128;
kinedata.param.stancetime_left = [];
kinedata.param.stancetime_left = stancetimel(2:end)/128;
kinedata.param.stancetime_right = [];
kinedata.param.stancetime_right = stancetimer(2:end)/128;
kinedata.param.doublesupportinitial_left = [];
kinedata.param.doublesupportinitial_left = doublesuppinil(2:end);
kinedata.param.doublesupportinitial_right = [];
kinedata.param.doublesupportinitial_right = doublesuppinir(2:end);
kinedata.param.doublesupportterminal_left = [];
kinedata.param.doublesupportterminal_left = doublesupptermil(2:end);
kinedata.param.doublesupportterminal_right = [];
kinedata.param.doublesupportterminal_right = doublesupptermir(2:end);
kinedata.param.doublesupport_left = [];
kinedata.param.doublesupport_left = doublesuppinil(2:end)+doublesupptermil(2:end);
kinedata.param.doublesupport_right = [];
kinedata.param.doublesupport_right = doublesuppinir(2:end)+doublesupptermir(2:end);
kinedata.param.limp_left = [];
kinedata.param.limp_left = abs(doublesuppinil(2:end) - doublesupptermil(2:end));
kinedata.param.limp_right = [];
kinedata.param.limp_right = abs(doublesuppinir(2:end) - doublesupptermir(2:end));
