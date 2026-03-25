% This file selects those CLMS stations from matalab file, that are inside a
% given basin.
clc
clear
close all
tic
addpath 'C:\Users\Bruger\Documents\MEGA\Geodesy\12_DataComputations\SFAS_Niger_Data\BackgroundFiles' % location for functions
load('CLMS_CSV2MAT.mat');
basinVectors = 'C:\Users\Bruger\Documents\MEGA\Geodesy\12_DataComputations\SFAS_Niger_Data\BackgroundFiles\33_main_world_basins_vectors'; % shapefile contours
addpath(basinVectors)
load('C:\Users\Bruger\Documents\MEGA\Geodesy\12_DataComputations\SFAS_Niger_Data\BackgroundFiles\Basin_Information_EF_33main.mat'); % shapefile info
toc

%% --- Change input in this section

% Amount of basins
numBasins = 1; % if 1 is the input, then Basin2 will not be shown

% Name of first basin
Basin1 = 'Niger'; % 'Danube' or 'Ganges'

BasinColor1 = 'y'; % Color of basin contour

% Name of second Basin
Basin2 = 'Brahmaputra'; % 'Brahmaputra'

BasinColor2 = 'w'; % Color of basin contour

% Line width for the basins
BasinLineWidth = 2;

if numBasins == 2 
    CombineBasin = sprintf('%s-%s', Basin1, Basin2);
else
    CombineBasin = Basin1;
end

%% Select those stations that are inside basin
tic
Stations_inside_Basin = FilterStationsByBasin( ...
    Basin_Name, Basin1, Basin2, ...
    SavedData, numBasins,basinVectors);
toc

%% Saving as CSV
% Saving: Name, Code, Lat, Lon, IdNumber
SI = struct2table(Stations_inside_Basin);
MyTable = [SI(:,1) SI(:,2) SI(:,3) SI(:,4)];
writetable(MyTable,'CLMS_Niger_Station_Information.csv')
