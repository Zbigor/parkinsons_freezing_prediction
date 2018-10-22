function [kinedata] = definegaitevents(kinedata)

if nargin == 0 
	disp('Not enough input arguments');
	return;
end	 

% extract time point of peak swing
% define timepoint of toe-off, heel strike, and midstance around each peak
% swing.
% delete gait cycles during turning (also when only one timepoint is during the turn)
for s = [1 2] % cycle through left and right leg    
    if s == 1
        clear midswing_samples g mx my mz
        midswing_samples = kinedata.segment.imidswing_left;
        acz = kinedata.leftankle.acc(:,3);
        g = kinedata.leftankle.gyr(:,2);
        mx = kinedata.leftankle.mag(:,1);
        my = kinedata.leftankle.mag(:,2);
        mz = kinedata.leftankle.mag(:,3);
        figure;plot(g)
        hold
    elseif s == 2
        clear midswing_samples g mx my mz
        midswing_samples = kinedata.segment.imidswing_right;
        acz = kinedata.rightankle.acc(:,3);
        g = kinedata.rightankle.gyr(:,2);
        mx = kinedata.rightankle.mag(:,1);
        my = kinedata.rightankle.mag(:,2);
        mz = kinedata.rightankle.mag(:,3);
        figure;plot(g)
        hold
    end
    clear timepoints
    timepoints = zeros(size(midswing_samples,2)-1,4); 
    mstridetime = median(diff(midswing_samples));
    stepCnt = 0;
    for cntSchritt=1:length(midswing_samples)  
        clear t_Schwung t_Absetz t_Aufsetz links rechts
        % Schwungphase aus gespeicherten Daten holen
        t_Schwung = midswing_samples(cntSchritt);
        % Ab- und Aufsetzzeitpunkte bestimmen
        % terminal contact: minimum AP acceleration before swing phase
        links = round(max([1 t_Schwung-mstridetime/3]));
        clear pks lks
        [pks,lks] = min(acz(links:t_Schwung-10));        
        t_Absetz = lks + links;
        
        % initial contact: maximum of velocity before maximum of AP
        % acceleration
        rechts = round(min([t_Schwung+mstridetime/3 length(g)]));
        clear pks lks
        [pks,lks] = findpeaks(acz(t_Schwung:rechts));
        [r,c] = max(pks); maxacz = lks(c);
        clear pks lks
        [pks,lks] = max(g(t_Schwung:t_Schwung+maxacz));        
        t_Aufsetz = lks + t_Schwung;
        % midstance bestimmen
        if ( cntSchritt==1 )
            t_Aufsetz_1 = t_Aufsetz;
        else
            if ( cntSchritt==2 )
                stepCnt = stepCnt + 1;
                [ x, idx ] = min( g( t_Aufsetz_1+25:t_Absetz-25 ) );
                timepoints(stepCnt,1) = t_Aufsetz_1+25 + idx;
            else
                stepCnt = stepCnt + 1;
                [ x, idx ] = min( g( timepoints(stepCnt-1, 4)+25:t_Absetz));%-25 ) );
                timepoints(stepCnt,1) = timepoints(stepCnt-1,4)+25 + idx;
            end
           
            % matrix timepoints with all timepoints for each gait cycle
            timepoints(stepCnt, 2) = t_Absetz;
            timepoints(stepCnt, 3) = t_Schwung;
            timepoints(stepCnt, 4) = t_Aufsetz;
            line([timepoints(stepCnt, 1) timepoints(stepCnt,1)],[min(g) max(g)],'color','g')
            line([timepoints(stepCnt, 2) timepoints(stepCnt,2)],[min(g) max(g)],'color','r')
            line([timepoints(stepCnt, 3) timepoints(stepCnt,3)],[min(g) max(g)],'color','b')
            line([timepoints(stepCnt, 4) timepoints(stepCnt,4)],[min(g) max(g)],'color','k')
            
        end
    end
    if s == 1
        timepointsl = timepoints;
        title('left leg')
    elseif s == 2 
        timepointsr = timepoints;
        title('right leg')
    end
end

clear timepoints

% check if the vector 'timepoints' has only increasing values for left and right
% separately
for s = 1:2
    if s == 1
        clear timepoints
       timepoints = timepointsl;
    elseif s == 2
        clear timepoints
        timepoints = timepointsr;
    end
    for i = 1:size(timepoints,1)
        clear d_timepoints x y
        d_timepoints = diff(timepoints(i,:));
        [x,y] = find(d_timepoints < 1);
        if ~isempty(x)
            display(['Mistake in defining the heelstrike and toe-off values in leg ' num2str(s) ' in gaitcycle nr ' num2str(i) ' !'])
        end
        if i < size(timepoints,1)-1
            if timepoints(i,4) > timepoints(i+1,1)
                display(['Mistake in defining the heelstrike and toe-off values in leg ' num2str(s) 'between heelstrike in gaitcycle nr ' num2str(i) ' and toe-off in nr ' num2str(i+1) '!'])
            end
        end
    end
end
clear timepoints i y x d_timepoints

% convert to structure, every cell is one walkway, every row in the
% walkway is a stride with midstance, toe-off, midswing, and heelstrike
% timepoints
% reject values during turning 
for s = [1 2]
    if s == 1
        clear timepoints
        timepoints = timepointsl;
    elseif s == 2
        clear timepoints
        timepoints = timepointsr;
    end
    if isfield(kinedata.segment,'turn')
        turn = round(kinedata.segment.turn(2:3,:)*128);
        t = 1; % the index for turns
        for r = 1:size(timepoints,1)
            for c = 1:size(timepoints,2)
                clear w
                w = timepoints(r,c);
                if w < turn(1,t)
                    t_event.way{1,t}(r,c) = w;
                elseif w > turn(2,end)
                    tt = size(turn,2)+1;
                    t_event.way{1,tt}(r,c) = w;
                elseif w > turn(2,t) % value lies after turning, continue to next 'walkway'
                    t = t+1;
                    t_event.way{1,t}(r,c) = w;
                end
            end
        end
    else
        t_event.way{1,1} = timepoints;
    end
    
    if s == 1
        t_eventl = t_event;
        clear t_event
    elseif s == 2
        t_eventr = t_event;
        clear t_event
    end
end
clear t_event turn r c t s
% delete gaitcycles consisting of only zeros
for s = [1 2]
    if s == 1
        clear t_event
        t_event = t_eventl;
    elseif s == 2
        clear t_event
        t_event = t_eventr;
    end
    for w = 1:length(t_event.way)
        %x = t_event.way{1,w};
        i = 1;
        while i < size(t_event.way{1,w},1)
            if isempty(find(t_event.way{1,w}(i,:))); % consisting of only zeros
                t_event.way{1,w}(i,:) = [];
                i = 0;
            end
            i = i+1;
        end
    end
    if s == 1
        t_eventl = t_event;
        clear t_event
    elseif s == 2
        t_eventr = t_event;
        clear t_event
    end
end
clear t_event i w s

% save in variable kinedata
kinedata.segment.event_left = t_eventl;
kinedata.segment.event_right = t_eventr;

