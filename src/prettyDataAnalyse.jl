include("analyse.jl");

export prettyTable, prettyPlot

function computeTable(name, performances, threshhold)
    n = length(performances)
    performances = round.(performances)
    pass_fail = [x > threshhold ? "PASS" : "FAIL" for x in performances];
    pass_fail = push!(pass_fail, sum(performances) > n * threshhold ? "PASS" : "FAIL");
    push!(name, "All ");
    performances = append!(performances,floor(sum(performances)))
    estimated = vcat([threshhold for i in 1:n], [n * threshhold])

    return performances, estimated, pass_fail
end

function prettyTable(name,performances,threshhold)
    performances, estimated, pass_fail = computeTable(name, performances, threshhold)
    return pretty_table(Matrix(reduce(hcat, [name, performances, estimated, pass_fail])), header=(["Station", "Mean Perf", "Expected Perf.", "Status"],["","bin/h","bin/h",""]))
end;

function prettyTable(name,performances)
    performances, _, _ = computeTable(name, performances, 0)
    return pretty_table(Matrix(reduce(hcat, [name, performances])), header=(["Station", "Mean Perf"],["","bin/h"]))
end;

function prettyPlot(midWindow, df, interp_lin, mean, begin_shift, end_shift, resolution=10)
    df = filter(:datedone => r -> r > begin_shift * 60 && r < df.datedone[end] - end_shift * 60, df)
    println(df.datedone[end-0])
    common_time = df.datedone[1+midWindow]:resolution:df.datedone[end-midWindow]
    println(common_time)

    return plot(common_time / 60, [sum(map(i -> i.(common_time), interp_lin)) [mean for i in 1:length(common_time)]], label="", xlabel="Time (min)", ylabel="Perf. (bin/h)")
end

function prettyPlot(midWindow, df, interp_lin, begin_shift, end_shift, resolution=10)
    df = filter(:datedone => r -> r > begin_shift * 60 && r < df.datedone[end] - end_shift * 60, df)
    common_time = df.datedone[1+midWindow]:resolution:df.datedone[end-midWindow]

    return plot(common_time / 60, sum(map(i -> i.(common_time), interp_lin)), label="", xlabel="Time (min)", ylabel="Perf. (bin/h)")
end

function plotVerticalLine(x)
    plot!(x, linetype = [:vline], widths = [100])
end