function formatPrettyTables(name,datedone,threshhold)
    means = 3600 * (length.(datedone) .- 1) ./ map(i -> i[end] - i[1], datedone);
    n = length(means)
    pass_fail = [x > threshhold ? "PASS" : "FAIL" for x in means];
    pass_fail = push!(pass_fail, sum(means) > n * threshhold ? "PASS" : "FAIL");
    push!(name, "All ");
    means = append!(means,sum(means))

    return name, means, pass_fail, vcat([threshhold for i in 1:n], [n * threshhold])
end;