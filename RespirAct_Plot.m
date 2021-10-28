function RespirAct_Plot(data_dir,subID,start_name,start_row,end_name,end_row,sequence_length)
% RespirAct_Plot(data_dir,start_name,start_row,end_name,end_row)
% e.g. RespirAct_Plot('/mydata/blockCO2/','SequenceStart',2,'SequenceEnd',5)
% Plots the CO2 and CO2 traces and overlays the end-tidal peaks that the RespirAct outputs
% By Rachael Stickland, 2021
%
% data_dir = path to your data directory (which contains the txt files RGM, EndTidal and Events)
% subID = subject ID for figure title

% start_name = name of the first time stamp e.g. 'Sequence Start'
% start_row = row number of this start_name in Events.txt (header information is row 1)

% end_name = name of the end time stamp e.g. 'Sequence End', or leave blank []
% end_row = row number of this end_name in Events.txt (header information is row 1), or leave blank []
% sequence_length = in seconds, use instead of end_name and end_row if there are no end markers, or leave blank [].

%% Read in the data

% RGM_Table = readtable([data_dir 'RGM.txt']);
% PO2 = RGM_Table.PO2_mmHg_;
% PCO2 = RGM_Table.PCO2_mmHg_;
% RGM_Time = RGM_Table.MRTime_s_;

EndTidal_Table = readtable([data_dir 'EndTidal.txt']);
ETCO2 = EndTidal_Table.PCO2_mmHg_;
ETO2 = EndTidal_Table.PO2_mmHg_;
Desired_ETCO2=EndTidal_Table.DesiredPCO2_mmHg_;
Desired_ETO2=EndTidal_Table.DesiredPO2_mmHg_;
ET_Time = EndTidal_Table.MRTime_s_;


%% Find the start and end of the experiment
Events_Table = readtable([data_dir 'Events.txt']);
start_index = Events_Table.MRTime_s_(start_row-1);

%double check that you read the correct row numbers for the start_index
if strcmp(Events_Table.Event(start_row-1),sprintf('%s',start_name)) == 0
    disp('** ERROR: The start index seems to be wrong. Please check **')
else
end

if isempty(sequence_length) == 1
    end_index = Events_Table.MRTime_s_(end_row-1);
    %double check that you read the correct row numbers for the end_index
    if strcmp(Events_Table.Event(end_row-1),sprintf('%s',end_name)) == 0
    disp('** ERROR: The end index seems to be wrong. Please check **')
    else
    end
else
   end_index = start_index+sequence_length;
end

%% Find the sequence start and end time indices
% RGM_Time_Protocol = RGM_Time > start_index;
% RGM_Sindex = find(RGM_Time_Protocol,1,'first');
% RGM_Time_Protocol = RGM_Time < end_index;
% RGM_Eindex = find(RGM_Time_Protocol,1,'last');

ET_Time_Protocol = ET_Time > start_index;
ET_Sindex = find(ET_Time_Protocol,1,'first');
ET_Time_Protocol = ET_Time  < end_index;
ET_Eindex = find(ET_Time_Protocol,1,'last');

%% Plot

figure;
sgtitle(sprintf('%s',subID),'FontSize',15)

subplot(2,1,1) %C02
plot(ETCO2(ET_Sindex:ET_Eindex,1),'o-')
hold on
plot(Desired_ETCO2(ET_Sindex:ET_Eindex,1),'o-')
ylabel('ETC02 mmHg','FontSize',15)
ylim([20,60]) %hardcoded to remove outlier breaths
legend('Achieved','Desired')

% hold on
% plot([start_index start_index],[0 max(PCO2)],'LineWidth',4,'Color',[0 0 0])
% hold on
% plot([end_index end_index], [0 max(PCO2)],'LineWidth',4,'Color',[0 0 0])

subplot(2,1,2) %02
plot(ETO2(ET_Sindex:ET_Eindex,1),'o')
hold on
plot(Desired_ETO2(ET_Sindex:ET_Eindex,1),'o')
ylabel('ET02 mmHg','FontSize',15)
ylim([80,140]) %hardcoded to remove outlier breaths
legend('Achieved','Desired')

%% Output to window

Time_seconds=end_index - start_index;
sprintf('Acquisition Time (seconds) = %0.5f', Time_seconds)

avPETCO2=mean(ETCO2(ET_Sindex:ET_Eindex,1));
stdevPETCO2=std(ETCO2(ET_Sindex:ET_Eindex,1));
targetavPETCO2=mean(Desired_ETCO2(ET_Sindex:ET_Eindex,1));
%targetavPETCO2=nanmean(Desired_ETCO2(ET_Sindex:ET_Eindex,1));
targetstdevPETCO2=std(Desired_ETCO2(ET_Sindex:ET_Eindex,1));
%targetstdevPETCO2=nanstd(Desired_ETCO2(ET_Sindex:ET_Eindex,1));

sprintf('targetPETCO2 = %0.5f, std = %0.5f, avPETCO2 = %0.5f, std = %0.5f',targetavPETCO2,targetstdevPETCO2, avPETCO2,stdevPETCO2)

avPETO2=mean(ETO2(ET_Sindex:ET_Eindex,1));
stdevPETO2=std(ETO2(ET_Sindex:ET_Eindex,1));
targetavPETO2=mean(Desired_ETO2(ET_Sindex:ET_Eindex,1));
%targetavPETO2=nanmean(Desired_ETO2(ET_Sindex:ET_Eindex,1));
targetstdevPETO2=std(Desired_ETO2(ET_Sindex:ET_Eindex,1));
%targetstdevPETO2=nanstd(Desired_ETO2(ET_Sindex:ET_Eindex,1));

sprintf('targetPETO2 = %0.5f, std = %0.5f, avPETO2 = %0.5f, std = %0.5f',targetavPETO2,targetstdevPETO2, avPETO2,stdevPETO2)
