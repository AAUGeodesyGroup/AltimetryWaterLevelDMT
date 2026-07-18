% Extracting gwm lake data for the chosen basin
clc
clear
close all

addpath '.\BackgroundFiles' % path to functions
Path_figures = '.\Saved_Figures'; % location of folder where the figures would be saved
Path_matFiles = '.\Saved_Matlab_Files'; % location of folder where the matlab files would be saved
Path_CSVFiles = '.\Saved_CSV_Files'; % location of folder where the CSV files would be saved
basinVectors = '.\BackgroundFiles\33_Main_world_basin_Vectors'; % shapefile contours

%% ### Change inputs down here ###

% ### File names - imported and saved ###
    PlaceOfFiles = 'gwm_lake_10day\*.txt'; % The name of the folder where the raw data is
    BasinName = 'Niger'; % Name of the basin worked on
    
    % Name of the folder where the matlab files are saved
    Place_of_Matlabfiles = fullfile(Path_matFiles, [BasinName '_GWM_Lakes']);
    if ~exist(Place_of_Matlabfiles, 'dir')
    mkdir(Place_of_Matlabfiles);
    end

     % Name of the folder where the CSV files are saved
    Place_of_CSVfiles = fullfile(Path_CSVFiles, [BasinName '_GWM_Lakes']);
    if ~exist(Place_of_CSVfiles, 'dir')
    mkdir(Place_of_CSVfiles);
    end

%% ### End of inputs ###

%% ##########################################
%% ### Filter of stations inside basin ###

dir_list = dir(PlaceOfFiles); %dir lists text-files from folder
ReadDataFromLine = 51;

Raw_gwm_lake = struct();
R= 0;

%% Extracting data and saving as matlab file
for i=length(dir_list):-1:1
    
    % Read file 
    data = readtable(sprintf("%s/%s",dir_list(i).folder,dir_list(i).name),'ReadVariableNames',false,'NumHeaderLine',ReadDataFromLine);
            
    m_header = readtable(sprintf("%s/%s",dir_list(i).folder,dir_list(i).name),"Range","2:3",'ReadVariableNames',false,'Delimiter',':');
    result = cellfun(@strsplit, m_header{:,:}, 'UniformOutput', false);

    R=R+1;
    Raw_gwm_lake(R).Name = [result{1,1}{2} ' ' result{1,1}{1}];
    
    % Converting cell to double
    if iscell(result{2,1}) 
        Raw_gwm_lake(R).Lat = str2double(result{2,1}{1});
        Raw_gwm_lake(R).Lon = str2double(result{2,1}{2});
    else
        Raw_gwm_lake(R).Lat = result{2,1}{1};
        Raw_gwm_lake(R).Lon = result{2,1}{2};
    end

    rawDate = data.Var3;
    rawHeight = data.Var6;
    rawError = data.Var7;
    rawHeightEGM = data.Var15;

    % Converting date to datetime
    if isnumeric(rawDate)
        dateTime = datetime(num2str(rawDate),'InputFormat','yyyyMMdd');
    else
        dateTime = datetime(string(rawDate),'InputFormat','yyyyMMdd');
    end
    
    % Finds data values that does not contain default values
    validIdx = ...
        rawHeight ~= 999.99 & ...
        rawError ~= 999.99 & ...
        rawHeightEGM ~= 999.99; 
    
    % Saves extracted data in struct
    Raw_gwm_lake(R).Date = dateTime(validIdx);
    Raw_gwm_lake(R).Height = rawHeight(validIdx);
    Raw_gwm_lake(R).Error = rawError(validIdx);
    Raw_gwm_lake(R).HeightEGM = rawHeightEGM(validIdx);
    
    Raw_gwm_lake(R).Id = i*ones(length(Raw_gwm_lake(R).Date),1);
    Raw_gwm_lake(R).IdNumber = i;
end

% Filtering gmw lakes that are inside the chosen basin 
GWM_lakes_inside_Basin = FilterDataByBasin( ...
    BasinName, Raw_gwm_lake, basinVectors);

% Saving gwm lakes as matlab file
NameOfgwmFile = sprintf('GWM_Lake_Data_%s.mat',BasinName);
fullFileName = fullfile(Place_of_Matlabfiles, NameOfgwmFile);
save(fullFileName, 'GWM_lakes_inside_Basin'); 

%% Saving as CSV
    % Saving: Name, Lat, Lon, IdNumber
SI = struct2table(GWM_lakes_inside_Basin);
MyTable = [SI(:,1) SI(:,2) SI(:,3) SI(:,9)];
writetable(MyTable, fullfile(Place_of_CSVfiles, sprintf('GWM_Lakes_in_%s_MetaData.csv',BasinName)));

    % Saving: Time, WaterLevel, WaterLevelUncertainty
for i= 1:size(SI,1)
Time = datetime(SI.Date{i,1});

TT = timetable( ...
    Time, ...
    SI.Height{i,1}, ...
    SI.Error{i,1}, ...
    SI.HeightEGM{i,1}, ...
    'VariableNames', {'Height','Error','HeightEGM'});

filename = fullfile(Place_of_CSVfiles, sprintf('GWM_lake_%d.csv', i));
writetimetable(TT, filename);
end
