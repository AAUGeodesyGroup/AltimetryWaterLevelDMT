function Data_inside_Basin = FilterDataByBasin( ...
    BasinName, Raw_Data, basinVectors)

    % Find and load polygon
    poly1 = load(sprintf('%s\\%s.vec', basinVectors,BasinName));

    % Add all data in struct
    Data_inside_Basin = Raw_Data;

    % Finds data that are inside the polygon
    for i = length(Data_inside_Basin):-1:1
        insideBasin = inpolygon( ...
            Data_inside_Basin(i).Lon, ...
            Data_inside_Basin(i).Lat, ...
            poly1(:,1), poly1(:,2));
        % Removes data outside the polygon
        if ~insideBasin
            Data_inside_Basin(i) = [];
        end
    end
end
