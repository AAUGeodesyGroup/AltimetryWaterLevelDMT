% Converting a single custom shapefile into multiple vector files, where
% each polygon from the shapefile has its own vec-file with corresponding
% names.

clc
clear
close all

addpath(genpath('./')) % letting MATLAB find the correct sub-folder

Shapefile = shaperead('./Custom_shapefiles/Something.shp'); % Loading the custom shapefile
outputFolder = 'Custom_vec_files'; % Defining the folder, where the vec-files would be saved

% if the output folder do not exist, MATLAB will create it.
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

for i = 1:length(Shapefile)
    shapefileName = Shapefile(i).Something; % Add the attribute name that determines the naming of each generated vector
    filename = fullfile(outputFolder,sprintf('%s.vec', shapefileName));
    fid = fopen(filename, 'w');
    
    % Add the attribute name for the coordinates that determine the geometry of each vector.
    X = Shapefile(i).X;
    Y = Shapefile(i).Y;

    for j = 1:length(X)
        if ~isnan(X(j)) && ~isnan(Y(j))
            fprintf(fid, '%.6f %.6f\n', X(j), Y(j)); % Coordinates are given with 6 decimals
        else
            fprintf(fid, '\n');
        end
    end

    fclose(fid);
end
