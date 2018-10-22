% compute peak angular velocity and range of motion (max-min) of the trunk of the yaw axis (around longitudinal axis)
function [kinedata] = gait_trunkparameters(kinedata)

if nargin == 0
    disp('Not enough input arguments');
    return;
end

% Calculate for each stride the peak angular velocity in yaw axis (x)
% and the range of motion (max-min) in the yaw axis
    
clear t_event gx
gx = kinedata.lumbar.gyr(:,1)*180/pi;

if isfield(kinedata.segment,'selevent_left')
    t_event = kinedata.segment.selevent_left;
else
    t_event = kinedata.segment.event_left;
end
trunkpavyaw_left = zeros(size(t_event.way,2),50);
trunkromyaw_left = zeros(size(t_event.way,2),50);
for w = 1:size(t_event.way,2)
    z = 0;
    for i = 1:size(t_event.way{1,w},1)-1        
        % if toe-off, midswing, or heelstrike of the event-values is 0 (indicate the value belongs to a turn),
        % proceed to next step
        x = t_event.way{1,w}(i:i+1,:);
        if any(find(x==0))
            continue        
        % if a value has nans
        elseif any(any(isnan(x)))
            continue        
        end
        % one step: from heelstrike to next heelstrike (4th column)
        clear d
        d = gx(x(1,4):x(2,4),1);
        z = z+1;
        trunkpavyaw_left(w,z) = max(d);
        trunkromyaw_left(w,z) = max(d) - min(d);
    end        
end

clear t_event x z

if isfield(kinedata.segment,'selevent_right')
    t_event = kinedata.segment.selevent_right;
else
    t_event = kinedata.segment.event_right;
end
trunkpavyaw_right = zeros(size(t_event.way,2),50);
trunkromyaw_right = zeros(size(t_event.way,2),50);
for w = 1:size(t_event.way,2)
    z = 0;
    for i = 1:size(t_event.way{1,w},1)-1        
        % if toe-off, midswing, or heelstrike of the event-values is 0 (indicate the value belongs to a turn),
        % proceed to next step
        x = t_event.way{1,w}(i:i+1,:);
        if any(find(x==0))
            continue        
        % if a value has nans
        elseif any(any(isnan(x)))
            continue        
        end
        % one step: from heelstrike to next heelstrike (4th column)
        clear d
        d = gx(x(1,4):x(2,4),1);
        z = z+1;
        trunkpavyaw_right(w,z) = max(d);
        trunkromyaw_right(w,z) = max(d) - min(d);
    end        
end
% reshape to one column
trunkpavyaw_left = reshape(trunkpavyaw_left,[size(trunkpavyaw_left,1)*size(trunkpavyaw_left,2),1]);
trunkromyaw_left = reshape(trunkromyaw_left,[size(trunkromyaw_left,1)*size(trunkromyaw_left,2),1]);

trunkpavyaw_right = reshape(trunkpavyaw_right,[size(trunkpavyaw_right,1)*size(trunkpavyaw_right,2),1]);
trunkromyaw_right = reshape(trunkromyaw_right,[size(trunkromyaw_right,1)*size(trunkromyaw_right,2),1]);

% insert in kinedata structure and remove zeros
kinedata.param.trunkpavyaw_left = [];
kinedata.param.trunkromyaw_left = []; 
kinedata.param.trunkpavyaw_left = trunkpavyaw_left(trunkpavyaw_left~=0);
kinedata.param.trunkromyaw_left = trunkromyaw_left(trunkpavyaw_left~=0);

kinedata.param.trunkpavyaw_right = [];
kinedata.param.trunkromyaw_right = []; 
kinedata.param.trunkpavyaw_right = trunkpavyaw_right(trunkpavyaw_right~=0);
kinedata.param.trunkromyaw_right = trunkromyaw_right(trunkpavyaw_right~=0);