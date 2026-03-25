% Extracting Dahiti stations that are satisfying the requirements

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
    
    startDatetime = datetime(startperiod,1,01);
    endDatetime = datetime(endperiod,12,31);
        % write 1,1 if endperiod only should stop by 1.jan of the selected year.
        % write 12,31 if the data for endperiod should go until the end of the year

% ### File names - imported and extracted ###
    PlaceOfFiles = '.\Dahiti_Niger\*.nc'; % The name of the folder where the raw data is
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
    Place_of_CSVfiles = fullfile(Path_CSVFiles, [BasinName '_Dahiti_Stations']);
    if ~exist(Place_of_CSVfiles, 'dir')
    mkdir(Place_of_CSVfiles);
    end
    
% ### Basin inputs ###
    % Insert the correct names that are found in "Basin_Name" from "Basin_Information_EF_33main.mat"
    VectorBasinName1 = 'Niger';
    VectorBasinName2 = 'Brahmaputra'; % leave as it is if NumberOfVectorBasins = 1, because it would not be used
    
    NumberOfVectorBasins = 1; % add the correct number that is similar to amount of basin names

% ### Information to write README text file ###  
    pct = sprintf('%d %%',TempCoveragePct);
    gap = sprintf('%d days',MaxDays);
    period = sprintf('%d-%d', startperiod, endperiod);

    Author = 'Hilda Vörös';
    CreationDate = datetime('today');
    MatlabVersion = version;
    PythonSourceFile = 'Download_Dahiti_data.py';
    fname = mfilename;
    MatlabSourceFile = [fname '.m'];
    Name_Processingcenter = 'Dahiti';

% ### Plot styling ###

    % Styling of plots
    PlotStyle = {'.-','MarkerSize',8};
    
    % x and y labels for all figures
    xlabelName = 'Time';
    ylabelName = 'ID of stations';

    % ### First selection plots ###

    figName_notincluded = 'Deleted stations (Dahiti)';
    titleNotincluded = sprintf(['%s\n'...
    'Discarded Dahiti stations\n' ...
    '(requirement: under %d days gap and %.0f%% coverage)'], ...
    BasinName, MaxDays, TempCoveragePct);

    figName_included = 'Kept stations (Dahiti)';
    titleIncluded =sprintf(['%s\n'...
    'Remained Dahiti stations\n' ...
    '(requirement: under %d days gap and %.0f%% coverage)'], ...
    BasinName, MaxDays, TempCoveragePct);
       
    % ### Second selection plots ###
    
    figUnselectedName = 'Stations outside timeperiod (Dahiti)';
    titleUnselected =sprintf(['%s\n'...
    'Discarded Dahiti stations in period %d-%d\n' ...
    '(requirement: under %d days gap and %.0f%% coverage)'], ...
    BasinName, startperiod, endperiod, MaxDays, TempCoveragePct);
    
    figSelectedName = 'Stations inside timeperiod (Dahiti)';
    titleSelected = sprintf(['%s\n'...
    'Remained Dahiti stations in period %d-%d\n' ...
    '(requirement: under %d days gap and %.0f%% coverage)'], ...
    BasinName, startperiod, endperiod, MaxDays, TempCoveragePct);
%% ### End of inputs ###

%% ###################################
%% ### Selection of stations inside basin ###
dir_list = dir(PlaceOfFiles);

Raw_Dahiti_Stations = struct();
Deleted_stations = struct();

% Create a structure to store imported netCDF data
Kept_stations = struct();
R= 0; J= 0; K= 0;

