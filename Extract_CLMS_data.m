% Extracting CLMS stations that are satisfying the requirements

clc
clear
close all

addpath '.\BackgroundFiles' % location for functions
Path_figures = '.\Saved_Figures'; % location of folder where the figures would be saved
Path_matFiles = '.\Saved_Matlab_Files'; % location of folder where the matlab files would be saved
Path_CSVFiles = '.\Saved_CSV_Files'; % location of folder where the CSV files would be saved
basinVectors = '.\BackgroundFiles\33_main_world_basins_vectors'; % shapefile contours
addpath(basinVectors)
load('.\BackgroundFiles\Basin_Information_EF_33main.mat'); % shapefile info
addpath '.\Files2Download_CLMS_Data' % location of raw CLMS data for this basin
load('Selected_CLMS_Stations.mat') % raw CLMS data for this basin

%% ### Change inputs down here ###

% ### Requirements ###
% In first selection retrieve stations with requirements:
    % Temporal Coverage
    TempCoveragePct = 80; 
    % - 80% of temporal coverage between the specific period that each virtual station has
    
    % Amount of maximum days the gap in timeperiod can be
    MaxDays = 365;
    % - no continuous gaps of longer than 12 months

% In second selection retrieve stations with requirements:
    startperiod = 2008;
    endperiod = 2025;
    
    startDatetime = datetime(startperiod,7,12);
    endDatetime = datetime(endperiod,12,31);
        % write 1,1 if endperiod only should stop by 1.jan of the selected year.
        % write 12,31 if the data for endperiod should go until the end of the year

% ### File names - imported and saved ###
    PlaceOfFiles = 'CLMS_Niger'; % The name of the folder where the raw data is
    BasinName = 'Niger'; % Name of the basin worked on
    
    % Names of the folders where the figures are saved
    Place_of_FirstSelection = fullfile(Path_figures, [BasinName '_Timeseries_First-selection']);
    if ~exist(Place_of_FirstSelection, 'dir')
    mkdir(Place_of_FirstSelection);
    end

    Place_of_SecondSelection = fullfile(Path_figures, [BasinName '_Timeseries_Second-selection']);
    if ~exist(Place_of_SecondSelection, 'dir')
    mkdir(Place_of_SecondSelection);
    end

    % Name of the folder where the matlab files are saved
    Place_of_Matlabfiles = fullfile(Path_matFiles, [BasinName '_Extracted_Stations']);
    if ~exist(Place_of_Matlabfiles, 'dir')
    mkdir(Place_of_Matlabfiles);
    end

    % Name of the folder where the CSV files are saved
    Place_of_CSVfiles = fullfile(Path_CSVFiles, [BasinName '_CLMS_Stations']);
    if ~exist(Place_of_CSVfiles, 'dir')
    mkdir(Place_of_CSVfiles);
    end

% ### Information to write README text file ###  
    pct = sprintf('%d %%',TempCoveragePct);
    gap = sprintf('%d days',MaxDays);
    period = sprintf('%d-%d', startperiod, endperiod);

    Author = 'Hilda Vörös';
    CreationDate = datetime('today');
    MatlabVersion = version;
    PythonSourceFile = 'Download_CLMS_data.py';
    fname = mfilename;
    MatlabSourceFile = [fname '.m'];
    Name_Processingcenter = 'CLMS';

% ### Plot styling ###

    % Styling of plots
    PlotStyle = {'.-','MarkerSize',8};
    
    % x and y labels for all figures
    xlabelName = 'Time';
    ylabelName = 'ID of stations';

    % ### First selection plots ###
    
    figName_notincluded = 'Deleted stations (CLMS)';
    titleNotincluded = sprintf(['%s\n'...
    'Discarded CLMS stations\n' ...
    '(requirement: under %d days gap and %.0f%% coverage)'], ...
    BasinName, MaxDays, TempCoveragePct);

    figName_included = 'Kept stations (CLMS)';
    titleIncluded =sprintf(['%s\n'...
    'Remained CLMS stations\n' ...
    '(requirement: under %d days gap and %.0f%% coverage)'], ...
    BasinName, MaxDays, TempCoveragePct);
       
    % ### Second selection plots ###
    figUnselectedName = 'Stations outside timeperiod (CLMS)';
    titleUnselected =sprintf(['%s\n'...
    'Discarded CLMS stations in period %d-%d\n' ...
    '(requirement: under %d days gap and %.0f%% coverage)'], ...
    BasinName, startperiod, endperiod, MaxDays, TempCoveragePct);
    
    figSelectedName = 'Stations inside timeperiod (CLMS)';
    titleSelected = sprintf(['%s\n'...
    'Remained CLMS stations in period %d-%d\n' ...
    '(requirement: under %d days gap and %.0f%% coverage)'], ...
    BasinName, startperiod, endperiod, MaxDays, TempCoveragePct);
    
%% ### End of inputs ###

% Since Selected_CLMS_Stations already contains those stations that are inside
% the given basin, there is no need for using the function FilterStationsByBasin
Total_Number = length(Selected_CLMS_Stations);
TotalNumberStation = sprintf('%d',Total_Number);

