% Contains: 
% 1) A map that shows the location of selected processing centers inside a chosen basin 
% 2) LSM (least square method) calculation for processing centers (Dahiti, CLMS,
% Hydroweb) resulting in values for linear trend, annual and semiannual
% amplitude. Results are plotted on map with tabs for every values. Matlab files and figures are saved.
% 3) Finding those stations that are close to each other. Triple match and
% double match.

clc
clear
close all

Path_figures = '.\Saved_Figures'; % location of folder where the figures would be saved
Path_matFiles = '.\Saved_Matlab_Files'; % location of folder where the matlab files would be saved
FilePathName = '.\Saved_Matlab_Files\Niger_Extracted_Stations'; % location of folder the matlab files
addpath '.\BackgroundFiles' 

%% --- Change input in this section

% Amount of basins
numBasins = 1; % if 1 is the input, then Basin2 will not be shown

% Name of first basin
Basin1 = 'Niger'; % 'Niger' or 'Ganges'

BasinColor1 = 'y'; % Color of basin contour

% Name of second Basin
Basin2 = 'Brahmaputra'; % 'Brahmaputra'

BasinColor2 = 'w'; % Color of basin contour

% Line width for the basins
BasinLineWidth = 2;

% Year the dataset is from
PeriodYear = '2008-2025'; % choose between '2008-2025' or '2016-2025' or '2018-2025'


if numBasins == 2 
    CombineBasin = sprintf('%s-%s', Basin1, Basin2);
else
    CombineBasin = Basin1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name of the folder where the figures are saved
    Map_of_stations = fullfile(Path_figures, [CombineBasin '_ProcessingCentres_positions']);
    if ~exist(Map_of_stations, 'dir')
        mkdir(Map_of_stations);
    end

% Name of the folder where the matlab files are saved
    Place_of_Matlabfiles = fullfile(Path_matFiles, [CombineBasin '_LSM_results']);
    if ~exist(Place_of_Matlabfiles, 'dir')
    mkdir(Place_of_Matlabfiles);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Importing processing centers

% List of processing centers
ProcCenter = {'Dahiti', 'CLMS', 'Hydroweb'};

