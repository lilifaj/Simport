include("analyse.jl");
include("format.jl");

export printPrettyData, prettyPlotSimple, prettyPlotSum

function printPrettyData(midWindow, path, begin_shift, end_shift, threshhold)
    name, datedone, res, interp_lin, zero = get_stats(midWindow, path, begin_shift, end_shift);

    name, means, pass_fail, est = formatPrettyTables(name, datedone, threshhold)

    return datedone, res, interp_lin, zero, pretty_table(Matrix(reduce(hcat, [name, means, est, pass_fail])), header=(["Station", "Mean Perf", "Expected Perf.", "Status"],["","bin/h","bin/h",""]))
end

function printPrettyData(midWindow, zero, path, begin_shift, end_shift, threshhold)
    name, datedone, res, interp_lin, zero = get_stats(midWindow, path, zero, begin_shift, end_shift);

    name, means, pass_fail, est = formatPrettyTables(name, datedone, threshhold)

    return datedone, res, interp_lin, pretty_table(Matrix(reduce(hcat, [name, means, est, pass_fail])), header=(["Station", "Mean Perf", "Expected Perf.", "Status"],["","bin/h","bin/h",""]))
end

function prettyPlotSimple(midWindow, datedone, interp_lin, mean)
    common_time = max([i[1+midWindow] for i in datedone]...):10:min([i[end-midWindow] for i in datedone]...);

    return common_time, prettyPlot(common_time, interp_lin, mean)

end

function prettyPlotSum(common_time_1, common_time_2, interp_lin_1, interp_lin_2, mean)
    common = max(common_time_1[1], common_time_2[1]):10:min(common_time_1[end], common_time_2[end]);

    plot(common / 60, [sum(map(i -> i.(common), interp_lin_1)) .+ sum(map(i -> i.(common), interp_lin_2)), [mean for i in common]], label="", xlabel="Time (min)", ylabel="Perf. (bin/h)")
end

function prettyPlot(common_time, interp_lin, mean)
    plot(common_time / 60, [sum(map(i -> i.(common_time), interp_lin)), [mean for i in common_time]], label="", xlabel="Time (min)", ylabel="Perf. (bin/h)")
end