J=0; K=0;

%% #######################
%% ### First selection ###
NotIncluded = Selected_CLMS_Stations;

for i = length(Selected_CLMS_Stations):-1:1
    %% We are finding out if the timeseries is useful by focusing on what the time data contains
    % Time vector
    raw_time = Selected_CLMS_Stations(i).Time; 
    
    [Keep, plottime] = IsDataGood(raw_time,TempCoveragePct,MaxDays,startDatetime,endDatetime,true); % "startDatetime,endDatetime" is ignored when true is written
    if Keep
        NotIncluded(i) = []; % deletes timeseries from NotIncluded if they DO satisfy the requirements
        % (Deletes timeseries from NotIncluded list if they are more than
        % TempCoverage or less than MaxDays)

        % saving and plotting timeseries, that was deleted from NotIncluded
        J=J+1; 

        Kept_stations(J).Name = Selected_CLMS_Stations(i).Name;
        Kept_stations(J).Code = Selected_CLMS_Stations(i).Code;
        Kept_stations(J).Lat = Selected_CLMS_Stations(i).Lat;
        Kept_stations(J).Lon = Selected_CLMS_Stations(i).Lon;
        FilteredData = ismember(raw_time, plottime); % filter the wrong time out that does not match with data
        Kept_stations(J).Time = plottime(FilteredData);
        Kept_stations(J).WaterLevel = Selected_CLMS_Stations(i).WaterLevel(FilteredData);
        Kept_stations(J).WaterLevelUncertainty = Selected_CLMS_Stations(i).WaterLevelUncertainty(FilteredData);
        Kept_stations(J).Id = Selected_CLMS_Stations(i).Id(1)*ones(length(Kept_stations(J).Time),1);
        Kept_stations(J).IdNumber = Selected_CLMS_Stations(i).IdNumber;

    else
        Selected_CLMS_Stations(i) = []; % deletes timeseries from dir_list that DO NOT satisfy the requirements
        % (Deletes timeseries from dir_list that are less than TempCoverage or more than MaxDays
        % Deleting/discarding data from dir_list when following requirements are meet:
            % ObservationAmount in timeperiod is covering less than 80% of months in the timeperiod
            % Maximum day difference between every data is bigger than 365
            % days)

        % saving and plotting timeseries, that was deleted from dir_list
        K=K+1;
        Deleted_stations(K).Time = plottime;
        Deleted_stations(K).Id = i*ones(length(Deleted_stations(K).Time),1);
    end
end

%Plotting figure with the stations of interest:
fig_good = PlotMyFigure(figName_included,Kept_stations,titleIncluded,xlabelName,ylabelName,PlotStyle);
fig_bad = PlotMyFigure(figName_notincluded,Deleted_stations,titleNotincluded,xlabelName,ylabelName,PlotStyle);

%saving the figures
filename_good = sprintf('%s_CLMS_Remainded_1Selection',BasinName);
savefig(fig_good, fullfile(Place_of_FirstSelection, [filename_good '.fig']));
saveas(fig_good, fullfile(Place_of_FirstSelection, [filename_good '.jpg']));
filename_bad = sprintf('%s_CLMS_Discarded_1Selection',BasinName);
savefig(fig_bad, fullfile(Place_of_FirstSelection, [filename_bad '.fig']));
saveas(fig_bad, fullfile(Place_of_FirstSelection, [filename_bad '.jpg']));

% saving information to readme file
Selection1_Number_deleted = length(Deleted_stations);
Selection1_Discarded = sprintf('%d',Selection1_Number_deleted);
Selection1_Number_kept = length(Kept_stations);
Selection1_Remained = sprintf('%d',Selection1_Number_kept);

ReadMeText = sprintf(['Made by: %s. '...
    'Date for creating the file: %s. '...
    'Matlab version: %s. '...
    'Source files: %s and %s. '...
    'Location: %s. '...
    'Processing Center: %s. '...
    'Requirements for first selection: %s coverage and no data gaps bigger than %s. '...
    'Number of stations before selection: %s. '...
    'Number of stations after first selection: %s discarded, %s remained.'],Author,CreationDate,MatlabVersion,PythonSourceFile,MatlabSourceFile,BasinName,Name_Processingcenter,pct,gap,TotalNumberStation,Selection1_Discarded,Selection1_Remained);
NameOfFirstFile = sprintf('CLMS_%s_first_kept.mat',BasinName);

% Saving data as mat files that also contains a README
%cell in matlab file
README = ReadMeText;
fullFileName = fullfile(Place_of_Matlabfiles, NameOfFirstFile);
save(fullFileName, 'Kept_stations','README'); 

%% Saving as CSV
    % Saving: Name, Code, Lat, Lon, IdNumber
SI = struct2table(Kept_stations);
MyTable = [SI(:,1) SI(:,2) SI(:,3) SI(:,4) SI(:,9)];
writetable(MyTable, fullfile(Place_of_CSVfiles, 'CLMS_Stations_MetaData.csv'));

for i= 1:size(SI,1)
Time = datetime(SI.Time{i,1});

