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
% Name of the basin working with
BasinName = 'Niger';

%% Select those stations that are inside basin
tic
Stations_inside_Basin = FilterStationsByBasin( ...
    BasinName, SavedData, basinVectors);
toc

%% Saving as CSV
% Saving: Name, Code, Lat, Lon, IdNumber
SI = struct2table(Stations_inside_Basin);
MyTable = [SI(:,1) SI(:,2) SI(:,3) SI(:,4)];
writetable(MyTable,'CLMS_Niger_Station_Information.csv')
