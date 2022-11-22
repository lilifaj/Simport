function rollingSum(time, midWindow)
    return [3600 *  midWindow * 2 / (time[i + midWindow] - time[i - midWindow]) for i in Int(1 + midWindow):Int(length(time) - midWindow)]
end;

function compute_stats(midWindow, df, begin_shift, end_shift)
    name = copy(df.name);
    unique!(name);

    df = filter(:datedone => r -> r > begin_shift * 60 && r < df.datedone[end] - end_shift * 60, df)
    datedone = [];
    for i in name
        append!(datedone, [filter(:name => r -> r == i, df).datedone])
    end;

    # res = rollingSum.(datedone, midWindow)
    # interp_lin = []

    # for i in 1:length(datedone)
    #     interp_lin = append!(interp_lin, [LinearInterpolation(datedone[i][1+midWindow:end-midWindow], res[i])])
    # end
    res = rollingSum(df.datedone, midWindow)
    interp_lin = []
    interp_lin = append!(interp_lin, [LinearInterpolation(df.datedone[1+midWindow:end-midWindow], res)])

    return name, datedone, res, interp_lin
end;

function get_df(file)
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
    return df
end;

function get_stats(midWindow, file, zero, begin_shift, end_shift)
    df = get_df(file)
    df.datedone = map(i -> Dates.value(i - zero) / 1000, df.datedone);

    name, datedone, res, interp_lin = compute_stats(midWindow, df, begin_shift, end_shift)
    return name, datedone, res, interp_lin
end;

function get_stats(midWindow, file, begin_shift, end_shift)
    df = get_df(file)
    zero = df.datedone[1]
    df.datedone = map(i -> Dates.value(i - zero) / 1000, df.datedone);

    name, datedone, res, interp_lin = compute_stats(midWindow, df, begin_shift, end_shift)
    return name, datedone, res, interp_lin, zero
end;