include("analyse.jl");

export prettyTable, prettyPlot

function computeTable(name, performances, threshhold)
    n = length(performances)
    pass_fail = [x > threshhold ? "PASS" : "FAIL" for x in performances];
    pass_fail = push!(pass_fail, sum(performances) > n * threshhold ? "PASS" : "FAIL");
    push!(name, "All ");
    performances = append!(performances,sum(performances))
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

function prettyPlot(midWindow, datedone, interp_lin, mean, resolution=10)
    common_time = min([i[1+midWindow] for i in datedone]...):resolution:max([i[end-midWindow] for i in datedone]...);

    return plot(common_time / 60, [sum(map(i -> i.(common_time), interp_lin)), [mean for i in common_time]], label="", xlabel="Time (min)", ylabel="Perf. (bin/h)")
end

function prettyPlot(midWindow, datedone, interp_lin, resolution=10)
    common_time = min([i[1+midWindow] for i in datedone]...):resolution:max([i[end-midWindow] for i in datedone]...);

    return plot(common_time / 60, sum(map(i -> i.(common_time), interp_lin)), label="", xlabel="Time (min)", ylabel="Perf. (bin/h)")
end