%% Using time to find data that satisfy the requirements
for i=length(dir_list):-1:1
    nc_data = fullfile(dir_list(i).folder, dir_list(i).name); %[dir_list(i).folder  '\'  dir_list(i).name];
    info = ncinfo(nc_data); % find variable names in finfo
    
    % Read global attributes
    SourceName = ncreadatt(nc_data, '/', 'source');
    TargetName = ncreadatt(nc_data, '/', 'target_name');
    NameCode   = ncreadatt(nc_data, '/', 'dahiti_id');
    Lat        = ncreadatt(nc_data, '/', 'latitude');
    Lon        = ncreadatt(nc_data, '/', 'longitude');
    
    % Read variables
    t           = ncread(nc_data, 'datetime');
    Waterlevel  = ncread(nc_data, 'water_level');
    Error       = ncread(nc_data, 'error');
    
    %Convert time to datetime
    t_datetime = datetime(t,'InputFormat','yyyy-MM-dd HH:mm:ss');
    t_datetime.Format = 'yyyy-MM-dd';

    % saving raw data in a struct
    R=R+1;
    Raw_Dahiti_Stations(R).Name = [SourceName ' ' convertStringsToChars(TargetName)];
    Raw_Dahiti_Stations(R).Code = NameCode;
    Raw_Dahiti_Stations(R).Lat = Lat;
    Raw_Dahiti_Stations(R).Lon = Lon;
    Raw_Dahiti_Stations(R).Time = t_datetime;
    Raw_Dahiti_Stations(R).WaterLevel = Waterlevel;
    Raw_Dahiti_Stations(R).WaterLevelUncertainty = Error;
    Raw_Dahiti_Stations(R).Id = i*ones(length(Raw_Dahiti_Stations(R).Time),1);
    Raw_Dahiti_Stations(R).IdNumber = i;
end

Stations_inside_Dahiti_Basin = FilterStationsByBasin( ...
    Basin_Name, VectorBasinName1, VectorBasinName2, ...
    Raw_Dahiti_Stations, NumberOfVectorBasins,basinVectors);

Total_Number = length(Stations_inside_Dahiti_Basin);
TotalNumberStation = sprintf('%d',Total_Number);

%% ###################################
%% ### First selection ###
NotIncluded = Stations_inside_Dahiti_Basin;

for i = length(Stations_inside_Dahiti_Basin):-1:1

    % Time vector
    raw_time = Stations_inside_Dahiti_Basin(i).Time;
%% We are finding out if the timeseries is useful by focusing on what the time data contains
    [Keep, plottime] = IsDataGood(raw_time,TempCoveragePct,MaxDays,startDatetime,endDatetime,true); % "startDatetime,endDatetime" is ignored when true is written
    if Keep
        NotIncluded(i) = []; % deletes timeseries from NotIncluded if they DO satisfy the requirements
        % (Deletes timeseries from NotIncluded list if they are more than
        % TempCoverage or less than MaxDays)
        J=J+1; 
        
        Kept_stations(J).Name = Stations_inside_Dahiti_Basin(i).Name;
        Kept_stations(J).Code = Stations_inside_Dahiti_Basin(i).Code;
        Kept_stations(J).Lat = Stations_inside_Dahiti_Basin(i).Lat;
        Kept_stations(J).Lon = Stations_inside_Dahiti_Basin(i).Lon;
        Kept_stations(J).Time = plottime;
        FilteredData = ismember(raw_time, plottime); % filter the wrong time out that does not match with data
        Kept_stations(J).WaterLevel = Stations_inside_Dahiti_Basin(i).WaterLevel(FilteredData);
        Kept_stations(J).WaterLevelUncertainty = Stations_inside_Dahiti_Basin(i).WaterLevelUncertainty(FilteredData);
        Kept_stations(J).Id = Stations_inside_Dahiti_Basin(i).Id(1)*ones(length(Kept_stations(J).Time),1);
        Kept_stations(J).IdNumber = Stations_inside_Dahiti_Basin(i).IdNumber;

    else
        Stations_inside_Dahiti_Basin(i) = []; % deletes timeseries from dir_list that DO NOT satisfy the requirements
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
filename_good = sprintf('%s_Dahiti_Remainded_1Selection',BasinName);
savefig(fig_good, fullfile(Place_of_FirstSelection, [filename_good '.fig']));
saveas(fig_good, fullfile(Place_of_FirstSelection, [filename_good '.jpg']));
filename_bad = sprintf('%s_Dahiti_Discarded_1Selection',BasinName);
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
NameOfFirstFile = sprintf('Dahiti_%s_first_kept.mat',BasinName);

% Saving data as mat files that also contains a README
%cell in matlab file
README = ReadMeText;
fullFileName = fullfile(Place_of_Matlabfiles, NameOfFirstFile);
save(fullFileName, 'Kept_stations','README'); 

%% Saving as CSV
    % Saving: Name, Code, Lat, Lon, IdNumber
SI = struct2table(Kept_stations);
MyTable = [SI(:,1) SI(:,2) SI(:,3) SI(:,4) SI(:,9)];
writetable(MyTable, fullfile(Place_of_CSVfiles, 'Dahiti_Stations_MetaData.csv'));

for i= 1:size(SI,1)
Time = datetime(SI.Time{i,1});

TT = timetable( ...
    Time, ...
    SI.WaterLevel{i,1}, ...
    SI.WaterLevelUncertainty{i,1}, ...
    'VariableNames', {'WaterLevel','WaterLevelUncertainty'});

filename = fullfile(Place_of_CSVfiles, sprintf('DahitiStation_%d.csv', i));
writetimetable(TT, filename);
end

%% ###################################
%% ### Second selection ###

LoadedFile = load(['./', fullFileName]);
general_list =LoadedFile.Kept_stations;

deleted_list = general_list;
Dahiti_deleted = struct();
Dahiti_final_kept = struct();
L = 0; M=0;

for i = length(general_list):-1:1

    % Time vector
    t_dahiti = general_list(i).Time;
    
    [Keep, SelectedPeriod] = IsDataGood(t_dahiti,TempCoveragePct,MaxDays,startDatetime,endDatetime,false);
    if Keep
        deleted_list(i) = [];

        L=L+1;
        
        Dahiti_final_kept(L).Name = general_list(i).Name;
        Dahiti_final_kept(L).Code = general_list(i).Code;
        Dahiti_final_kept(L).Lat = general_list(i).Lat;
        Dahiti_final_kept(L).Lon = general_list(i).Lon;
        Dahiti_final_kept(L).Time = SelectedPeriod;
        insideSelectedPeriod = ismember(t_dahiti, SelectedPeriod); 
        Dahiti_final_kept(L).WaterLevel = general_list(i).WaterLevel(insideSelectedPeriod);
        Dahiti_final_kept(L).WaterLevelUncertainty = general_list(i).WaterLevelUncertainty(insideSelectedPeriod);      
        Dahiti_final_kept(L).Id = general_list(i).Id(1)*ones(length(Dahiti_final_kept(L).Time),1);
        Dahiti_final_kept(L).IdNumber = general_list(i).IdNumber;
        
    else
        % saving and plotting timeseries, that was deleted from
        % general_list
        M=M+1;
        Dahiti_deleted(M).Time = SelectedPeriod;
        Dahiti_deleted(M).Id = i*ones(length(Dahiti_deleted(M).Time),1);
        
        general_list(i) = [];
    end 
end

%Plotting figure with the stations of interest:
fig_selected= PlotMyFigure(figSelectedName,Dahiti_final_kept,titleSelected,xlabelName,ylabelName,PlotStyle);
fig_unselected =PlotMyFigure(figUnselectedName,Dahiti_deleted,titleUnselected,xlabelName,ylabelName,PlotStyle);

%saving the figures
filename_selected = sprintf('%s_Dahiti_Remainded_2Selection_%d-%d', BasinName, startperiod, endperiod);
filename_unselected = sprintf('%s_Dahiti_Discarded_2Selection_%d-%d', BasinName, startperiod, endperiod);

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
Selection2_Number_deleted = length(Dahiti_deleted);
Selection2_Discarded = sprintf('%d',Selection2_Number_deleted);
Selection2_Number_kept = length(Dahiti_final_kept);
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
NameOfFinalFile = sprintf('Dahiti_%s_%s.mat',BasinName,period);

% Saving data as mat files that also contains a README
%cell in matlab file
READMEfinal = ReadMeTextFinal;
fullFinalFileName = fullfile(Place_of_Matlabfiles, NameOfFinalFile);
save(fullFinalFileName,'Dahiti_final_kept','READMEfinal');


% Make a sound when running is done
load handel
sound(y,Fs)