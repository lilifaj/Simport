include("analyse.jl");

export prettyTable, prettyPlot

function computeTable(name, performances, threshhold)
    n = length(performances)
    performances = round.(performances, digits=1)
    pass_fail = [x > threshhold ? "PASS" : "FAIL" for x in performances];
    pass_fail = push!(pass_fail, sum(performances) > n * threshhold ? "PASS" : "FAIL");
    push!(name, "All ");
    performances = append!(performances,round(sum(performances), digits=1))
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