% name of files
filenames = cellfun(@(name) sprintf('%s_%s_%s.mat', name, CombineBasin, PeriodYear), ProcCenter, 'UniformOutput', false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting all stations

% Figure title
if numBasins == 2
    figName = sprintf('Stations from %s in %s-%s basins', PeriodYear, Basin1, Basin2);
else
    figName = sprintf('Stations from %s in %s basin', PeriodYear, Basin1);
end

% Plot of figure showing all stations
    Fig_AllStations = figure('Name', figName);
    geobasemap colorterrain
    hold on

allStations = struct();

for s = 1:length(ProcCenter)
    [sourceName, dataStruct, keptName] = ImportingProcCenters(ProcCenter, filenames, FilePathName, s);   
    allStations.(sourceName) = dataStruct.(keptName);

    % Plotting stations from each processing center
    FigPlot.(sourceName) = MapStations(allStations.(sourceName), sourceName);
end

title(['Stations from ' PeriodYear])

    % Adding basin polygons
    if numBasins == 2
        PlotBasin(Basin1, Basin2, BasinColor1, BasinColor2, BasinLineWidth);
    else
        PlotBasin(Basin1, '', BasinColor1, '', BasinLineWidth);
    end

    legend show; % gather all DisplayName inputs
    legend('Location','best', 'Color','#707070', 'TextColor','w');

    %Saving figures
    FigSavedName = sprintf('%s_Station_positions_%s.fig',CombineBasin,PeriodYear);
    savefig(Fig_AllStations,fullfile(Map_of_stations, FigSavedName));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LSM

ProcCenterNames = fieldnames(allStations);  % defines names of processing centers
all_LSM_results = struct();

for s = 1:length(ProcCenterNames)
    sourceName = ProcCenterNames{s};
    stations = allStations.(sourceName);
    numStations = length(stations);

    % Vectors for results
    trend_values = zeros(1, numStations); 
    amplitude_annual = zeros(1, numStations);
    amplitude_semiannual = zeros(1, numStations);

    for i = 1:numStations
        T = decyear(datevec(stations(i).Time));  % Time in decimal years
        B = stations(i).WaterLevel;
        % Model formula:
        % f(T) = a + b*T + c*sin(2*pi*T) + d*cos(2*pi*T) + e*sin(4*pi*T) + f*cos(4*pi*T) + noise
        A = [ones(length(T),1), T/T(end), sin(2*pi*T), cos(2*pi*T), sin(4*pi*T), cos(4*pi*T)];
        [U,S,V]=svd(A'*A); %singular value decomposition of matrix. 
        if min(max(S))>1e-5
            x = (A' * A) \ (A' * B);
        else
            x = (U*(S+1e-5)*V') \ (A' * B); %If the singular values (S) contains a very small number a warning about inaccurate results occour. In this case add a small value to S (S+1e-5)
        end
        B_hat = A*x;
        residuals = B_hat - B;

        % Parameters
        b = x(2); c = x(3); d = x(4); e = x(5); f = x(6);

        trend_values(i) = b/T(end); %%To reduce Matrix badness column 2 of A (T) has been scaled down by T(end). This modification is to ensure that the coefficent used still apply to b*T, rather than b_0*T/T(end)
        amplitude_annual(i) = sqrt(c^2 + d^2);
        amplitude_semiannual(i) = sqrt(e^2 + f^2);
    end

    % Saving results in a struct
    results = struct();
    results.trend = trend_values;
    results.amp_annual = amplitude_annual;
    results.amp_semiannual = amplitude_semiannual;
    results.lat = [stations.Lat];
    results.lon = [stations.Lon];
    results.station_names = {stations.Name};

    % Struct for all processing centers are saved
    all_LSM_results.(sourceName) = results;

    % Creating README-file
    README_separate = sprintf('File contains trend values, annual and semiannual amplitude values for stations from %s', sourceName);

    % Saving results for each processing center separate
    NameOfFile = sprintf('%s_LSM_results_%s.mat', sourceName, PeriodYear);
    fullFileName = fullfile(Place_of_Matlabfiles, NameOfFile);
    save(fullFileName, 'README_separate', 'results'); 

    % Plot LSM results
        f = figure('Name', ['Results - ' sourceName]);

        tgroup = uitabgroup(f);
        tab1 = uitab(tgroup, 'Title', 'Linear Trend');
        tab2 = uitab(tgroup, 'Title', 'Annual Amplitude');
        tab3 = uitab(tgroup, 'Title', 'Semiannual Amplitude');

        % Plot of linear trend value
        gx1 = geoaxes(tab1);
        geobasemap(gx1, 'colorterrain')
        colormap('hot')

        if numBasins == 2
            PlotBasin(Basin1, Basin2, BasinColor1, BasinColor2, BasinLineWidth);
        else
            PlotBasin(Basin1, '', BasinColor1, '', BasinLineWidth);
        end

        scatter(gx1, [stations.Lat], [stations.Lon], 25, trend_values, 'filled');
        colorbar(gx1);
        clim([-0.5 0.5]);
        title(gx1, ['Linear trend - ' sourceName ' (' PeriodYear '), ' CombineBasin]);

        % Annual Amplitude
        gx2 = geoaxes(tab2);
        geobasemap(gx2, 'colorterrain')
        colormap('hot')
        hold(gx2, 'on')

        if numBasins == 2
            PlotBasin(Basin1, Basin2, BasinColor1, BasinColor2, BasinLineWidth);
        else
            PlotBasin(Basin1, '', BasinColor1, '', BasinLineWidth);
        end

        scatter(gx2, [stations.Lat], [stations.Lon], 25, amplitude_annual, 'filled');
        colorbar(gx2);
        title(gx2, ['Annual amplitude - ' sourceName ' (' PeriodYear '), ' CombineBasin]);

        % Semiannual Amplitude
        gx3 = geoaxes(tab3);
        geobasemap(gx3, 'colorterrain')
        colormap('hot')
        hold(gx3, 'on')

        if numBasins == 2
            PlotBasin(Basin1, Basin2, BasinColor1, BasinColor2, BasinLineWidth);
        else
            PlotBasin(Basin1, '', BasinColor1, '', BasinLineWidth);
        end

        scatter(gx3, [stations.Lat], [stations.Lon], 25, amplitude_semiannual, 'filled');
        colorbar(gx3);
        title(gx3, ['Semiannual amplitude - ' sourceName ' (' PeriodYear '), ' CombineBasin]);

        % Saving the figures
        Map_of_LSM = fullfile(Path_figures, [CombineBasin '_LSM_values']);
        if ~exist(Map_of_LSM, 'dir')
            mkdir(Map_of_LSM);
        end

        FigSavedName_LSM = sprintf('%s_%s_LSM_values_%s.fig', CombineBasin, sourceName, PeriodYear);
        savefig(f, fullfile(Map_of_LSM, FigSavedName_LSM));
end

% All processing centers saved at matlab files in one file with readme file
    README_collective = sprintf('File contains trend values, amplitude annual and semiannual values for stations from Dahiti, Hydroweb and CLMS for period %s. ',PeriodYear);
    NameOfAllLSMfile = sprintf('%s_%s_All_LSM_results.mat',CombineBasin,PeriodYear);
    FileName = fullfile(Place_of_Matlabfiles, NameOfAllLSMfile);
    save(FileName, 'all_LSM_results', 'README_collective'); 

%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup for finding triple and double matches

% Defines a shorter name
D = allStations.Dahiti;
C = allStations.CLMS;
H = allStations.Hydroweb;   

J= 0;

% Defining the distance
tolerance_km = 1.2; %[km]

% Defines coordinates
latD = [D.Lat]; lonD = [D.Lon];
latC = [C.Lat]; lonC = [C.Lon];
latH = [H.Lat]; lonH = [H.Lon];

idD = [];
idC = [];
idH = [];

fieldsToKeep = {'Name','Code','Lat','Lon','Time','WaterLevel','WaterLevelUncertainty','Id','IdNumber'};

%%%%%%%%%%%%%%%%%%%%%%%%%
%% Finding triple matches

TripleMatches_DCH =FindAndPlotMatches( ...
    tolerance_km, ...
    {D,C,H}, ...
    {latD,latC,latH}, ...
    {lonD,lonC,lonH}, ...
    {'Dahiti','CLMS','Hydroweb'}, ...
    fieldsToKeep, ...
    numBasins, Basin1, Basin2, BasinColor1, BasinColor2, BasinLineWidth,...
    9,Path_figures,CombineBasin,PeriodYear);

%%%%%%%%%%%%%%%%%%%%%%%%%
%% Finding double matches

doubleMatches_DC= FindAndPlotMatches( ...
    tolerance_km, ...
    {D,C}, ...
    {latD,latC}, ...
    {lonD,lonC}, ...
    {'Dahiti','CLMS'}, ...
    fieldsToKeep, ...
    numBasins, Basin1, Basin2, BasinColor1, BasinColor2, BasinLineWidth,...
    9,Path_figures,CombineBasin,PeriodYear);

doubleMatches_CH = FindAndPlotMatches( ...
    tolerance_km, ...
    {C, H}, {latC, latH}, {lonC, lonH}, ...
    {'CLMS','Hydroweb'}, ...
    fieldsToKeep, ...
    numBasins, Basin1, Basin2, BasinColor1, BasinColor2, BasinLineWidth, ...
    9,Path_figures,CombineBasin,PeriodYear);

doubleMatches_DH= FindAndPlotMatches( ...
    tolerance_km, ...
    {D,H}, ...
    {latD,latH}, ...
    {lonD,lonH}, ...
    {'Dahiti','Hydroweb'}, ...
    fieldsToKeep, ...
    numBasins, Basin1, Basin2, BasinColor1, BasinColor2, BasinLineWidth,...
    9,Path_figures,CombineBasin,PeriodYear);

%%%%%%%%%%%%%%%%%%%%%
%%%  Functions    %%%
%%%%%%%%%%%%%%%%%%%%%
%% --- Function to import matlab data for processing centers --- 
function [sourceName, dataStruct, keptName] = ImportingProcCenters(ProcCenter,filenames,FilePathName,s)
    sourceName = ProcCenter{s};
    filename = filenames{s};

    % Full path to the files used her
    pathFileName = fullfile(FilePathName, filename);

    % Importing data
    dataStruct = load(pathFileName);
    keptName = [sourceName '_final_kept'];
end

%% --- Function to plot basins ---
function BasinPolyPlot = PlotBasin(NameOfBasin1, NameOfBasin2, BasinColor1, BasinColor2, BasinLineWidth)

    addpath('C:\Users\Bruger\Documents\MEGA\Geodesy\12_DataComputations\SFAS_Niger_Data\BackgroundFiles\33_main_world_basins_vectors')
    dataInfo = load('C:\Users\Bruger\Documents\MEGA\Geodesy\12_DataComputations\SFAS_Niger_Data\BackgroundFiles\Basin_Information_EF_33main.mat','Basin_Name');
    Basin_Name = dataInfo.Basin_Name;

    hold on;

    % First basin
    ChoosenBasin1 = find(ismember(Basin_Name, NameOfBasin1));
    poly1 = load(sprintf('bd00%02d.vec', ChoosenBasin1));
    h1 = plot(poly1(:,2), poly1(:,1), ...
        'Color', BasinColor1, ...
        'LineWidth', BasinLineWidth, ...
        'DisplayName', NameOfBasin1);

    if ~isempty(NameOfBasin2)
        % Second basin
        ChoosenBasin2 = find(ismember(Basin_Name, NameOfBasin2));
        poly2 = load(sprintf('bd00%02d.vec', ChoosenBasin2));
        h2 = plot(poly2(:,2), poly2(:,1), ...
            'Color', BasinColor2, ...
            'LineWidth', BasinLineWidth, ...
            'DisplayName', NameOfBasin2);
        BasinPolyPlot = [h1; h2];
    else
        BasinPolyPlot = h1;
    end
end

%% --- Function to numerate name of processing center ---
function GivenNumer=ProcessingCenterName2Number(name)
    if name=="Dahiti"
        GivenNumer=1;
    elseif name=="CLMS"
        GivenNumer=2;
    elseif name=="Hydroweb"
        GivenNumer=3;
    end
end

%% --- Function to plot stations ---
 function Mapping = MapStations(data, name)
    hold on;
    k=ProcessingCenterName2Number(name);
    datastyles = {
        'm', 'o', [-0.02, 0.02]; % Dahiti
        'b', '|', [0.02, 0.02]; % CLMS
        'g', '_', [-0.02, -0.02]; % Hydroweb
    };

    color = datastyles{k,1};
    marker = datastyles{k,2};
    offset = datastyles{k,3};

    % Plot stations and ID numbers
        MapScatter= scatter([data.Lat], [data.Lon], ...
            'MarkerEdgeColor', color, ...
            'Marker', marker, ...
            'LineWidth', 2, ...
            'DisplayName', [name ' Stations']); % Name for legend
        pointNumbers = [data.IdNumber];
        MapText = text([data.Lat] + offset(1), [data.Lon] + offset(2),...
            string(pointNumbers), "Color", color);

        Mapping = struct('Scatter',MapScatter, 'Text', MapText);
 end

%% --- Function to find match, map and plot those matches ---
function Matches = FindAndPlotMatches( ...
    tolerance_km, ...
    PCs, latPCs, lonPCs, ...
    PCNames, ...
    fieldsToKeep, ...
    numBasins, Basin1, Basin2, BasinColor1, BasinColor2, BasinLineWidth, ...
    maxPlotsPerFigure,Path_figures,CombineBasin,PeriodYear)

    nPC = numel(PCs); 
    assert(nPC == numel(PCNames), 'Mismatch in PC inputs')
    
    % FIND MATCHES
    
    Matches = struct();
    for p = 1:nPC
        Matches.(PCNames{p}) = [];
    end
    Matches = Matches([]); 
    
    for i = 1:length(PCs{1})
    
        lat0 = latPCs{1}(i);
        lon0 = lonPCs{1}(i);
    
        closeIdx = cell(1,nPC);
        closeIdx{1} = i;
    
        valid = true;
    
        for p = 2:nPC
            dist_km = deg2km(distance(lat0, lon0, latPCs{p}, lonPCs{p}));
            closeIdx{p} = find(dist_km <= tolerance_km);
    
            if isempty(closeIdx{p})
                valid = false;
                break
            end
        end
    
        if ~valid
            continue
        end
    
        combos = closeIdx{2};
        if nPC == 3
            combos = combvec(closeIdx{2}, closeIdx{3})';
        end
    
        for c = 1:size(combos,1)
            match = struct();
            match.(PCNames{1}) = rmfield(PCs{1}(i), ...
                setdiff(fieldnames(PCs{1}(i)), fieldsToKeep));
    
            for p = 2:nPC
                idx = combos(c,p-1);
                match.(PCNames{p}) = rmfield(PCs{p}(idx), ...
                    setdiff(fieldnames(PCs{p}(idx)), fieldsToKeep));
            end
    
            Matches(end+1) = match;
        end
    end
    
    if isempty(Matches)
        disp('No matches found.')
        return
    end
    
    % MAPPING
    figMap = figure('Name', sprintf('%s – %d-way Match %s', ...
        strjoin(PCNames,' & '), nPC,PeriodYear));
    
    geobasemap colorterrain
    hold on
    
    for p = 1:nPC
        data_plot = [Matches.(PCNames{p})];
        MapStations(data_plot, PCNames{p});
    end
    
    if numBasins == 2
        PlotBasin(Basin1, Basin2, BasinColor1, BasinColor2, BasinLineWidth);
    else
        PlotBasin(Basin1, '', BasinColor1, '', BasinLineWidth);
    end
    
    legend show
    legend('Location','best','Color','#707070','TextColor','w');
    
    mapTitle = sprintf('%s stations within ≤ %.1f km (%s)', ...
        strjoin(PCNames,' & '), tolerance_km, PeriodYear);
    title(mapTitle)
   
    Map_of_matchedstations = fullfile(Path_figures, [CombineBasin '_MatchedStations_Map']);
    if ~exist(Map_of_matchedstations, 'dir')
        mkdir(Map_of_matchedstations);
    end

    Plot_of_timeseries = fullfile(Path_figures, [CombineBasin '_MatchedStations_Timeseries']);
    if ~exist(Plot_of_timeseries, 'dir')
        mkdir(Plot_of_timeseries);
    end

    % SAVE MAP FIGURE
    mapFileName = matlab.lang.makeValidName(figMap.Name);
    savefig(figMap, fullfile(Map_of_matchedstations, [mapFileName '.fig']));

    % TIMESERIES
    nMatches = numel(Matches);
    nFigures = ceil(nMatches / maxPlotsPerFigure);
    
    PCColorMap = containers.Map( ...
        {'Dahiti','CLMS','Hydroweb'}, ...
        {'m','b','g'} );
    
    for f = 1:nFigures
    
        idxStart = (f-1)*maxPlotsPerFigure + 1;
        idxEnd   = min(f*maxPlotsPerFigure, nMatches);
        idxRange = idxStart:idxEnd;
    
        nPlot = numel(idxRange);
        nCols = ceil(sqrt(nPlot));
        nRows = ceil(nPlot / nCols);
    
        figTS = figure('Name', sprintf('%s Timeseries – Page %d/%d Year: %s', ...
            strjoin(PCNames,' & '), f, nFigures,PeriodYear));
        
        t = tiledlayout(nRows, nCols, ...
            'TileSpacing','compact','Padding','compact');
        
        title(t, sprintf('%d-way matches (%s) %s', ...
            nPC, strjoin(PCNames,' – '), PeriodYear))
        xlabel(t,'Year')
        ylabel(t,'Water level (m)')
    
        for ii = 1:nPlot
            j = idxRange(ii);
    
            ax = nexttile(t);
            ax.Color = [0.83 0.83 0.83];
            hold on
            grid on
    
            for p = 1:nPC
                tp = Matches(j).(PCNames{p}).Time;
                if ~isdatetime(tp)
                    tp = datetime(tp,'ConvertFrom','datenum');
                end
         
                pcName = PCNames{p};
    
                if isKey(PCColorMap, pcName)
                    pcColor = PCColorMap(pcName);
                else
                    pcColor = 'k';
                end
                
                plot(tp, Matches(j).(PCNames{p}).WaterLevel, ...
                    pcColor, 'LineWidth',1.2)
            end
    
            idParts = strings(1,nPC);
            for p = 1:nPC
                idParts(p) = sprintf('%s %s', ...
                    PCNames{p}, ...
                    string(Matches(j).(PCNames{p}).IdNumber));
            end
            idStr = strjoin(idParts, ', ');
            
            title(sprintf('Match %d | Id: %s', j, idStr))
            xtickformat('yyyy')
    
            if ii == 1
                axLegend = ax;
            end
        end
    
        lgd = legend(axLegend, PCNames);
        lgd.Location = 'southoutside';
        lgd.Orientation = 'horizontal';

        %Saving figures
        tsFileName = matlab.lang.makeValidName(figTS.Name);
        savefig(figTS, fullfile(Plot_of_timeseries, [tsFileName '.fig']));
    end

end
