% Saving HydroRIVERS shapefiles as vec files that are inside the chosen basin

clc
clear
close all

basinVectors = '.\33_Main_world_basin_Vectors'; % shapefile contours

BasinName = 'Niger'; % Name of the basin being worked on

outputFolder = sprintf('%s_HydroRIVERS', BasinName);  % Defining the folder, where the vec-files will be saved

% if the output folder do not exist, MATLAB will create it.
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

poly1 = load(sprintf('%s\\%s.vec', basinVectors, BasinName)); % loading chosen basin polygon

% Adding box around the chosen basin
bbox = [min(poly1(:,1)) min(poly1(:,2));
        max(poly1(:,1)) max(poly1(:,2))];

HydroRivers_raw = shaperead( ...
    './HydroRIVERS_v10_af_shp/HydroRIVERS_v10_af_shp/HydroRIVERS_v10_af.shp', ...
    'BoundingBox', bbox);

% Threshold
threshold = 6;

% Keeping only rivers with ORD_STRA bigger than threshold
HydroRivers = HydroRivers_raw([HydroRivers_raw.ORD_STRA] > threshold);

% Filtering rivers that are inside the chosen basin
    for i = length(HydroRivers):-1:1
            insideBasin=inpolygon( ...
            HydroRivers(i).X, ... 
            HydroRivers(i).Y, ... 
            poly1(:,1), poly1(:,2));
        % Removes rivers that are outside the basin
        if ~insideBasin
         HydroRivers(i) = [];
        end
    end

% Plotting basin
mapfig= figure('Name','Plot of HydroRivers');
geobasemap colorterrain    
 hold on
poly1 = load(sprintf('%s\\%s.vec', basinVectors,BasinName));
h1 = plot(poly1(:,2), poly1(:,1), ...
    'Color', 'y', ...
    'LineWidth', 2, ...
    'DisplayName', BasinName);

 % Plot HydroRIVERS
 for i = length(HydroRivers):-1:1
     hold on
     h = plot(HydroRivers(i).Y,HydroRivers(i).X,'Color' ,'#00b3ff', 'LineWidth', 2);
     h.Annotation.LegendInformation.IconDisplayStyle = 'off';
 end

% Adding a general legend for HydroRIVERS
plot(nan, nan, 'Color' ,'#00b3ff', 'LineWidth', 2, 'DisplayName','HydroRIVERS');

% Adding legend for basin
legend('Location','best', 'Color','#707070', 'TextColor','w'); 

title(['HydroRIVERS in ' BasinName])

% Saving filtered HydroRIVERS as vec files
    for i = 1:length(HydroRivers)
        % Defining the name of each vector files based on the given id
        filename = fullfile(outputFolder, sprintf('%d.vec', HydroRivers(i).HYRIV_ID));

        fid = fopen(filename, 'w');
        % Adding the attribute name for the coordinates that determine the geometry of each vector.
        Lon = HydroRivers(i).X;
        Lat = HydroRivers(i).Y;

        for j = 1:length(Lon)
            if isnan(Lon(j)) || isnan(Lat(j))
                fprintf(fid, 'NaN NaN\n'); % Separator between polygons
            else
                fprintf(fid, '%.6f %.6f\n', Lon(j), Lat(j));
            end
        end
        fclose(fid);

    end
