function [Keep, SelectedPeriod] = IsDataGood(t,Coverage,Gap,DatetimeStart,DatetimeEnd,IgnorePeriod)
    Keep=true;
    if IgnorePeriod % true
        % the entire period is considered
        trim_start = 1;
        trim_end = length(t);
    else %false
        % trim after the specified period
        if t(end)<DatetimeStart || t(1)>DatetimeEnd
            Keep=false; %discards
            trim_start = 1;
            trim_end = length(t);
        else
            trim_start = find(t >= DatetimeStart, 1, 'first');
            trim_end = find(t <= DatetimeEnd, 1, 'last'); 
        end
        Start_dateT = DatetimeStart;
        dayGap = days(Gap);
        SumTime_start= Start_dateT+dayGap;
        if t(trim_start)>SumTime_start  
            Keep=false; %discards
        end
        End_dateT = DatetimeEnd;
        SumTime_end= End_dateT+dayGap; 
         if t(trim_end)>SumTime_end
            Keep=false; %discards
        end
    end
    
    SelectedPeriod = t(trim_start:trim_end);
    if Keep
        start_t = SelectedPeriod(1);
        end_t = SelectedPeriod(end);
    
        % Getting 1 month for every month if they appear more than once (fx There are multiple December 2009 which is reduced to one)
        % There will be no months that repeats again in the same year.
        TimePeriod = unique(datetime(year(SelectedPeriod),month(SelectedPeriod),1));    
    
    %% Calculation for finding 80% of temporal coverage in specific timeperiod
        % Finding the amount of observations inside the specific timeperiod
        ObservationAmount = length(TimePeriod);
    
        % Number of month between start and end time
            % +1 is there so the last month can be included in the timeperiod.
                % If "TimeInsidePeriod" contains "(uniqueTime<= endtime)" then +1
                % should be added here. If "=" is removed then delete +1. 
                MonthAmount = (year(end_t)-year(start_t))*12+month(end_t)-month(start_t)+1;
    
    %% Calculation for finding gaps in timeseries for each virtual stations
        % Difference between times to see if there is more than 1 month gap
            % (over 31 days would mean that the timeperiod has gaps that are more than 1 month)
        time_difference = TimePeriod(2:end) - TimePeriod(1:end-1);
            %¤ matrix going from line 2 to end line
            %¤ matrix going from line 1 to second last line
            % output is duration
            
        % amount of days that are between two observations in specific timeseries
        % (over 31 days would mean that the timeperiod has gaps)
        day_difference = days(time_difference);
    
        Keep = ObservationAmount/MonthAmount < Coverage/100 || max(day_difference) > Gap;  
        Keep = ~Keep;
    end
end