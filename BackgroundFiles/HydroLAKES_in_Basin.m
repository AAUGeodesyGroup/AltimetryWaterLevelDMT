% Saving HydroLAKES shapefiles as vec files that are inside the chosen basin

clc
clear
close all

basinVectors = '.\33_Main_world_basin_Vectors'; % shapefile contours

BasinName = 'Niger'; % Name of the basin being worked on

outputFolder = 'HydroLAKES'; % Defining the folder, where the vec-files will be saved

% if the output folder do not exist, MATLAB will create it.
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

poly1 = load(sprintf('%s\\%s.vec', basinVectors, BasinName)); % loading chosen basin polygon

% creating a box around the chosen basin polygon
bbox = [min(poly1(:,1)) min(poly1(:,2));
        max(poly1(:,1)) max(poly1(:,2))];

% importing HydroLAKES polygons that are inside the box
HydroLakes = shaperead( ...
    './HydroLAKES_polys_v10_shp/HydroLAKES_polys_v10_shp/HydroLAKES_polys_v10.shp', ...
    'BoundingBox', bbox);

% Filtering lakes that are inside the chosen basin
    for i = length(HydroLakes):-1:1
            insideBasin=inpolygon( ...
            HydroLakes(i).X, ... 
            HydroLakes(i).Y, ... 
            poly1(:,1), poly1(:,2));
        % Removes lakes that are outside the basin
        if ~insideBasin
         HydroLakes(i) = [];
        end
    end

% Saving filtered lakes as vec files
    for i = 1:length(HydroLakes)
        % Defining the name of each vector files based on the given id
        filename = fullfile(outputFolder, sprintf('%d.vec', HydroLakes(i).Hylak_id));
        fid = fopen(filename, 'w');
        % Adding the attribute name for the coordinates that determine the geometry of each vector.
        Lon = HydroLakes(i).X;
        Lat = HydroLakes(i).Y;

        for j = 1:length(Lon)
            if isnan(Lon(j)) || isnan(Lat(j))
                fprintf(fid, 'NaN NaN\n'); % Separator between polygons
            else
                fprintf(fid, '%.6f %.6f\n', Lon(j), Lat(j));
            end
        end
        fclose(fid);
    end

