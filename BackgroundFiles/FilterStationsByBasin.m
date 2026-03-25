function Stations_inside_Basin = FilterStationsByBasin( ...
    BasinName, FirstVectorBasinName, SecondVectorBasinName, ...
    Raw_Stations, NumberOfBasins,basinVectors)

    % Find and load polygon(s)
    ChoosenBasin1 = find(ismember(BasinName, FirstVectorBasinName),1);
    poly1 = load(sprintf('%s\\bd00%02d.vec', basinVectors,ChoosenBasin1));

    if NumberOfBasins == 2
        ChoosenBasin2 = find(ismember(BasinName, SecondVectorBasinName));
        poly2 =  load(sprintf('%s\\bd00%02d.vec', basinVectors,ChoosenBasin2));
    end

    % Extract the data variable
    Stations_inside_Basin = Raw_Stations;

    % Remove stations outside the polygon(s)
    for i = length(Stations_inside_Basin):-1:1
        insideBasin1 = inpolygon( ...
            Stations_inside_Basin(i).Lon, ...
            Stations_inside_Basin(i).Lat, ...
            poly1(:,1), poly1(:,2));

        if NumberOfBasins == 2
            insideBasin2 = inpolygon( ...
                Stations_inside_Basin(i).Lon, ...
                Stations_inside_Basin(i).Lat, ...
                poly2(:,1), poly2(:,2));
        else
            insideBasin2 = false;
        end

        if ~(insideBasin1 || insideBasin2)
            Stations_inside_Basin(i) = [];
        end
    end
end
