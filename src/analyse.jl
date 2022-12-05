export getDf, getPerformances, getMaxPerformances

function rollingSum(time, midWindow)
    return [3600 *  midWindow * 2 / (time[i + midWindow] - time[i - midWindow]) for i in Int(1 + midWindow):Int(length(time) - midWindow)]
end;

function getPerformances(datedone, timeWindow, resolution)
    res = []
    for i in 0:resolution:datedone[end]
        append!(res, 3600 * sum(i - timeWindow / 2 .< datedone .< i + timeWindow / 2) / timeWindow)
    end

    return res
end;

function computeTime(df, begin_shift, end_shift)
    name = copy(df.name);
    unique!(name);

    df = filter(:datedone => r -> r > begin_shift * 60 && r < df.datedone[end] - end_shift * 60, df)
    datedone = [];
    for i in name
        append!(datedone, [filter(:name => r -> r == i, df).datedone])
    end;

    return name, datedone
end

function getMaxPerformancesStations(df, performances, window = 60, resolution = 30)
    name = copy(df.name);
    unique!(name);

    index = 1:1:length(performances) - Int(60 / resolution) * window
    value_max = findmax(map(i -> mean(performances[i:i + Int(60 / resolution) * window]), index))

    beginning = resolution * value_max[2]
    ending = beginning + 60 * window
    df = filter(:datedone => r -> r > beginning && r < ending, df)
    reduced_datedone = [];
    for i in name
        append!(reduced_datedone, [filter(:name => r -> r == i, df).datedone])
    end;
    res = [x != [] ?  3600 * (length(x) - 1) / (x[end] - x[1]) : 0 for x in reduced_datedone]
    return name, res, round(beginning/60), round(ending/60)
end

function getPerformancesStations(df)
    name, datedone = computeTime(df, 0, 0)
    return name, 3600 .* (length.(datedone) .- 1) ./ map(i -> i[end] - i[1], datedone);
end;

function getDf(file, beginning, ending)
    df = CSV.File(file) |> DataFrame;

    function custom_split(s)
        r=0
        try
            r = match(r"[0-9|:| |-]*\.{0,1}[0-9]{1,3}", s).match
        catch e
            println(s)
        end
        return r
    end;

    df.datedone = custom_split.(df.datedone);
    df.datedone = DateTime.(df.datedone, "yyyy-mm-dd HH:MM:SS.s");
    zero = df.datedone[1]
    df.datedone = map(i -> Dates.value(i - zero) / 1000, df.datedone);
    df.received_time = custom_split.(df.received_time);
    df.received_time = DateTime.(df.received_time, "yyyy-mm-dd HH:MM:SS.s");
    df.received_time = map(i -> Dates.value(i - zero) / 1000, df.received_time);

    df = filter(:datedone => r -> r >= beginning * 60 && r <= ending * 60, df)
    return df
end;
