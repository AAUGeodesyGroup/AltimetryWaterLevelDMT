% Extracting Hydroweb stations that are satisfying the requirements

clc
clear
close all

addpath '.\BackgroundFiles' % path to functions
Path_figures = '.\Saved_Figures'; % location of folder where the figures would be saved
Path_matFiles = '.\Saved_Matlab_Files'; % location of folder where the matlab files would be saved
Path_CSVFiles = '.\Saved_CSV_Files'; % location of folder where the CSV files would be saved
basinVectors = '.\BackgroundFiles\33_Main_world_basin_Vectors'; % shapefile contours

%% ### Change inputs down here ###

% ### Requirements ###
% In first filtration retrieve stations with requirements:
    % Temporal Coverage
    TempCoveragePct = 80; 
    % - 80% of temporal coverage between the specific period that each virtual station has
    
    % Amount of maximum days the gap in timeperiod can be
    MaxDays = 365;
    % - no continuous gaps of longer than 12 months
% In second filtration retrieve stations with requirements:
    startperiod = 2008;
    endperiod = 2025;
    
    startDatetime = datetime(startperiod,1,01);
    endDatetime = datetime(endperiod,12,31);
        % write 1,1 if endperiod only should stop by 1.jan of the selected year.
        % write 12,31 if the data for endperiod should go until the end of the year

% ### File names - imported and saved ###
    PlaceOfFiles = 'Hydroweb_Niger\*.txt'; % The name of the folder where the raw data is
    BasinName = 'Niger'; % Name of the basin worked on
    
    % Names of the folders where the figures are saved
    
    Place_of_FirstFilter = fullfile(Path_figures, [BasinName '_Timeseries_First-filter']);
    if ~exist(Place_of_FirstFilter, 'dir')
    mkdir(Place_of_FirstFilter);
    end

    Place_of_SecondFilter = fullfile(Path_figures, [BasinName '_Timeseries_Second-filter']);
    if ~exist(Place_of_SecondFilter, 'dir')
    mkdir(Place_of_SecondFilter);
    end

    % Name of the folder where the matlab files are saved
    Place_of_Matlabfiles = fullfile(Path_matFiles, [BasinName '_Extracted_Stations']);
    if ~exist(Place_of_Matlabfiles, 'dir')
    mkdir(Place_of_Matlabfiles);
    end
    
    % Name of the folder where the CSV files are saved
    Place_of_CSVfiles = fullfile(Path_CSVFiles, [BasinName '_Hydroweb_Stations']);
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
    PythonSourceFile = 'Download_Hydroweb_data.py';
    fname = mfilename;
    MatlabSourceFile = [fname '.m'];
    Name_Processingcenter = 'Hydroweb';

% ### Plot styling ###

    % Styling of plots
    PlotStyle = {'.-','MarkerSize',8};
    
    % x and y labels for all figures
    xlabelName = 'Time';
    ylabelName = 'ID of stations';

    % ### First filter plots ###
    figName_notincluded = 'Deleted stations (Hydroweb)';
    titleNotincluded = sprintf(['%s\n'...
    'Discarded Hydroweb stations\n' ...
    '(requirement: under %d days gap and %.0f%% coverage)'], ...
    BasinName, MaxDays, TempCoveragePct);

    figName_included = 'Kept stations (Hydroweb)';
    titleIncluded =sprintf(['%s\n'...
    'Remained Hydroweb stations\n' ...
    '(requirement: under %d days gap and %.0f%% coverage)'], ...
    BasinName, MaxDays, TempCoveragePct);
       
    % ### Second filter plots ###
    
    figDiscardedName = 'Stations outside timeperiod (Hydroweb)';
    titleDiscarded =sprintf(['%s\n'...
    'Discarded Hydroweb stations in period %d-%d\n' ...
    '(requirement: under %d days gap and %.0f%% coverage)'], ...
    BasinName, startperiod, endperiod, MaxDays, TempCoveragePct);
    
    figRemainedName = 'Stations inside timeperiod (Hydroweb)';
    titleRemained = sprintf(['%s\n'...
    'Remained Hydroweb stations in period %d-%d\n' ...
    '(requirement: under %d days gap and %.0f%% coverage)'], ...
    BasinName, startperiod, endperiod, MaxDays, TempCoveragePct);
%% ### End of inputs ###

%% ##########################################
%% ### Filter of stations inside basin ###

