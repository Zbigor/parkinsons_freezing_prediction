data = load('S03R01.txt');
dt = 1/64;
data(:,2:10) = data(:,2:10)/1000;
data_tt = timetable(data(:,2),data(:,3),data(:,4),...
                    data(:,5),data(:,6),data(:,7),...
                    data(:,8),data(:,9),data(:,10),...
                    data(:,11),'TimeStep',seconds(dt));

data_tt.Properties.VariableNames{1} = 'ankle_forw';
data_tt.Properties.VariableNames{2} = 'ankle_vert';
data_tt.Properties.VariableNames{3} = 'ankle_lat';

data_tt.Properties.VariableNames{4} = 'knee_forw';
data_tt.Properties.VariableNames{5} = 'knee_vert';
data_tt.Properties.VariableNames{6} = 'knee_lat';

data_tt.Properties.VariableNames{7} = 'trunk_forw';
data_tt.Properties.VariableNames{8} = 'trunk_vert';
data_tt.Properties.VariableNames{9} = 'trunk_lat';

data_tt.Properties.VariableNames{10} = 'label';