function Stations_inside_Basin = FilterStationsByBasin( ...
    BasinName, Raw_Stations, basinVectors)

    % Find and load polygon
    poly1 = load(sprintf('%s\\%s.vec', basinVectors,BasinName));

    % Add all stations in struct
    Stations_inside_Basin = Raw_Stations;

    % Finds stations that are inside the polygon
    for i = length(Stations_inside_Basin):-1:1
        insideBasin = inpolygon( ...
            Stations_inside_Basin(i).Lon, ...
            Stations_inside_Basin(i).Lat, ...
            poly1(:,1), poly1(:,2));
        % Removes stations outside the polygon
        if ~insideBasin
            Stations_inside_Basin(i) = [];
        end
    end
end