dir_list = dir(PlaceOfFiles); %dir lists text-files from folder
ReadDataFromLine = 45;

Raw_Hydroweb_Stations = struct();
Deleted_stations = struct();

% Create a structure to store imported netCDF data
Kept_stations = struct();
R= 0; J= 0; K= 0;

%% Using time to find data that satisfy the requirements
for i=length(dir_list):-1:1
    
    % Generate adequate filename to read
    find_ = strfind(dir_list(i).name(),'_'); 
    sta_name = dir_list(i).name(find_(3)+1:find_(4)-1); 
    num_code = dir_list(i).name(find_(4)+1:find_(5)-1);

    sta_name(2:end) = lower(sta_name(2:end)); % First character of name is kept as upper case and the other characters are lowercase.
    
    % Read file 
    data = readtable(sprintf("%s/%s",dir_list(i).folder,dir_list(i).name),'ReadVariableNames',false,'NumHeaderLine',ReadDataFromLine);
            
    m_header = readtable(sprintf("%s/%s",dir_list(i).folder,dir_list(i).name),"Range","9:10",'ReadVariableNames',false,'Delimiter','::');

    % saving raw data in a struct
    R=R+1;
    Raw_Hydroweb_Stations(R).Name = [sta_name ' ' num_code];
    Raw_Hydroweb_Stations(R).Code = num_code;
    % Makes if statement for converting cell to double. So coordinates are
    % given as double instead of string
    if iscell(m_header.Var2(2)) 
        Raw_Hydroweb_Stations(R).Lat = str2double(m_header.Var2(2));
    else
        Raw_Hydroweb_Stations(R).Lat = m_header.Var2(2);
    end
     if iscell(m_header.Var2(1))
        Raw_Hydroweb_Stations(R).Lon = str2double(m_header.Var2(1));
    else
        Raw_Hydroweb_Stations(R).Lon = m_header.Var2(1);
    end

    Raw_Hydroweb_Stations(R).Time = data.Var1;
    Raw_Hydroweb_Stations(R).WaterLevel = data.Var3;
    Raw_Hydroweb_Stations(R).WaterLevelUncertainty = data.Var4;
    Raw_Hydroweb_Stations(R).Id = i*ones(length(Raw_Hydroweb_Stations(R).Time),1);
    Raw_Hydroweb_Stations(R).IdNumber = i;
end

Stations_inside_Hydroweb_Basin = FilterStationsByBasin( ...
    BasinName, Raw_Hydroweb_Stations, basinVectors);

Total_Number = length(Stations_inside_Hydroweb_Basin);
TotalNumberStation = sprintf('%d',Total_Number);

%% #######################
%% ### First filter ###
NotIncluded = Stations_inside_Hydroweb_Basin;

for i = length(Stations_inside_Hydroweb_Basin):-1:1

%% We are finding out if the timeseries is useful by focusing on what the time data contains
    % Time vector
    raw_time = Stations_inside_Hydroweb_Basin(i).Time;
    
    [Keep, plottime] = IsDataGood(raw_time,TempCoveragePct,MaxDays,startDatetime,endDatetime,true); % "startDatetime,endDatetime" is ignored when true is written
    if Keep
        NotIncluded(i) = []; % deletes timeseries from NotIncluded if they DO satisfy the requirements
        % (Deletes timeseries from NotIncluded list if they are more than
        % TempCoverage or less than MaxDays)
        J=J+1; 
        % Save data in structure
        Kept_stations(J).Name = Stations_inside_Hydroweb_Basin(i).Name;
        Kept_stations(J).Code = Stations_inside_Hydroweb_Basin(i).Code;
        Kept_stations(J).Lat = Stations_inside_Hydroweb_Basin(i).Lat;
        Kept_stations(J).Lon = Stations_inside_Hydroweb_Basin(i).Lon;      
        FilteredData = ismember(raw_time, plottime); % filter the wrong time out that does not match with data
        Kept_stations(J).Time = plottime(FilteredData);
        Kept_stations(J).WaterLevel = Stations_inside_Hydroweb_Basin(i).WaterLevel(FilteredData);
        Kept_stations(J).WaterLevelUncertainty = Stations_inside_Hydroweb_Basin(i).WaterLevelUncertainty(FilteredData);
        Kept_stations(J).Id = Stations_inside_Hydroweb_Basin(i).Id(1)*ones(length(Kept_stations(J).Time),1);
        Kept_stations(J).IdNumber = Stations_inside_Hydroweb_Basin(i).IdNumber;
    else
        Stations_inside_Hydroweb_Basin(i) = []; % deletes timeseries from dir_list that DO NOT satisfy the requirements
       % (Deletes timeseries from dir_list that are less than TempCoverage or more than MaxDays
        % Deleting/discarding data from dir_list when following requirements are meet:
            % ObservationAmount in timeperiod is covering less than 80% of months in the timeperiod
            % Maximum day difference between every data is bigger than 365
            % days)
        K=K+1;
        Deleted_stations(K).Time = plottime;
        Deleted_stations(K).Id = i*ones(length(Deleted_stations(K).Time),1);
    end
