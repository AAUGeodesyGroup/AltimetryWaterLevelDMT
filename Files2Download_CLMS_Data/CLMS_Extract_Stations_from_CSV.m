% This file selects those CLMS stations from MATLAB file, that are inside a
% given basin.
clc
clear
close all
tic
addpath ('..\BackgroundFiles') % Path to functions
load('CLMS_CSV2MAT.mat');
basinVectors = '..\BackgroundFiles\33_Main_world_basin_Vectors'; % shapefile contours
toc

%% --- Change input in this section
% Name of the basin(s) working with
BasinName = 'Niger';

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
    BasinName, Basin1, Basin2, ...
    SavedData, numBasins,basinVectors);
toc

%% Saving as CSV
% Saving: Name, Code, Lat, Lon, IdNumber
SI = struct2table(Stations_inside_Basin);
MyTable = [SI(:,1) SI(:,2) SI(:,3) SI(:,4)];
writetable(MyTable,'CLMS_Niger_Station_Information.csv')