TT = timetable( ...
    Time, ...
    SI.WaterLevel{i,1}, ...
    SI.WaterLevelUncertainty{i,1}, ...
    'VariableNames', {'WaterLevel','WaterLevelUncertainty'});

filename = fullfile(Place_of_CSVfiles, sprintf('CLMSstation_%d.csv', i));
writetimetable(TT, filename);
end

%% ########################
%% ### Second selection ###

LoadedFile = load(['./', fullFileName]);
general_list =LoadedFile.Kept_stations;

deleted_list = general_list;
CLMS_deleted = struct();
CLMS_final_kept = struct();
L = 0; M=0;

for i = length(general_list):-1:1
    % Time vector
    t_clms = general_list(i).Time;
    
    [Keep, SelectedPeriod] = IsDataGood(t_clms,TempCoveragePct,MaxDays,startDatetime,endDatetime,false);
    if Keep
        deleted_list(i) = [];

        L=L+1;
        CLMS_final_kept(L).Name = general_list(i).Name;
        CLMS_final_kept(L).Code = general_list(i).Code;
        CLMS_final_kept(L).Lat = general_list(i).Lat;
        CLMS_final_kept(L).Lon = general_list(i).Lon;
        CLMS_final_kept(L).Time = SelectedPeriod;
        insideSelectedPeriod = ismember(t_clms, SelectedPeriod); 
        CLMS_final_kept(L).WaterLevel = general_list(i).WaterLevel(insideSelectedPeriod);
        CLMS_final_kept(L).WaterLevelUncertainty = general_list(i).WaterLevelUncertainty(insideSelectedPeriod);
        CLMS_final_kept(L).Id = general_list(i).Id(1)*ones(length(CLMS_final_kept(L).Time),1);
        CLMS_final_kept(L).IdNumber = general_list(i).IdNumber;
                
    else
        % saving and plotting timeseries, that was deleted from
        % general_list
        M=M+1;
        CLMS_deleted(M).Time = SelectedPeriod;
        CLMS_deleted(M).Id = i*ones(length(CLMS_deleted(M).Time),1);
        
        general_list(i) = [];
    end 
end

%Plotting figure with the stations of interest:
fig_selected= PlotMyFigure(figSelectedName,CLMS_final_kept,titleSelected,xlabelName,ylabelName,PlotStyle);
fig_unselected =PlotMyFigure(figUnselectedName,CLMS_deleted,titleUnselected,xlabelName,ylabelName,PlotStyle);

%saving the figures
filename_unselected = sprintf('%s_CLMS_Discarded_2Selection_%d-%d',BasinName, startperiod, endperiod);
filename_selected = sprintf('%s_CLMS_Remainded_2Selection_%d-%d', BasinName, startperiod, endperiod);

if ~isempty(fig_selected) && isvalid(fig_selected)
    savefig(fig_selected, fullfile(Place_of_SecondSelection, [filename_selected '.fig']));
    saveas(fig_selected, fullfile(Place_of_SecondSelection, [filename_selected '.jpg']));
else
    disp('No stations in selected timeperiod, therefore no plot of it.');
end

if ~isempty(fig_unselected) && isvalid(fig_unselected)
    savefig(fig_unselected, fullfile(Place_of_SecondSelection, [filename_unselected '.fig']));
    saveas(fig_unselected, fullfile(Place_of_SecondSelection, [filename_unselected '.jpg']));
else
    disp('No stations in selected timeperiod, therefore no plot of it.');
end

% saving information to readme file
Selection2_Number_deleted = length(CLMS_deleted);
Selection2_Discarded = sprintf('%d',Selection2_Number_deleted);
Selection2_Number_kept = length(CLMS_final_kept);
Selection2_Remained = sprintf('%d',Selection2_Number_kept);

ReadMeTextFinal = sprintf(['Made by: %s. '...
    'Date for creating the file: %s. '...
    'Matlab version: %s. '...
    'Source files: %s and %s. '...
    'Location: %s. '...
    'Processing Center: %s. '...
    'Requirements for first selection: %s coverage and no data gaps bigger than %s. '...
    'Requirements for second selection: %s coverage and no data gaps bigger than %s in period %s. '...
    'Number of stations before selection: %s. '...
    'Number of stations after first selection: %s discarded, %s remained. '...
    'Number of stations after second selection: %s discarded, %s remained.'],Author,CreationDate,MatlabVersion,PythonSourceFile,MatlabSourceFile,BasinName,Name_Processingcenter,pct,gap,pct,gap,period,TotalNumberStation,Selection1_Discarded,Selection1_Remained,Selection2_Discarded,Selection2_Remained);
NameOfFinalFile = sprintf('CLMS_%s_%s.mat',BasinName,period);

% Saving data as mat files that also contains a README
%cell in matlab file
READMEfinal = ReadMeTextFinal;
fullFinalFileName = fullfile(Place_of_Matlabfiles, NameOfFinalFile);
save(fullFinalFileName,'CLMS_final_kept','READMEfinal');

% Make a sound when running is done
load handel
sound(y,Fs)