end

%Plotting figure with the stations of interest:
fig_good = PlotMyFigure(figName_included,Kept_stations,titleIncluded,xlabelName,ylabelName,PlotStyle);
fig_bad = PlotMyFigure(figName_notincluded,Deleted_stations,titleNotincluded,xlabelName,ylabelName,PlotStyle);

%saving the figures
filename_good = sprintf('%s_Hydroweb_Remainded_1Filter',BasinName);
savefig(fig_good, fullfile(Place_of_FirstFilter, [filename_good '.fig']));
saveas(fig_good, fullfile(Place_of_FirstFilter, [filename_good '.jpg']));
filename_bad = sprintf('%s_Hydroweb_Discarded_1Filter',BasinName);
savefig(fig_bad, fullfile(Place_of_FirstFilter, [filename_bad '.fig']));
saveas(fig_bad, fullfile(Place_of_FirstFilter, [filename_bad '.jpg']));

% saving information to readme file
Filter1_Number_deleted = length(Deleted_stations);
Filter1_Discarded = sprintf('%d',Filter1_Number_deleted);
Filter1_Number_kept = length(Kept_stations);
Filter1_Remained = sprintf('%d',Filter1_Number_kept);

ReadMeText = sprintf(['Made by: %s. '...
    'Date for creating the file: %s. '...
    'Matlab version: %s. '...
    'Source files: %s and %s. '...
    'Location: %s. '...
    'Processing Center: %s. '...
    'Requirements for first filter: %s coverage and no data gaps bigger than %s. '...
    'Number of stations before filter: %s. '...
    'Number of stations after first filter: %s discarded, %s remained.'],Author,CreationDate,MatlabVersion,PythonSourceFile,MatlabSourceFile,BasinName,Name_Processingcenter,pct,gap,TotalNumberStation,Filter1_Discarded,Filter1_Remained);
NameOfFirstFile = sprintf('Hydroweb_%s_first_kept.mat',BasinName);

% Saving data as mat files that also contains a README
%cell in matlab file
README = ReadMeText;
fullFileName = fullfile(Place_of_Matlabfiles, NameOfFirstFile);
save(fullFileName, 'Kept_stations','README'); 

%% Saving as CSV
    % Saving: Name, Code, Lat, Lon, IdNumber
SI = struct2table(Kept_stations);
MyTable = [SI(:,1) SI(:,2) SI(:,3) SI(:,4) SI(:,9)];
writetable(MyTable, fullfile(Place_of_CSVfiles, 'Hydroweb_Stations_MetaData.csv'));

for i= 1:size(SI,1)
Time = datetime(SI.Time{i,1});

TT = timetable( ...
    Time, ...
    SI.WaterLevel{i,1}, ...
    SI.WaterLevelUncertainty{i,1}, ...
    'VariableNames', {'WaterLevel','WaterLevelUncertainty'});

filename = fullfile(Place_of_CSVfiles, sprintf('HydrowebStation_%d.csv', i));
writetimetable(TT, filename);
end

%% ########################
%% ### Second filter ###

LoadedFile = load(['./', fullFileName]);
general_list =LoadedFile.Kept_stations;

deleted_list = general_list;
Hydroweb_deleted = struct();
Hydroweb_final_kept = struct();
L = 0; M=0;

