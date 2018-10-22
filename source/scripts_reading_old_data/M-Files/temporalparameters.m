function [kinedata] = temporalparameters(kinedata)


steptimel = 0;steptimer = 0;stancetimel = 0;stancetimer = 0;swingtimel = 0;swingtimer = 0;stridetimel = 0;stridetimer = 0;
%doublesupport = 0;singlesupport = 0;
for ww = 1:size(kinedata.segment.event_left.way,2)
        % create matrix with each column: Toe_off-Midswing-HS-Toe_off-Midswing-HS
        % then calculate step time: 4th - 2nd column; 
        % event_way consist of 4 columns: midstance - toe-off -
        % midswing - heelstrike            

        % create columns of 'matrix' 
        sz = [size(kinedata.segment.event_left.way{1,ww},1) size(kinedata.segment.event_right.way{1,ww},1)];
        matrix = zeros(max(sz),6);
        if kinedata.segment.event_left.way{1,ww}(1,4) < kinedata.segment.event_right.way{1,ww}(1,4)
           firststep = 1; % if left is first
           matrix(1:size(kinedata.segment.event_left.way{1,ww},1),1:3) = kinedata.segment.event_left.way{1,ww}(:,2:4)
           matrix(1:size(kinedata.segment.event_right.way{1,ww},1),4:6) = kinedata.segment.event_right.way{1,ww}(:,2:4)            
        else 
            firststep = 2; % if right is first
            matrix(1:size(kinedata.segment.event_right.way{1,ww},1),1:3) = kinedata.segment.event_right.way{1,ww}(:,2:4)
            matrix(1:size(kinedata.segment.event_left.way{1,ww},1),4:6) = kinedata.segment.event_left.way{1,ww}(:,2:4)
        end   
        % check whether values in matrix are consecutive
        p = 0;
        for k = 1:size(matrix,1)
            d = diff(matrix(k,:));
            dd = find(d <= 0);
            if isempty(dd) == 0
                p = p+1;
                del(p) = k;
            end
        end
        if exist('del','var')
            matrix(del,:) = [];
        end
        clear p k d dd del
        dl = find( diff(matrix(:,6)) > 128*3);
        dr = find( diff(matrix(:,3)) > 128*3);
        [r,d] = find(matrix == 0);          
        % delete zero's if present            
        if isempty(r) == 0
            matrix(r,:) = [];
        end
        clear d r
        % delete stride time bigger than 3 seconds
        if isempty(dl) == 0
            matrix(dl,:) = []; 
        elseif isempty(dr) == 0
            matrix(dr,:) = [];
        end  
        % compute steptime, stride time, stance time, swingtime, double
        % support, and single support out of the matrix
        if firststep == 1
            steptimel = [steptimel; matrix(2:end,3) - matrix(1:end-1,6)];
            steptimer = [steptimer; matrix(:,6) - matrix(:,3)];
            
            stridetimel = [stridetimel; diff(matrix(:,3))];
            stridetimer = [stridetimer; diff(matrix(:,6))];
            
            swingtimel = [swingtimel; matrix(:,3) - matrix(:,1)];
            swingtimer = [swingtimer; matrix(:,6) - matrix(:,4)];             
            
            stancetimel = [stancetimel; matrix(2:end,1) - matrix(1:end-1,3)];
            stancetimer = [stancetimer; matrix(2:end,4) - matrix(1:end-1,6)];
        elseif firststep == 2
            steptimel = [steptimel; matrix(:,6) - matrix(:,3)];
            steptimer = [steptimer; matrix(2:end,3) - matrix(1:end-1,6)];
            
            stridetimel = [stridetimel; diff(matrix(:,6))];
            stridetimer = [stridetimer; diff(matrix(:,3))];
            
            swingtimel = [swingtimel; matrix(:,6) - matrix(:,4)];
            swingtimer = [swingtimer; matrix(:,3) - matrix(:,1)];   
            
            stancetimel = [stancetimel; matrix(2:end,4) - matrix(1:end-1,6)];
            stancetimer = [stancetimer; matrix(2:end,1) - matrix(1:end-1,3)];
        end    
        %% Divide doublesupport time by stride time!
%         doublesupport = [doublesupport; (matrix(2:end,4)-matrix(2:end,3))+(matrix(2:end,1) - matrix(1:end-1,6))];
%         singlesupport = [singlesupport; (matrix(2:end,6)-matrix(2:end,4))+(matrix(2:end,3)-matrix(2:end,1))];
        clear matrix
end
% convert from samples to seconds and save in kinedata
kinedata.param.steptime_left = [];
kinedata.param.steptime_left = steptimel(2:end)'/128;
kinedata.param.steptime_right = [];
kinedata.param.steptime_right = steptimer(2:end)'/128;
kinedata.param.stridetime_left = [];
kinedata.param.stridetime_left = stridetimel(2:end)'/128;
kinedata.param.stridetime_right = [];
kinedata.param.stridetime_right = stridetimer(2:end)'/128;
kinedata.param.swingtime_left = [];
kinedata.param.swingtime_left = swingtimel(2:end)'/128;
kinedata.param.swingtime_right = [];
kinedata.param.swingtime_right = swingtimer(2:end)'/128;
kinedata.param.stancetime_left = [];
kinedata.param.stancetime_left = stancetimel(2:end)'/128;
kinedata.param.stancetime_right = [];
kinedata.param.stancetime_right = stancetimer(2:end)'/128;
% kinedata.param.doublesupport = [];
% kinedata.param.doublesupport = doublesupport(2:end)/128;
% kinedata.param.singlesupport = [];
% kinedata.param.singlesupport = singlesupport(2:end)/128;

