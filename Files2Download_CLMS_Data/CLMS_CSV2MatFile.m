clc
clear
close all

% This file saves selected columns from a CSV file and saves the data as a
% matlabfile.

% Import CSV data
data = readtable("wl-rivers_global_vector_daily_v2_geojson.csv");

coordStrings = string(data{:,12});
nums = extractBetween(coordStrings, "((", ")"); % extract all numbers as strings
coords = split(nums);
lon = str2double(coords(:,1)); % extract number from string that is for longitude
lat = str2double(coords(:,6)); % extract number from string that is for latitude

lon=lon';
lat=lat';
ID = table2cell(data(:,1));
Name = table2cell(data(:,2));

%% save data in struct
SavedData = struct();
for i = 1:length(ID)
    SavedData(i).Id = ID(i);
    SavedData(i).Name = Name(i);
    SavedData(i).Lon = lon(i);
    SavedData(i).Lat = lat(i);
end

save('CLMS_CSV2MAT.mat', 'SavedData');