for i = length(general_list):-1:1
 
    % Time vector
    t_hydroweb = general_list(i).Time;
    
    [Keep, SelectedPeriod] = IsDataGood(t_hydroweb,TempCoveragePct,MaxDays,startDatetime,endDatetime,false); % "startDatetime,endDatetime" is used when false is written
    if Keep
        deleted_list(i) = [];

        L=L+1;
        Hydroweb_final_kept(L).Name = general_list(i).Name;
        Hydroweb_final_kept(L).Code = general_list(i).Code;
        Hydroweb_final_kept(L).Lat = general_list(i).Lat;
        Hydroweb_final_kept(L).Lon = general_list(i).Lon;
        Hydroweb_final_kept(L).Time = SelectedPeriod;
        insideSelectedPeriod = ismember(t_hydroweb, SelectedPeriod); 
        Hydroweb_final_kept(L).WaterLevel = general_list(i).WaterLevel(insideSelectedPeriod);
        Hydroweb_final_kept(L).WaterLevelUncertainty = general_list(i).WaterLevelUncertainty(insideSelectedPeriod);
        Hydroweb_final_kept(L).Id = general_list(i).Id(1)*ones(length(Hydroweb_final_kept(L).Time),1);
        Hydroweb_final_kept(L).IdNumber = general_list(i).IdNumber;
        
    else
        % saving and plotting timeseries, that was deleted from
        % general_list
        M=M+1;
        Hydroweb_deleted(M).Time = SelectedPeriod;
        Hydroweb_deleted(M).Id = i*ones(length(Hydroweb_deleted(M).Time),1);
        
        general_list(i) = [];
    end 
end

%Plotting figure with the stations of interest:
fig_remained= PlotMyFigure(figRemainedName,Hydroweb_final_kept,titleRemained,xlabelName,ylabelName,PlotStyle);
fig_discarded =PlotMyFigure(figDiscardedName,Hydroweb_deleted,titleDiscarded,xlabelName,ylabelName,PlotStyle);

%saving the figures
filename_discarded = sprintf('%s_Hydroweb_Discarded_2Filter_%d-%d',BasinName, startperiod, endperiod);
filename_remained = sprintf('%s_Hydroweb_Remainded_2Filter_%d-%d', BasinName, startperiod, endperiod);

if ~isempty(fig_remained) && isvalid(fig_remained)
    savefig(fig_remained, fullfile(Place_of_SecondFilter, [filename_remained '.fig']));
    saveas(fig_remained, fullfile(Place_of_SecondFilter, [filename_remained '.jpg']));
else
    disp('No stations are remained with this timeperiod, therefore no plot of it.');
end

if ~isempty(fig_discarded) && isvalid(fig_discarded)
    savefig(fig_discarded, fullfile(Place_of_SecondFilter, [filename_discarded '.fig']));
    saveas(fig_discarded, fullfile(Place_of_SecondFilter, [filename_discarded '.jpg']));
else
    disp('No stations are remained with this timeperiod, therefore no plot of it.');
end

% saving information to readme file
Filter2_Number_deleted = length(Hydroweb_deleted);
Filter2_Discarded = sprintf('%d',Filter2_Number_deleted);
Filter2_Number_kept = length(Hydroweb_final_kept);
Filter2_Remained = sprintf('%d',Filter2_Number_kept);

ReadMeTextFinal = sprintf(['Made by: %s. '...
    'Date for creating the file: %s. '...
    'Matlab version: %s. '...
    'Source files: %s and %s. '...
    'Location: %s. '...
    'Processing Center: %s. '...
    'Requirements for first filter: %s coverage and no data gaps bigger than %s. '...
    'Requirements for second filter: %s coverage and no data gaps bigger than %s in period %s. '...
    'Number of stations before filter: %s. '...
    'Number of stations after first filter: %s discarded, %s remained. '...
    'Number of stations after second filter: %s discarded, %s remained.'],Author,CreationDate,MatlabVersion,PythonSourceFile,MatlabSourceFile,BasinName,Name_Processingcenter,pct,gap,pct,gap,period,TotalNumberStation,Filter1_Discarded,Filter1_Remained,Filter2_Discarded,Filter2_Remained);
NameOfFinalFile = sprintf('Hydroweb_%s_%s.mat',BasinName,period);

% Saving data as mat files that also contains a README
%cell in matlab file
READMEfinal = ReadMeTextFinal;
fullFinalFileName = fullfile(Place_of_Matlabfiles, NameOfFinalFile);
save(fullFinalFileName,'Hydroweb_final_kept','READMEfinal');

% Make a sound when running is done
load handel
sound(y,Fs)