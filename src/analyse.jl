export getDf, getPerformances, getMaxPerformances, getInterpolation, computeTime

function rollingSum(time, midWindow)
    return [3600 *  midWindow * 2 / (time[i + midWindow] - time[i - midWindow]) for i in Int(1 + midWindow):Int(length(time) - midWindow)]
end;

function getInterpolation(midWindow, df)
    res = rollingSum(df.datedone, midWindow)
    interp_lin = [LinearInterpolation(df.datedone[1+midWindow:end-midWindow], res)]

    return interp_lin
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

function getMaxPerformances(interp_lin, datedone, midWindow)
    common_time = min([i[1+midWindow] for i in datedone]...):60:max([i[end-midWindow] for i in datedone]...) ;
    index = 1:length(common_time) - 60
    value_max = findmax(map(i -> mean(map(f -> f.(common_time[i:i+40]), interp_lin)[1]), index))
    beginning = value_max[2] * 60
    ending = beginning + 3600
    reduced_datedone = map(t -> filter(x -> x < ending && x > beginning,t), datedone)
    res = [x != [] ?  3600 * (length(x) - 1) / (x[end] - x[1]) : 0 for x in reduced_datedone]
    return res
end

function getPerformances(datedone)
    return 3600 .* (length.(datedone) .- 1) ./ map(i -> i[end] - i[1], datedone);
end;

function getDf(file)
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
    df.datedone = map(i -> Dates.value(i - df.datedone[1]) / 1000, df.datedone);
    return df
end;