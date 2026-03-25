clc
clear
close all

addpath 'C:\Users\Bruger\Documents\MEGA\Geodesy\12_DataComputations\SFAS_Niger_Data\BackgroundFiles'
PlaceOfFiles =  'C:\Users\Bruger\Documents\MEGA\Geodesy\12_DataComputations\SFAS_Niger_Data\CLMS_Niger';

%% --- Reading json files ---
dir_list=dir(PlaceOfFiles);
dir_list(1:2) = []; % deleting the first 2 rows, since they are not data

Raw_CLMS_Stations = struct();

R= 0; 

for i=length(dir_list):-1:1
    myJsonFile = [dir_list(i).folder  '\'  dir_list(i).name];
    text1 = fileread(myJsonFile);
    % finding part of text that will be trimmed
    text= json_trim(text1);
   
    filedata = jsondecode(text);
    structvalues = filedata.data;
    DATA = struct2table(structvalues);

    % Generate adequate filename to read
    StationName = DATA.identifier{1};
    find_ = strfind(StationName,'_'); 
    sta_name = StationName(find_(2)+1:find_(3)-1); 
    num_code = StationName(find_(3)+1:end);

    sta_name(2:end) = lower(sta_name(2:end)); % First character of name is kept as upper case and the other characters are lowercase.
   
    % Read file
        % json has following arrays that shows up when writing
        % fieldnames(filedata) in Command Window
     m_header = filedata.geometry.coordinates;
     Waterlevel = DATA.orthometric_height_of_water_surface_at_reference_position;


    % saving raw data in a struct
    R=R+1;
    Raw_CLMS_Stations(R).Name = [sta_name ' ' num_code];
    Raw_CLMS_Stations(R).Code = num_code;
    Raw_CLMS_Stations(R).Lat = m_header(2);
    Raw_CLMS_Stations(R).Lon = m_header(1);
    Raw_CLMS_Stations(R).Time = datetime(year(DATA.datetime),month(DATA.datetime),day(DATA.datetime));
    Raw_CLMS_Stations(R).WaterLevel = Waterlevel;
    Raw_CLMS_Stations(R).WaterLevelUncertainty = DATA.associated_uncertainty;
    Raw_CLMS_Stations(R).Id = i*ones(length(Raw_CLMS_Stations(R).Time),1);
    Raw_CLMS_Stations(R).IdNumber = i;
end

%% --- Select station with longest WaterLevel time series ---

N = numel(Raw_CLMS_Stations);

allCodes = {Raw_CLMS_Stations.Code};

[uniqueCodes, ~, idxCode] = unique(allCodes);

Selected_CLMS_Stations = Raw_CLMS_Stations([]);
S = 0;

for k = 1:numel(uniqueCodes)

    ind = find(idxCode == k);

    if isscalar(ind)
        S = S + 1;
        Selected_CLMS_Stations(S) = Raw_CLMS_Stations(ind);
        continue
    end

    nWL = zeros(numel(ind),1);

    for j = 1:numel(ind)
        wl = Raw_CLMS_Stations(ind(j)).WaterLevel;

        if isempty(wl)
            nWL(j) = 0;
        else
            nWL(j) = numel(wl);
        end
    end

    [~, imax] = max(nWL);
    bestInd = ind(imax);

    S = S + 1;
    Selected_CLMS_Stations(S) = Raw_CLMS_Stations(bestInd);
end

save('Selected_CLMS_Stations.mat','Selected_CLMS_Stations')